# Backend (.NET Clean Architecture)

This backend is implemented as a clean architecture .NET solution with four projects:

- `TPSS.GoldWallet.Domain` (Core): entities and value objects only (POCO).
- `TPSS.GoldWallet.Application` (Use Cases): CQRS handlers with MediatR, validation, and interfaces.
- `TPSS.GoldWallet.Infrastructure`: EF Core persistence + repository implementations.
- `TPSS.GoldWallet.Api` (Presentation): ASP.NET Core Web API endpoints.

## API endpoints

- `GET /api/products` - returns catalog items for frontend list screens.
- `GET /api/customers/{customerId}/cart` - returns the customer cart.
- `POST /api/customers/{customerId}/cart/items` - adds item to cart.

## Run locally

```bash
cd Backend/src/TPSS.GoldWallet.Api
dotnet restore
dotnet run
```

Swagger is available in development mode.
