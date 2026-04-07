# Mobile ↔ Backend Mapping (Entities, Tables, APIs, Roles)

This document maps current Flutter mobile features/models to backend entities and API endpoints.

## Authentication & User

- Mobile model: `features/app/data/models/user_model.dart`
- Backend tables/entities:
  - `AspNetUsers` (Identity)
  - `UserProfiles`
- APIs:
  - `POST /api/auth/login`
  - `GET /api/customers/{customerId}/profile`
- Roles:
  - `Customer`, `ComplianceOfficer`, `Admin`

## Product Catalog

- Mobile model: `features/product/data/models/product_item_model.dart`
- Backend tables/entities:
  - `Products`
- APIs:
  - `GET /api/products`
- Permissions:
  - `catalog.read`

## Cart

- Mobile model: `features/cart/domain/entities/cart_item_entity.dart`
- Backend tables/entities:
  - `Carts`
  - `CartItems`
- APIs:
  - `GET /api/customers/{customerId}/cart`
  - `POST /api/customers/{customerId}/cart/items`
- Permissions:
  - `cart.read`, `cart.write`

## Wallet & Holdings

- Mobile models:
  - `features/wallet/data/models/wallet_model.dart`
  - `features/wallet/data/models/asset_model.dart`
- Backend tables/entities:
  - `WalletAccounts`
  - `WalletTransactions`
- APIs:
  - `GET /api/customers/{customerId}/wallet`
  - `POST /api/customers/{customerId}/wallet/transactions`
- Permissions:
  - `wallet.read`, `wallet.write`

## Transactions / History

- Mobile model: `features/transaction/data/models/transaction_model.dart`
- Backend tables/entities:
  - `TradeTransactions`
  - `WalletTransactions`
- APIs:
  - `GET /api/customers/{customerId}/transactions`
  - `GET /api/customers/{customerId}/history`
- Permissions:
  - `history.read`

## Account Summary / Dashboard / Home

- Mobile model: `features/account_summary/data/models/account_summary_model.dart`
- Backend tables/entities:
  - `AccountSummaries`
  - `WalletAccounts`
  - `KycVerifications`
  - `Carts`
- APIs:
  - `GET /api/customers/{customerId}/account-summary`
  - `GET /api/customers/{customerId}/dashboard`
- Permissions:
  - `dashboard.read`

## Notifications

- Mobile model: `features/notification/data/models/notification_model.dart`
- Backend tables/entities:
  - `Notifications`
- APIs:
  - `GET /api/customers/{customerId}/notifications`
- Permissions:
  - `profile.read`

## KYC & Compliance

- Mobile flow: signup/profile verification
- Backend tables/entities:
  - `KycVerifications`
- APIs:
  - `POST /api/customers/{customerId}/kyc/submit`
- Permissions:
  - `kyc.submit`

## Security / Admin Logs

- Backend tables/entities:
  - `AuditLogs`
- APIs:
  - `GET /api/admin/logs`
- Permissions:
  - `audit.read`

## Notes

- This backend is code-first with EF Core PostgreSQL provider.
- SQL bootstrap script is available at `Backend/scripts/001_init_schema.sql`.
