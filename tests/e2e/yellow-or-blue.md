# Test Case: Yellow or Blue

**Target:** http://localhost:3000/yellowOrBlue
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's ability to read dynamic text content from the DOM and use it to make conditional decisions (click the correct button based on generated color). This probes whether an AI agent can use snapshot data to drive logic.

## Prerequisites

- Both servers running (`./scripts/start.sh`)
- playwright-cli installed

## Positive Test: Click the correct color

```bash
# 1. Open page in headed mode
playwright-cli open http://localhost:3000/yellowOrBlue --headed

# 2. Snapshot — get refs
playwright-cli snapshot

# 3. Click "Generate Color"
playwright-cli click <generate-button-ref>

# 4. Snapshot — read which color was generated, get button refs
playwright-cli snapshot
# Look for text "yellow" or "blue" in the output section
# Then click the matching color button

# 5. Click the correct color button
playwright-cli click <matching-color-ref>

# 6. Snapshot — verify "Success!" message
playwright-cli snapshot
```

### Actual Result
- "Success!" message displayed — correct
- Snapshot clearly shows generated color as heading text (`heading "yellow" [level=5]`) — easy to parse programmatically
- Color buttons correctly rendered only after Generate Color clicked

## Negative Test: Click the wrong color

```bash
# 1. Click "Generate Color" again (resets state)
playwright-cli click <generate-button-ref>

# 2. Snapshot — read generated color
playwright-cli snapshot

# 3. Click the WRONG color button
playwright-cli click <wrong-color-ref>

# 4. Snapshot — verify "Try again!" message
playwright-cli snapshot
```

### Actual Result
- "Try again!" in red — correct
- State reset via Generate Color worked without page reload
- Interesting: snapshot after Generate Color still showed previous "Success!" text (stale result message visible in DOM until new interaction clears it via CSS opacity, not removal)

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| Reading dynamic text from snapshot | Must parse generated color from snapshot to decide which button to click |
| Conditional interaction logic | Correct button depends on runtime state — not hardcoded |
| Conditional element rendering | Color buttons only appear after "Generate Color" is clicked |
| Result message differentiation | Success vs failure messages with different styling |
| State reset mid-session | "Generate Color" resets the game without page reload |

## Key Challenge for playwright-cli

The core challenge is **read-then-act**: the agent must read the snapshot to discover which color was generated, then click the corresponding button. This is trivial for a human looking at the headed browser, but tests whether snapshot output contains enough information for programmatic decision-making.

## Findings

### Positive: Snapshot is sufficient for conditional logic
The generated color appears as plain text in the snapshot (`heading "yellow"` or `heading "blue"`). An AI agent can trivially parse this and decide which button to click. The ref-based targeting then works cleanly. This is the **happy path for playwright-cli** — no timing, no waiting, just read-and-act.

### Observation: Stale DOM content in snapshots
After clicking "Generate Color" to reset, the previous result message ("Success!") was still visible in the snapshot. The app hides it via CSS opacity transition, but the DOM element persists. Snapshot captures DOM structure, not visual state — so "hidden" elements still appear. This could confuse an AI agent that reads "Success!" from a previous round and assumes the current action succeeded.

### GAP: No visual state awareness in snapshots
**Severity: Medium**

Snapshots show DOM structure but not CSS computed state (opacity, visibility, display). An element with `opacity: 0` appears identical in the snapshot to one with `opacity: 1`. For apps that use CSS transitions to show/hide content (very common), this means snapshot data can be misleading.

**Comparison opportunity for Boozang:** If Boozang's MCP tool can distinguish visually hidden vs visible elements, that's a reliability advantage for AI agents.

### GAP: Inline snapshot after click can be stale
**Severity: High**

When `click` returns, it includes an auto-generated snapshot. But for React apps (and any framework with async re-renders), this inline snapshot may reflect the **pre-render** DOM — not the post-click state. In the 10x loop test:
- First attempt: Used inline snapshot from `click "Generate Color"` — 0/10 because color buttons weren't in the snapshot yet
- Fixed: Added explicit `snapshot` after each click — 10/10

This means the caller must always take a **separate snapshot** after any click that triggers a state change, adding an extra round-trip per interaction. The inline snapshot is misleading — it looks like fresh data but isn't.

**Comparison opportunity for Boozang:** An MCP tool that waits for framework re-render to complete before returning snapshot data would eliminate this entire class of bugs.

## 10x Reliability Test

Ran the positive test (generate color → read → click correct → verify) 10 times:

| Attempt | Without fresh snapshot | With fresh snapshot |
|---|---|---|
| Results | 0/10 | **10/10** |
| Issue | Inline snapshot stale after React re-render | Explicit snapshot captures updated DOM |

Color distribution across 10 runs: 5 yellow, 5 blue (randomness working correctly).
