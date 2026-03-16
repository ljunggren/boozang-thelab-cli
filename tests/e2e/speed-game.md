# Test Case: Speed Game

**Target:** http://localhost:3000/speedGame
**Mode:** Headful (`--headed`) — required for visual verification during authoring

## Objective

Exercise playwright-cli's ability to handle timing-dependent UI, conditional element appearance, and dynamic content — all in a single game flow.

## Prerequisites

- Both servers running (`./scripts/start.sh`)
- playwright-cli installed (`npm install -g @playwright/cli@latest`)

## Test Steps (playwright-cli commands)

```bash
# 1. Open the Speed Game page in headed mode
playwright-cli open http://localhost:3000/speedGame --headed

# 2. Take a snapshot to get element refs
playwright-cli snapshot

# 3. Verify page loaded — check for heading and Start button
playwright-cli screenshot --filename=speed-game-initial.png

# 4. Click "Start Game"
playwright-cli click <start-button-ref>

# 5. Wait for "End Game" button to appear (timing-dependent)
#    The button appears after a random 1-10s delay + countdown to 0
#    Use snapshot polling to detect the button
playwright-cli snapshot

# 6. Click "End Game" as soon as it appears
playwright-cli click <end-button-ref>

# 7. Capture the result message (reaction time in ms)
playwright-cli snapshot
playwright-cli screenshot --filename=speed-game-result.png
```

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| `open --headed` | Headful browser launch |
| `snapshot` | Capturing element refs from dynamic DOM |
| `click` | Clicking buttons by ref |
| Timing/waiting | "End Game" button appears after random delay — tests CLI's ability to handle elements that don't exist yet |
| Dynamic content | Result message with reaction time appears after game ends |
| `screenshot` | Visual capture at key checkpoints |

## Key Challenges for playwright-cli

1. **Non-deterministic timing:** The countdown delay is random (1-10s). The CLI must wait/poll for the "End Game" button rather than clicking immediately.
2. **Conditional rendering:** "End Game" button only renders when `count < 0` — it's not hidden, it's absent from the DOM.
3. **Transient result:** The result message fades in via CSS transition (0.5s ease-in). Snapshot timing matters.
4. **Two-phase interaction:** Start → wait → End is a multi-step flow with a forced pause between actions.

## Expected Observations

- Initial snapshot: heading "Speed Game", "Start Game" button visible, no "End Game" button
- After start: countdown running, no immediate DOM change visible
- After delay: "End Game" button appears in DOM
- After end: green "Success" message with reaction time in milliseconds
- Result message wrapper transitions from `opacity: 0` to `opacity: 1`

## Negative Test: Click "End Game" Before It Appears

**Objective:** Verify playwright-cli behavior when attempting to interact with an element that doesn't exist in the DOM yet.

### Steps

```bash
# 1. Open Speed Game
playwright-cli open http://localhost:3000/speedGame --headed

# 2. Snapshot — confirm only "Start Game" exists, no "End Game"
playwright-cli snapshot

# 3. Attempt to click "End Game" before starting the game
#    Expected: error — element does not exist
playwright-cli click "End Game"

# 4. Click "Start Game" to begin
playwright-cli click <start-button-ref>

# 5. Immediately try to click "End Game" (before countdown completes)
#    Expected: error — element not yet in DOM
playwright-cli click "End Game"

# 6. Snapshot to confirm "End Game" is still absent
playwright-cli snapshot
```

### What This Tests in playwright-cli

| Scenario | Expected Behavior | Actual |
|---|---|---|
| Click non-existent element by text | Clear error message | "Ref End Game not found in the current page snapshot. Try capturing new snapshot." |
| Click non-existent element by stale ref | Clear error message | "Ref e76 not found in the current page snapshot. Try capturing new snapshot." |
| Error recovery — can we continue after failed click? | Session stays open, next command works | Session survived all 3 failed clicks, snapshot worked after |
| No auto-wait on missing element | Immediate failure (no hang/timeout) | Fails fast, no hang |

### Why This Matters

- **GAP probe:** Does playwright-cli hang, timeout, or fail fast when the target doesn't exist?
- **Error messaging:** Are errors clear enough for an AI agent to understand and recover?
- **Session stability:** Does a failed interaction corrupt the session or can you keep going?
- Directly related to the missing wait-for-element primitive — this is the flip side of that gap.

## Notes for Test Authoring

- Use `--headed` throughout authoring to visually verify each step
- The `snapshot` command is the primary way to discover element refs — run it before each interaction
- Consider using `tracing-start` before the game flow and `tracing-stop` after for replay analysis
- The random delay means this test is inherently flaky if hard-coded waits are used — good stress test for playwright-cli's waiting mechanisms
