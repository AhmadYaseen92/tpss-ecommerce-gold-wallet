#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../TPSS.GoldWallet.Api"

export Database__Provider="SqlServer"
export ConnectionStrings__SqlServer="${ConnectionStrings__SqlServer:-Server=localhost;Database=GoldWalletDb;Trusted_Connection=True;TrustServerCertificate=True;}"

dotnet ef migrations add InitialCreate --project ../TPSS.GoldWallet.Infrastructure --startup-project . --output-dir Persistence/Migrations

dotnet ef database update --project ../TPSS.GoldWallet.Infrastructure --startup-project .
