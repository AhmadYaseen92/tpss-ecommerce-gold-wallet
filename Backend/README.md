# Backend (.NET 9 Clean Architecture)

## Solution projects

- `TPSS.GoldWallet.Api` (**Executable API project**)  
- `TPSS.GoldWallet.Application` (**Class Library**)  
- `TPSS.GoldWallet.Domain` (**Class Library**)  
- `TPSS.GoldWallet.Infrastructure` (**Class Library**)

All are real projects inside `TPSS.GoldWallet.sln`, so in Visual Studio you can right-click each project and use **Build / Rebuild / Clean / Publish**.

## Build commands

Run from repository root:

```powershell
dotnet clean Backend/TPSS.GoldWallet.sln
dotnet build Backend/TPSS.GoldWallet.sln -c Debug
```

## Windows SQL Server (SSMS) — create DB + migrate + run

### 1) Create database in SSMS

```sql
IF DB_ID(N'GoldWalletDb') IS NULL
BEGIN
    CREATE DATABASE [GoldWalletDb];
END
GO
```

(also in `Backend/scripts/sqlserver-create-db.sql`)

### 2) Run migration + API

Run from repository root (recommended):

```powershell
./Backend/scripts/windows-sqlserver-migrate-and-run.ps1 -Server "localhost" -Database "GoldWalletDb"
```

Or if you are inside `Backend/TPSS.GoldWallet.Api`:

```powershell
./run-sqlserver.ps1 -Server "localhost" -Database "GoldWalletDb"
```

### 3) Optional: add a migration first

```powershell
./Backend/scripts/windows-sqlserver-migrate-and-run.ps1 -Server "localhost" -Database "GoldWalletDb" -AddMigration -MigrationName "YourMigration"
```

## Important (path issue)

If your current folder is `Backend/TPSS.GoldWallet.Api`, **do not** run `cd Backend/scripts` (that path won't exist relative to API folder).  
Either:
- go back to repo root first, or
- use `./run-sqlserver.ps1` from API folder.
