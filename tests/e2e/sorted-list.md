# Test Case: Sorted List

**Target:** http://localhost:3000/sortedList
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's ability to handle CRUD operations on a list backed by a REST API (json-server), verify list order, enforce business rules (max 5 items), and use `fill` for form input.

## Prerequisites

- Both servers running (`./scripts/start.sh`)
- json-server has default 4 todos in `data/db.json`

## Test 1: Add a todo — verify appended at end

### Steps
1. Snapshot initial state — 4 todos
2. `fill` the input with "Test todo from playwright-cli"
3. `click` "Add todo"
4. Fresh snapshot — verify 5th item at end of list

### Actual Result
- New todo appeared at position 5 (end of list) — correct for sorted list behavior
- "Your schedule is full!" message appeared (5/5 limit reached)
- API call persisted to json-server

## Test 2: Delete a todo — verify removal

### Steps
1. Click delete button on "Test todo from playwright-cli"
2. Fresh snapshot — verify 4 items, no "schedule is full" message

### Actual Result
- Todo removed from list and API
- "Your schedule is full!" message disappeared
- Original 4 todos in correct order: Play with Filip → Make some dinner → Do the dishes → Walk with cats

## Test 3: Max 5 enforcement (negative)

### Steps
1. Add "Fifth todo" — hits limit
2. Fill "Sixth todo should fail" and click Add
3. Verify list still has 5 items

### Actual Result
- 6th todo was NOT added — stays at 5 items
- Input field retained the text but submit was silently blocked
- "Your schedule is full!" message persisted

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| `fill` command | Text input for new todo |
| `click` with dynamic refs | Delete buttons have unique refs per todo item |
| List verification via snapshot | Can read all list items and their order from snapshot |
| API-backed CRUD | Add and delete trigger real HTTP requests to json-server |
| Business rule verification | Max 5 items — snapshot shows error message when limit hit |
| State cleanup | Delete test data to restore original state |

## Findings

### Positive: `fill` command works cleanly
`fill` correctly fills text inputs and playwright-cli resolved the ref to `getByRole('textbox', { name: 'Add new Todo:' })`. No issues.

### Positive: Smart selector generation for delete buttons
When clicking a delete button inside a list item, playwright-cli generated:
```js
await page.getByRole('listitem').filter({ hasText: 'Fifth todo' }).getByLabel('Delete todo').click();
```
This is a high-quality, context-aware selector — it scopes the delete button to its parent list item by text content. Impressive for automated selector generation.

### Confirmed: Stale refs after `fill`
After `fill`, the previous ref for the "Add todo" button (`e54`) became stale and failed. Had to take a fresh snapshot to get the updated ref (`e119`). This is the same stale snapshot issue seen in Yellow or Blue, but triggered by `fill` instead of `click`. **Any state-changing command can invalidate refs.**

### Observation: No assertion primitives
playwright-cli can capture snapshots to verify state, but there's no built-in `assert` or `expect` command. All verification must be done by the caller parsing snapshot YAML. For an AI agent this works (it can read YAML), but it means:
- No pass/fail reporting
- No assertion error messages
- No test results summary
- The caller must implement all verification logic

### Data cleanup note
Tests that modify API data need explicit cleanup (delete test items). playwright-cli has no built-in test fixtures or teardown mechanism. The `state-save`/`state-load` commands only handle browser state (cookies/storage), not backend data.
