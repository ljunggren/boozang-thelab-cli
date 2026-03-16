# Test Case: Concatenate Strings

**Target:** http://localhost:3000/concatStrings
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's ability to extract data from the page, manipulate it (concatenate), and use it in a subsequent interaction. This is a core test automation pattern: read → transform → act → verify.

## Test 1: Positive — read strings, concatenate, submit

### Steps
1. Click "Generate strings" → two random animal names appear
2. Snapshot → read both strings from paragraphs
3. Concatenate them
4. Fill the input with the concatenated result
5. Click "Submit string"
6. Verify "Success!" message

### Actual Results
- Strings "lion" and "elephant" generated
- Snapshot clearly shows both as `paragraph` text
- Filled "lionelephant", submitted → "Success!"

## Test 2: Negative — submit wrong string

### Actual Results
- Filled "wrong answer", submitted → "Try again!" in red

## 10x Reliability Test

| Run | String 1 | String 2 | Concatenated | Result |
|-----|----------|----------|-------------|--------|
| 1 | cow | horse | cowhorse | SUCCESS |
| 2 | cow | lion | cowlion | SUCCESS |
| 3 | cow | bunny | cowbunny | SUCCESS |
| 4 | bird | cow | birdcow | SUCCESS |
| 5 | tiger | horse | tigerhorse | SUCCESS |
| 6 | bear | cow | bearcow | SUCCESS |
| 7 | bird | elephant | birdelephant | SUCCESS |
| 8 | bunny | bunny | bunnybunny | SUCCESS |
| 9 | bear | elephant | bearelephant | SUCCESS |
| 10 | turtle | lion | turtlelion | SUCCESS |

**Results: 10/10 successes**

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| Data extraction from snapshot | Read two random strings from paragraph elements |
| Data manipulation by caller | Concatenate strings (done in shell script, not playwright-cli) |
| Fill with computed value | Input the concatenated result |
| Verification | Check success/failure message |

## Findings

### Positive: Read-transform-act pattern works reliably
This is the strongest demonstration of playwright-cli's data extraction capability. The full pipeline — read random data → transform → type result → verify — worked 10/10. The snapshot YAML is clean enough for programmatic parsing.

### Positive: Stable refs across generate cycles
The "Generate strings" button (`e31`) and "Submit string" button (`e38`) retained their refs across all 10 cycles. Unlike Yellow or Blue where refs changed on each generate, this component's structure stays stable. The only new refs are the two string paragraphs.

### Observation: Data extraction is the caller's job
playwright-cli provides the raw snapshot data but has no `extract`, `getText`, or `getValue` command. The caller (shell script, AI agent) must:
1. Parse the YAML snapshot
2. Find the relevant elements
3. Extract text content
4. Perform the transformation

This works but adds complexity. A built-in `getText <ref>` command would simplify the most common data extraction pattern.

### This is playwright-cli's sweet spot
No timing issues, no visual analysis needed, no CSS state concerns — just DOM text extraction and form interaction. When the task is purely text-based read-and-act, playwright-cli performs well.
