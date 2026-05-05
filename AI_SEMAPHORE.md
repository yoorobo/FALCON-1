# 🚦 AI 자원 세마포어 (AI_SEMAPHORE.md)

여러 안티그래비티(AI) 인스턴스가 하드웨어 자원에서 충돌하는 것을 방지하기 위한 파일입니다.
**규칙**: 작업 전 읽기, 시작 전 기록, 종료 후 해제.

| 작업 명칭 | 소유 AI | 상태 | 자원 (Port/PID) | 마지막 업데이트 |
| :--- | :--- | :--- | :--- | :--- |
| **DualArm_Stream_v3** | 클라이언트&서버_AI | 점유(LOCKED) | Port 8516, 8214 / PID: 1234166 | 2026-04-30 11:25 |

## 🔑 자원 예약 테이블
- **Port 8211**: WebRTC (주요 스트리밍)
- **Port 8212**: Native Streaming (보조/테스트)
- **Port 8213**: 테스트용 예약됨
- **Port 8214**: VNC (시각적 디버깅) [ACTIVE]
- **Port 8516**: WebSocket JSON (JointState 스트리밍) [ACTIVE]
- **Port 8215**: FastDDS Discovery Server [READY]
- **Port 8000~8100**: 클라이언트(노트북) 작업용 예약됨

## 🛡️ 로그 안전 프로토콜 (Log Safety Protocol)

공동 작업 로그(AI_COMM_LOG.md)의 유실 및 덮어쓰기 방지를 위해 다음 원칙을 준수한다.

1. **Append Only**: 로그 기록 시 전체 파일을 덮어쓰지 않고, 반드시 >> 또는 특정 줄 추가 방식을 사용한다.
2. **Pull-Before-Push**: 서버로 로그를 전송하기 전, 반드시 서버의 최신본을 로컬로 가져와 변경 사항이 있는지 확인(Diff)한다.
3. **Snapshot Backup**: 매시간 정기 업데이트 시 AI_COMM_LOG.md.bak 스냅샷을 생성하여 보관한다.
4. **Pre-Save Backup (Mandatory)**: `AI_COMM_LOG.md` 또는 `AI_SEMAPHORE.md` 파일을 수정하기 직전, 반드시 해당 파일의 최신본을 `.bak` 파일로 복사하여 저장한다. (예: `cp AI_SEMAPHORE.md AI_SEMAPHORE.md.bak`)
5. **Conflict Resolution**: 기록 시점이 겹칠 경우, 클라이언트 AI가 수동 머지(Manual Merge)를 수행하여 모든 에이전트의 기록을 보존한다.

## 🧽 컨테이너 및 이미지 보호 정책 (Container & Image Protection Policy)

**의도치 않은 자원 삭제 및 작업 유실 방지**를 위해 다음 원칙을 의무화한다.

1. **No Unauthorized Deletion**: 다른 에이전트가 생성한 컨테이너나 이미지를 `AI_COMM_LOG.md`에서 상호 합의 없이 삭제하는 것을 엄격히 금지한다.
2. **Pre-Cleanup Broadcast**: `docker rm`, `docker system prune` 등 파괴적 명령을 수행하기 전, 반드시 대상 리스트를 `AI_COMM_LOG.md`에 공지하고 1분간 이의 제기가 없는지 대기한다.
3. **Active Work Marker**: 작업 중인 컨테이너는 반드시 `dual_arms_working_` 접두사를 붙이거나, `AI_SEMAPHORE.md`의 자원 점유 테이블에 PID와 함께 명시한다.
4. **Checkpoint Commit**: 1시간 이상의 중대한 환경 변경이 발생할 경우, 반드시 `vX.X_dev` 태그로 중간 커밋을 생성하여 컨테이너 유실에 대비한다.
5. **Host-Volume Priority**: 모든 작업 결과물(코드, 에셋)은 반드시 호스트 마운트 폴더(`/workspace/dual_arms`) 내부에서 생성하여 컨테이너 삭제 시에도 데이터가 보존되도록 한다.

