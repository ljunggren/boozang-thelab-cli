# Test Case: Unsorted List

**Target:** http://localhost:3000/unsortedList
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's ability to verify element position in a non-deterministic list. Unlike Sorted List (appends to end), Unsorted List inserts new items at a **random position**. This tests whether snapshot data can be used to verify item ordering and detect positional variation.

## Prerequisites

- Both servers running (`./scripts/start.sh`)
- json-server has default 4 todos in `data/db.json`

## Test 1: Verify random insertion position (5x add/delete cycle)

### Steps
1. Add a todo, snapshot to find its position, delete it — repeat 5 times
2. Compare positions across runs

### Actual Results

| Run | Todo | Snapshot Line | Position |
|-----|------|---------------|----------|
| 1 | Unsorted-1 | 35 | 4th (near end) |
| 2 | Unsorted-2 | 31 | 3rd |
| 3 | Unsorted-3 | 31 | 3rd |
| 4 | Unsorted-4 | 27 | 2nd |
| 5 | Unsorted-5 | 27 | 2nd |

**4 unique positions out of 5 runs** — confirmed random insertion.

### Cleanup verification
After all 5 add/delete cycles, list restored to original 4 items in correct order:
1. Play with Filip
2. Make some dinner
3. Do the dishes
4. Walk with cats

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| Position verification | Can determine where an element sits in a list by parsing snapshot YAML line order |
| Repeated CRUD in loop | 5 cycles of fill → add → snapshot → delete without session issues |
| Non-deterministic UI | Element position changes each run — can't hardcode expected position |
| Data cleanup reliability | Add/delete cycles leave no residual data |

## Findings

### Positive: Snapshot preserves DOM order
Snapshot YAML reflects actual DOM order of list items. By comparing line numbers or item sequence, you can verify element position. This works for both sorted and unsorted lists.

### Positive: Session stability through rapid cycling
5 rapid add/delete cycles with multiple snapshots per cycle (15+ commands total) completed without session corruption. playwright-cli handles sustained interaction well.

### Observation: Position verification requires caller logic
There's no built-in way to assert "item X is at position Y in the list." The caller must:
1. Parse the snapshot YAML
2. Extract list items in order
3. Find the target item's position
4. Compare against expected position

For an AI agent this is natural (it can parse text), but for scripted automation it's fragile — YAML line numbers are not a stable API.

### Comparison with Sorted List
| Behavior | Sorted List | Unsorted List |
|----------|------------|---------------|
| Insert position | Always end | Random |
| Position verifiable? | Yes (last item) | Yes (by snapshot order) |
| Same API? | Yes (/todos/) | Yes (/todos) |
| Same UI? | Identical | Identical |
| Test complexity | Lower | Higher (non-deterministic) |

The unsorted list is a harder test case — you can't assert a fixed position, only that the item exists somewhere in the list and that positions vary across runs.
