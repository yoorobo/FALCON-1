#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "현재 브랜치:"
git branch --show-current
echo ""

echo "git status:"
git status --short --branch
echo ""

echo "최근 커밋 3개:"
git log --oneline -3
echo ""

cat "$PROJECT_ROOT/docs/agent-protocol/end-check.txt"
