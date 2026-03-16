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

### E2E Tests (Playwright)

```bash
npm run test:e2e      # run Playwright tests
```

Playwright is installed but e2e tests and config are not yet set up.

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
