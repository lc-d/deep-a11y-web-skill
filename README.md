---
name: deep-a11y-web-skills
version: 0.2.0
---

# Deep A11y Web Skills

The final web accessibility agent skill to help front end developers build 100% accessible user interface component and web pages.

An [Agent Skills](https://agentskills.io/) that audit web pages for accessibility and fix what it find,
against the highest standards: WCAG 2.2 and the WAI-ARIA Authoring Practices (APG).

**Stack-agnostic.** Works with any framework (React, Vue, Angular, Svelte, Next.js, Nuxt, Astro, plain HTML, and more)
and with any agent that supports the Agent Skills format (Claude Code, Codex, Copilot, Gemini CLI, Cursor, OpenCode…).

## Why deep a11y web skills?

Most quality checks stop at an automated score. These skills go deeper:

- **Local, page-by-page audits** run in your development environment against the pages you are actually building
- **Multiple independent engines**: Lighthouse and axe-core, cross-checked against each other
- **Live browser inspection** of the rendered DOM, keyboard behaviour and focus management, at desktop and mobile
  (320px) viewports
- **Standards-mapped findings**: every issue is traced to a WCAG 2.2 success criterion and, for widgets, to the
  matching WAI-ARIA APG pattern
- **Report first, fix second**: each skill always works in two phases:
  1. it produces a report listing the issues found;
  2. it fixes them directly in your code, **only after you approve**.

## Available skills

| Skill                                   | Description                                                                                                                                         | Use when                                                                    |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| **[a11y-page-audit](#a11y-page-audit)** | Single-page accessibility audit with Lighthouse, axe-core and live browser inspection, per WCAG 2.2 and the WAI-ARIA APG patterns, then fixes them | "Audit this page for accessibility", "WCAG check", "Fix a11y issues on …" |

## Quick start

### Requirements

- **Node.js ≥ 20** (the audit scripts install their own dependencies on first run)
- **Google Chrome / Chromium** installed locally (used by Lighthouse and axe-core)
- A page reachable from your machine (e.g. `http://localhost:3000`)
- *Recommended:* a browser extension or MCP server for your agent (e.g. Claude in Chrome,
  [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp)) to enable live DOM inspection

### Installation

#### npx (any agent)

Install with the [`skills`](https://www.npmjs.com/package/skills) CLI, which detects your agent and copies the skills
into the right folder:

```bash
npx skills add lc-d/deep-a11y-web-skill
```

or

```bash
npx add-skill lc-d/deep-a11y-web-skill
```

#### Claude Code (plugin)

Install as a versioned, namespaced plugin from inside Claude Code:

```text
/plugin marketplace add lc-d/deep-a11y-web-skill
/plugin install deep-a11y-web-skills@deep-a11y-web-skills
```

Skills are then namespaced (e.g. `/deep-a11y-web-skills:a11y-page-audit`) and update with `/plugin update`. The plugin
reads the same `skills/` directory as the manual copy below, with no duplication.

#### Codex

```bash
codex plugin marketplace add lc-d/deep-a11y-web-skill
```

Then invoke the skill with `@` (e.g. `@a11y-page-audit http://localhost:3000`). See
[docs/codex-setup.md](docs/codex-setup.md) for local installation and troubleshooting.

#### Gemini CLI

```bash
gemini extensions install https://github.com/lc-d/deep-a11y-web-skill
```

Skills are auto-discovered and activate when your prompt matches their description. See
[docs/gemini-setup.md](docs/gemini-setup.md) for workspace mode and troubleshooting.

#### Manual

Clone the repository and copy the skill folder into your project's (or your user's) skills directory:

| Agent              | Project folder    | User folder          |
|--------------------|-------------------|----------------------|
| Claude Code        | `.claude/skills/` | `~/.claude/skills/`  |
| Codex / Grok       | `.agents/skills/` | `~/.agents/skills/`  |
| GitHub Copilot     | `.github/skills/` | —                    |
| Gemini CLI         | `.gemini/skills/` | `~/.gemini/skills/`  |

```bash
git clone https://github.com/lc-d/deep-a11y-web-skill.git
cp -r deep-a11y-web-skill/skills/a11y-page-audit .claude/skills/
```

#### claude.ai

Upload the skill folder as a custom skill (Settings → Capabilities → Skills), or paste the `SKILL.md` contents into
your conversation. Note that the audit scripts need a local shell, so the full workflow is best run from Claude Code.

### Usage

Invoke the skill explicitly, passing the URL of the page to audit:

```text
/a11y-page-audit http://localhost:3000/checkout
```

Or just ask; skills activate automatically when your request matches their description:

```text
Audit http://localhost:3000 for accessibility issues
```

```text
Check this page against WCAG 2.2 and fix what you find
```

## Skill details

### a11y-page-audit

Audits a single page for accessibility barriers using two independent automated engines plus live browser inspection,
then turns the findings into concrete code fixes.

**Trigger phrases:** "accessibility audit", "a11y", "WCAG", "screen reader", "keyboard navigation", "contrast",
"alt text", "ARIA", "Lighthouse/axe accessibility check"

**What it does:**

- Runs Lighthouse (accessibility category) and axe-core on the page
- Inspects the live page at desktop (≥ 1024px) and mobile (320px, WCAG 1.4.10 reflow) viewports
- Checks keyboard operability, focus order and visibility, and collapsed navigation (e.g. hamburger menus)
- Maps every automated rule to its WCAG 2.2 success criterion and every custom widget to its WAI-ARIA APG pattern
- Produces a prioritised report, then applies fixes only with your approval

**Bundled references:** WCAG 2.2 quick reference, accessible code patterns, APG pattern mapping, axe-core/Lighthouse
rule → WCAG mapping.

## Project structure

Each skill lives in its own folder under `skills/` and is self-contained, with all the scripts and references it needs.
The same folder is shared by every distribution channel (Claude Code, Codex, Gemini CLI, npx), with no duplication.

```text
deep-a11y-web-skill/
├── skills/                       # All skills (single source of truth)
│   └── a11y-page-audit/          # Web accessibility (WCAG 2.2) audit skill
│       ├── SKILL.md              # Entry point: workflow, tool routing, common fixes
│       ├── references/           # Reference material loaded on demand
│       │   ├── WCAG.md           # WCAG 2.2 success criteria quick reference
│       │   ├── A11Y-PATTERNS.md  # Accessible code patterns
│       │   ├── APG-PATTERNS.md   # WAI-ARIA APG patterns → components (mapping)
│       │   └── AXE-RULES.md      # axe-core/Lighthouse rule ID → WCAG (mapping)
│       └── scripts/              # Executable audit tooling
│           ├── audit.sh          # Orchestrator: single-page audit
│           ├── run-lighthouse.sh # Lighthouse accessibility audit wrapper
│           ├── run-axe.mjs       # axe-core runner (via puppeteer-core)
│           └── package.json      # Script dependencies (installed on first run)
├── .claude-plugin/               # Claude Code plugin + marketplace manifests
├── codex/                        # Codex plugin (manifest + symlink to skills/)
├── .agents/plugins/              # Codex marketplace manifest
├── gemini-extension.json         # Gemini CLI extension manifest
├── .gemini/skills                # Symlink to skills/ (Gemini workspace mode)
├── docs/                         # Codex and Gemini setup guides
├── LICENSE
└── README.md
```

- **`SKILL.md`**: the skill definition (frontmatter + instructions).
- **`references/`**: supporting documents, loaded only when needed.
- **`scripts/`**: executable scripts the skill uses to do its work.

## Contributing

Contributions are welcome! Please follow the [Agent Skills specification](https://agentskills.io/specification).

1. Fork the repository
2. Create your skill in `skills/{skill-name}/SKILL.md`
3. Keep `SKILL.md` under 500 lines (move details into `references/`)
4. Write skills in English and keep them model-, language- and framework-agnostic
5. Submit a pull request

## Resources

- [WCAG 2.2 Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)
- [WAI-ARIA Authoring Practices Guide (APG)](https://www.w3.org/WAI/ARIA/apg/)
- [axe-core rules](https://dequeuniversity.com/rules/axe/)
- [Google Lighthouse documentation](https://developer.chrome.com/docs/lighthouse/)
- [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp)
- [Agent Skills specification](https://agentskills.io/specification)

## License

MIT License. See [LICENSE](LICENSE) for details.
