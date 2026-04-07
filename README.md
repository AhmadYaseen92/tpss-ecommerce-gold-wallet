# TPSS E-commerce Gold Wallet (Monorepo Layout)

## Structure
- `Frontend/Mobile`: Flutter mobile application (current app code).
- `Frontend/Web`: Reserved for future web frontend.
- `Backend`: Reserved for future backend services/APIs.

## Important
Run Flutter commands from `Frontend/Mobile` (not repository root):

```bash
cd Frontend/Mobile
flutter pub get
flutter run
```

If VS Code still shows red errors after the move:
1. Open `Frontend/Mobile` as the workspace folder, or keep repo root open and run `Flutter: Restart Analysis Server`.
2. Run `flutter clean && flutter pub get` inside `Frontend/Mobile`.
3. Delete accidental generated folders at repo root (for example root-level `android/` or `.dart_tool/`) if they appear.


## Quick cleanup (if duplicate root folders still appear)
From repository root run:

```bash
./scripts/cleanup-root-artifacts.sh
```
