# TPSS Gold Wallet Mobile

Flutter mobile client for the TPSS ecommerce gold wallet platform.

## Backend connection (local network)

This app now uses **Dio + Retrofit + GetIt** for auth APIs.

Default backend URL is configured for your local machine/network setup:

- `http://192.168.1.2:5095/api`

You can override it at runtime without code changes:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.2:5095/api
```

> Keep your phone/emulator and backend machine on the same Wi-Fi/LAN.

## Generate Retrofit/JSON code

Run these commands whenever API models/services change:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Auth endpoints used

- `POST /auth/login`
- `POST /auth/register`

If your backend currently exposes only login, keep login flow enabled and add `/auth/register` in backend before testing signup.
