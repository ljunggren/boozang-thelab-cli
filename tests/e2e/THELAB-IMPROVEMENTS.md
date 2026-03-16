# TheLab Improvements

Recommendations for making TheLab a better test automation target, based on the playwright-cli evaluation session.

---

## High Priority

### 1. Add missing `data-testid` attributes
Some elements lack test IDs, making them harder to target reliably:
- Result messages (`Success!`, `Try again!`) — no testid on the text paragraphs
- Animal table rows and filter checkboxes
- Speed/Wait game countdown display
- Cat shelter list items and toggle buttons

**Why:** Test tools (including Boozang) benefit from stable anchors. Test IDs are the most resilient selector strategy — they survive CSS, text, and structural changes.

### 2. Fix the "empty row" bug in Tables
Arthur (unliked animal) renders as an empty `<tr>` with no cell content visible to accessibility tools. This appears to be a conditional rendering issue where unliked items get different markup.

**Why:** This creates a blind spot for any DOM-based tool. The item exists but is invisible in the accessibility tree.

### 3. Add a Canvas Game test page
`/canvasGame` exists but was not tested. Canvas is a fundamentally different rendering target — DOM-based tools can't inspect it. This is a valuable edge case.

**Why:** Canvas testing is a known gap for playwright-cli and most browser automation tools. Having a well-designed canvas test target would strengthen the evaluation.

### 4. Add explicit visual bugs to Visual Bugs
The current implementation has the image alt text and label from the same source array — they always match in the DOM. The "bugs" are only visible by looking at the actual images.

**Suggestion:** Intentionally mismatch some labels in the code:
```js
// Current: animals[index] used for both image and label
// Suggested: some labels are deliberately wrong
const labels = ["zebra", "leopard", "lion", "giraffe", "meerkat", "elephant", "cheetah"];
// Note: image 2 (cheetah.jpg) labeled "leopard", image 7 (leopard.jpg) labeled "cheetah"
```

**Why:** This would create a detectable DOM-level bug (alt text ≠ label) that tools could catch, alongside the visual-only bugs that require image recognition.

---

## Medium Priority

### 5. Add loading states with realistic delays
Most components load instantly (json-server is local, fast). Add artificial delays to simulate real API latency:
- Cat shelter: 500-2000ms load delay
- Form fill: submission delay
- Sorted/unsorted list: fetch delay with visible loading spinner

**Why:** Loading states test wait-for-element capabilities — the biggest gap we found in playwright-cli.

### 6. Add form validation beyond password length
Form Fill only validates password ≥ 6 characters. Add:
- Email format validation with error message
- Required field validation (empty submit)
- Duplicate email detection
- Password strength indicator

**Why:** Richer validation gives more negative test scenarios and tests error message detection.

### 7. Add a search/filter on Cat Shelter
The cat list is static (no search). Add a text filter that dynamically hides/shows cats by name.

**Why:** Tests real-time filtering — snapshot must capture the filtered state, not the full list.

### 8. Add confirmation dialogs
Delete operations (todos, cats, users) happen immediately without confirmation. Add `window.confirm()` dialogs.

**Why:** Dialog handling (`dialog-accept`/`dialog-dismiss`) is a playwright-cli feature we didn't test. Boozang should handle this too.

---

## Low Priority

### 9. Add dark mode toggle
A theme toggle that changes CSS variables across the entire app.

**Why:** Tests whether tools can detect theme changes (CSS custom properties). Also good for visual regression testing.

### 10. Add responsive breakpoint tests
The app uses Bootstrap responsive classes but we only tested at one viewport size.

**Why:** `resize` is a playwright-cli command we didn't exercise. Responsive layout changes are a visual testing target.

### 11. Add error boundary page
Create a route that intentionally throws a React error to test error state handling.

**Why:** Error boundaries change the entire page content. Tests whether tools can detect and recover from app crashes.

### 12. Add WebSocket or real-time updates
Add a component that receives live data (e.g., chat, notifications).

**Why:** Tests real-time DOM updates without user interaction — a different pattern from click-driven state changes.

---

## Test Infrastructure

### 13. Add Cucumber feature files for all components
Some components reference feature files (`/features/speedGame.txt`) but not all have them. Complete the set.

**Why:** BDD specs provide a natural test case structure that both humans and AI agents can follow.

### 14. Add a test data reset endpoint
json-server has no built-in reset. Add a script or endpoint that restores `data/db.json` to its original state.

**Why:** Tests that modify API data (sorted list, form fill, cat shelter) need cleanup. A reset endpoint simplifies this.

### 15. Document expected behavior per route
Each component has "What to test?" hints, but no formal expected behavior spec. Add a `SPEC.md` per component with:
- Initial state
- Valid interactions
- Expected outcomes
- Edge cases

**Why:** Makes the app useful as a test target for any tool evaluation, not just this session.
