# Test Case: Cat Shelter

**Target:** http://localhost:3000/catshelter, /addcat, /cats/:id
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's multi-page navigation, form handling across routes, CRUD with redirects, radio buttons, and toggle interactions. This is the most complex flow in TheLab — spanning 3 routes with create, read, update, and delete operations.

## Test 1: View cat list

### Actual Results
- 6 cats displayed (Filip, Hugo, Trulsis, Theo, Truls, Penelope)
- Each cat has a link to detail page (`/cats/{id}`) and a toggle home button
- Snapshot captures all cat names, links with URLs, and toggle buttons

## Test 2: Navigate to detail page, edit, save

### Steps
1. Click "Filip details page" link
2. Verify URL changed to `/cats/8`
3. Verify form fields: name "Filip", description "Big kind cat...", radio "outside" checked
4. Edit description
5. Click Save → redirected to `/catshelter`
6. Navigate back to Filip → verify edit persisted
7. Revert description and save

### Actual Results
- Navigation worked — URL changed to `/cats/8`
- Detail page snapshot exposed: text inputs, textarea, radio buttons with checked state
- `fill` on textarea worked for description edit
- Save triggered PUT request and redirected to `/catshelter`
- Edit persisted across navigation round-trip
- Revert and save worked cleanly

## Test 3: Add a new cat

### Steps
1. Click "Add Cat" link → navigated to `/addcat`
2. Fill name: "TestCat", description: "A test cat from playwright-cli"
3. Click radio "Wants to go outside"
4. Click "Add Cat" button
5. Verify redirected to `/catshelter` with TestCat in list

### Actual Results
- All form fields filled correctly including radio button via `click`
- POST request sent to `/cats/`
- Redirected to shelter page — TestCat appeared in list
- json-server assigned ID `D9u03uT`

## Test 4: Delete cat from detail page

### Steps
1. Click "TestCat details page" link
2. Click "Delete" button
3. Verify redirected to `/catshelter` without TestCat

### Actual Results
- Navigation to detail page worked
- Delete triggered DELETE request and redirected to shelter
- TestCat removed from list — confirmed via snapshot grep

## Test 5: Toggle foundHome status

### Steps
1. Click toggle button on Filip (foundHome: true → false)
2. Screenshot to verify visual change
3. Toggle back to restore state

### Actual Results
- Toggle button worked — PUT request fired
- Screenshot showed dimmed home icon (foundHome: false)
- **Snapshot cannot detect the toggle state change** — the button text/aria stays identical, only CSS class changes
- Toggled back to restore original state

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| Multi-page navigation | 3 routes: `/catshelter` → `/addcat` → `/cats/:id` |
| Link-based navigation | Click link, verify URL change |
| Redirect after action | Save/Delete redirect back to listing |
| Radio buttons | Click radio, verify checked state in snapshot |
| Textarea fill | Edit multi-line description |
| Full CRUD cycle | Create (POST), Read (GET), Update (PUT), Delete (DELETE) |
| Toggle interaction | Click button that changes visual state without navigation |

## Findings

### Positive: Multi-page navigation works seamlessly
playwright-cli handled all route transitions correctly. After each navigation:
- URL updated in page metadata
- Fresh snapshots reflected new page content
- Refs correctly reflected the new DOM

### Positive: Radio button state visible in snapshots
Checked radio buttons show `[checked]` attribute in snapshot:
```
radio "Wants to go outside" [checked] [ref=e140]
radio "Stay inside" [ref=e143]
```
This is sufficient for an AI agent to read current state and make decisions.

### Positive: Redirect detection
After Save/Delete, playwright-cli correctly reported the new URL in snapshot metadata. An agent can verify successful operations by checking the redirect destination.

### GAP reinforced: Toggle state invisible in snapshots
The foundHome toggle changes a CSS class (adds/removes "found"), which affects the icon color. Snapshot shows identical button text/aria before and after toggle. The only way to verify the toggle worked is:
- Screenshot comparison (visual)
- API call to check backend state
- Neither is supported natively by playwright-cli

This is the same "no visual state awareness" gap identified in Yellow or Blue, but more impactful here because the toggle is the primary interaction for this feature.
