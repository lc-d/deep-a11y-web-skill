---
name: a11y-page-audit
description: Audit a single page for accessibility issues using Lighthouse, axe-core, and live browser inspection, then with user permission fix them per WCAG 2.2 and the WAI-ARIA APG patterns. Use when asked to audit, check, or fix a web page's accessibility (a11y, WCAG, screen reader or keyboard support, contrast, alt text, ARIA widget patterns), or to run Lighthouse/axe accessibility checks.
license: MIT
argument-hint: <URL>
metadata:
  author: LC.D
  version: "1.1"
---

# Accessibility audit

Audits a single page (the URL passed as the argument; ask for it if missing) for accessibility barriers, using two
independent automated engines plus live browser inspection, then turns the findings into concrete code fixes.

Get the user's approval before changing any code: the report comes first, and fixes are applied only once the user
agrees to them.

Audit every page at two viewports, desktop (at least 1024px wide) and mobile (320px wide, the WCAG 1.4.10 reflow width),
because layout and navigation differ between them. On mobile, check that a menu collapsed behind a hamburger button can
be opened, operated, and closed by keyboard and screen reader (APG Disclosure pattern).

**What "automated" does and doesn't cover:** axe-core and Lighthouse reliably catch roughly a third
of WCAG failures — missing alt text, unlabeled fields, contrast ratios, missing landmarks, invalid
ARIA. They cannot judge whether alt text is *meaningful*, whether a keyboard flow is *usable*, or
whether reading order makes sense. A 100/100 Lighthouse score is not WCAG conformance. Always pair
the automated pass with the manual checklist near the end of this file.

## Requirements

- **Node.js 20+** and `npm` (for the axe-core runner and Lighthouse CLI).
- **A local Chrome, Chromium, or Edge install** (the scripts drive it directly; no chromedriver
  needed).
