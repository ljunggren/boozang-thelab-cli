# Scripts

Shell scripts for managing the development environment. PID files are written to this directory for process tracking.

## Usage

```bash
./scripts/start.sh    # Start all services
./scripts/stop.sh     # Stop all services
./scripts/status.sh   # Check service status
```

## Services

| Script | Service | Port |
|--------|---------|------|
| start.sh | React dev server | 3000 |
| start.sh | json-server (data/db.json) | 9000 |

## PID Files

Each running service writes a `.pid` file to this directory:

- `react-dev.pid` — React development server
- `json-server.pid` — json-server API

PID files are gitignored and cleaned up by `stop.sh`.
