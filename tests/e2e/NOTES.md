# playwright-cli Test Authoring Notes

## Setup

```bash
npm install -g @playwright/cli@latest
playwright-cli install --skills
```

## Headful Mode (use for all authoring)

Always use `--headed` when authoring tests — you need to see what the CLI sees:

```bash
playwright-cli open http://localhost:3000 --headed
```

## Workflow Pattern

1. `open <url> --headed` — launch browser
2. `snapshot` — get element refs (compact, token-efficient)
3. `click`/`fill`/`select` using refs from snapshot
4. `snapshot` again after interaction to get updated refs
5. `screenshot` at key checkpoints for visual verification

## Key Learnings

### Ref-based targeting
playwright-cli uses `ref` identifiers from `snapshot` output, not CSS selectors or XPath. Always snapshot before interacting.

### Auto-resolved selectors
playwright-cli auto-resolves refs to Playwright selectors. In the Speed Game test, `click e32` became `getByTestId('startBtn')` and `click e76` became `getByTestId('endBtn')`. This means the app's `data-testid` attributes are being picked up — good for stable selectors.

### GAP: No wait-for-element primitive
**Severity: High** — This is the biggest gap found so far.

playwright-cli has no `waitForSelector`, `waitForVisible`, or equivalent command. When an element appears after a delay (like SpeedGame's "End Game" button), the only option is:
1. Sleep for an arbitrary duration
2. Run `snapshot` and hope the element is there
3. Repeat if not

**Impact on Speed Game test:** The game measures reaction time in ms. Our test reported **16180ms** because we had to `sleep 3` then `snapshot` before we could even discover the "End Game" button's ref. The actual game delay was ~1-10s, but the polling overhead added seconds on top.

**Why this matters:** Any app with async rendering, loading spinners, conditional UI, or animation-gated interactions will hit this. Playwright (the library) has excellent auto-waiting built in — `page.click()` waits for the element automatically. But playwright-cli exposes no equivalent. This forces the caller into a manual poll loop, which is:
- Slow (sleep granularity adds latency)
- Fragile (too short = miss the element, too long = wasted time)
- Token-expensive (each snapshot poll is a full round-trip)

**Recommendation:** playwright-cli needs a `wait <selector|ref-pattern> [--timeout=ms]` command or auto-wait semantics on `click`/`fill` that block until the target element exists.

### Positive: Error handling and session resilience
Negative testing on the Speed Game revealed solid error behavior:
- **Fails fast** — no hang or timeout when clicking a missing element
- **Clear error messages** — `"Ref X not found in the current page snapshot. Try capturing new snapshot."` is specific and actionable
- **Session survives errors** — 3 consecutive failed clicks didn't corrupt the session; snapshot/click continued to work after
- **Stale ref detection** — refs from a previous DOM state are correctly rejected, not silently resolved to wrong elements

This is well-designed for AI agent consumers — errors are parseable, recoverable, and don't require session restart. However, the error message hints at the gap: it suggests "try capturing new snapshot" rather than offering a wait/retry primitive. The burden is entirely on the caller to implement polling.

### GAP: Headed mode gives no visual error feedback
**Severity: Medium**

When a command fails (e.g. clicking a non-existent element), the error is only reported in the CLI terminal output. The headed browser window shows nothing — no overlay, no highlight, no console message. The browser just sits unchanged.

**Impact:** During test authoring, you're watching a browser that gives zero feedback on failures. You have to context-switch back to the terminal to see what went wrong. For an AI agent this doesn't matter (it reads CLI output), but for a human authoring tests in headed mode, this is a poor experience.

**Comparison opportunity for Boozang:** Visual error feedback in the browser during test authoring (highlights, overlays, step indicators) would be a clear UX differentiator.

### GAP: Massive timing overhead on every command
**Severity: High**

Every playwright-cli command (snapshot, click, screenshot) adds significant latency. This makes timing-sensitive tests wildly inaccurate:

- **Speed Game:** Reported 16180ms "reaction time" — actual game delay was ~3s, the rest was CLI overhead
- **Wait Game:** `sleep 6` + click produced "19964 ms above 5 seconds" — should have been ~1000ms above. That's ~14 seconds of CLI/snapshot overhead accumulated across the session.

**Root cause:** Each CLI invocation is a separate process that must connect to the browser, execute, and return. There is no pipelining, no batching, and no built-in `sleep`/`delay` command. Shell `sleep` is the only timing mechanism, but the overhead of the surrounding commands is unpredictable and large.

**Impact:** playwright-cli cannot reliably test anything time-sensitive. A tool that adds 10-20s of overhead per test flow cannot produce meaningful timing measurements. This is not a minor gap — it fundamentally limits the types of applications that can be accurately tested.

**No built-in sleep/delay command:** playwright-cli has no `wait <ms>` or `sleep <ms>` primitive. You must use shell `sleep`, which doesn't account for CLI overhead before/after. A proper delay command that runs inside the browser context would be essential for timing tests.

**Comparison opportunity for Boozang:** Tight timing control, in-browser command execution, and pipelined actions would be major differentiators for any app with timing-dependent behavior.

### Confirmed: Any state-changing command invalidates refs
Originally discovered with `click` in Yellow or Blue, now confirmed with `fill` in Sorted List. After filling a text input, the "Add todo" button ref became stale. This means **every** state-changing command (click, fill, select, type) can invalidate the entire ref set. The caller must snapshot after every interaction — doubling the number of round-trips.

### Positive: Smart selector generation
playwright-cli generates high-quality, context-aware Playwright selectors. For deleting a specific todo, it generated:
```js
page.getByRole('listitem').filter({ hasText: 'Fifth todo' }).getByLabel('Delete todo').click()
```
This scopes the action to the correct list item by content. Much better than raw CSS selectors or XPath.

### Observation: No assertion primitives or test lifecycle
playwright-cli has no `assert`, `expect`, or `verify` commands. No test fixtures, teardown, or results reporting. All verification and cleanup is the caller's responsibility. For API-backed apps, this means the caller must also handle data cleanup (delete test records).

### CSS transitions don't block snapshots
The result message uses a 0.5s CSS fade-in (`opacity: 0` → `1`). The snapshot captured the content immediately regardless of visual transition state. Screenshots may catch mid-transition if taken too fast.

### Tracing
Use `tracing-start`/`tracing-stop` to record full interaction traces for debugging and review.

### State management
`state-save`/`state-load` for checkpointing browser state — useful for CRUD test flows (cat shelter, user forms) where you want to reset between runs.

## Test Cases

| Test Case | File | Target Route | Key Challenge |
|---|---|---|---|
| Speed Game | [speed-game.md](speed-game.md) | `/speedGame` | Timing, conditional rendering, dynamic content |
| Wait Game | [wait-game.md](wait-game.md) | `/waitGame` | Precise timing, success/failure paths, timing overhead |
| Yellow or Blue | [yellow-or-blue.md](yellow-or-blue.md) | `/yellowOrBlue` | Conditional logic, read-then-act, stale DOM in snapshots |
| Cat or Dog | [cat-or-dog.md](cat-or-dog.md) | `/catOrDog` | Image alt text reading, visual content limitations |
| Sorted List | [sorted-list.md](sorted-list.md) | `/sortedList` | CRUD, fill, list order, max limit, API interaction |
| Unsorted List | [unsorted-list.md](unsorted-list.md) | `/unsortedList` | Random insertion position, non-deterministic verification |

## TheLab Routes Worth Testing

Priority routes for exercising playwright-cli capabilities:

- `/speedGame` — timing, conditional DOM (done)
- `/formFill` — form fill, validation, CRUD via API
- `/catshelter` → `/addcat` — navigation, form submission, list verification
- `/scramble` — DOM mutations, element reordering
- `/canvasGame` — canvas interactions (mouse events)
- `/visualBugs` — screenshot comparison potential
- `/yellowOrBlue` — conditional rendering, rapid state changes
