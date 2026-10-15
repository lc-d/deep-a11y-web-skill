#!/usr/bin/env node
// Runs axe-core against a rendered page using puppeteer-core driving a local Chrome/Chromium.
// Deliberately avoids @axe-core/cli: its chromedriver dependency's install step calls require()
// on an ESM-only package and crashes with ERR_REQUIRE_ESM, even on current Node LTS releases.
// Puppeteer-core has no such dependency — it just needs a path to an already-installed browser.
//
// Requires Node 20+ (this skill's baseline runtime — see SKILL.md#requirements).
//
// stdout = structured JSON (success/error), stderr = human progress logs.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const __dirname = path.dirname(fileURLToPath(import.meta.url));

const MAX_VIOLATIONS = 50;
const MAX_TARGETS_PER_VIOLATION = 10;

function log(msg) {
  process.stderr.write(`${msg}\n`);
}

function emitError(type, message, suggestion) {
  process.stdout.write(
    JSON.stringify({ success: false, error: { type, message, suggestion, retryable: false } }, null, 2) + '\n'
  );
  process.exit(1);
}

function parseArgs(argv) {
  const args = { tags: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa', 'best-practice'] };
  const rest = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--out') args.out = argv[++i];
    else if (a === '--chrome-path') args.chromePath = argv[++i];
    else if (a === '--tags') args.tags = argv[++i].split(',');
    else if (a === '--timeout') args.timeout = Number(argv[++i]);
    else if (a === '--viewport') {
      const [width, height] = argv[++i].split('x').map(Number);
      args.viewport = { width, height };
    }
    else rest.push(a);
  }
  args.url = rest[0];
  return args;
}

function findChrome(explicitPath) {
  if (explicitPath) return explicitPath;
  if (process.env.CHROME_PATH && fs.existsSync(process.env.CHROME_PATH)) return process.env.CHROME_PATH;

  const candidates = {
    darwin: [
      '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      '/Applications/Chromium.app/Contents/MacOS/Chromium',
      '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge',
    ],
    linux: [
      '/usr/bin/google-chrome-stable',
      '/usr/bin/google-chrome',
      '/usr/bin/chromium-browser',
      '/usr/bin/chromium',
      '/snap/bin/chromium',
    ],
    win32: [
      'C:/Program Files/Google/Chrome/Application/chrome.exe',
      'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
      'C:/Program Files/Microsoft/Edge/Application/msedge.exe',
    ],
  }[process.platform] || [];

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  return null;
}

async function main() {
  const nodeMajor = Number(process.versions.node.split('.')[0]);
  if (nodeMajor < 20) {
    emitError(
      'unsupported_runtime',
      `Node ${process.versions.node} detected; this skill requires Node 20+`,
      'Install/switch to Node 20+, e.g.: nvm install 20 && nvm use 20'
    );
    return;
  }

  const args = parseArgs(process.argv.slice(2));
  if (!args.url) {
    emitError('invalid_input', 'No URL provided', 'Usage: run-axe.mjs <url> [--out file.json] [--chrome-path path] [--tags wcag2a,wcag2aa]');
    return;
  }

  let puppeteer;
  try {
    puppeteer = (await import('puppeteer-core')).default;
    require.resolve('axe-core/axe.min.js');
  } catch {
    emitError(
      'missing_dependency',
      'puppeteer-core and/or axe-core are not installed',
      `Run: npm install --prefix "${__dirname}"`
    );
    return;
  }

  const chromePath = findChrome(args.chromePath);
  if (!chromePath) {
    emitError(
      'missing_dependency',
      'Could not find a local Chrome/Chromium/Edge install',
      'Pass --chrome-path "/path/to/chrome" or set the CHROME_PATH environment variable'
    );
    return;
  }

  log(`Launching ${chromePath}`);
  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });

  try {
    const page = await browser.newPage();
    await page.setViewport(args.viewport || { width: 1280, height: 800 });
    log(`Navigating to ${args.url}`);
    try {
      await page.goto(args.url, { waitUntil: 'networkidle0', timeout: args.timeout || 30000 });
    } catch (navErr) {
      emitError('navigation_failed', `Could not load ${args.url}: ${navErr.message}`, 'Check the URL is reachable and not behind auth/a firewall');
      return;
    }

    const axeSource = fs.readFileSync(require.resolve('axe-core/axe.min.js'), 'utf8');
    await page.evaluate(axeSource);

    log(`Running axe-core (tags: ${args.tags.join(', ')})`);
    const results = await page.evaluate(async (tags) => {
      // eslint-disable-next-line no-undef
      return await axe.run(document, { runOnly: { type: 'tag', values: tags } });
    }, args.tags);

    const violations = results.violations.slice(0, MAX_VIOLATIONS).map((v) => ({
      id: v.id,
      impact: v.impact,
      help: v.help,
      helpUrl: v.helpUrl,
      wcagTags: v.tags.filter((t) => /^wcag\d/.test(t) || t === 'best-practice'),
      nodeCount: v.nodes.length,
      targets: v.nodes.slice(0, MAX_TARGETS_PER_VIOLATION).map((n) => ({
        selector: n.target.join(' '),
        summary: n.failureSummary,
        html: n.html?.slice(0, 300),
      })),
    }));

    const output = {
      success: true,
      url: results.url,
      timestamp: new Date().toISOString(),
      counts: {
        violations: results.violations.length,
        passes: results.passes.length,
        incomplete: results.incomplete.length,
        inapplicable: results.inapplicable.length,
      },
      truncated: results.violations.length > MAX_VIOLATIONS,
      violations,
    };

    const json = JSON.stringify(output, null, 2);
    if (args.out) {
      fs.mkdirSync(path.dirname(args.out), { recursive: true });
      fs.writeFileSync(args.out, json);
      log(`Wrote ${args.out}`);
    }
    process.stdout.write(json + '\n');
  } finally {
    await browser.close();
  }
}

main().catch((err) => emitError('unexpected_error', err.message, 'Re-run with the underlying error above; file an issue if it persists'));
