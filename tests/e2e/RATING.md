# playwright-cli Competitive Rating

**Based on:** 12 test cases across TheLab app, covering timing, conditional logic, forms, CRUD, tables, visual bugs, DOM mutations, and data extraction.

---

## Overall Rating: 6.5 / 10

Solid DOM interaction tool for AI agents. Strong text-based workflows, weak on anything visual or time-sensitive.

---

## Category Ratings

### Core Interaction (8/10)
| Strength | Detail |
|----------|--------|
| `click` | Reliable, smart selector generation |
| `fill` | Works across text, email, password, textarea |
| `snapshot` | Clean YAML, parseable, good element refs |
| `screenshot` | Works, captures full viewport |
| Checkbox/radio | State tracked via `[checked]` attribute |
| Navigation | Multi-page, redirects, `goto` — all seamless |

**Why not higher:** Every interaction requires a snapshot round-trip. No pipelining.

---

### Selector Quality (9/10)
| Strength | Detail |
|----------|--------|
| Row-scoped selectors | `getByRole('row', { name: '...' }).getByLabel('...')` |
| Test-id preference | Resolves to `getByTestId()` when available |
| Aria-label awareness | Uses accessible names for targeting |
| Content-based scoping | Filters by text content within parent |

**Best-in-class.** This is playwright-cli's standout feature.

---

### Error Handling & Recovery (8/10)
| Strength | Detail |
|----------|--------|
| Fail-fast on missing refs | Immediate, no hang |
| Clear error messages | "Ref X not found... Try capturing new snapshot" |
| Element interception detail | Names exact blocking element and subtree |
| Session resilience | Survives multiple errors without corruption |

**Why not higher:** Errors are CLI-only — no visual feedback in headed mode.

---

### Data Extraction (7/10)
| Strength | Detail |
|----------|--------|
| Text content | Paragraph, heading, cell text all exposed |
| Image alt text | `img "cat"` clearly shown |
| Table structure | Full row/cell/header hierarchy |
| Form values | Input values shown in snapshot |

| Weakness | Detail |
|----------|--------|
| No `getText` command | Must parse YAML manually |
| No `getValue` command | Same — caller does all extraction |
| HTML id/class hidden | Not exposed in snapshot YAML |
| Inline styles hidden | Position, color, etc. not captured |

---

### Timing & Waiting (3/10)
| Weakness | Detail |
|----------|--------|
| No wait-for-element | Must poll with snapshot — slow, fragile |
| No sleep/delay command | Relies on shell `sleep` |
| Massive overhead per command | Each CLI call adds 1-2s+ latency |
| Speed Game: 16180ms | Should have been ~3000ms |
| Wait Game: 19964ms over 5s | Should have been ~1000ms |

**This is the biggest weakness.** Any timing-sensitive app is untestable with meaningful precision.

---

### Visual Awareness (2/10)
| Weakness | Detail |
|----------|--------|
| No image analysis | Can't see what images actually show |
| CSS state invisible | opacity, visibility, color — all undetectable |
| Toggle state blind | CSS class changes (liked, foundHome) invisible |
| Inline styles hidden | Position, layout changes invisible |
| No screenshot diff | Can take screenshots but can't compare them |
| No visual regression | Zero capability |

**Only gets 2 (not 0) because:** Screenshots exist and can be analyzed externally. Alt text is exposed.

---

### Stale State Management (4/10)
| Weakness | Detail |
|----------|--------|
| Inline snapshot after click is stale | Pre-render DOM, not post-render |
| Refs invalidated by fill | Any state-changing command can break refs |
| Must snapshot after every interaction | Doubles round-trips |
| Yellow or Blue: 0/10 without fresh snapshot | 10/10 with it |

**The caller must learn the workaround** (always snapshot after state changes) or face silent failures.

---

### Test Lifecycle (2/10)
| Weakness | Detail |
|----------|--------|
| No assertions | No `assert`, `expect`, `verify` |
| No test runner | No pass/fail, no reporting |
| No fixtures/teardown | Caller manages all setup/cleanup |
| No data reset | API data cleanup is manual |
| No test grouping | No suites, no tags |

**By design** — playwright-cli is a browser control tool, not a test framework. But this means significant integration work for any real test workflow.

---

## Strengths Summary (what Boozang should respect)

1. **Selector generation is excellent** — context-aware, accessible, resilient
2. **Error messages are AI-optimized** — parseable, actionable, detailed
3. **Session stability is solid** — handles errors, rapid cycling, multi-page flows
4. **Snapshot YAML is clean** — compact, hierarchical, low-token-cost for AI agents
5. **Test-id and aria integration** — first-class support for well-structured apps

## Weaknesses Summary (where Boozang can differentiate)

1. **Timing is broken** — no wait primitives, massive CLI overhead
2. **Visually blind** — CSS state, images, layout all invisible
3. **Stale snapshots are a trap** — looks fresh but isn't after state changes
4. **No test lifecycle** — no assertions, no fixtures, no reporting
5. **HTML attributes hidden** — id/class changes undetectable
6. **Round-trip heavy** — every interaction needs 2 commands (act + snapshot)

---

## Strategic Implications for Boozang MCP

### Compete on:
- Timing precision (in-browser execution, no CLI overhead)
- Visual intelligence (AI vision, screenshot diff, CSS state awareness)
- Wait primitives (auto-wait, explicit wait, element appearance)
- Test lifecycle (assertions, fixtures, reporting)
- Single-command interactions (act + verify in one call)

### Don't compete on:
- Selector generation (playwright-cli is very good here)
- Basic DOM interaction (click, fill, navigate — both will be fine)
- AI-agent token efficiency (their YAML snapshot is well-designed)

### Integrate where:
- Use Playwright under the hood for browser control (don't reinvent)
- Add Boozang value on top: visual layer, timing, assertions, lifecycle
