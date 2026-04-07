#!/usr/bin/env bash
set -euo pipefail

# Remove accidental artifacts created when Flutter/Android commands are run at repo root.
rm -rf \
  .dart_tool \
  .android \
  android \
  .gradle \
  .flutter-plugins \
  .flutter-plugins-dependencies \
  .packages \
  .pub \
  build

echo "✅ Removed accidental root-level Flutter/Android artifacts (if present)."
