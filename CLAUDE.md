# CLAUDE.md — Claude Code 전용 필수 규칙

> 이 파일은 Claude Code(Antigravity)가 FALCON-1에서 작업할 때 반드시 준수해야 하는 규칙이다.
> 상위 운영 규칙은 `AGENTS.md`를 참조한다.

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
