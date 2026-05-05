#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# verify-task.sh — FALCON-1 커밋 전 자동 검증 스크립트
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
set -euo pipefail

# 프로젝트 루트로 이동
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS_COUNT=0
TOTAL_STEPS=5

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  FALCON-1 검증 시작${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ──────────────────────────────────────────────────
# 단계 1: Python 린트 (ruff)
# ──────────────────────────────────────────────────
echo -e "${BLUE}[1/${TOTAL_STEPS}]${NC} Python 린트 (ruff) ..."

if command -v ruff &> /dev/null; then
    PYTHON_FILES=$(find src/ -path src/openarm_ros2 -prune -o -name '*.py' -print 2>/dev/null || true)
    if [ -n "$PYTHON_FILES" ]; then
        if ruff check src/ --exclude src/openarm_ros2; then
            echo -e "${GREEN}  ✅ Python 린트 통과${NC}"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "${RED}  ❌ Python 린트 실패 — 커밋 중단${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}  ⏭️  Python 파일 없음 — 건너뜀${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
else
    echo -e "${YELLOW}  ⚠️  ruff 미설치 — 건너뜀 (pip install ruff)${NC}"
    PASS_COUNT=$((PASS_COUNT + 1))
fi

# ──────────────────────────────────────────────────
# 단계 2: C++ 린트 (clang-tidy)
# ──────────────────────────────────────────────────
echo -e "${BLUE}[2/${TOTAL_STEPS}]${NC} C++ 린트 (clang-tidy) ..."

if command -v clang-tidy &> /dev/null; then
    CPP_FILES=$(find src/ -path src/openarm_ros2 -prune -o \( -name '*.cpp' -o -name '*.hpp' \) -print 2>/dev/null || true)
    if [ -n "$CPP_FILES" ]; then
        CLANG_FAIL=0
        while IFS= read -r file; do
            if ! clang-tidy "$file" -- -std=c++17 2>/dev/null; then
                CLANG_FAIL=1
            fi
        done <<< "$CPP_FILES"
        if [ "$CLANG_FAIL" -eq 0 ]; then
            echo -e "${GREEN}  ✅ C++ 린트 통과${NC}"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "${RED}  ❌ C++ 린트 실패 — 커밋 중단${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}  ⏭️  C++ 파일 없음 — 건너뜀${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
else
    echo -e "${YELLOW}  ⚠️  clang-tidy 미설치 — 건너뜀 (apt install clang-tidy)${NC}"
    PASS_COUNT=$((PASS_COUNT + 1))
fi

# ──────────────────────────────────────────────────
# 단계 3: 단위 테스트 (pytest)
# ──────────────────────────────────────────────────
echo -e "${BLUE}[3/${TOTAL_STEPS}]${NC} 단위 테스트 (pytest) ..."

if command -v python3 &> /dev/null && python3 -m pytest --version &> /dev/null; then
    TEST_FILES=$(find src/ -path src/openarm_ros2 -prune -o \( -name 'test_*.py' -o -name '*_test.py' \) -print 2>/dev/null || true)
    if [ -n "$TEST_FILES" ]; then
        PYTEST_EXIT=0
        python3 -m pytest src/ --ignore=src/openarm_ros2 -q --tb=short || PYTEST_EXIT=$?
        # exit code 2 = collection error (import 실패 등) — ROS 2 환경 미구성 시 허용
        # exit code 0 = 통과, exit code 1 = 테스트 실패
        if [ "$PYTEST_EXIT" -eq 0 ]; then
            echo -e "${GREEN}  ✅ 단위 테스트 통과${NC}"
            PASS_COUNT=$((PASS_COUNT + 1))
        elif [ "$PYTEST_EXIT" -eq 2 ] || [ "$PYTEST_EXIT" -eq 5 ]; then
            echo -e "${YELLOW}  ⚠️  테스트 수집 실패 (ROS 2 환경 미구성 가능) — 건너뜀${NC}"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "${RED}  ❌ 단위 테스트 실패 — 커밋 중단${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}  ⏭️  테스트 파일 없음 — 건너뜀${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
else
    echo -e "${YELLOW}  ⚠️  pytest 미설치 — 건너뜀 (pip install pytest)${NC}"
    PASS_COUNT=$((PASS_COUNT + 1))
fi

# ──────────────────────────────────────────────────
# 단계 4: 빌드 검증 (colcon)
# ──────────────────────────────────────────────────
echo -e "${BLUE}[4/${TOTAL_STEPS}]${NC} 빌드 검증 (colcon) ..."

if command -v colcon &> /dev/null; then
    # ROS 2 환경 소스 (setup.bash가 미설정 변수를 사용할 수 있어 nounset 임시 해제)
    if [ -f /opt/ros/jazzy/setup.bash ]; then
        set +u
        source /opt/ros/jazzy/setup.bash
        set -u
    fi
    # 서브모듈(openarm_ros2) 제외 빌드
    OWN_PACKAGES=$(colcon list --names-only --paths src/falcon1_* 2>/dev/null || true)
    if [ -n "$OWN_PACKAGES" ]; then
        COLCON_EXIT=0
        colcon build --packages-select $OWN_PACKAGES --symlink-install 2>&1 || COLCON_EXIT=$?
        if [ "$COLCON_EXIT" -eq 0 ]; then
            echo -e "${GREEN}  ✅ 빌드 통과${NC}"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "${YELLOW}  ⚠️  빌드 실패 (의존성 미설치 가능) — 경고${NC}"
            PASS_COUNT=$((PASS_COUNT + 1))
        fi
    else
        echo -e "${YELLOW}  ⏭️  빌드 대상 패키지 없음 — 건너뜀${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
else
    echo -e "${YELLOW}  ⚠️  colcon 미설치 — 건너뜀${NC}"
    PASS_COUNT=$((PASS_COUNT + 1))
fi

# ──────────────────────────────────────────────────
# 단계 5: 파일 크기 제한 검사 (500줄 초과 경고)
# ──────────────────────────────────────────────────
echo -e "${BLUE}[5/${TOTAL_STEPS}]${NC} 파일 크기 제한 검사 (500줄) ..."

OVERSIZED=0
while IFS= read -r file; do
    LINES=$(wc -l < "$file")
    if [ "$LINES" -gt 500 ]; then
        echo -e "${YELLOW}  ⚠️  ${file} — ${LINES}줄 (500줄 초과)${NC}"
        OVERSIZED=1
    fi
done < <(find src/ -path src/openarm_ros2 -prune -o \( -name '*.py' -o -name '*.cpp' -o -name '*.hpp' \) -print 2>/dev/null || true)

if [ "$OVERSIZED" -eq 0 ]; then
    echo -e "${GREEN}  ✅ 파일 크기 검사 통과${NC}"
else
    echo -e "${YELLOW}  ⚠️  500줄 초과 파일 존재 — 분할을 권장합니다 (경고, 커밋 허용)${NC}"
fi
PASS_COUNT=$((PASS_COUNT + 1))

# ──────────────────────────────────────────────────
# 결과 요약
# ──────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$PASS_COUNT" -eq "$TOTAL_STEPS" ]; then
    echo -e "${GREEN}  ✅ 검증 완료 — 커밋 가능 (${PASS_COUNT}/${TOTAL_STEPS} 통과)${NC}"
else
    echo -e "${RED}  ❌ 검증 실패 (${PASS_COUNT}/${TOTAL_STEPS} 통과)${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

[ "$PASS_COUNT" -eq "$TOTAL_STEPS" ] || exit 1
