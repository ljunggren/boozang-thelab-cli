# Test Case: Visual Bugs

**Target:** http://localhost:3000/visualBugs
**Mode:** Headful (`--headed`)

## Objective

Test playwright-cli's ability (or inability) to detect visual bugs — where an image's visual content doesn't match its label. This is the ultimate test of the "no visual analysis" limitation.

## The App

Image carousel of 7 African animals (zebra, cheetah, lion, giraffe, meerkat, elephant, leopard). A "city dweller" intentionally mislabeled some images. The challenge: find the mismatches.

## Test: Cycle through all 7 images

### Steps
1. For each image: snapshot (get alt text + label), screenshot, click "Next image"
2. Compare alt text vs label for each

### Actual Results — Snapshot Data

| # | img alt | Label | Match? |
|---|---------|-------|--------|
| 1 | zebra | zebra | Yes |
| 2 | cheetah | cheetah | Yes |
| 3 | lion | lion | Yes |
| 4 | giraffe | giraffe | Yes |
| 5 | meerkat | meerkat | Yes |
| 6 | elephant | elephant | Yes |
| 7 | leopard | leopard | Yes |

**All 7 match** — because both the `alt` attribute and the label text come from the same source array in the component code. They will always be identical.

### The Real Visual Bugs

The visual bugs are between what the **image file actually shows** and what the label says. For example, `cheetah.jpg` might show a leopard, or vice versa. These can only be detected by:
- A human looking at the image
- An AI with vision capabilities analyzing the screenshot
- Image classification/comparison tools

playwright-cli's snapshot data is **completely blind to visual bugs**.

## What This Tests in playwright-cli

| Capability | How It's Exercised |
|---|---|
| Image carousel cycling | "Next image" button clicks through 7 states |
| Screenshot capture | 7 screenshots taken for visual review |
| Alt text reading | img alt attributes correctly captured |
| Text label reading | Paragraph text correctly captured |

## Findings

### GAP: No visual analysis capability
**Severity: High (for visual testing use cases)**

playwright-cli cannot detect visual bugs because:
1. Snapshots only contain DOM text (alt attributes, labels, text content)
2. Images are referenced but not analyzed visually
3. No screenshot comparison or visual diff capability
4. No integration with image recognition or classification

For this component, the DOM data says "everything matches" while the visual content may have deliberate mismatches. A human in headed mode can see the bugs instantly; playwright-cli's snapshot-based approach is fundamentally blind to them.

**This is by design** — playwright-cli is a DOM interaction tool, not a visual testing tool. But it highlights a major category of bugs that cannot be caught:
- Layout/CSS regressions
- Image mismatches
- Color/styling errors
- Overlapping elements
- Responsive design breaks
- Font rendering issues

**Comparison opportunity for Boozang:** Visual bug detection, screenshot diff, and AI-powered visual analysis would be a strong differentiator. The app literally says "finding visual bugs is best left to the human" — an MCP tool with vision could challenge that assumption.

### Positive: Carousel navigation works
7 sequential "Next image" clicks cycled through all images correctly, wrapping from image 7 back to image 1. Button ref (`e36`) remained stable throughout all clicks — no stale ref issues for this simple state change.
