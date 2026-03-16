# TheLab Improvements

TheLab's purpose is to be a **realistic test automation challenge** — an app that behaves like real-world software with all its messiness. Improvements should make the app **harder to automate**, not easier. The goal is to expose tool weaknesses and differentiate strong tools from weak ones.

**Design principle:** If every tool can automate it easily, it's not a useful test bed.

---

## Make It Harder (represent real-world pain)

### 1. Remove some `data-testid` attributes
Real apps don't have test IDs on everything. Remove test IDs from:
- Result messages — force tools to find "Success!" by text content
- Some buttons — force tools to use text, role, or position
- Keep test IDs only where a real developer would add them (form inputs, major actions)

**Why:** Tools that only work with test IDs are brittle in the real world. TheLab should test whether a tool can cope without them.

### 2. Add realistic API delays
Inject 500-3000ms random latency on json-server responses:
- Cat shelter list: slow load with visible spinner
- Form submit: 1-2s delay before success message
- Todo add/delete: variable latency

**Why:** This is how real apps behave. Fast local json-server gives tools a free pass on timing. Real latency exposes wait-for-element failures, race conditions, and flaky tests.

### 3. Add dynamic IDs and classes
Generate random suffixes on IDs and classes on each page load:
- `id="btn-puma-a7x3"` instead of `id="small"`
- `class="form_btn_9f2k"` instead of `class="form_btn"`

**Why:** Real apps with CSS-in-JS, build hashes, and dynamic frameworks produce unstable selectors. Tools must cope with changing IDs.

### 4. Add animations and transitions that block interaction
- Fade-in forms that aren't clickable during the transition
- Slide-in panels that overlap content temporarily
- Loading overlays that intercept clicks (we accidentally found this with the menu)

**Why:** The menu overlay timeout was one of the most interesting findings. Real apps are full of overlapping elements, loading spinners that block clicks, and animations that make elements temporarily unreachable.

### 5. Add iframes
Embed one component inside an iframe (e.g., the cat shelter form in an iframe on a parent page).

**Why:** Iframes are one of the hardest patterns for test automation. Context switching between frames is a common failure point.

### 6. Add shadow DOM components
Wrap some UI elements in web components with shadow DOM.

**Why:** Shadow DOM hides elements from normal CSS selectors and many automation tools. Only tools with proper shadow DOM support can reach inside.

### 7. Add race conditions
Two buttons that trigger overlapping async operations:
- "Save" and "Delete" on the same record — what happens if both fire?
- Rapid double-click on "Add todo" — does it add twice?

**Why:** Race conditions are real. Tools that can't control timing will produce inconsistent results.

### 8. Add conditional rendering based on viewport
Show/hide elements based on screen size — not just CSS hiding, actual conditional rendering (element absent from DOM on mobile, present on desktop).

**Why:** Responsive conditional rendering means the same page has different DOM structures at different viewports. Tools must handle this.

---

## Make It Messier (real apps aren't clean)

### 9. Add inconsistent element patterns
Mix up how similar things are built:
- Some delete buttons use `<button>`, others use `<a>`
- Some lists use `<ul>/<li>`, others use `<div>` soup
- Some forms use `<form>` with submit, others use `<div>` with click handlers

**Why:** Real codebases have inconsistency across components built by different developers at different times. Tools must handle structural variety.

### 10. Add stale DOM elements
Keep old elements in the DOM but hidden (not removed):
- Previous result messages stay in DOM with `display: none`
- Old list items marked as deleted but still present with `aria-hidden`
- Multiple forms on the page, only one active

**Why:** Many React/SPA apps accumulate stale DOM. Tools that count elements or find "the first match" can target the wrong one.

### 11. Add error states with partial data
- API returns 500 mid-list-load (3 of 6 cats loaded)
- Form submit succeeds on server but response times out on client
- Optimistic UI update that gets rolled back

**Why:** Real apps fail in messy ways. Tools should be tested against partial failure, not just clean success/failure.

### 12. Add third-party widgets
- Cookie consent banner that overlays content on first visit
- Chat widget in bottom-right corner
- Toast notifications that appear/disappear unpredictably

**Why:** Real apps have third-party overlays that interfere with automation. The cookie banner alone breaks many test suites.

---

## Add Missing Challenge Categories

### 13. Add authentication flow
Login page with username/password → session cookie → protected routes → logout.

**Why:** Auth is the first thing any real test suite must handle. Session management, cookies, and protected routes are fundamental.

### 14. Add file upload and download
- Cat shelter: upload cat photo
- Export data: download CSV of all cats/users

**Why:** File upload/download are standard patterns that many tools handle poorly.

### 15. Add keyboard-only navigation
Ensure the full app is navigable by Tab/Enter/Escape. Add keyboard shortcuts (e.g., `Ctrl+S` to save).

**Why:** Accessibility automation and keyboard testing are increasingly important. Tools should be tested on `press`, `keydown`, `keyup`.

### 16. Add multi-step wizard
A 3-step form: Step 1 (personal info) → Step 2 (preferences) → Step 3 (confirm & submit). Back/Next navigation. State persists across steps.

**Why:** Multi-step flows with forward/backward navigation and state management are common in SaaS. Tests must handle partial progress and step validation.

---

## Keep As-Is (already good challenges)

These existing components already work well as test challenges — don't simplify them:

| Component | Why It's Good |
|-----------|--------------|
| Speed Game | Non-deterministic timing, conditional rendering |
| Wait Game | Precise timing measurement |
| Yellow or Blue | Random state that forces conditional logic |
| Cat or Dog | Image-based decisions (tool must read alt text) |
| Visual Bugs | Fundamentally untestable by DOM-only tools |
| Scramble Items | Attribute mutation stress test |
| Unsorted List | Non-deterministic position |
| Tables (unliked empty row) | The "bug" is actually a great challenge — keep it |

---

## Summary

| # | Change | Difficulty for tools | Effort |
|---|--------|---------------------|--------|
| 1 | Remove some test IDs | Higher | Low |
| 2 | Add API delays | Much higher | Low |
| 3 | Dynamic IDs/classes | Much higher | Medium |
| 4 | Blocking animations | Higher | Medium |
| 5 | Iframes | Much higher | Medium |
| 6 | Shadow DOM | Much higher | Medium |
| 7 | Race conditions | Much higher | Medium |
| 8 | Viewport conditional rendering | Higher | Medium |
| 9 | Inconsistent element patterns | Higher | Low |
| 10 | Stale DOM elements | Higher | Low |
| 11 | Error states with partial data | Much higher | Medium |
| 12 | Third-party widgets | Higher | Low |
| 13 | Authentication flow | Higher | Medium |
| 14 | File upload/download | Higher | Low |
| 15 | Keyboard navigation | Higher | Low |
| 16 | Multi-step wizard | Higher | Medium |

The best test bed is one where **weak tools fail and strong tools shine**. Every improvement should widen that gap.
