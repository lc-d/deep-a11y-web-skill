# Using deep-a11y-web-skills with Gemini CLI

This repository is also a [Gemini CLI extension](https://geminicli.com/docs/extensions/). Gemini reads the same
`skills/` directory used by Claude Code and Codex, so no skill files are copied or duplicated.

## Install

Make sure you have installed the [Gemini CLI](https://geminicli.com/), then run:

```bash
gemini extensions install https://github.com/lc-d/deep-a11y-web-skill
```

Gemini clones the repo into `~/.gemini/extensions/deep-a11y-web-skills/`, registers the extension and auto-discovers the
bundled skills. Restart Gemini CLI if it's already running.

Local clones work too:

```bash
gemini extensions install /path/to/your/clone
```

## Usage

Gemini activates a skill automatically when your prompt matches its description. `a11y-page-audit` needs the URL of
the page to audit, so include it in your prompt (if you don't, Gemini asks for it). Try:

```text
Audit http://localhost:3000 for accessibility issues
```

Available skills:

- `a11y-page-audit`

## Requirements

The audit scripts need **Node.js ≥ 20** and a local **Chrome / Chromium**. Their npm dependencies are installed on the
first run. Live DOM inspection works best if Gemini has browser tooling available, such as
[Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp).

## How it works

- `gemini-extension.json`: extension manifest at the repo root. Gemini CLI needs it to recognise the directory as an
  extension.
- `skills/<name>/SKILL.md`: unchanged. Gemini CLI auto-discovers the `skills/` directory bundled with an extension.
- `.gemini/skills`: git-tracked symlink to `../skills`. Lets Gemini load the same skills as **workspace skills** when
  you run Gemini CLI inside a clone of this repo, without installing the extension.

## Workspace mode (running from a clone)

If you've cloned the repo and want the skills active only in that working directory, launch Gemini CLI from the repo
root: it auto-loads the skills it finds under `.gemini/skills/`.

## No symlinks (Windows or personal preference)

If symlinks don't work on your machine, replace the symlink with a real copy of the skills. Run this from the repo
root after cloning:

```bash
rm .gemini/skills
cp -R skills .gemini/skills
```

This is a **local-only** change; don't commit it.
