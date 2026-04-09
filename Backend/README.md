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
