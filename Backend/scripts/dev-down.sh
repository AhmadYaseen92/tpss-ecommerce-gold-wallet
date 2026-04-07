#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if docker compose version >/dev/null 2>&1; then
  docker compose -f "$SCRIPT_DIR/docker-compose.postgres.yml" down
elif command -v docker-compose >/dev/null 2>&1; then
  docker-compose -f "$SCRIPT_DIR/docker-compose.postgres.yml" down
else
  echo "[ERROR] docker compose not found." >&2
  exit 1
fi
