# Backend (.NET 9 Clean Architecture, JWT, RBAC, KYC, Audit)

## Projects

- `TPSS.GoldWallet.Domain`: Core entities and POCO models.
- `TPSS.GoldWallet.Application`: Use-cases (CQRS + MediatR), DTOs, abstractions, permissions.
- `TPSS.GoldWallet.Infrastructure`: EF Core + PostgreSQL, Identity, JWT, repository implementations.
- `TPSS.GoldWallet.Api`: REST API entrypoint.

## Quick start (create DB + run app)

### Option A: One command bootstrap

```bash
cd Backend/scripts
./dev-bootstrap.sh
```

This will:
1. start PostgreSQL in Docker,
2. apply SQL schema,
3. run EF migrations,
4. start the API.

### Option B: Step by step

```bash
cd Backend/scripts
./dev-up.sh
./dev-init-db.sh
./dev-run-api.sh
```

### Stop DB container

```bash
cd Backend/scripts
./dev-down.sh
```

## Script reference

- `docker-compose.postgres.yml`: local PostgreSQL service (port `5432`).
- `dev-up.sh`: starts DB container and waits for health.
- `dev-init-db.sh`: applies SQL schema (`001_init_schema.sql`) via `psql`.
- `dev-run-api.sh`: restores, migrates, and runs ASP.NET API.
- `dev-bootstrap.sh`: full flow in one command.
- `run-migrations.sh`: explicit EF migration generation + database update.

## API coverage

- Auth (`/api/auth/login`)
- Products/catalog
- Cart
- Wallet
- Dashboard
- Account summary
- Profile
- History + transactions
- Notifications
- KYC
- Admin logs

## Security model

- ASP.NET Core Identity with password + lockout rules
- JWT bearer authentication
- Role-based identities (`Customer`, `ComplianceOfficer`, `Admin`)
- Permission-based API authorization policies
- Audit logs for sensitive actions

## DB + mobile mapping docs

- DB SQL init: `Backend/scripts/001_init_schema.sql`
- Mobile/backend mapping: `Backend/docs/mobile-backend-mapping.md`
