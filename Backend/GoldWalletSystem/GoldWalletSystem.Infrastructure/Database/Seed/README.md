# Database seed files

This folder stores SQL seed scripts for local/dev environments.

## Files

- `sample-data.sql`: multi-seller sample data (sellers, users, products) with empty cart items, wallet assets, and transaction history baseline.

## Reset + recreate + seed workflow

1. Drop and recreate DB:
   - Run `../recreate-database.sql` with `sqlcmd`.
2. Apply EF migrations from API startup project.
3. Run `sample-data.sql`.

Example:

```bash
# from Backend/GoldWalletSystem
sqlcmd -S <server> -v DbName="GoldWalletSystemDb" -i GoldWalletSystem.Infrastructure/Database/recreate-database.sql

dotnet ef database update \
  --project GoldWalletSystem.Infrastructure \
  --startup-project GoldWalletSystem.API

sqlcmd -S <server> -d GoldWalletSystemDb -i GoldWalletSystem.Infrastructure/Database/Seed/sample-data.sql
```
