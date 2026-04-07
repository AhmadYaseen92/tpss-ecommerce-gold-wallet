#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../TPSS.GoldWallet.Api"

dotnet ef migrations add InitialCreate --project ../TPSS.GoldWallet.Infrastructure --startup-project . --output-dir Persistence/Migrations

dotnet ef database update --project ../TPSS.GoldWallet.Infrastructure --startup-project .
