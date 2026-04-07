#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker is required." >&2
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  DCMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  DCMD=(docker-compose)
else
  echo "[ERROR] docker compose is required (docker compose or docker-compose)." >&2
  exit 1
fi

"${DCMD[@]}" -f "$SCRIPT_DIR/docker-compose.postgres.yml" up -d

echo "[INFO] Waiting for postgres to become healthy..."
for _ in {1..40}; do
  health=$(docker inspect --format='{{json .State.Health.Status}}' tpss_goldwallet_postgres 2>/dev/null || true)
  if [[ "$health" == '"healthy"' ]]; then
    echo "[OK] postgres is healthy on localhost:5432"
    exit 0
  fi
  sleep 2
 done

echo "[ERROR] postgres container did not become healthy in time." >&2
exit 1
