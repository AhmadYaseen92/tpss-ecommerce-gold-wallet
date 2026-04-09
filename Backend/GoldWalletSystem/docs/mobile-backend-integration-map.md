# Mobile ↔ Backend Integration Map

This document defines which backend APIs should power each major mobile feature,
and which database entities/fields must be populated when manually seeding sample data.

## 1) Authentication & profile

- `POST /api/auth/login`
- `POST /api/auth/register`
- `GET /api/auth/ping`
- `POST /api/profile/by-user`

Required entities/fields:
- `Users`: `Id`, `Email`, `PasswordHash`, `Role`, `SellerId`, `IsActive`
- `UserProfiles`: `UserId`, `Nationality`, `DocumentType`, `IdNumber`, `ProfilePhotoUrl`, `PreferredLanguage`, `PreferredTheme`
- `Sellers`: `Id`, `Name`, `Code`, `IsActive`

## 2) Product list/catalog

- `POST /api/products/search`

Required entities/fields:
- `Products`: `Id`, `Name`, `Sku`, `Description`, `Price`, `AvailableStock`, `SellerId`, `IsActive`
- `Sellers`: rows referenced by `Products.SellerId`

## 3) Wallet sections/assets

- `POST /api/wallet/by-user`
- `POST /api/dashboard/by-user` (summary counts and balances)

Required entities/fields:
- `Wallets`: `UserId`, `CashBalance`, `CurrencyCode`
- `WalletAssets`: `WalletId`, `AssetType`, `Weight`, `Unit`, `Purity`, `Quantity`, `AverageBuyPrice`, `CurrentMarketPrice`

## 4) Cart and actions

- `POST /api/cart/by-user`
- `POST /api/cart/items`

Required entities/fields:
- `Carts`: `UserId`
- `CartItems`: `CartId`, `ProductId`, `Quantity`, `UnitPrice`, `LineTotal`
- `Products`: `SellerId` must match the logged-in user's seller scope

## 5) Transactions history & invoices

- `POST /api/transaction-history/search`
- `POST /api/invoices/search`
- `POST /api/invoices/create`

Required entities/fields:
- `TransactionHistories`: `UserId`, `TransactionType`, `Amount`, `Currency`, `Reference`, `CreatedAtUtc`
- `Invoices`: `InvestorUserId`, `SellerUserId`, `InvoiceNumber`, `SubTotal`, `TaxAmount`, `TotalAmount`, `Status`
- `InvoiceItems`: `InvoiceId`, `ProductId`, `Quantity`, `UnitPrice`, `LineTotal`

## 6) Notifications

- `POST /api/notifications/search`
- `PUT /api/notifications/read`

Required entities/fields:
- `AppNotifications`: `UserId`, `Title`, `Body`, `IsRead`, `CreatedAtUtc`

## Seller scoping rules

- User session carries `seller_id` claim.
- Product listing is filtered by seller.
- Cart item addition validates product belongs to current seller scope.
- User-level APIs are still protected by user ownership checks (`UserId` in token must match request except admin).