## 5. 주기적 커뮤니케이션 및 로그 동기화 정책 (2026-04-30 추가)
- **로그 동기화 의무**: 모든 에이전트는 최소 10분 간격으로 서버의 AI_COMM_LOG.md와 자신의 로컬 로그를 동기화하여 정보 격차를 방지한다.
- **실시간 상태 보고**: 주요 프로세스(아이작 심 등) 가동 시, 로그상으로 활성화 완료를 선언하기 전 반드시 실제 포트 및 프로세스 상태를 재검증한다.
- **침묵 금지**: 작업이 지연되거나 병목 발생 시, 진행 중임을 5분 단위로 로그에 남겨 관리자와 상대 에이전트의 불안을 해소한다.

## 6. ROS 2 기반 AI 실시간 통신 규약 (ROS 2 AI Comm Protocol)

**아이작 심 가동 시 실시간 상태 공유 및 모니터링 효율화**를 위해 다음을 준수한다.

1. **Topic Name**: 모든 에이전트 대화 및 상태 보고는 `/ai/comm_log` (std_msgs/String) 토픽을 통해 송출한다.
2. **Message Format**: `[발신자] 메시지 내용` 형식을 유지한다. (예: `[Server_AI] 시뮬레이션 가동 성공 (8516 포트 활성)`)
3. **Logging Frequency**: 시뮬레이션 물리 스텝 100회당 1회 혹은 주요 상태 변화(Error, Reset, Ready) 시 즉시 송출한다.
4. **Priority**: 파일 기반 로그(`AI_COMM_LOG.md`)는 최종 기록 및 아카이빙 용도로 사용하며, 실시간 디버깅은 ROS 2 토픽을 우선순위로 둔다.

## 7. 소스 코드 주권 및 도메인 분리 정책 (Source Code Sovereignty)

**시스템 안정성과 역할 분담 명확화**를 위해 소스 코드에 대한 접근 및 수정 권한을 다음과 같이 규정한다.

### 📜 핵심 원칙
1. **도메인 전속성**: 각 에이전트는 자신의 도메인에 속한 코드에 대해 수정 및 실행의 전권(Sovereignty)을 가진다.
2. **Read-Only 참조**: 상대 도메인의 코드는 참조 및 디버깅을 위한 읽기만 허용되며, **사전 승인 없는 수정은 엄격히 금지**한다.
3. **Sandbox 원칙**: 타 도메인 코드의 실험적 수정이 필요할 경우, 원본을 복사하여 `_sandbox` 또는 `_client_test` 접미사를 붙여 작업한다.
4. **@owner 명기**: 모든 신규 스크립트 상단에 소유 주체(Server_AI/Client_AI)를 주석으로 명시한다.

### 📁 파일 및 작업영역 권한 분류표

| 영역 (Domain) | 소유 주체 | 주요 대상 파일/경로 (예시) | 권한 범위 |
| :--- | :--- | :--- | :--- |
| **Simulation & HW** | **서버_AI** | `scripts/test_*.py`, `scripts/sim_*.py`, `scripts/relink_*.py`, `assets/` (USD 전체), `scripts/docker_run*` | 수정/실행/커밋 |
| **Teleop & UI** | **클라이언트_AI** | `scripts/rviz_*.py`, `scripts/teleop_*.sh`, `scripts/ros2_marker*`, `launch_rviz_robot.sh` | 수정/실행/커밋 |
| **Infrastructure** | **공동(Shared)** | `AI_COMM_LOG.md`, `AI_SEMAPHORE.md`, `docs/`, `RECOVERY_DETAILS_REPORT.md` | 상호 합의 후 수정 |

### 🚨 위반 시 조치
- 타 에이전트의 전속 파일을 무단 수정하여 시스템 크래시를 유발할 경우, 즉시 `AI_COMM_LOG.md`를 통해 원인 보고 및 롤백을 수행해야 한다.
- 관리자(User)는 언제든 소유권을 재조정하거나 강제 롤백을 지시할 수 있다.
