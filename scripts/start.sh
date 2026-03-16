#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Start json-server
cd "$PROJECT_DIR"
npx json-server --watch data/db.json --port 9000 &
echo $! > "$SCRIPT_DIR/json-server.pid"
echo "json-server started (PID $(cat "$SCRIPT_DIR/json-server.pid")) on port 9000"

# Start React dev server
npx react-scripts start &
echo $! > "$SCRIPT_DIR/react-dev.pid"
echo "react-dev started (PID $(cat "$SCRIPT_DIR/react-dev.pid")) on port 3000"
