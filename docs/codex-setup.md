# Using deep-a11y-web-skills with Codex

This repository is also a [Codex plugin](https://developers.openai.com/codex/plugins/build). Codex reads the same
`skills/` directory used by Claude Code and Gemini CLI, so no skill files are copied or duplicated.

## Install

```bash
codex plugin marketplace add lc-d/deep-a11y-web-skill
```

> Requires Codex CLI v0.122 or later. On older releases the command was `codex marketplace add`. See the
> [Codex CLI docs](https://developers.openai.com/codex/cli).

Codex clones the repo, registers the marketplace in `~/.codex/config.toml` and makes the plugin available. Restart
Codex if it's already running.

Local clones work too:

```bash
codex plugin marketplace add /path/to/your/clone
```

## Usage

Invoke a skill in Codex chat with `@` and pass the URL of the page to audit:

```text
@a11y-page-audit http://localhost:3000
```

Or just describe the task (e.g. _"audit http://localhost:3000 for accessibility issues"_) and Codex picks the right
skill.

Available skills:

- `a11y-page-audit`

## Requirements

The audit scripts need **Node.js ≥ 20** and a local **Chrome / Chromium**. Their npm dependencies are installed on the
first run. Live DOM inspection works best if Codex has browser tooling available, such as
[Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp).

## How it works

- `codex/.codex-plugin/plugin.json`: Codex plugin manifest. Points `skills` at `./skills/`.
- `codex/skills`: git-tracked symlink to `../skills`. Keeps the plugin directory self-contained without duplicating
  skill content. macOS and Linux handle this natively.
- `.agents/plugins/marketplace.json`: marketplace entry declaring the plugin at `./codex`. Codex requires plugins to
  live in a subdirectory of the marketplace root.
- `skills/<name>/SKILL.md`: unchanged. Codex and Claude Code share the same `name` + `description` frontmatter
  format, so one file serves both.

## No symlinks (Windows or personal preference)

If symlinks don't work on your machine, replace the symlink with a real copy of the skills. Run this from the repo
root after cloning:

```bash
rm codex/skills
cp -R skills codex/skills
```

This is a **local-only** change; don't commit it.
