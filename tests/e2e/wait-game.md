# Test Case: Wait Game

**Target:** http://localhost:3000/waitGame
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's ability to handle timed interactions and verify dynamic result messages (success vs failure). Unlike SpeedGame, the "End Game" button appears immediately — the challenge is precise timing control.

## Prerequisites

- Both servers running (`./scripts/start.sh`)
- playwright-cli installed

## Positive Test: Wait 5+ seconds (success path)

```bash
# 1. Open Wait Game in headed mode
playwright-cli open http://localhost:3000/waitGame --headed

# 2. Snapshot — verify Start Game button
playwright-cli snapshot

# 3. Screenshot initial state
playwright-cli screenshot --filename=tests/e2e/screenshots/wait-game-initial.png

# 4. Click "Start Game"
playwright-cli click <start-button-ref>

# 5. Snapshot — verify "End Game" button appeared immediately
playwright-cli snapshot

# 6. Wait 5+ seconds (must be >= 5000ms for success)
# sleep 6

# 7. Click "End Game"
playwright-cli click <end-button-ref>

# 8. Snapshot — verify success message
playwright-cli snapshot
playwright-cli screenshot --filename=tests/e2e/screenshots/wait-game-success.png
```

### Actual Result
- Green "Success!" message
- Sub-message: "19964 ms above 5 seconds" — **should have been ~1000ms**. The ~14s excess is pure CLI overhead (snapshot, click round-trips). This confirms the timing overhead gap.

## Negative Test: Click too early (failure path)

```bash
# 1. Reload page
playwright-cli goto http://localhost:3000/waitGame

# 2. Click "Start Game"
playwright-cli click <start-button-ref>

# 3. Click "End Game" immediately (< 5000ms)
playwright-cli click <end-button-ref>

# 4. Snapshot — verify failure message
playwright-cli snapshot
playwright-cli screenshot --filename=tests/e2e/screenshots/wait-game-failure.png
```

### Actual Result
- Red "Try again!" message displayed — correct
- No sub-message — correct
- Chained `click start && click end` worked — commands executed back-to-back with ~1s between them

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| Precise timing control | Can playwright-cli reliably wait a specific duration between actions? |
| Result verification | Can snapshot capture and differentiate success vs failure messages? |
| Conditional styling | Can snapshot detect success (green) vs failure (red) styling? |
| Immediate element appearance | "End Game" renders instantly after start — no wait needed (contrast with SpeedGame) |
| Page reload mid-session | `goto` same URL to reset state between test runs |

## Key Challenges for playwright-cli

1. **No sleep/wait command:** playwright-cli has no built-in delay command. Must rely on shell `sleep` between CLI calls. This is a gap — precise timing control should be a primitive for a test tool.
2. **Styling detection:** Can `snapshot` capture color/class differences between success and failure states?
3. **Timing accuracy:** Shell sleep + CLI overhead may add unpredictable ms, making precise timing tests unreliable.
