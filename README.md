# TheLab CLI

Interactive web app for learning and practicing test automation. Built with React, designed as a clean target for Playwright end-to-end testing.

![Screenshot](/src/assets/screenshot.jpg?raw=true "Screenshot")

## Quick Start

```bash
npm install
./scripts/start.sh     # starts React dev server (port 3000) + json-server (port 9000)
./scripts/status.sh    # check running services
./scripts/stop.sh      # stop all services
```

## Architecture

- **Frontend:** React 18 with React Router v5, SCSS, Bootstrap 4
- **Backend:** json-server serving `data/db.json` on port 9000
- **Proxy:** React dev server proxies API requests to json-server

### API Endpoints (json-server)

| Endpoint | Description |
|----------|-------------|
| `/todos` | Todo items (CRUD) |
| `/cats` | Cat shelter entries (CRUD) |
| `/users` | User accounts (CRUD) |

### App Routes

| Route | Description |
|-------|-------------|
| `/` | Home page |
| `/introduction` | Introduction |
| `/overview` | Overview |
| `/catshelter` | Cat shelter listing |
| `/addcat` | Add a new cat |
| `/cats/:cat_id` | Cat details |
| `/formFill` | User form with validation |
| `/sortedList` | Sorted list |
| `/unsortedList` | Unsorted list |
| `/tables` | Data tables |
| `/speedGame` | Reaction time game |
| `/waitGame` | Wait timing game |
| `/visualBugs` | Visual bug detection |
| `/yellowOrBlue` | Color matching |
| `/catOrDog` | Image identification |
| `/scramble` | DOM scramble |
| `/multiScramble` | Multiple DOM scramble |
| `/concatStrings` | String concatenation |
| `/kittenCollect` | Kitten collection game |
| `/canvasGame` | Canvas-based game |

## Testing

### Unit Tests (Jest + React Testing Library)

```bash
npm test              # watch mode
npm run test:coverage # coverage report
```

11 unit test files covering components in `src/components/*/__test__/`.

### playwright-cli Evaluation

This repo was used to evaluate [microsoft/playwright-cli](https://github.com/microsoft/playwright-cli) as part of Boozang's MCP strategy research. Results are in `tests/e2e/`:

| Document | Description |
|----------|-------------|
| [RATING.md](tests/e2e/RATING.md) | Overall rating: 6.5/10 with category breakdowns |
| [SESSION-REPORT.md](tests/e2e/SESSION-REPORT.md) | Full session metrics, token usage, effectiveness analysis |
| [NOTES.md](tests/e2e/NOTES.md) | Detailed findings — gaps, strengths, learnings per test |
| [THELAB-IMPROVEMENTS.md](tests/e2e/THELAB-IMPROVEMENTS.md) | Recommendations for improving TheLab as a test target |

**12 test cases** covering all major routes with 33 screenshots:

| Test Case | Route | Key Finding |
|-----------|-------|-------------|
| [Speed Game](tests/e2e/speed-game.md) | `/speedGame` | No wait-for-element, 16s overhead |
| [Wait Game](tests/e2e/wait-game.md) | `/waitGame` | 20s timing overhead on 6s test |
| [Yellow or Blue](tests/e2e/yellow-or-blue.md) | `/yellowOrBlue` | Stale snapshots: 0/10 → 10/10 after fix |
| [Cat or Dog](tests/e2e/cat-or-dog.md) | `/catOrDog` | Image alt text works, no visual analysis |
| [Sorted List](tests/e2e/sorted-list.md) | `/sortedList` | CRUD + smart selectors, max limit works |
| [Unsorted List](tests/e2e/unsorted-list.md) | `/unsortedList` | Random position verified across 5 runs |
| [Form Fill](tests/e2e/form-fill.md) | `/formFill` | Multi-field fill, validation, table parsing |
| [Cat Shelter](tests/e2e/cat-shelter.md) | `/catshelter` | Multi-page CRUD, toggle state invisible |
| [Tables](tests/e2e/tables.md) | `/tables` | Filters, pagination, checkbox state |
| [Visual Bugs](tests/e2e/visual-bugs.md) | `/visualBugs` | Completely blind to visual content |
| [Scramble](tests/e2e/scramble.md) | `/scramble` | HTML id/class invisible in snapshots |
| [Concat Strings](tests/e2e/concat-strings.md) | `/concatStrings` | 10/10 read-transform-act reliability |

## Scripts

See [scripts/README.md](scripts/README.md) for details on the process management scripts.

## Built With

- React 18
- React Router 5
- SCSS / Bootstrap 4
- json-server
- Jest + React Testing Library
- Playwright (e2e)

## Original Author

- **Karin Ljunggren** - [karinlj](https://github.com/karinlj)

## License

MIT License - see [LICENSE.md](LICENSE.md) for details.
