# Web Frontend - Gold Wallet Control Center (Vue 3 + Modern UI)

A modern web app flow similar to common SaaS dashboards:

1. Login page (remember me, register link, forgot password link).
2. Role-aware dashboard after login (Admin/Seller based on server response).
3. Compact modern top bar with icon+text actions (notifications, theme, settings, logout).
4. Left side menu focused only on module navigation (no active role selector).

## Included modules

- Dashboard summary cards.
- Products management (auto ID, unique SKU validation, category/weight dropdowns, active toggle, image upload, details view, add/edit/delete with confirm).
- Investors and Transactions modules in side menu.
- Fees module (admin).
- Advanced reports generator (type cards, criteria filters, and CSV download).
- Top-bar notifications vertical panel and settings -> change-password form panel (ESC/close supported).

## Clean architecture

- `src/domain`: entities and contracts.
- `src/application`: business rules/use-cases.
- `src/infrastructure`: HTTP/API gateway and mapping.
- `src/presentation`: shell/components/composables/UI pages.
- `src/shared`: visual theme and global styles.

## Backend integration

Default backend URL:

- `VITE_API_BASE_URL=http://localhost:5095`

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
