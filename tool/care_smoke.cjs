// Operates the compiled Flutter app. No OS notifications are claimed in web mode.
// NODE_PATH / SB_CHROME may point to an existing Playwright / Chromium installation.
const { chromium } = require('playwright');
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

(async () => {
  const root = path.resolve(process.env.SB_WEB_DIR || 'build/web');
  const shots = path.resolve(process.env.SB_CARE_SHOTS || 'build/care-preview');
  fs.mkdirSync(shots, { recursive: true });
  const types = { '.html': 'text/html', '.js': 'text/javascript',
    '.json': 'application/json', '.wasm': 'application/wasm',
    '.ttf': 'font/ttf', '.otf': 'font/otf' };
  const server = http.createServer((req, res) => {
    const name = decodeURIComponent(req.url.split('?')[0]);
    const file = path.join(root, name === '/' ? '/index.html' : name);
    if (!file.startsWith(root + path.sep) || !fs.existsSync(file) || !fs.statSync(file).isFile()) {
      res.writeHead(404); res.end(); return;
    }
    res.setHeader('Content-Type', types[path.extname(file)] || 'application/octet-stream');
    fs.createReadStream(file).pipe(res);
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  let browser;
  try {
    browser = await chromium.launch({ headless: true,
      ...(process.env.SB_CHROME ? { executablePath: process.env.SB_CHROME } : {}) });
    const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
    const errors = [], badResponses = [], remote = [], failed = [];
    page.on('pageerror', e => errors.push(e.message));
    page.on('requestfailed', r => failed.push(r.url()));
    page.on('response', r => { if (r.status() >= 400) badResponses.push(`${r.status()} ${r.url()}`); });
    page.on('request', r => { if (/^https?:/.test(r.url()) && !r.url().startsWith('http://127.0.0.1:')) remote.push(r.url()); });
    const button = name => page.getByRole('button', { name, exact: true });
    async function reveal(locator, direction = 1) {
      for (let n = 0; n < 15 && !(await locator.count()); n++) {
        await page.mouse.move(180, 550);
        await page.mouse.wheel(0, direction * 280);
        await page.waitForTimeout(180);
      }
      await locator.waitFor();
    }
    async function snap(name) {
      await page.mouse.move(2, 2);
      await page.waitForTimeout(900);
      await page.screenshot({ path: path.join(shots, name + '.png') });
    }
    async function semanticStart() {
      const placeholder = page.locator('flt-semantics-placeholder');
      await placeholder.waitFor();
      await placeholder.evaluate(e => e.click());
      await page.getByRole('tab', { name: 'Pflege', exact: true }).click();
    }
    await page.goto(`http://127.0.0.1:${server.address().port}`);
    await semanticStart();
    await button('Bildanleitung starten').waitFor();
    await snap('pflege-uebersicht');
    await button('Bildanleitung starten').click();
    await button('Los geht’s').waitFor();
    await snap('venty-vorbereitung');
    await button('Los geht’s').click();
    await button('Weiter').waitFor();
    await snap('venty-ausschalten');
    // The VENTY guide has ten steps. Traverse the rendered cards, not app internals.
    for (let n = 0; n < 10; n++) {
      if (n === 6) await snap('venty-reinigung');
      await button('Weiter').click();
      await page.waitForTimeout(300);
    }
    const save = button('Reinigung speichern');
    await save.waitFor();
    assert.equal(await save.isDisabled(), true);
    const confirm = page.getByRole('checkbox', { name: 'Alles trocken und geprüft', exact: true });
    await reveal(confirm);
    await confirm.click();
    await page.waitForFunction(() => [...document.querySelectorAll('[role="button"]')]
      .some(e => e.textContent === 'Reinigung speichern' && e.getAttribute('aria-disabled') !== 'true'));
    assert.equal(await save.isEnabled(), true);
    await save.click();
    await button('Bildanleitung starten').waitFor();
    const careSwitch = page.getByRole('switch', { name: /^An Reinigung erinnern/ });
    await reveal(careSwitch);
    await careSwitch.click();
    await page.waitForFunction(() => [...document.querySelectorAll('[role="switch"]')]
      .some(e => e.getAttribute('aria-checked') === 'true'));
    await snap('pflege-erinnerung');
    // Persisted history and reminder choice must survive a real browser reload.
    await page.reload();
    await semanticStart();
    await reveal(careSwitch);
    assert.equal(await careSwitch.getAttribute('aria-checked'), 'true');
    const storage = await page.evaluate(() => Object.fromEntries(Object.entries(localStorage)));
    const persisted = Object.entries(storage).find(([key]) => key.includes('sb-control.care.demo.v1'));
    assert.ok(persisted, 'separate preview storage exists');
    assert.ok(persisted[1].includes('cleaned'), 'cleaning is persisted');
    await page.getByRole('tab', { name: 'Optionen', exact: true }).click();
    const master = page.getByRole('switch', { name: /^Pflege-Benachrichtigungen/ });
    await reveal(master);
    await master.click();
    await page.waitForFunction(e => e.getAttribute('aria-checked') === 'false', await master.elementHandle());
    await page.getByRole('tab', { name: 'Pflege', exact: true }).click();
    await button('Gerät auswählen VENTY').click();
    await page.getByRole('menuitem', { name: 'VOLCANO HYBRID', exact: true }).click();
    await button('Bildanleitung starten').click();
    await button('Los geht’s').waitFor();
    await page.setViewportSize({ width: 320, height: 740 });
    await button('Los geht’s').click();
    await button('Weiter').click();
    await page.waitForTimeout(350);
    await snap('hybrid-zubehoer-320');
    assert.deepEqual(errors, []);
    assert.deepEqual(failed, []);
    assert.deepEqual(remote, []);
    assert.deepEqual(badResponses, []);
    console.log('PASS compiled Flutter care: illustrated VENTY guide, dry confirmation, cleaning saved, reminder opt-in, browser reload persistence, global off, model switch and HYBRID at 320px. No JS errors, failed or external requests. OS notification delivery remains untested.');
  } finally {
    await browser?.close();
    await new Promise(resolve => server.close(resolve));
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
