# Backend (.NET 9 Clean Architecture)

## If your terminal is already inside `Backend/`

Use these exact commands:

```powershell
# from D:\TPSS\tpss-ecommerce-gold-wallet\Backend
./build.ps1
./run-sqlserver.ps1 -Server "localhost" -Database "GoldWalletDb"
```

This avoids all path mistakes.

## Solution projects

- `TPSS.GoldWallet.Api` (**Executable API project**)  
- `TPSS.GoldWallet.Application` (**Class Library**)  
- `TPSS.GoldWallet.Domain` (**Class Library**)  
- `TPSS.GoldWallet.Infrastructure` (**Class Library**)

All are real projects inside `TPSS.GoldWallet.sln`, so in Visual Studio you can right-click each project and use **Build / Rebuild / Clean / Publish**.

## Alternative commands by location

### From repository root (`.../tpss-ecommerce-gold-wallet`)

```powershell
dotnet clean Backend/TPSS.GoldWallet.sln
dotnet build Backend/TPSS.GoldWallet.sln -c Debug
./Backend/scripts/windows-sqlserver-migrate-and-run.ps1 -Server "localhost" -Database "GoldWalletDb"
```

### From `Backend/`

```powershell
dotnet clean TPSS.GoldWallet.sln
dotnet build TPSS.GoldWallet.sln -c Debug
./scripts/windows-sqlserver-migrate-and-run.ps1 -Server "localhost" -Database "GoldWalletDb"
```

### From `Backend/TPSS.GoldWallet.Api`

```powershell
./run-sqlserver.ps1 -Server "localhost" -Database "GoldWalletDb"
```

## Create DB in SSMS

```sql
IF DB_ID(N'GoldWalletDb') IS NULL
BEGIN
    CREATE DATABASE [GoldWalletDb];
END
GO
```

(also in `Backend/scripts/sqlserver-create-db.sql`)
