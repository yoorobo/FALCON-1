#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# doc-gardening.sh — 오래된 문서 자동 정리 스크립트
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 매주 실행 권장: 30일 이상 수정되지 않은 문서를 감지하여 알림
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

STALE_DAYS=30

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  FALCON-1 문서 가비지 컬렉션${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ──────────────────────────────────────────────────
# 1. 장기 방치된 active 실행 계획
# ──────────────────────────────────────────────────
echo -e "${BLUE}[1/3]${NC} active/ 에서 ${STALE_DAYS}일 이상 된 실행 계획 검색..."

STALE_ACTIVE=$(find docs/exec-plans/active -name '*.md' ! -name 'README.md' -mtime +${STALE_DAYS} 2>/dev/null || true)

if [ -n "$STALE_ACTIVE" ]; then
    echo -e "  ${YELLOW}⚠️  장기 방치된 계획 발견:${NC}"
    echo "$STALE_ACTIVE" | while IFS= read -r file; do
        DAYS_OLD=$(( ($(date +%s) - $(stat -c %Y "$file")) / 86400 ))
        echo -e "    ${YELLOW}• $(basename "$file") — ${DAYS_OLD}일 전 수정${NC}"
    done
    echo ""
    echo "  → completed/로 이동하거나 삭제를 검토하세요."
else
    echo -e "  ${GREEN}✅ 장기 방치된 계획 없음${NC}"
fi

# ──────────────────────────────────────────────────
# 2. 오래된 문서 감지 (docs/ 전체)
# ──────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[2/3]${NC} docs/ 에서 ${STALE_DAYS}일 이상 수정되지 않은 문서..."

STALE_DOCS=$(find docs/ -name '*.md' -mtime +${STALE_DAYS} \
    ! -path 'docs/exec-plans/completed/*' \
    ! -path 'docs/references/*' \
    2>/dev/null || true)

if [ -n "$STALE_DOCS" ]; then
    STALE_COUNT=$(echo "$STALE_DOCS" | wc -l)
    echo -e "  ${YELLOW}⚠️  ${STALE_COUNT}개 문서가 ${STALE_DAYS}일 이상 수정되지 않음:${NC}"
    echo "$STALE_DOCS" | while IFS= read -r file; do
        DAYS_OLD=$(( ($(date +%s) - $(stat -c %Y "$file")) / 86400 ))
        echo -e "    ${YELLOW}• ${file} — ${DAYS_OLD}일${NC}"
    done
    echo ""
    echo "  → 내용이 최신인지 검토하세요."
else
    echo -e "  ${GREEN}✅ 모든 문서가 최신 상태${NC}"
fi

# ──────────────────────────────────────────────────
# 3. 500줄 초과 파일 감지
# ──────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[3/3]${NC} 500줄 초과 소스 파일 검사..."

OVERSIZED=0
while IFS= read -r file; do
    [ -z "$file" ] && continue
    LINES=$(wc -l < "$file")
    if [ "$LINES" -gt 500 ]; then
        echo -e "  ${YELLOW}⚠️  ${file} — ${LINES}줄${NC}"
        OVERSIZED=1
    fi
done < <(find src/ -path src/openarm_ros2 -prune -o -path docs/references -prune -o \( -name '*.py' -o -name '*.cpp' -o -name '*.hpp' \) -print 2>/dev/null || true)

if [ "$OVERSIZED" -eq 0 ]; then
    echo -e "  ${GREEN}✅ 500줄 초과 파일 없음${NC}"
fi

# ──────────────────────────────────────────────────
# 완료
# ──────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ 문서 가비지 컬렉션 완료${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