- `jq` — used by the shell scripts for JSON handling.
- If you have Chrome DevTools MCP or the `claude-in-chrome` browser tool available, use it too —
  it gives you live DOM/accessibility-tree inspection the scripts can't (see
  [Live browser inspection](#2-live-browser-inspection-recommended)).

Everything here runs locally; nothing is uploaded to a third-party service.

## How it works

1. Run Lighthouse (accessibility category) and axe-core against the given URL only — don't follow
   links to other pages.
2. If a browser tool is available, inspect the live accessibility tree and exercise the page by
   keyboard — automated tools miss most of what this step catches.
3. Map every interactive component to one or more APG patterns and check it against them.
4. Cross-reference findings against [references/AXE-RULES.md](references/AXE-RULES.md),
   [references/WCAG.md](references/WCAG.md), and [references/APG-PATTERNS.md](references/APG-PATTERNS.md).
5. Report findings by severity with file:line locations and concrete fixes, then apply the fixes
   the user approves.
6. Re-run the same audit to confirm the fix and check for regressions.

### 1. Run the automated engines

For an authenticated or user-generated-state page, prefer whatever browser tool is already open at
that state over navigating fresh — the scripts always do a clean navigation, so they'll hit a login
wall for authenticated content. Use [live browser inspection](#2-live-browser-inspection-recommended)
for those pages instead of the scripts.

```bash
./scripts/audit.sh https://example.com --viewport desktop --out-dir ./a11y-report
./scripts/audit.sh https://example.com --viewport mobile --out-dir ./a11y-report
```

First run installs `puppeteer-core` + `axe-core` into `scripts/node_modules` (not committed —
already gitignored). This orchestrator:

- Runs `scripts/run-lighthouse.sh` (Lighthouse, accessibility-only) and `scripts/run-axe.mjs`
  (axe-core) against the page.
- Writes condensed results (up to 10 failing nodes per rule) to
  `<out-dir>/<slug>.<viewport>.lighthouse.json` and `<out-dir>/<slug>.<viewport>.axe.json`.
- Prints a summary to stdout (also saved as `<slug>.<viewport>.summary.json`) — the score and the failing rules ranked
  by how many nodes fail
  them (`topAxeRules`, `topLighthouseAudits`).

Read the `.axe.json` / `.lighthouse.json` files for node-level detail (selectors, HTML
snippets, failure summaries) once you know which rules to chase from the summary.

Use `run-axe.mjs` rather than `@axe-core/cli`: the CLI's `chromedriver` dependency fails to install (`ERR_REQUIRE_ESM`),
while `run-axe.mjs` drives your existing browser through `puppeteer-core`.

#### Tool routing

| Need                                            | Preferred route                                                        | Fallback                                                                                  |
|-------------------------------------------------|------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| Accessibility score + audit-level detail        | `scripts/run-lighthouse.sh`                                            | Chrome DevTools MCP `lighthouse_audit`, if available and a fresh navigation is acceptable |
| Rule-level violations with exact failing nodes  | `scripts/run-axe.mjs`                                                  | axe DevTools / WAVE browser extension (manual)                                            |
| Rendered accessibility tree, names/roles/states | Chrome DevTools MCP `take_snapshot`, or `claude-in-chrome` `read_page` | Manual screen reader pass                                                                 |
| Keyboard interaction                            | `claude-in-chrome` `computer` (Tab/Enter/Space/Arrow keys)             | Manual keyboard testing                                                                   |

### 2. Live browser inspection (recommended)

Automated engines can't tell you if focus order is logical, if a modal traps keyboard focus
correctly, or if an `aria-label` is actually *accurate*. When a browser tool is available:

1. Open the audited URL.
2. Take an accessibility-tree snapshot; check that interactive elements have sensible names, roles,
   and states, and that headings/landmarks form a logical outline.
3. Tab through the whole page. Every interactive element must be reachable, show a visible focus
   indicator, and activate with Enter/Space. Watch for keyboard traps.
4. For each composite widget (tabs, menus, comboboxes, dialogs, …), exercise the keyboard model of its APG pattern —
   arrow keys, Home/End, Escape, focus return — not just Tab (see [step 3](#3-map-components-to-apg-patterns)).
5. Re-run the automated engines after any fix and repeat the manual pass on the changed area — don't
   just trust the new score.

If no browser tool is available, do this manually in a real browser and note it in the report as a
pending manual check rather than skipping it silently.

### 3. Map components to APG patterns

Every interactive web component must match, or at least reference, one or more
[WAI-ARIA APG patterns](https://www.w3.org/WAI/ARIA/apg/patterns/). Automated engines check that ARIA is *valid*, not
that a widget *behaves* the way its role promises — the APG pattern is the yardstick for that.

1. Inventory the interactive components on the page (from the accessibility tree and the source): navigation, menus,
   dialogs, disclosures, form widgets, tabs, carousels, tables, etc. Plain links and buttons only need listing when
   they are custom-built (`role="button"`, `role="link"`).
2. Map each one to its APG pattern(s) **by behavior, not by name or look** — use the catalog and the
   component-name table in [references/APG-PATTERNS.md](references/APG-PATTERNS.md). Composite components cite every
   pattern they combine; components with no direct match cite the closest one and say so.
3. Check each component against its pattern: roles, required states and properties, accessible name, keyboard model,
   and focus management.
4. Classify it as **Matches**, **Deviates** (documented and justified, no WCAG failure), or **Fails** (breaks a WCAG
   criterion — report it as a finding). A deviation is acceptable; an undocumented or unjustified one is not.

Follow the matching rules in [references/APG-PATTERNS.md](references/APG-PATTERNS.md#matching-rules) — in particular,
prefer native HTML and never use `role="menu"` for site navigation.

## Fixing common issues

Before fixing a finding, read the matching fix pattern in
[references/A11Y-PATTERNS.md](references/A11Y-PATTERNS.md). It covers missing alt text
(`image-alt`), color contrast (`color-contrast`), keyboard navigation and focus, form labels, error
handling, skip links, modal focus traps, ARIA tabs, live regions, and repeated link text. For a
rule-by-rule fix table that matches the scripts' JSON output, see
[references/AXE-RULES.md](references/AXE-RULES.md).

When a fix touches a widget's role, states, or keyboard handling, implement it to its APG pattern: open the pattern page
linked in [references/APG-PATTERNS.md](references/APG-PATTERNS.md) and follow its keyboard table and example code
rather than inventing a new interaction model.

Contrast thresholds (WCAG 1.4.3 / 1.4.11): 4.5:1 for normal text, 3:1 for large text (≥ 24px or
≥ 18.66px bold) and for UI components.

## Manual testing checklist

Run this after the automated pass, at both viewports, on the parts of the page the automated findings touched:

- [ ] **Keyboard:** Tab through the whole page/flow; Enter/Space activate controls; no traps.
- [ ] **APG patterns:** Each interactive component is mapped to one or more APG patterns, and its keyboard model
  matches them (or the deviation is documented).
- [ ] **Screen reader:** Spot-check with VoiceOver (Mac), NVDA (Windows), or TalkBack (Android).
- [ ] **Zoom:** Content and functionality usable at 200% zoom.
- [ ] **Reduced motion:** Respects `prefers-reduced-motion: reduce`.
- [ ] **Focus order:** Matches visual/logical order; focused elements aren't hidden by sticky
  headers/footers (WCAG 2.4.11).
- [ ] **Target size:** Interactive elements meet the 24×24px minimum (WCAG 2.5.8).

Screen reader shortcut reference:
[references/A11Y-PATTERNS.md#screen-reader-commands](references/A11Y-PATTERNS.md#screen-reader-commands).

## Reporting findings

Structure the report by severity, referencing the rule ID so it's traceable back to the scripts'
raw JSON — or `APG: <pattern>` for findings from the pattern check. Include the component inventory from
[step 3](#3-map-components-to-apg-patterns):

```markdown
## Accessibility audit — <url>

### Evidence

| Lighthouse a11y score | axe violations | Source |
|------------------------|-----------------|--------|
| 82                     | 6               | scripts/audit.sh |

### Component inventory (APG)

| Component     | Location                          | APG pattern(s)              | Conformance |  Notes                                    |
|---------------|-----------------------------------|-----------------------------|-------------|-------------------------------------------|
| Main nav      | `src/components/Header.tsx:22`    | Disclosure, Landmarks, Link | ❌ Fails     | Uses `role="menubar"` — see Critical      |
| Language menu | `src/components/LangSwitch.tsx:8` | Menu Button + Menu          | ⚠️ Deviates  | No type-ahead (accepted: 3 items only)    |

### Critical (fix immediately)

- **[image-alt]** Logo `<img>` has no alt text. `src/components/Header.tsx:14`
    - **Impact:** Screen reader users hear "image" with no context.
    - **Evidence:** axe-core violation, selector `header img.logo`.
    - **Fix:** `<img src="logo.svg" alt="Acme Inc.">`
- **[APG: Disclosure]** Main navigation uses `role="menubar"`/`menuitem` but only supports Tab, so arrow keys do
  nothing and screen readers announce an application menu. `src/components/Header.tsx:22`
    - **Impact:** Keyboard and screen reader users get a menu interaction model the component doesn't implement
      (WCAG 4.1.2, 2.1.1).
    - **Evidence:** Live keyboard pass; accessibility tree shows `menubar`.
    - **Fix:** Drop the menu roles; use `<nav aria-label="Main">` with disclosure buttons (`aria-expanded`) for
      submenus — [APG Disclosure navigation](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/).

### Serious / Moderate / Minor

...

### Manual checks

- [x] Keyboard pass completed — no traps found.
- [ ] Screen reader pass pending.

### Verification

- Re-ran `scripts/audit.sh` after fixes: Lighthouse 82 → 100, axe violations 6 → 0.
```

Severity ordering: **Critical** (blocks access entirely — missing labels/alt/names, keyboard traps)
→ **Serious** (major barrier — contrast, missing landmarks/lang, broken heading structure) → **Moderate** (real but
workaroundable) → **Minor**. See
[references/AXE-RULES.md](references/AXE-RULES.md) for the full per-rule breakdown, and use
axe-core's own `impact` field on each violation when it disagrees with the table — it's computed
per-instance and is the more precise signal.

## References

- [WCAG 2.2 Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/), [patterns](https://www.w3.org/WAI/ARIA/apg/patterns/)
- [Deque axe-core rules](https://dequeuniversity.com/rules/axe/4.10)
- [WCAG criteria reference](references/WCAG.md)
- [Accessibility code patterns](references/A11Y-PATTERNS.md)
- [axe-core rule → fix mapping](references/AXE-RULES.md)
- [APG pattern catalog and component mapping](references/APG-PATTERNS.md)
