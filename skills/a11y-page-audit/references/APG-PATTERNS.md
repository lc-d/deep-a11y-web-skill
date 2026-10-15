# APG Patterns

Every interactive web component must be traceable to one or more
[WAI-ARIA Authoring Practices Guide (APG) patterns](https://www.w3.org/WAI/ARIA/apg/patterns/). The main
[SKILL.md](../SKILL.md) points here when mapping components and judging their roles, states, and keyboard behavior.

---

## Matching rules

1. **One or more patterns per component.** Each interactive component on the page cites at least one APG pattern.
   Composite components cite all the patterns they combine, e.g. a date picker = Dialog (Modal) + Grid + Button.
2. **Native HTML first.** A native element that already provides the pattern's semantics counts as a match —
   `<button>`, `<a href>`, `<input type="checkbox">`, `<input type="range">`, `<select>`, `<details>`/`<summary>`,
   `<dialog>` opened with `showModal()`, `<table>`. Still cite the pattern: it defines the behavior to verify.
3. **Deviations are allowed, but must be stated.** A component may differ from its pattern (design constraints,
   simplified keyboard model, extra features). Name the pattern it is based on, list what differs and why. A deviation
   must never drop an accessible name, a role, a state, keyboard operability, or focus management.
4. **No direct match → closest pattern.** When no pattern fits exactly (stepper, card, progress bar, …), cite the
   closest pattern (s) and say "no direct APG pattern". Base roles and states on the
   [WAI-ARIA spec](https://www.w3.org/TR/wai-aria-1.2/) in that case.
5. **Don't borrow the wrong pattern.** Choosing a pattern by appearance rather than behavior is a defect. The most
   common one: `role="menu"`/`menubar` for site navigation — use Disclosure (navigation menu) plus links instead.
   Likewise a "dropdown" that selects a value is a Combobox or Listbox, not a Menu.
6. **APG is guidance, WCAG is the requirement.** A pattern mismatch is reported against the WCAG criterion it breaks —
   usually 4.1.2 (name/role/value), 2.1.1 (keyboard), 2.4.3 (focus order), 2.4.7 (focus visible), or 1.3.1 (info and
   relationships). A mismatch that breaks none of them is a Minor finding (consistency), not a failure.

---

## Pattern catalog

Keyboard shortcuts listed are the essentials; open the pattern page for the full model and working examples.

| Pattern                                                                             | Roles / key attributes                                                                                                            | Keyboard essentials                                                                                                         |
|-------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| [Accordion](https://www.w3.org/WAI/ARIA/apg/patterns/accordion/)                    | Heading wrapping a `button` with `aria-expanded`, `aria-controls`; panel optionally `role="region"` + `aria-labelledby`           | Enter/Space toggle; optional ↑/↓, Home/End between headers                                                                  |
| [Alert](https://www.w3.org/WAI/ARIA/apg/patterns/alert/)                            | `role="alert"` (must exist in the DOM before content is injected)                                                                 | None — never moves focus                                                                                                    |
| [Alert and Message Dialogs](https://www.w3.org/WAI/ARIA/apg/patterns/alertdialog/)  | `role="alertdialog"`, `aria-modal="true"`, `aria-labelledby`, `aria-describedby`                                                  | As Dialog (Modal); initial focus usually on the least destructive action                                                    |
| [Breadcrumb](https://www.w3.org/WAI/ARIA/apg/patterns/breadcrumb/)                  | `<nav aria-label="Breadcrumb">` + ordered list of links; `aria-current="page"` on the current item                                | Standard link Tab navigation                                                                                                |
| [Button](https://www.w3.org/WAI/ARIA/apg/patterns/button/)                          | `<button>` or `role="button"`; toggle button: `aria-pressed`                                                                      | Enter and Space activate                                                                                                    |
| [Carousel](https://www.w3.org/WAI/ARIA/apg/patterns/carousel/)                      | Container `role="region"`/`group` + `aria-roledescription="carousel"`; slides `aria-roledescription="slide"`; rotation control    | Rotation stops on focus/hover; first Tab stop is the rotation control; prev/next are buttons; optional tabs as slide picker |
| [Checkbox](https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/)                      | `role="checkbox"`, `aria-checked` = `true`/`false`/`mixed`                                                                        | Space toggles                                                                                                               |
| [Combobox](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/)                      | `role="combobox"`, `aria-expanded`, `aria-controls`, `aria-autocomplete`, `aria-activedescendant`; popup listbox/grid/tree/dialog | ↓ opens/moves, ↑ moves, Enter accepts, Esc closes (then clears), Alt+↓ opens without moving                                 |
| [Dialog (Modal)](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/)            | `role="dialog"` (or `<dialog>`), `aria-modal="true"`, `aria-labelledby`                                                           | Focus moves inside on open; Tab/Shift+Tab cycle inside; Esc closes; focus returns to the trigger                            |
| [Disclosure (Show/Hide)](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/)      | `button` with `aria-expanded`, `aria-controls` (or `<details>`/`<summary>`)                                                       | Enter/Space toggle                                                                                                          |
| [Feed](https://www.w3.org/WAI/ARIA/apg/patterns/feed/)                              | `role="feed"`; children `role="article"` with `aria-posinset`, `aria-setsize`, `aria-labelledby`; `aria-busy` while loading       | Page Down/Up between articles; Ctrl+End/Home leave the feed                                                                 |
| [Grid](https://www.w3.org/WAI/ARIA/apg/patterns/grid/)                              | `role="grid"`, `row`, `gridcell`, `columnheader`/`rowheader`; `aria-selected` if selectable                                       | Single Tab stop; arrows between cells; Home/End; Ctrl+Home/End; Page Up/Down                                                |
| [Landmarks](https://www.w3.org/WAI/ARIA/apg/patterns/landmarks/)                    | `header`/`banner`, `nav`, `main`, `aside`, `footer`/`contentinfo`, `search`, labelled `section`/`form`                            | None — duplicated landmarks of the same type need unique labels                                                             |
| [Link](https://www.w3.org/WAI/ARIA/apg/patterns/link/)                              | `<a href>`; custom: `role="link"` + `tabindex="0"`                                                                                | Enter activates (Space does not)                                                                                            |
| [Listbox](https://www.w3.org/WAI/ARIA/apg/patterns/listbox/)                        | `role="listbox"`, `option`, `aria-selected`, `aria-multiselectable`, `aria-activedescendant`                                      | ↑/↓, Home/End, type-ahead; multi-select: Space, Shift+arrows, Ctrl+A                                                        |
| [Menu and Menubar](https://www.w3.org/WAI/ARIA/apg/patterns/menubar/)               | `role="menu"`/`menubar`, `menuitem`, `menuitemcheckbox`, `menuitemradio`                                                          | Single Tab stop; arrows move; Enter/Space activate; Esc closes; type-ahead. **App-style actions only, not site navigation** |
| [Menu Button](https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/)                | `button` with `aria-haspopup="menu"`, `aria-expanded`, `aria-controls`                                                            | Enter/Space/↓ open and focus the first item; ↑ focuses the last                                                             |
| [Meter](https://www.w3.org/WAI/ARIA/apg/patterns/meter/)                            | `role="meter"` (or `<meter>`), `aria-valuenow`/`min`/`max`, `aria-valuetext`                                                      | Not interactive                                                                                                             |
| [Radio Group](https://www.w3.org/WAI/ARIA/apg/patterns/radio/)                      | `role="radiogroup"` + labelled; `role="radio"`, `aria-checked`                                                                    | Tab enters on the checked radio; arrows move and check                                                                      |
| [Slider](https://www.w3.org/WAI/ARIA/apg/patterns/slider/)                          | `role="slider"`, `aria-valuenow`/`min`/`max`, `aria-valuetext`, `aria-orientation`                                                | Arrows step; Home/End min/max; Page Up/Down large step                                                                      |
| [Slider (Multi-Thumb)](https://www.w3.org/WAI/ARIA/apg/patterns/slider-multithumb/) | One `role="slider"` per thumb, each labelled; min/max of each constrained by the other                                            | Tab between thumbs; per-thumb slider keys                                                                                   |
| [Spinbutton](https://www.w3.org/WAI/ARIA/apg/patterns/spinbutton/)                  | `role="spinbutton"`, `aria-valuenow`/`min`/`max`, `aria-valuetext`                                                                | ↑/↓ step; Home/End; Page Up/Down; typing allowed                                                                            |
| [Switch](https://www.w3.org/WAI/ARIA/apg/patterns/switch/)                          | `role="switch"`, `aria-checked` = `true`/`false`; label must not change with state                                                | Space toggles (Enter optional)                                                                                              |
| [Table](https://www.w3.org/WAI/ARIA/apg/patterns/table/)                            | `<table>` or `role="table"`, `row`, `cell`, `columnheader`/`rowheader`; `aria-sort` on sorted header                              | Not interactive (sort controls are buttons in headers)                                                                      |
| [Tabs](https://www.w3.org/WAI/ARIA/apg/patterns/tabs/)                              | `tablist` (labelled), `tab` with `aria-selected`, `aria-controls`; `tabpanel` with `aria-labelledby`                              | Single Tab stop on the active tab; ←/→ (or ↑/↓ if vertical), Home/End; automatic or manual activation                       |
| [Toolbar](https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/)                        | `role="toolbar"`, labelled, `aria-orientation` if vertical                                                                        | Single Tab stop; arrows between controls; Home/End                                                                          |
| [Tooltip](https://www.w3.org/WAI/ARIA/apg/patterns/tooltip/)                        | `role="tooltip"`; trigger has `aria-describedby` pointing at it; no focusable content inside                                      | Appears on focus and hover; Esc dismisses (WCAG 1.4.13)                                                                     |
| [Tree View](https://www.w3.org/WAI/ARIA/apg/patterns/treeview/)                     | `role="tree"`, `treeitem`, `group`; `aria-expanded` on parent nodes; `aria-selected`/`aria-checked`                               | Single Tab stop; ↑/↓ move; → expand / to child; ← collapse / to parent; Home/End; type-ahead                                |
| [Treegrid](https://www.w3.org/WAI/ARIA/apg/patterns/treegrid/)                      | `role="treegrid"`, `row` with `aria-expanded`/`aria-level`, `gridcell`                                                            | Grid keys plus → / ← to expand/collapse rows                                                                                |
| [Window Splitter](https://www.w3.org/WAI/ARIA/apg/patterns/windowsplitter/)         | Focusable `role="separator"`, `aria-valuenow`/`min`/`max`, `aria-controls`, labelled                                              | Arrows move; Enter collapses/restores; Home/End optional                                                                    |

---

## Common component names → APG patterns

Design systems rarely use APG names. Map by behavior, not by name or look.

| Component (common names)                                             | APG pattern(s)                                                                    | Notes                                                                                 |
|----------------------------------------------------------------------|-----------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| Modal, lightbox, drawer / offcanvas / side sheet (modal)             | Dialog (Modal)                                                                    | Non-modal drawer: Disclosure + a labelled landmark                                    |
| Confirm / destructive-action dialog                                  | Alert and Message Dialogs                                                         |                                                                                       |
| Toast, snackbar, inline notification                                 | Alert                                                                             | Non-urgent messages: `role="status"` live region (not an APG pattern, same principle) |
| Hamburger menu, mega menu, site navigation dropdown                  | Disclosure + Landmarks + Link                                                     | Not Menu/Menubar — see [matching rule 5](#matching-rules)                             |
| Collapse, expander, FAQ, "show more"                                 | Disclosure; Accordion when several stacked sections                               |                                                                                       |
| Actions dropdown, kebab / "more" menu, context menu                  | Menu Button + Menu                                                                |                                                                                       |
| Select, custom dropdown, autocomplete, typeahead, search suggestions | Combobox (+ Listbox popup)                                                        | Native `<select>` is preferred when no filtering is needed                            |
| Multi-select, tag input                                              | Combobox + Listbox (`aria-multiselectable`)                                       |                                                                                       |
| Toggle                                                               | Switch (on/off setting) or Button (toggle, `aria-pressed`)                        |                                                                                       |
| Segmented control                                                    | Radio Group; Tabs if it switches panels; Toolbar of toggle buttons for formatting |                                                                                       |
| Filter chips                                                         | Button (toggle) or Checkbox                                                       |                                                                                       |
| Star rating                                                          | Radio Group                                                                       | APG has a rating radio group example                                                  |
| Date picker                                                          | Dialog (Modal) + Grid + Button, or Combobox + Dialog                              | APG has both examples                                                                 |
| Range / price filter                                                 | Slider (Multi-Thumb)                                                              |                                                                                       |
| Quantity / number stepper                                            | Spinbutton                                                                        | Or native `<input type="number">` with labelled +/– buttons                           |
| Data table (read-only, sortable)                                     | Table                                                                             | Use Grid only when cells are interactive (editing, cell navigation)                   |
| Data grid, spreadsheet                                               | Grid                                                                              |                                                                                       |
| File explorer, nested navigation tree                                | Tree View (nested nav of links may use Disclosure instead)                        |                                                                                       |
| Hero slider, image gallery rotator                                   | Carousel                                                                          |                                                                                       |
| Infinite scroll / news stream                                        | Feed                                                                              |                                                                                       |
| Resizable split pane                                                 | Window Splitter                                                                   |                                                                                       |
| Rich-text editor toolbar                                             | Toolbar (+ Button, Menu Button)                                                   |                                                                                       |
| Popover                                                              | Dialog (non-modal) if it holds interactive content; Tooltip if purely descriptive |                                                                                       |
| Pagination                                                           | Landmarks (`nav`, labelled) + Link with `aria-current="page"`                     | No direct APG pattern                                                                 |
| Stepper / wizard progress                                            | Landmarks + Link or Button, `aria-current="step"`                                 | No direct APG pattern                                                                 |
| Progress bar, loader                                                 | Meter (closest)                                                                   | No direct APG pattern — use `role="progressbar"` / `<progress>`, not `meter`          |
| Card                                                                 | Link or Button for its single main action; headings inside                        | No direct APG pattern                                                                 |

---

## Component inventory format

Record the mapping in the audit report (see [SKILL.md](../SKILL.md#reporting-findings)):

```markdown
| Component      | Location                         | APG pattern(s)                      | Conformance | Notes                                        |
|----------------|----------------------------------|-------------------------------------|-------------|----------------------------------------------|
| Main nav       | `src/components/Header.ts:22`    | Disclosure, Landmarks, Link         | ✅ Matches  |                                              |
| Language menu  | `src/components/LangSwitch.ts:8` | Menu Button + Menu                  | ⚠️ Deviates | No type-ahead (accepted: 3 items only)       |
| Product filter | `src/components/Filters.ts:41`   | Slider (Multi-Thumb)                | ❌ Fails    | Thumbs not focusable — see Critical findings |
| Stepper        | `src/components/Wizard.ts:12`    | No direct pattern — Landmarks, Link | ⚠️ Deviates | `aria-current="step"` on the active step     |
```

Conformance values: **✅ Matches** (roles, states, keyboard per pattern) · **⚠️ Deviates** (documented, justified, no
WCAG failure) · **❌ Fails** (breaks a WCAG criterion — also listed as a finding).
