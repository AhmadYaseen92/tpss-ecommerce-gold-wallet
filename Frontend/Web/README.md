# Web Frontend - Gold Wallet Control Center (Vue 3 + Modern UI)

A modern web app flow similar to common SaaS dashboards:

1. Login page (remember me, register link, forgot password link).
2. Role-aware dashboard after login (Admin/Seller based on server response).
3. Top bar with welcome message, theme toggle, settings, and logout.
4. Left side menu with module navigation.

## Included modules

- Dashboard summary cards.
- Products (server list + seller management actions).
- Investors and transaction/request management.
- Invoices and inventory views.
- Fees module.
- Reports and notifications.

## Clean architecture

- `src/domain`: entities and contracts.
- `src/application`: business rules/use-cases.
- `src/infrastructure`: HTTP/API gateway and mapping.
- `src/presentation`: shell/components/composables/UI pages.
- `src/shared`: visual theme and global styles.

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
