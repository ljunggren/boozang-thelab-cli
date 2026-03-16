#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

found=0
for pidfile in "$SCRIPT_DIR"/*.pid; do
  [ -f "$pidfile" ] || continue
  found=1
  name="$(basename "$pidfile" .pid)"
  pid="$(cat "$pidfile")"
  if kill -0 "$pid" 2>/dev/null; then
    echo "$name (PID $pid) — running"
  else
    echo "$name (PID $pid) — not running (stale PID file)"
  fi
done

if [ "$found" -eq 0 ]; then
  echo "No services tracked (no PID files found)"
fi
