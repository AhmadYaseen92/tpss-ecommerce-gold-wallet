#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   DB_SERVER=localhost DB_NAME=GoldWalletSystemDb ./scripts/recreate-db-and-seed.sh

DB_SERVER="${DB_SERVER:-localhost}"
DB_NAME="${DB_NAME:-GoldWalletSystemDb}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[1/3] Recreating database: ${DB_NAME} on ${DB_SERVER}"
sqlcmd -S "${DB_SERVER}" -v DbName="${DB_NAME}" -i "${ROOT_DIR}/GoldWalletSystem.Infrastructure/Database/recreate-database.sql"

echo "[2/3] Applying EF migrations"
dotnet ef database update \
  --project "${ROOT_DIR}/GoldWalletSystem.Infrastructure" \
  --startup-project "${ROOT_DIR}/GoldWalletSystem.API"

echo "[3/3] Seeding sample data"
sqlcmd -S "${DB_SERVER}" -d "${DB_NAME}" -i "${ROOT_DIR}/GoldWalletSystem.Infrastructure/Database/Seed/sample-data.sql"

echo "Done. Database recreated and seeded." 
