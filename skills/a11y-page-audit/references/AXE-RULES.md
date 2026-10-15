# axe-core rule reference

Lighthouse's Accessibility category runs axe-core internally, so `scripts/run-lighthouse.sh` and
`scripts/run-axe.mjs` report many of the **same rule IDs**. This table is the lookup for both: find
the `id` from either tool's JSON output, then apply the fix.

Full canonical list: [Deque axe-core rules](https://dequeuniversity.com/rules/axe/4.10).

## Critical impact — fix immediately

| Rule ID               | WCAG                    | Issue                                                             | Fix                                                                                                                  |
|-----------------------|-------------------------|-------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| `image-alt`           | 1.1.1 (A)               | `<img>` has no `alt` attribute                                    | Add descriptive `alt="..."`, or `alt=""` if purely decorative                                                        |
| `input-image-alt`     | 1.1.1 (A)               | `<input type="image">` has no accessible name                     | Add `alt` describing the action (e.g. `alt="Submit search"`)                                                         |
| `area-alt`            | 1.1.1, 4.1.2 (A)        | Image map `<area>` has no accessible name                         | Add `alt` on each `<area>`                                                                                           |
| `object-alt`          | 1.1.1 (A)               | `<object>` has no accessible text                                 | Add `aria-label` or fallback text content                                                                            |
| `button-name`         | 4.1.2 (A)               | Button has no accessible name (empty, icon-only with no label)    | Add visible text, `aria-label`, or a `.sr-only` span — see [A11Y-PATTERNS](A11Y-PATTERNS.md#screen-reader-only-text) |
| `link-name`           | 2.4.4, 4.1.2 (A)        | Link has no accessible name                                       | Add link text, `aria-label`, or `aria-labelledby`                                                                    |
| `label`               | 1.3.1, 3.3.2, 4.1.2 (A) | Form field has no programmatically associated label               | Add `<label for="id">` or wrap input in `<label>` — see [A11Y-PATTERNS](A11Y-PATTERNS.md#form-labels)                |
| `select-name`         | 4.1.2 (A)               | `<select>` has no accessible name                                 | Associate a `<label>`                                                                                                |
| `aria-hidden-focus`   | 4.1.2 (A)               | Focusable element inside `aria-hidden="true"` container           | Remove `tabindex`/interactivity, or drop `aria-hidden` from that ancestor                                            |
| `frame-title`         | 4.1.2, 2.4.1 (A)        | `<iframe>` has no `title`                                         | Add `title="describes the frame's purpose"`                                                                          |
| `duplicate-id-active` | 4.1.1 legacy / 4.1.2    | Two focusable/interactive elements share an `id`                  | Make every `id` unique on the page                                                                                   |
| `nested-interactive`  | 4.1.2, 2.1.1 (A)        | Interactive element nested inside another (e.g. button in a link) | Flatten the markup — pick one interactive element                                                                    |

## Serious impact — fix before launch

| Rule ID                               | WCAG         | Issue                                                             | Fix                                                                                                                     |
|---------------------------------------|--------------|-------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `color-contrast`                      | 1.4.3 (AA)   | Text/background contrast below 4.5:1 (or 3:1 for large text)      | Darken text or lighten background until the ratio passes — see contrast table in [SKILL.md](../SKILL.md#color-contrast) |
| `html-has-lang`                       | 3.1.1 (A)    | `<html>` has no `lang` attribute                                  | Add `<html lang="en">` (or the page's language)                                                                         |
| `html-lang-valid`                     | 3.1.1 (A)    | `lang` value isn't a valid BCP 47 code                            | Use a valid code, e.g. `en`, `en-US`, `es`, `it`                                                                        |
| `valid-lang`                          | 3.1.2 (AA)   | `lang` on a sub-element isn't valid                               | Fix or remove the invalid `lang` attribute                                                                              |
| `document-title`                      | 2.4.2 (A)    | Page has no `<title>` or an empty one                             | Add a descriptive, unique `<title>`                                                                                     |
| `landmark-one-main`                   | 1.3.1, 2.4.1 | Page has no `<main>` landmark                                     | Wrap primary content in `<main>`                                                                                        |
| `region`                              | 1.3.1, 2.4.1 | Content exists outside any landmark region                        | Wrap sections in `<header>`, `<nav>`, `<main>`, `<footer>`, or `role="region"` with a label                             |
| `page-has-heading-one`                | 2.4.6, 1.3.1 | No `<h1>` on the page                                             | Add one `<h1>` describing the page's main content                                                                       |
| `heading-order`                       | 1.3.1        | Heading levels skip (e.g. `h2` → `h4`)                            | Fix nesting so levels increase by one at a time                                                                         |
| `duplicate-id-aria`                   | 4.1.2        | `aria-labelledby`/`aria-describedby` references a duplicated `id` | Make referenced `id`s unique                                                                                            |
| `aria-required-attr`                  | 4.1.2        | Element with an ARIA role is missing a required attribute         | Add the attribute the role mandates (e.g. `aria-checked` for `role="checkbox"`)                                         |
| `aria-valid-attr-value`               | 4.1.2        | ARIA attribute has an invalid value                               | Use a value from the spec (e.g. `true`/`false`, not `yes`)                                                              |
| `autocomplete-valid`                  | 1.3.5 (AA)   | `autocomplete` value isn't a valid token                          | Use a spec token, e.g. `autocomplete="email"`                                                                           |
| `form-field-multiple-labels`          | 3.3.2, 1.3.1 | Field has more than one `<label>`                                 | Keep a single label; move extra text to `aria-describedby`                                                              |
| `meta-viewport`                       | 1.4.4 (AA)   | `user-scalable=no` or `maximum-scale<2` blocks zoom               | Remove those restrictions from the viewport meta tag                                                                    |
| `td-has-header` / `th-has-data-cells` | 1.3.1        | Data table cells aren't associated with headers                   | Use `<th scope="col\|row">` or `headers`/`id` pairs                                                                     |

## Moderate impact — fix soon

| Rule ID                       | WCAG         | Issue                                                             | Fix                                                                                           |
|-------------------------------|--------------|-------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `link-in-text-block`          | 1.4.1        | Link is distinguished from surrounding text by color alone        | Add underline or another non-color cue                                                        |
| `target-size`                 | 2.5.8 (AA)   | Interactive target smaller than 24×24 CSS px                      | Increase padding/`min-width`/`min-height` to at least 24×24px (44×44px is more comfortable)   |
| `list` / `listitem`           | 1.3.1        | `<li>` not inside `<ul>`/`<ol>`, or non-`<li>` children in a list | Fix list structure or use `role="list"`/`role="listitem"` if a wrapper `<div>` is unavoidable |
| `definition-list`             | 1.3.1        | `<dl>` has children other than `<dt>`/`<dd>`/`<div>`              | Fix structure to match the `<dl>` content model                                               |
| `scrollable-region-focusable` | 2.1.1        | Scrollable region isn't keyboard-focusable                        | Add `tabindex="0"` and a label to the scrollable container                                    |
| `tabindex`                    | 2.4.3        | Positive `tabindex` value (breaks natural tab order)              | Use `tabindex="0"` or `"-1"` only; reorder markup instead                                     |
| `aria-allowed-attr`           | 4.1.2        | ARIA attribute not allowed on this role/element                   | Remove the attribute or change the role                                                       |
| `empty-heading`               | 1.3.1, 2.4.6 | Heading element has no accessible text                            | Add text or remove the empty heading                                                          |

## Minor impact — fix when convenient

| Rule ID                | WCAG         | Issue                                                               | Fix                                                 |
|------------------------|--------------|---------------------------------------------------------------------|-----------------------------------------------------|
| `aria-roledescription` | 4.1.2        | Non-standard `aria-roledescription` may confuse some screen readers | Verify it adds real value; remove if not            |
| `landmark-unique`      | 1.3.1, 2.4.1 | Multiple landmarks of the same type lack distinguishing labels      | Add `aria-label` to each, e.g. two `<nav>` elements |
| `css-orientation-lock` | 1.3.4 (AA)   | CSS locks the display to one orientation                            | Remove the orientation lock unless essential        |

## How to read the scripts' output

- `scripts/run-axe.mjs` output: `violations[].id` matches the left column here; `violations[].impact`
  is axe-core's own severity (`critical`/`serious`/`moderate`/`minor`) — trust that field over the
  table headings above when they disagree, since axe recalculates impact per instance.
- `scripts/run-lighthouse.sh` output: `failingAudits[].id` matches the same rule IDs. Lighthouse
  doesn't report an `impact` field — use this table's grouping instead.
- `scripts/audit.sh` output: `topAxeRules` / `topLighthouseAudits` rank rule IDs by how many nodes
  fail them — many failing nodes under one rule usually trace back to a single shared component, so
  one source-file fix resolves every occurrence.
