# Privacy Policy

_Last updated: October 15, 2026_

deep-a11y-web-skills is a set of agent skills that run entirely on your machine. The author does not operate any
server or service for it, and collects, stores or receives no data from you.

## What the skill does locally

- Runs Lighthouse and axe-core in a local headless Chrome against the URL you provide.
- Writes audit reports to a directory on your machine (by default `./a11y-audit-<timestamp>`).
- With your approval, edits files in your local project to fix the issues it finds.

Nothing from these steps is sent to the author.

## Third parties

- **Package registry:** on first run the skill downloads Lighthouse and axe-core from the npm registry, which is
  subject to [npm's privacy policy](https://docs.npmjs.com/policies/privacy).
- **Audited pages:** Chrome loads the page you ask it to audit, so that site receives the request as it would from any
  browser.
- **Your AI agent:** the audit results and page content are read by the agent you run the skill in (Claude Code,
  Codex, Gemini CLI, etc.). How that data is handled is governed by your agent provider's privacy policy.

## Contact

Questions about this policy: [open an issue](https://github.com/lc-d/deep-a11y-web-skill/issues).
