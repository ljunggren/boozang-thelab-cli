# Test Case: Tables

**Target:** http://localhost:3000/tables
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's handling of filterable data tables with custom checkboxes, pagination, and toggle interactions. 10 savannah animals, filterable by species (lions, elephants, zebras), paginated at 6 per page, with like/unlike toggle per row.

## Test 1: Verify initial table data

### Actual Results
- Table renders with header (Name, Species, Hairdo) and 6 data rows on page 1
- Snapshot captures full cell content: name, species, hairdo, image alt text
- 3 filter checkboxes all show `[checked]` state
- Arthur (unliked) renders as empty `row` in snapshot — **no cell data visible**

## Test 2: Filter — uncheck lions

### Actual Results
- After unchecking lions, only elephants and zebras shown (5 animals)
- Lions checkbox lost `[checked]` attribute — snapshot correctly reflects unchecked state
- Snapshot correctly shows filter state change

## Test 3: Empty table — uncheck all filters

### Actual Results
- All species cells disappeared — table body empty
- No error messages — clean empty state
- Re-enabling all filters restored full table

## Test 4: Pagination — next/previous

### Actual Results
- "next page" button (`ref=e96`) visible on page 1
- Click Next → page 2 shows Sally, Ruby, Charlie (remaining 3-4 animals)
- "previous page" button appeared, "next page" gone (last page)
- Click Previous → back to page 1 with original data

## Test 5: Toggle like (Oscar)

### Actual Results
- Toggle like button clicked — playwright-cli generated: `getByRole('row', { name: 'Oscar...' }).getByLabel('Toggle like')`
- **Snapshot identical before and after toggle** — like state is CSS-only (heart icon color)
- Same CSS-visibility gap as cat shelter toggle and Yellow or Blue stale DOM

## Test 6: Filter to single species (lions only)

### Actual Results
- 3 lions total: Oscar (empty row — unliked), Millie, Charlie
- Pagination not needed (under 6 items)
- Filter correctly removed non-lion rows

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| Checkbox interaction | Custom-styled checkboxes with checked state |
| Table cell parsing | Read name, species, hairdo from cells |
| Dynamic table filtering | Table updates when filters toggled |
| Pagination | Next/previous buttons, content changes per page |
| Row-scoped actions | Toggle like button within specific row |
| Checkbox state in snapshots | `[checked]` attribute visible/absent |

## Findings

### Positive: Checkbox state tracking in snapshots
Checkboxes show `[checked]` when selected, absent when not. This is reliable for filter state verification — unlike CSS-only toggles, checkbox state is a DOM attribute.

### Positive: Table cell data well-structured in snapshots
Each row exposes full structured data:
```
row "Oscar Oscar lion mohawk Toggle like"
  cell "Oscar" → img "Oscar"
  cell "Oscar"
  cell "lion"
  cell "mohawk"
  cell "Toggle like" → button "Toggle like"
```
Highly parseable for data extraction and verification.

### GAP: Unliked rows render as empty in snapshot
Arthur (the only initially-unliked animal) shows as an empty `- row` in the snapshot with no cell content. This appears to be a rendering issue where the component conditionally renders row content based on like state. An agent cannot read data about unliked items from the snapshot — it's effectively invisible.

This is different from the CSS-opacity gap. Here the content actually appears different in the DOM (possibly empty row), making it impossible to identify which animal it is without toggling it first.

### GAP reinforced: Toggle state invisible
Like/unlike toggle changes heart icon color via CSS class — identical in snapshot before and after. Same pattern as cat shelter foundHome toggle. Any CSS-only state change remains undetectable.

### Positive: Pagination buttons correctly conditional
"next page" only shows on non-last pages, "previous page" only on non-first pages. Snapshot correctly reflects which buttons are present, making it easy to detect page boundaries.
