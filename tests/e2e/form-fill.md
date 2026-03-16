# Test Case: Form Fill

**Target:** http://localhost:3000/formFill
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's form handling: multi-field fill, submit, validation errors, table data verification, and row-level delete. This is the most complete CRUD flow in the app — create via form, read via table, delete via button.

## Test 1: Positive — fill form, submit, verify in table

### Steps
1. Fill First name: "Test", Last name: "User", Email: "test@playwright.cli", Password: "password123"
2. Click "Save to db"
3. Verify "Data saved to DB" message
4. Click "Show users in db"
5. Verify "Test User" / "test@playwright.cli" appears in table (newest first)
6. Delete test user to clean up

### Actual Results
- All 4 fields filled with `fill` command — worked perfectly
- "Data saved to DB" message appeared after submit
- Table showed "Test User" at top (newest first) with correct email
- Delete button worked — playwright-cli generated scoped selector: `getByRole('row', { name: 'Test User test@playwright.cli' }).getByLabel('Delete person from db')`
- User removed from both UI and API

## Test 2: Negative — password validation (< 6 chars)

### Steps
1. Fill form with password "123" (too short)
2. Click "Save to db"
3. Verify validation error message

### Actual Results
- Error message: "Password needs to be at least 6 characters." displayed in red
- Form retained all field values (not cleared on validation failure)
- No API call made (checked — user not in table)

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| `fill` on multiple field types | text, email, password inputs |
| Form submission | Click submit, verify success message |
| Table data reading | Parse table rows/cells from snapshot |
| Row-scoped actions | Delete button within a specific table row |
| Validation error detection | Read error message from snapshot after failed submit |
| Show/hide toggle | "Show/Hide users in db" button toggles table visibility |

## Findings

### Positive: Multi-field fill is fast and reliable
4 sequential `fill` commands executed quickly. playwright-cli resolved each to the correct `getByRole('textbox', { name: '...' })` selector. No issues with field focus or input type.

### Positive: Table parsing is excellent
Snapshot captures full table structure with semantic roles:
```
row "Test User test@playwright.cli Delete person from db"
  cell "Test User"
  cell "test@playwright.cli"
  cell "Delete person from db"
    button "Delete person from db"
```
This is highly parseable — an AI agent can easily extract row data, find specific records, and target actions within rows.

### Positive: Row-scoped selector generation
For deleting a specific user from the table, playwright-cli generated:
```js
page.getByRole('row', { name: 'Test User test@playwright.cli' })
    .getByLabel('Delete person from db').click()
```
This is excellent — scopes the delete to the correct row by content, not brittle index.

### Observation: Stale DOM content persists
After validation failure, the snapshot still showed "Data saved to DB" from the previous successful submit. The message is CSS-hidden (opacity: 0) but present in DOM. Same pattern as Yellow or Blue — snapshot doesn't distinguish visible from hidden content.

### Observation: Refs stable through fill sequence
Unlike Sorted List where refs went stale after fill, here the "Save to db" button ref (`e41`) survived all 4 fill operations. Ref stability may depend on whether React re-renders the parent component — fills that only update controlled input state may not trigger full re-render.
