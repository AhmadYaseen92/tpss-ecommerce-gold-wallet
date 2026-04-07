#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/dev-up.sh"
"$SCRIPT_DIR/dev-init-db.sh" || true
"$SCRIPT_DIR/dev-run-api.sh"
