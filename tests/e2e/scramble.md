# Test Case: Scramble Items & Multi Scramble

**Target:** http://localhost:3000/scramble, http://localhost:3000/multiScramble
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's resilience when DOM attributes, content, order, and positions change dynamically. These components deliberately break common selector strategies (id, class, text content, DOM position).

---

## Scramble Items (`/scramble`)

### Initial State
- Two buttons: "puma" (id=small, class=blue) and "tiger" (id=big, class=pink_dark)
- Code display shows raw HTML attributes
- 5 scramble controls: Swap Id, Swap Class, Swap Content, Random Position, Swap DOM Order

### Test 1: Swap Id

**Result:** Button text unchanged in snapshot ("puma", "tiger"). Id swap only visible in the code display paragraph:
- Before: `id="small"` on puma, `id="big"` on tiger
- After: `id="big"` on puma, `id="small"` on tiger

**Finding:** Snapshot doesn't expose HTML id or class attributes on elements. The only way to verify id/class swaps is through the code display text, which is specific to this app's UI. In a real app, id/class changes would be **completely invisible** to playwright-cli snapshots.

### Test 2: Swap Content

**Result:** Button text swapped — button 1 now shows "tiger", button 2 shows "puma". Refs changed (new elements rendered). Snapshot correctly tracks the content swap since button text is visible in the YAML.

### Test 3: Swap DOM Order

**Result:** Button order reversed in snapshot. Code display order also swapped. Refs changed again. Snapshot correctly reflects DOM order changes.

### Test 4: Random Position

**Result:** Buttons repositioned via inline CSS styles. Snapshot shows **identical button entries** before and after — positions are invisible (inline styles not captured). Only screenshots can verify position changes.

### Test 5: Click button after scrambling

**Result:** Button clickable by ref after all scrambles. Code display should show `clicked_class` highlight, but this CSS class is not visible in snapshot.

## Multi Scramble (`/multiScramble`)

### Initial State
- 6 buttons: Add Koala/Kangaroo/Dolphin, Delete Koala/Kangaroo/Dolphin
- 2 text inputs to change "Add" and "Delete" wording

### Test 6: Change "Add" to "Create"

**Result:** All 3 Add buttons became "Create Koala/Kangaroo/Dolphin". Snapshot correctly shows new button text. Refs changed for renamed buttons. Delete button refs stayed the same (unchanged).

### Test 7: Change "Delete" to "Remove"

**Result:** All 3 Delete buttons became "Remove Koala/Kangaroo/Dolphin". Snapshot correctly reflects both renamed sets.

### Test 8: Click renamed button

**Result:** First attempt failed — **menu overlay intercepted pointer events** (Timeout 5000ms). The sidebar menu had opened (possibly triggered by fill interaction) and was blocking buttons.

Error message was very detailed and helpful:
```
<ul class="sub_list">…</ul> from <div class="menu_section">…</div> subtree intercepts pointer events
```

After closing menu, click succeeded. playwright-cli resolved the ref to `getByTestId('add-koala')` — using test-id is more resilient than text-based selectors since test-ids survive label changes.

---

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| Id/class attribute visibility | Swap Id/Class — invisible in snapshot |
| Content change tracking | Swap Content — visible, refs update |
| DOM order detection | Swap DOM Order — reflected in snapshot order |
| CSS position detection | Random Position — invisible in snapshot |
| Dynamic label changes | MultiScramble rename — correctly tracked |
| Element interception handling | Menu overlay blocked click — good error |
| Test-id resilience | Buttons targetable by data-testid after rename |

## Findings

### GAP: HTML attributes (id, class) invisible in snapshots
**Severity: Medium**

Snapshots don't expose HTML id or class attributes. Only element role, text content, and aria attributes are shown. This means:
- Id-based selector changes are undetectable
- Class-based state changes (active, selected, disabled-by-class) are invisible
- Only content/text changes and checked/aria state changes are trackable

### GAP reinforced: Inline styles/positions invisible
CSS positions from inline styles are not captured in snapshots. `Random Position` moves buttons visually but the snapshot is identical before and after.

### Positive: Content changes correctly tracked
When button text changes (Swap Content, MultiScramble rename), snapshot immediately reflects the new text. Refs update for re-rendered elements. This is the most reliable form of state tracking.

### Positive: Excellent element interception errors
The menu overlay timeout produced a highly detailed error identifying exactly which element was intercepting and from which DOM subtree. An AI agent can easily diagnose and resolve this (close menu, retry).

### Positive: Test-id resilience
playwright-cli resolved `ref=e78` to `getByTestId('add-koala')` rather than text-based selectors. data-testid attributes survive label changes, making them the most robust targeting strategy.
