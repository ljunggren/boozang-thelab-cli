# TheLab Improvements

TheLab's purpose is to be a **test automation test bed** — an app designed to be tested by tools. Every improvement should make the app easier and more valuable to automate against, not harder. The goal is comprehensive coverage of real-world test automation challenges with predictable, well-documented behavior.

---

## Design Principles for a Test Bed

1. **Every interactive element should be targetable** — test-ids, aria-labels, semantic HTML
2. **Every state change should be verifiable** — expose state in DOM attributes, not just CSS
3. **Behavior should be documented** — expected inputs, outputs, edge cases per route
4. **Data should be resettable** — no manual cleanup between test runs
5. **Real-world patterns should be represented** — loading, errors, dialogs, async, responsive

---

## Testability (make it easy to automate)

### 1. Complete `data-testid` coverage
Add test IDs to every interactive and verifiable element:

| Missing on | Suggested testid |
|-----------|-----------------|
| Result messages (Success/Try again) | `result-message`, `result-submessage` |
| Speed/Wait game reaction time display | `reaction-time` |
| Table filter checkboxes | `filter-lion`, `filter-elephant`, `filter-zebra` |
| Table rows | `animal-row-{name}` |
| Table like buttons | `like-{name}` |
| Cat shelter list items | `cat-item-{id}` |
| Cat shelter toggle buttons | `toggle-home-{id}` |
| Visual Bugs image + label | `visual-bug-image`, `visual-bug-label` |
| Scramble buttons (puma/tiger) | `scramble-btn-one`, `scramble-btn-two` |
| Pagination buttons | `pagination-next`, `pagination-prev` |

**Why:** Test IDs are the universal stable anchor. Every tool (Playwright, Cypress, Boozang, Selenium) benefits. This is the single highest-impact change.

### 2. Expose state in DOM attributes, not just CSS
Toggle states (liked, foundHome) currently use CSS classes only. Add `aria-pressed` or `data-state` attributes:

```html
<!-- Current: state only in CSS class -->
<button class="new_home found">🏠</button>

<!-- Improved: state in accessible attribute -->
<button class="new_home found" aria-pressed="true" data-state="found-home">🏠</button>
```

Apply to:
- Cat shelter foundHome toggle → `aria-pressed="true/false"`
- Table like toggle → `aria-pressed="true/false"`
- Scramble button clicked state → `aria-pressed="true"`
- Result message visibility → `data-visible="true/false"` instead of CSS opacity

**Why:** DOM-based tools (all of them) can only reliably verify DOM attributes, not computed CSS. This makes state verifiable without screenshots.

### 3. Fix the empty table row for unliked animals
Arthur (unliked) renders as an empty `<tr>`. All rows should render the same structure regardless of liked state — only styling should differ.

**Why:** Every row should be readable and targetable. An empty row is an accessibility bug and breaks any tool trying to enumerate table data.

### 4. Add a test data reset mechanism
Options (pick one):
- **Script:** `scripts/reset-data.sh` that copies `data/db.json.default` → `data/db.json` and restarts json-server
- **Endpoint:** json-server middleware that handles `POST /reset`
- **Snapshot file:** `data/db.json.default` committed to repo, with a reset script

**Why:** Every CRUD test (sorted list, form fill, cat shelter) modifies shared data. Without reset, tests must clean up after themselves or risk polluting subsequent runs.

---

## Coverage (represent real-world patterns)

### 5. Add configurable API delays
Add a delay control (URL param or UI toggle) that injects latency into json-server responses:

```
/todos?_delay=2000    # 2 second delay
```

Or a global toggle in the UI: "Simulate slow network" checkbox that adds 1-3s random delay to all fetches.

**Why:** Fast local json-server hides timing issues. Real apps have latency. Loading spinners, skeleton screens, and "please wait" states are where test tools struggle most. This was the #1 gap found in playwright-cli.

### 6. Add confirmation dialogs on destructive actions
Delete todo, delete cat, delete user → show `window.confirm("Are you sure?")` before proceeding.

**Why:** Dialog handling is a standard test automation challenge. Every tool needs to handle it. Currently untestable in TheLab.

### 7. Add inline validation with real-time error messages
Form Fill should validate as the user types, not just on submit:
- Email format check on blur
- Password strength meter (weak/medium/strong)
- "Required" error when field is emptied
- Character count on description fields

**Why:** Real-time validation creates dynamic error messages that appear/disappear — tests must handle elements that come and go.

### 8. Add a sortable table column
Tables page should allow clicking column headers to sort by Name, Species, or Hairdo.

**Why:** Column sort is ubiquitous in SaaS apps. Tests must verify row order changes after sort — a harder version of the sorted/unsorted list pattern.

### 9. Add drag-and-drop
Add a simple drag-and-drop reorder on the sorted list (reorder todos by dragging).

**Why:** Drag-and-drop is a known hard problem for test automation. `drag` is a playwright-cli command we didn't test.

### 10. Add file upload
Cat shelter "Add Cat" should accept an image upload for the cat's photo.

**Why:** `upload` is a playwright-cli command. File upload is a common real-world form pattern.

---

## Documentation (make it self-describing)

### 11. Add `SPEC.md` per component route
Each route should have a spec file documenting:

```markdown
# /speedGame — Speed Game

## Initial State
- "Start Game" button visible
- "End Game" button NOT in DOM
- No result message

## Interactions
| Action | Expected Result |
|--------|----------------|
| Click "Start Game" | Button stays visible, countdown starts (1-10s random) |
| Wait for countdown | "End Game" button appears in DOM |
| Click "End Game" | Result message: "Success" + reaction time in ms |

## Selectors
| Element | data-testid | aria-label |
|---------|-------------|------------|
| Start button | startBtn | — |
| End button | endBtn | — |
| Result message | result | — |

## Edge Cases
- Click "End Game" before it appears → should fail gracefully
- Click "Start Game" twice → should reset
```

**Why:** A test bed is only useful if the tester knows what to expect. This makes TheLab usable by any team evaluating any tool — not just people who read the source code.

### 12. Complete Cucumber feature files
Some routes have feature files in `/public/features/`, others don't. Add them for all routes.

**Why:** BDD specs are both human-readable and machine-parseable. AI agents can use them as test instructions directly.

### 13. Add a test automation guide page
Add a `/guide` route (or section on the home page) explaining:
- TheLab's purpose as a test bed
- List of challenges by category (timing, forms, visual, DOM mutations, etc.)
- Recommended test order (simple → complex)
- Links to specs for each route

**Why:** Makes TheLab self-documenting. A new user (or AI agent) can understand the entire test surface from a single page.

---

## Summary: Priority Order for Implementation

| # | Change | Effort | Impact |
|---|--------|--------|--------|
| 1 | Complete `data-testid` coverage | Low | Very High |
| 2 | Expose state in DOM attributes (`aria-pressed`, `data-state`) | Low | Very High |
| 3 | Fix empty table row bug | Low | Medium |
| 4 | Add test data reset script | Low | High |
| 5 | Add `SPEC.md` per route | Medium | High |
| 6 | Add configurable API delays | Medium | High |
| 7 | Add confirmation dialogs | Low | Medium |
| 8 | Add inline form validation | Medium | Medium |
| 9 | Complete Cucumber feature files | Medium | Medium |
| 10 | Add sortable table columns | Medium | Medium |
| 11 | Add drag-and-drop | Medium | Medium |
| 12 | Add file upload | Low | Medium |
| 13 | Add test automation guide page | Medium | Medium |

Items 1-4 are quick wins that dramatically improve testability. Items 5-6 add the most value for tool evaluations. The rest round out the test bed for comprehensive coverage.
