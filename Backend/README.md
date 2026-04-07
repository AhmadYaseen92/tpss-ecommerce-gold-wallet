# Backend (.NET 9 Clean Architecture)

## Solution projects

- `TPSS.GoldWallet.Api` (**Executable API project**)  
- `TPSS.GoldWallet.Application` (**Class Library**)  
- `TPSS.GoldWallet.Domain` (**Class Library**)  
- `TPSS.GoldWallet.Infrastructure` (**Class Library**)

All are real projects inside `TPSS.GoldWallet.sln`, so in Visual Studio you can right-click each project and use **Build / Rebuild / Clean**.

## Windows SQL Server (SSMS) — migration flow

### 1) Create database
Run in SSMS:

```sql
IF DB_ID(N'GoldWalletDb') IS NULL
BEGIN
    CREATE DATABASE [GoldWalletDb];
END
GO
```

Or use: `Backend/scripts/sqlserver-create-db.sql`.

### 2) Run migrations + start API

```powershell
cd Backend/scripts
./windows-sqlserver-migrate-and-run.ps1 -Server "localhost" -Database "GoldWalletDb"
```

### 3) Optional: add new migration

```powershell
cd Backend/scripts
./windows-sqlserver-migrate-and-run.ps1 -Server "localhost" -Database "GoldWalletDb" -AddMigration -MigrationName "YourMigration"
```

## Alternative (bash helper)

```bash
cd Backend/scripts
./run-migrations.sh
```


## Important (Visual Studio vs VS Code)

- In **VS Code Explorer**, everything appears as folders and right-click does **not** show project actions like Clean/Build/Publish.
- To right-click projects and use **Clean / Rebuild / Publish**, open the solution in **Visual Studio 2022**:

```powershell
start Backend/TPSS.GoldWallet.sln
```

If you still see old `src` folder, run:

```powershell
cd Backend/scripts
./cleanup-legacy-layout.ps1
```
