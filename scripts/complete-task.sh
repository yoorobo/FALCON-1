#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# complete-task.sh — 태스크 완료 처리 스크립트
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  FALCON-1 태스크 완료 처리${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ──────────────────────────────────────────────────
# 1. 완료된 실행 계획을 completed/로 이동
# ──────────────────────────────────────────────────
ACTIVE_DIR="docs/exec-plans/active"
COMPLETED_DIR="docs/exec-plans/completed"

ACTIVE_PLANS=$(find "$ACTIVE_DIR" -name '*.md' ! -name 'README.md' 2>/dev/null || true)

if [ -n "$ACTIVE_PLANS" ]; then
    echo -e "${BLUE}[1/3]${NC} 완료된 실행 계획 이동..."
    echo ""
    echo "  active/ 에 있는 계획 파일:"
    echo "$ACTIVE_PLANS" | while IFS= read -r plan; do
        echo "    - $(basename "$plan")"
    done
    echo ""
    read -rp "  이동할 파일을 선택하세요 (all/파일명/skip): " CHOICE

    if [ "$CHOICE" = "all" ]; then
        echo "$ACTIVE_PLANS" | while IFS= read -r plan; do
            mv "$plan" "$COMPLETED_DIR/"
            echo -e "  ${GREEN}✅ $(basename "$plan") → completed/${NC}"
        done
    elif [ "$CHOICE" = "skip" ]; then
        echo -e "  ${YELLOW}⏭️  건너뜀${NC}"
    elif [ -f "$ACTIVE_DIR/$CHOICE" ]; then
        mv "$ACTIVE_DIR/$CHOICE" "$COMPLETED_DIR/"
        echo -e "  ${GREEN}✅ $CHOICE → completed/${NC}"
    else
        echo -e "  ${YELLOW}⏭️  일치하는 파일 없음 — 건너뜀${NC}"
    fi
else
    echo -e "${BLUE}[1/3]${NC} active/ 에 이동할 계획 없음 — ${YELLOW}건너뜀${NC}"
fi

# ──────────────────────────────────────────────────
# 2. PLANS.md 최신화 알림
# ──────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[2/3]${NC} docs/PLANS.md 최신화 확인..."
echo -e "  ${YELLOW}⚠️  docs/PLANS.md 를 수동으로 업데이트해주세요.${NC}"
echo "       - 완료된 항목을 Completed 섹션으로 이동"
echo "       - 새로운 Active 항목이 있다면 추가"

# ──────────────────────────────────────────────────
# 3. 품질 점수 업데이트 알림
# ──────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[3/3]${NC} docs/QUALITY_SCORE.md 업데이트 확인..."
echo -e "  ${YELLOW}⚠️  이번 작업으로 품질 등급이 변경되었다면 업데이트해주세요.${NC}"

# ──────────────────────────────────────────────────
# 완료
# ──────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ 태스크 완료 처리 종료${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
