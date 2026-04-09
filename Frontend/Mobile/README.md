# TPSS Gold Wallet Mobile

Flutter mobile client for the TPSS ecommerce gold wallet platform.

## Backend connection (local network)

This app uses **Dio + Retrofit + GetIt** for auth APIs.

### Global Base URL variable

The global API base URL is defined in:

- `lib/core/constants/api_config.dart`

Default value:

- `http://192.168.1.2:5095/api`

You can change it in **two ways**:

1. Runtime (UI): in Login screen tap **Server Settings** and update Base URL/timeout.
2. Build/run-time:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.2:5095/api --dart-define=API_TIMEOUT_SECONDS=40
```

> Keep your phone/emulator and backend machine on the same Wi-Fi/LAN.

## How to verify server connection success

From Login screen:

1. Tap **Server Settings**.
2. Set Base URL and timeout.
3. Tap **Save & Test**.
4. If connected, you'll get a green success snackbar.

Connection check calls `/auth/login` with a test credential and treats `400/401` as **reachable server**.

## Generate Retrofit/JSON code

Run these commands whenever API models/services change:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Auth endpoints used

- `POST /auth/login`
- `POST /auth/register`

If backend currently exposes only login, signup will fail until `/auth/register` is added server-side.
