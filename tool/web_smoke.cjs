// Exercises the compiled Flutter web app, not an HTML approximation.
// Development-only dependency: npm install --no-save playwright
const { chromium } = require('playwright');
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

(async () => {
  const root = path.resolve(process.env.SB_WEB_DIR || 'build/web');
  const types = { '.html': 'text/html', '.js': 'text/javascript',
    '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png',
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
    async function reveal(locator) {
      for (let n=0; n<12 && !(await locator.count()); n++) {
        await page.mouse.move(180, 500); await page.mouse.wheel(0, 300); await page.waitForTimeout(120);
      }
    }
    const errors = [], failed = [], remote = [], badResponses = [];
    page.on('pageerror', e => errors.push(e.message));
    page.on('requestfailed', r => failed.push(r.url()));
    page.on('response', r => { if (r.status() >= 400) badResponses.push(`${r.status()} ${r.url()}`); });
    page.on('request', r => { if (/^https?:/.test(r.url()) && !r.url().startsWith('http://127.0.0.1:')) remote.push(r.url()); });
    await page.goto(`http://127.0.0.1:${server.address().port}`);
    const placeholder = page.locator('flt-semantics-placeholder');
    await placeholder.waitFor();
    await placeholder.evaluate(element => element.click());
    await page.getByRole('button', { name: 'Aufheizen', exact: true }).waitFor();
    await page.getByRole('tab', { name: 'Optionen', exact: true }).click();
    const permanent = page.getByRole('switch', { name: /^Boost-Temperatur halten/ });
    await reveal(permanent);
    await permanent.click();
    await page.waitForFunction(() => [...document.querySelectorAll('[role="switch"]')].some(e => e.getAttribute('aria-label')?.startsWith('Boost-Temperatur halten') && e.getAttribute('aria-checked') === 'true'));
    await reveal(page.getByRole('switch', { name: /^Boost-Stufe am Gerät anzeigen/ }));
    await page.getByRole('switch', { name: /^Boost-Stufe am Gerät anzeigen/ }).click();
    await reveal(page.getByRole('button', { name: 'Geräteeinstellungen zurücksetzen', exact: true }));
    await page.getByRole('button', { name: 'Geräteeinstellungen zurücksetzen', exact: true }).click();
    await page.getByRole('button', { name: 'Abbrechen', exact: true }).click();
    await page.getByRole('button', { name: 'Abbrechen', exact: true }).waitFor({ state: 'hidden' });
    await page.getByRole('button', { name: 'Geräteeinstellungen zurücksetzen', exact: true }).click();
    await page.getByRole('button', { name: 'Zurücksetzen', exact: true }).click();
    await page.mouse.move(180,500); await page.mouse.wheel(0,-1600);
    await page.waitForTimeout(200);
    await reveal(permanent);
    await page.waitForFunction(() => [...document.querySelectorAll('[role="switch"]')].some(e => e.getAttribute('aria-label')?.startsWith('Boost-Temperatur halten') && e.getAttribute('aria-checked') === 'false'));
    await page.getByRole('tab', { name: /^Übersicht/ }).click();
    await page.getByRole('button', { name: 'Temperatur um 1 °C erhöhen' }).click();
    await page.getByRole('group', { name: /Zieltemperatur 181 °C/ }).waitFor();
    await page.getByRole('button', { name: 'Aufheizen', exact: true }).click();
    await page.getByRole('button', { name: 'Aufheizen stoppen', exact: true }).waitFor();
    await page.getByRole('tab', { name: 'Geräte', exact: true }).click();
    await page.getByRole('button', { name: /^VEAZY / }).waitFor();
    await page.getByRole('tab', { name: 'Optionen', exact: true }).click();
    await page.getByRole('radio', { name: '°F', exact: true }).click();
    await page.waitForFunction(() => document.querySelector('[role="radio"][aria-label="°F"]')?.getAttribute('aria-checked') === 'true');
    await page.getByRole('tab', { name: /^Übersicht/ }).click();
    await page.getByRole('group', { name: /Zieltemperatur 358 °F/ }).waitFor();
    for (const model of ['VEAZY', 'CRAFTY', 'CRAFTY+', 'VOLCANO HYBRID']) {
      await page.getByRole('tab', { name: /^Geräte/ }).click();
      const prefix = model.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      await page.getByRole('button', { name: new RegExp('^' + prefix + ' ') }).click();
      await page.getByRole('button', { name: 'Aufheizen', exact: true }).waitFor();
    }
    await page.getByRole('button', { name: 'Pumpe einschalten', exact: true }).click();
    await page.getByRole('button', { name: 'Pumpe ausschalten', exact: true }).waitFor();
    await page.getByRole('tab', { name: /^Diagnose/ }).click();
    await page.mouse.move(180, 550);
    await page.mouse.wheel(0, 450);
    await page.getByRole('button', { name: 'Diagnosebericht kopieren', exact: true }).waitFor();
    await page.getByRole('button', { name: 'Diagnose aktualisieren', exact: true }).click();
    await page.setViewportSize({ width: 320, height: 740 });
    await page.getByRole('tab', { name: /^Optionen/ }).click();
    await page.getByRole('radio', { name: '°C', exact: true }).waitFor();
    await page.getByRole('tab', { name: /^Übersicht/ }).click();
    await page.getByRole('button', { name: 'Aufheizen', exact: true }).waitFor();
    await page.getByRole('button', { name: 'Verbindung trennen', exact: true }).click();
    await page.getByRole('button', { name: 'Gerät verbinden', exact: true }).waitFor();
    if (process.env.SB_SCREENSHOT) await page.screenshot({ path: process.env.SB_SCREENSHOT });
    assert.deepEqual(errors, []);
    assert.deepEqual(failed, []);
    assert.deepEqual(remote, []);
    assert.deepEqual(badResponses, []);
    console.log('PASS compiled Flutter web: device permanent boost, visualization, reset cancel/confirm, target, heat, units, five profiles, pump, diagnosis, 320px, disconnect. No JS errors, failed requests or external requests.');
  } finally {
    await browser?.close();
    await new Promise(resolve => server.close(resolve));
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
