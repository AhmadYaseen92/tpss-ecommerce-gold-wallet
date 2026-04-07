# Backend (.NET 9 Clean Architecture)

## Solution structure (projects, not nested src folders)

- `TPSS.GoldWallet.Api`
- `TPSS.GoldWallet.Application`
- `TPSS.GoldWallet.Domain`
- `TPSS.GoldWallet.Infrastructure`

All four projects now live directly under `Backend/` and are included in `TPSS.GoldWallet.sln`.

## Windows + SQL Server (no Docker) — create DB and run with migrations

### 1) Create database in SQL Server (SSMS)
Run this script in SSMS:

```sql
IF DB_ID(N'GoldWalletDb') IS NULL
BEGIN
    CREATE DATABASE [GoldWalletDb];
END
GO
```

(also available at `Backend/scripts/sqlserver-create-db.sql`)

### 2) Run migration + start API (PowerShell)

```powershell
cd Backend/scripts
./windows-sqlserver-migrate-and-run.ps1 -Server "localhost" -Database "GoldWalletDb"
```

If you use SQL login instead of Windows auth:

```powershell
cd Backend/scripts
./windows-sqlserver-migrate-and-run.ps1 -Server "localhost" -Database "GoldWalletDb" -TrustedConnection:$false -SqlUser "sa" -SqlPassword "YourPassword"
```

This script will:
1. `dotnet restore`
2. `dotnet ef database update`
3. `dotnet run`

## Manual commands (alternative)

```powershell
cd Backend/TPSS.GoldWallet.Api
$env:Database__Provider="SqlServer"
$env:ConnectionStrings__SqlServer="Server=localhost;Database=GoldWalletDb;Trusted_Connection=True;TrustServerCertificate=True;"
dotnet restore
dotnet ef database update --project ../TPSS.GoldWallet.Infrastructure --startup-project .
dotnet run
```

## Notes

- `appsettings.json` defaults to SQL Server provider.
- PostgreSQL support is still available by setting `Database:Provider = PostgreSql` and `ConnectionStrings:PostgreSql`.
- Swagger is available in development mode.
