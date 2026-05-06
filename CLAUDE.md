# CLAUDE.md — Claude Code 전용 필수 규칙

> 이 파일은 Claude Code(Antigravity)가 FALCON-1에서 작업할 때 반드시 준수해야 하는 규칙이다.
> 상위 운영 규칙은 `AGENTS.md`를 참조한다.

---

## 0. 행동 원칙 (Karpathy Guidelines)

> 전역 규칙 (~/.claude/CLAUDE.md) 과 병합된 원칙. 모든 작업에 적용.

### 0-1. Think Before Coding
코딩 전에 반드시:
- 가정을 명시적으로 밝혀라. 불확실하면 질문하라.
- 해석이 여러 개라면 침묵으로 선택하지 말고 제시하라.
- 더 단순한 접근이 있다면 말하라. 필요하면 반박하라.
- 불명확한 것이 있으면 멈추고 이름을 붙여 질문하라.

### 0-2. Simplicity First
- 요청받은 것만 구현한다. 추측성 기능 금지.
- 단일 사용 코드에 추상화 금지.
- 요청하지 않은 유연성/설정 가능성 금지.
- 200줄로 쓸 수 있으면 50줄로 다시 쓴다.

### 0-3. Surgical Changes
- 필요한 곳만 수정한다. 인접 코드 건드리지 않는다.
- 기존 스타일을 따른다. 스타일 정리는 별도 커밋.
- 요청받지 않은 리팩터링 금지.

### 0-4. Goal-Driven Execution
- "버그 고쳐줘" → "버그 재현 테스트 작성 → 통과시키기"로 변환.
- 성공 기준을 먼저 정의하고, 기준을 통과할 때까지 루프.
- 막연한 기준("작동하게 해줘")은 명확한 기준으로 재정의 후 진행.

---

## 1. 절대 규칙 (MUST)

- [ ] 작업 시작 전 `AGENTS.md` 읽기
- [ ] 작업 시작 전 `docs/exec-plans/active/` 에 실행 계획 작성
- [ ] 코드 수정 전 관련 테스트 파일 확인
- [ ] 모호한 구현 계획이 있으면 반드시 사용자에게 먼저 확인
- [ ] 하드코딩이나 목킹으로 작업 회피 금지
- [ ] 작업 완료 후 반드시 결과 요약 제공

---

## 2. 기술 스택

| 영역 | 기술 | 비고 |
|---|---|---|
| OS | Ubuntu 24.04 LTS | |
| 미들웨어 | ROS 2 Jazzy | |
| 빌드 | colcon / CMake / setuptools | |
| Python 린터 | ruff | `.ruff.toml` 설정 참조 |
| C++ 린터 | clang-tidy | |
| 테스트 | pytest | |
| 시뮬레이션 | Gazebo / Isaac Sim | 실기체 실행 전 통과 필수 |
| ML | ACT / LeRobot | |
| 컨테이너 | Docker | |
| 패키지 관리 | pip / apt / rosdep | |

---

## 3. 4단계 검증 프로세스

모든 커밋 전 아래 순서를 반드시 실행한다:

```bash
# 단계 1: Python 린트
ruff check src/ --exclude src/openarm_ros2

# 단계 2: C++ 린트 (변경된 파일만)
find src/ -path src/openarm_ros2 -prune -o \( -name '*.cpp' -o -name '*.hpp' \) -print \
  | xargs -r clang-tidy

# 단계 3: 단위 테스트
python -m pytest src/ --ignore=src/openarm_ros2 -q

# 단계 4: 전체 검증 스크립트
bash scripts/verify-task.sh
```

어느 단계든 실패 시 즉시 중단하고 수정한다.

---

## 4. 5단계 커밋 프로세스

```bash
# 1. 검증 통과 확인
bash scripts/verify-task.sh

# 2. 변경 파일 스테이징
git add <변경파일>

# 3. Conventional Commits 형식으로 커밋
git commit -m "feat(perception): add tool detection pipeline"
#   허용 타입: feat, fix, docs, refactor, test, chore, ci, style
#   scope: 도메인 또는 패키지명 (예: perception, interfaces, description)

# 4. 원격 push
git push origin main

# 5. 태스크 완료 처리
bash scripts/complete-task.sh
```

---

## 5. 금지 사항 (NEVER)

| # | 금지 항목 |
|---|---|
| 1 | `git push --force` 사용 금지 |
| 2 | 사용자 승인 없이 파일 삭제 금지 |
| 3 | `src/openarm_ros2/` (서브모듈) 수정 금지 |
| 4 | 시뮬레이션 미통과 상태에서 실기체 코드 배포 금지 |
| 5 | `.env`, `.secrets` 파일을 커밋에 포함 금지 |
| 6 | 500줄 초과 단일 파일 생성 금지 (분할 필수) |
| 7 | 테스트 없는 로직 코드 커밋 금지 |

---

## 6. 빠른 시작 명령어

```bash
# ROS 2 환경 소스
source /opt/ros/jazzy/setup.bash

# 워크스페이스 빌드
cd ~/Falcon-1/FALCON-1
colcon build --symlink-install

# 빌드 결과 소스
source install/setup.bash

# Python 린트
ruff check src/ --exclude src/openarm_ros2

# 테스트 실행
python -m pytest src/ --ignore=src/openarm_ros2 -q

# 전체 검증
bash scripts/verify-task.sh

# 태스크 완료
bash scripts/complete-task.sh
```
