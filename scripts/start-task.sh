#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# start-task.sh — FALCON-1 태스크 시작 스크립트
# 사용법: bash scripts/start-task.sh <task-name> <type>
# 예시:   bash scripts/start-task.sh perception-tool-detector feat
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -euo pipefail

TASK_NAME="${1:-}"
TASK_TYPE="${2:-feat}"

if [ -z "$TASK_NAME" ]; then
  echo "❌ 사용법: bash scripts/start-task.sh <task-name> <type>"
  echo "   type: feat | fix | harness | docs"
  exit 1
fi

BRANCH="${TASK_TYPE}/${TASK_NAME}"
PLAN_FILE="docs/exec-plans/active/${TASK_NAME}.md"
DATE=$(date '+%Y-%m-%d')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  FALCON-1 태스크 시작: ${BRANCH}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 브랜치 생성
if git show-ref --verify --quiet refs/heads/"${BRANCH}"; then
  echo "⚠️  브랜치 이미 존재: ${BRANCH} — 전환만 합니다"
  git checkout "${BRANCH}"
else
  git checkout -b "${BRANCH}"
  echo "✅ 브랜치 생성: ${BRANCH}"
fi

# 2. 실행 계획 파일 생성
mkdir -p docs/exec-plans/active
if [ -f "${PLAN_FILE}" ]; then
  echo "⚠️  실행 계획 이미 존재: ${PLAN_FILE}"
else
  cat > "${PLAN_FILE}" << EOF
# 실행 계획: ${TASK_NAME}

> 생성일: ${DATE} | 브랜치: ${BRANCH}

## 목표
<!-- 이 태스크가 해결하려는 문제를 한 줄로 -->

## 접근법
<!-- 구현 방법 요약 -->

## 단계별 계획
- [ ] 1.
- [ ] 2.
- [ ] 3.

## 완료 기준
<!-- 무엇이 통과되면 완료인가 (테스트, 동작, 검증) -->

## 제약 사항
<!-- 건드리지 말아야 할 것, 주의 사항 -->

## 예상 소요 시간
<!-- 30분 / 2시간 / 반나절 등 -->
EOF
  echo "✅ 실행 계획 생성: ${PLAN_FILE}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ 태스크 준비 완료"
echo "  브랜치: $(git branch --show-current)"
echo "  계획:   ${PLAN_FILE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  다음 단계:"
echo "  1. ${PLAN_FILE} 을 열어 계획을 작성"
echo "  2. 코드 구현"
echo "  3. bash scripts/verify-task.sh"
echo "  4. git commit -m '${TASK_TYPE}(scope): 설명'"
echo "  5. git push origin ${BRANCH}"
echo "  6. 정학님에게 PR 머지 요청"
echo ""
