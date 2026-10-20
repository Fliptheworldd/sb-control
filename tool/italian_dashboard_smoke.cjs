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
    const placeholder = page.locator('flt-semantics-placeholder');
    await placeholder.waitFor(); await placeholder.evaluate(e => e.click());
    await page.getByRole('group', {name: /Temperatura impostata/}).waitFor();
    await snap('dashboard-italiano');
    await page.mouse.move(180, 500); await page.mouse.wheel(0, 250);
    await button('Riscalda').waitFor();
    await snap('boost-italiano');
    await button('Riscalda').click();
    await button('Arresta riscaldamento').waitFor();
    for (const name of ['VEAZY', 'CRAFTY', 'CRAFTY+', 'VOLCANO HYBRID']) {
      await page.getByRole('tab', {name:/^Dispositivi/}).click();
      const escaped = name.replace('+', '\\+');
      await page.getByRole('button', {name: new RegExp('^' + escaped + ' ')}).click();
      await page.getByRole('group', {name: /Temperatura impostata/}).waitFor();
      await snap(name.replace(/[^a-zA-Z]/g, '') + '-italiano');
    }
    await page.setViewportSize({width:320,height:740});
    await snap('hybrid-320-italiano');
    assert.deepEqual(errors, []); assert.deepEqual(failed, []);
    assert.deepEqual(remote, []); assert.deepEqual(badResponses, []);
    console.log('PASS Italian compiled dashboard: heat action, five model illustrations, 320px, no network errors.');
  } finally { await browser?.close(); await new Promise(resolve => server.close(resolve)); }
})().catch(error => { console.error(error); process.exitCode = 1; });
