#!/usr/bin/env bash
set -euo pipefail

# Remove accidental Flutter project/artifacts created at repository root.
# Safety: never delete files that are tracked by git.

CANDIDATES=(
  .dart_tool
  .android
  android
  ios
  linux
  macos
  windows
  web
  lib
  test
  assets
  .metadata
  analysis_options.yaml
  devtools_options.yaml
  pubspec.yaml
  pubspec.lock
  .gradle
  .flutter-plugins
  .flutter-plugins-dependencies
  .packages
  .pub
  build
)

removed_any=false
for path in "${CANDIDATES[@]}"; do
  [[ -e "$path" ]] || continue

  # If path (or files under path) is tracked, skip.
  if git ls-files --error-unmatch "$path" >/dev/null 2>&1 || git ls-files "$path/*" | grep -q .; then
    echo "⚠️  Skipped tracked path: $path"
    continue
  fi

  rm -rf "$path"
  echo "🗑️  Removed: $path"
  removed_any=true
done

if [[ "$removed_any" == false ]]; then
  echo "✅ No removable accidental root artifacts were found."
else
  echo "✅ Cleanup complete."
fi

# Rebuild Dart package config for the real mobile app so package: imports resolve in IDE.
if [[ -d "Frontend/Mobile" ]]; then
  if command -v flutter >/dev/null 2>&1; then
    echo "🔄 Running 'flutter pub get' in Frontend/Mobile ..."
    (cd Frontend/Mobile && flutter pub get)
    echo "✅ Mobile dependencies refreshed."
  else
    echo "⚠️  Flutter SDK not found in PATH. Run manually: cd Frontend/Mobile && flutter pub get"
  fi
fi
