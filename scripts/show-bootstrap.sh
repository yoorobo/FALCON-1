#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MODE="${1:-short}"

case "$MODE" in
  short)
    cat "$PROJECT_ROOT/docs/agent-protocol/bootstrap-short.txt"
    ;;
  long)
    cat "$PROJECT_ROOT/docs/agent-protocol/bootstrap-long.txt"
    ;;
  *)
    echo "Usage: bash scripts/show-bootstrap.sh [short|long]" >&2
    exit 1
    ;;
esac
