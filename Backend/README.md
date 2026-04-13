# Backend

This folder contains backend services and APIs.

## GoldWalletSystem database migrations

From the solution directory:

```bash
cd Backend/GoldWalletSystem
```

Apply migrations:

```bash
dotnet ef database update --project GoldWalletSystem.Infrastructure --startup-project GoldWalletSystem.API
```

Create a new migration:

```bash
dotnet ef migrations add <MigrationName> --project GoldWalletSystem.Infrastructure --startup-project GoldWalletSystem.API
```

If you see `PendingModelChangesWarning`, verify that the latest migration and
`AppDbContextModelSnapshot` both include the same model updates before rerunning
`dotnet ef database update`.

## Troubleshooting: `There is already an object named 'MobileAppConfigurations'`

If your database already exists and you run an initial migration that contains full `CreateTable(...)` calls,
SQL Server will fail with duplicate-object errors (for example `MobileAppConfigurations`).

Use one of these approaches:

1. **Baseline-first migration strategy (recommended for existing DBs):**
   - create a baseline migration for the current DB state (empty `Up/Down`),
   - then add a new migration for only the delta columns.
2. **Run idempotent upgrade SQL** for this profile/payment/bank update (adds missing columns and payment-detail tables):

```sql
:r Backend/GoldWalletSystem/scripts/upgrade-profile-payment-bank-fields.sql
```

The script is safe to run multiple times and only adds missing columns.

## Troubleshooting: seller/profile schema not created

If `dotnet ef database update` reports success but `Sellers` table and seller/profile columns are still missing,
you likely applied an **empty migration** locally (for example `AddSellerTable`) that advanced history without DDL.

Run these checks in SQL Server:

```sql
SELECT [MigrationId], [ProductVersion] FROM [__EFMigrationsHistory] ORDER BY [MigrationId];
SELECT OBJECT_ID('Sellers') AS SellersTableId;
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='UserProfiles' AND COLUMN_NAME IN ('DocumentType','IdNumber','ProfilePhotoUrl');
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Users' AND COLUMN_NAME='SellerId';
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Products' AND COLUMN_NAME='SellerId';
```

Then apply migrations again from `Backend/GoldWalletSystem`:

```bash
dotnet ef database update --project GoldWalletSystem.Infrastructure --startup-project GoldWalletSystem.API
```

This repo includes a repair migration (`EnsureSellerAndProfileColumns`) that creates missing seller/profile schema
idempotently for drifted environments.

If your DB is already drifted and you need an immediate fix, run the emergency SQL script in SSMS:

```sql
:r Backend/GoldWalletSystem/scripts/fix-missing-seller-schema.sql
```

(Or copy/paste script contents from `Backend/GoldWalletSystem/scripts/fix-missing-seller-schema.sql`.)


## Integration architecture

For full mobile feature coverage and required sample-data fields, see:

- `Backend/GoldWalletSystem/docs/mobile-backend-integration-map.md`
