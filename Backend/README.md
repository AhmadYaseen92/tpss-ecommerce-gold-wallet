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
