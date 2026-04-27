# Database seed files

This folder stores SQL seed scripts for local/dev environments.

## Files

- `seed.sql`: canonical seed entrypoint (includes `sample-data.sql`).
- `sample-data.sql`: multi-seller sample data (sellers, users, products) with empty cart items, wallet assets, and transaction history baseline.
- `../../scripts/seed-full-data.sql`: **Option 1** full seed dataset (delegates to `fresh-install-full-seed.sql`).
- `../../scripts/seed-2-sellers-1-investor-1-admin.sql`: **Option 2** minimal deterministic dataset with 2 sellers (full profile), 1 investor (full profile), 1 admin.
- `../../scripts/clear-all-data.sql`: **Option 3** clears all app data (including users/sellers/products).

## Reset + recreate + seed workflow

1. Drop and recreate DB:
   - Run `../recreate-database.sql` with `sqlcmd`.
2. Apply EF migrations from API startup project.
3. Run `seed.sql` (or `sample-data.sql` directly).

Example:

```bash
# from Backend/GoldWalletSystem
sqlcmd -S <server> -v DbName="GoldWalletSystemDb" -i GoldWalletSystem.Infrastructure/Database/recreate-database.sql

dotnet ef database update \
  --project GoldWalletSystem.Infrastructure \
  --startup-project GoldWalletSystem.API

sqlcmd -S <server> -d GoldWalletSystemDb -i GoldWalletSystem.Infrastructure/Database/Seed/seed.sql
```

## Quick seed options

```bash
# Option 1: full data
sqlcmd -S <server> -d GoldWalletSystemDb -i scripts/seed-full-data.sql

# Option 2: 2 sellers + 1 investor + 1 admin
sqlcmd -S <server> -d GoldWalletSystemDb -i scripts/seed-2-sellers-1-investor-1-admin.sql

# Option 3: system settings + fees + 1 admin + Imseeh seller + investor@goldwallet.com
sqlcmd -S <server> -d GoldWalletSystemDb -i scripts/seed-imseeh-admin-investor-full.sql

# Option 4: clear all data
sqlcmd -S <server> -d GoldWalletSystemDb -i scripts/clear-all-data.sql
```
