# Web Frontend - Gold Wallet Control Center (Vue 3 + Modern UI)

A modern side-menu based control center using the same gold/brown visual language as the mobile app theme.

## Included modules

- Executive overview dashboard with key summary cards.
- Investors monitoring and status management.
- Investor transactions/requests review and approvals.
- Seller product management (view/add/update/delete).
- Seller invoice management (view/add/update/delete).
- Fees management (Delivery, Storage, Service Charge).
- Inventory / stock availability summary.
- Report cards and notifications center.
- Backend integrated auth/data sync for supported endpoints.

## Clean architecture

- `src/domain`: entities and application contracts.
- `src/application`: business rules/use-cases.
- `src/infrastructure`: HTTP/API layer and backend gateway.
- `src/presentation`: app shell, pages, and view composables.
- `src/shared`: visual theme and shared styles.

## Backend integration

Default backend URL:

- `VITE_API_BASE_URL=http://localhost:5294`

Current integrated endpoints:

- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/products/search`
- `POST /api/dashboard/by-user`
- `POST /api/logs/search` (admin)

## Run

```bash
cd Frontend/Web
npm install
npm run dev
```
