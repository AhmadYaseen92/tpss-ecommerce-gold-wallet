#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_DIR="$ROOT_DIR/src/TPSS.GoldWallet.Api"

if ! command -v dotnet >/dev/null 2>&1; then
  echo "[ERROR] dotnet SDK is required." >&2
  exit 1
fi

export ASPNETCORE_ENVIRONMENT="${ASPNETCORE_ENVIRONMENT:-Development}"
export ConnectionStrings__Default="${ConnectionStrings__Default:-Host=localhost;Port=5432;Database=gold_wallet;Username=postgres;Password=postgres}"

cd "$API_DIR"
dotnet restore
dotnet ef database update --project ../TPSS.GoldWallet.Infrastructure --startup-project .
dotnet run
