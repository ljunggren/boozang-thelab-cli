# Test Case: Cat or Dog

**Target:** http://localhost:3000/catOrDog
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's ability to identify images via alt text in snapshots and use that information for conditional interactions. This is the image-based variant of Yellow or Blue — instead of reading text, the agent must read an image's `alt` attribute.

## Positive Test: Click the correct pet

### Steps
1. Open page in headed mode
2. Click "Generate Image" → random cat or dog image appears
3. Fresh snapshot → read `img "cat"` or `img "dog"` alt text
4. Click the matching button
5. Verify "Success!" message

### Actual Result
- "Success!" displayed correctly
- Snapshot clearly exposes image alt text: `img "cat" [ref=e81]` or `img "dog" [ref=e86]`
- Image alt text is the sole mechanism for identifying which pet was generated

## Negative Test: Click the wrong pet

### Steps
1. Click "Generate Image"
2. Fresh snapshot → read pet type
3. Click the opposite button
4. Verify "Try again!" message

### Actual Result
- "Try again!" in red — correct

## 10x Reliability Test

| Run | Pet | Result |
|-----|-----|--------|
| 1 | dog | SUCCESS |
| 2 | dog | SUCCESS |
| 3 | cat | SUCCESS |
| 4 | dog | SUCCESS |
| 5 | cat | SUCCESS |
| 6 | cat | SUCCESS |
| 7 | cat | SUCCESS |
| 8 | cat | SUCCESS |
| 9 | dog | SUCCESS |
| 10 | cat | SUCCESS |

**Results: 10/10 successes** (7 cat, 3 dog)

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| Image alt text in snapshots | Must read `img "cat"` or `img "dog"` to decide which button to click |
| Image-based conditional logic | Decision based on image content, not text — but alt text is the proxy |
| Consistent with Yellow or Blue pattern | Same generate → read → click → verify flow |

## Findings

### Positive: Alt text fully exposed in snapshots
Snapshot renders images as `img "alt-text" [ref=...]`. This is sufficient for any test that depends on image identification via alt attributes. playwright-cli does not do visual image recognition — it relies entirely on DOM attributes.

### Observation: No visual image analysis
playwright-cli cannot actually "see" the image. If the alt text were missing or wrong, it would have no way to determine cat vs dog. This is fine for well-structured apps with proper alt text, but would fail for:
- Images without alt attributes
- Canvas-rendered graphics
- CSS background images
- Apps where visual state differs from DOM state

### Note: Same stale snapshot pattern applies
As with Yellow or Blue, must take a fresh snapshot after "Generate Image" click. The inline snapshot from the click doesn't reliably reflect the re-rendered DOM.
