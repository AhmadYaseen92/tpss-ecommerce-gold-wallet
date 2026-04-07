# Backend (.NET 9 Clean Architecture, JWT, RBAC, KYC, Audit)

## Projects

- `TPSS.GoldWallet.Domain`: Core entities and business rules (POCO only).
- `TPSS.GoldWallet.Application`: Use-cases (CQRS + MediatR), DTOs, repository abstractions, permission constants.
- `TPSS.GoldWallet.Infrastructure`: EF Core + PostgreSQL, Identity, JWT token service, repository implementations.
- `TPSS.GoldWallet.Api`: HTTP entrypoint with JWT authentication and permission-based authorization policies.

## Covered screens/features

The backend now includes endpoints and use-cases for:

- Catalog / product listing
- Cart
- Wallet
- Dashboard
- Profile
- History
- KYC submission
- Admin audit logs
- Authentication (JWT login)
- Role + permissions access control

## Security model

- ASP.NET Core Identity with hardened password + lockout options
- JWT bearer tokens
- Role-based accounts (`Customer`, `ComplianceOfficer`, `Admin`)
- Permission-based API policies (claim: `permission`)
- Audit log table + write hooks for security-sensitive operations

## Database (PostgreSQL, code-first)

- EF Core configured with PostgreSQL provider in Infrastructure.
- `AppDbContext` defines entities/relations/indexes.
- SQL bootstrap script: `Backend/scripts/001_init_schema.sql`.
- EF migration helper script: `Backend/scripts/run-migrations.sh`.

## Run locally

```bash
cd Backend/src/TPSS.GoldWallet.Api
dotnet restore
dotnet run
```

## Migration commands

```bash
cd Backend/scripts
./run-migrations.sh
```

## Default seeded admin

- Email: `admin@goldwallet.local`
- Password: `Admin#12345Secure`

> Change both for non-local environments.


## Mobile feature mapping

- See `Backend/docs/mobile-backend-mapping.md` for detailed mapping between Flutter mobile models and backend entities/APIs/roles.
