# FALCON-1 상세설계 마스터 플랜 보고서

## 1. 문서 목적

본 문서는 확정된 시스템 요구사항(SR)과 기술조사 자료(Technology Research A~L)를 결합해, FALCON-1의 상세설계 문서군을 어떤 순서로 어떤 역할로 작성해야 하는지 정의하는 마스터 플랜이다.

본 문서의 직접 입력은 다음 세 묶음이다.

- SR 원본: `docs/requirements/system_requirements.md`
- 경계 원칙: `docs/requirements/_analysis/shoppinkki_design_boundary_analysis.md`
- 기술조사 자료: `docs/references/Technology -Research/` 하위 PDF 12종

본 문서는 SR을 구현 코드로 침범시키지 않고, SR의 정책을 상세설계 문서군으로 정확히 위임하는 것을 목표로 한다.

## 2. 상세설계 작성에 적용할 경계 원칙

`shoppinkki_design_boundary_analysis.md`의 결론을 FALCON-1에 맞게 재정리하면 다음 다섯 가지가 설계 문서 작성의 기준선이 된다.

1. SR은 `What/When`만 고정하고, 상세설계는 `How`를 기술한다.
2. 포트 번호, 토픽명, JSON 키, DDS QoS, 라이브러리 플러그인 이름은 상세설계 문서에서 정의한다.
3. LED, 음성 문구, 정지 거리, 속도 한계, 배터리 임계값처럼 사용자와 안전에 직접 연결되는 정책 수치는 SR에 남긴다.
4. OpenArm, Nav2, MoveIt 2, MediaPipe, Whisper 같은 기술 선택은 상세설계에서 드러내되, SR 본문에는 넣지 않는다.
5. 상태 전환 조건은 SR이 소유하고, 트리거 이름, 콜백, 횡단 변수 수명주기, 노드 배치, 메시지 스키마는 상세설계가 소유한다.

## 3. 기술 스택 총괄 결론

기술조사 PDF를 종합하면 FALCON-1 PoC의 기본 무기는 다음 조합으로 수렴한다.

- 미들웨어/통신: `ROS 2 Jazzy + Cyclone DDS + Zenoh bridge + micro-ROS`
- 시간 동기화: `PTP (linuxptp)`, 보조로 `chrony/NTP`, 시뮬레이션에서는 `use_sim_time`
- 모바일 자율주행: `Nav2 + slam_toolbox + AMCL`, 보강 옵션으로 `RTAB-Map`
- 조작 제어: `MoveIt 2 + Pilz Industrial Motion + MoveIt Task Constructor + ros2_control`, 필요 시 `MoveIt Servo`
- 비전/깊이: `YOLOv11`, `MediaPipe Hands`, `MediaPipe Pose`, `AprilTag 3`, `librealsense2`, `Open3D`, `PCL`, 선택적으로 `FoundationPose`
- 음성/HRI: `faster-whisper medium`, `Silero VAD`, `Piper TTS`, 선택적으로 `Whisper-large v3 turbo`
- 안전/전원: `Sub-1GHz wireless E-stop`, `hardware safety relay`, `software safety state machine`, `UPS/BMS`
- 시뮬레이션/검증: `Isaac Sim 4.5`, 대안으로 `Gazebo Harmonic`, 로깅은 `Foxglove Studio + MCAP`

## 4. Task 1: SR - 기술 스택 매핑 분석

### 4.1 호출통신

| SR ID | SR 정책 요약 | 매핑 기술 스택 | 근거 자료 | 1차 위임 문서 | 설계 메모 |
|---|---|---|---|---|---|
| `SR_A01` | PTT 음성을 화이트리스트 명령으로 인지하고 신뢰도 임계값 이상만 수락 | `ESP32-S3 + micro-ROS` PTT 입력, `faster-whisper medium`, `Silero VAD`, 필요 시 `Whisper-large v3 turbo` | A, G | `IS` | IS가 오디오 입력 토픽, STT 요청/응답 메시지, confidence 필드, 명령 화이트리스트 페이로드를 고정해야 한다. |
| `SR_A02` | 유효 명령 수신 후 1초 이내 LED/음성 피드백 | `micro-ROS` 헬멧/LED 채널, `Piper TTS`, `ROS 2 Jazzy` 이벤트 버스 | A, G | `SM` | 유효 명령 이벤트를 받은 뒤 어떤 상태 전환에서 LED 초록 점멸과 음성 응답이 발생하는지는 SM이 소유한다. |
| `SR_A03` | 저신뢰도 또는 미등록 명령은 구동 금지 후 재발화 안내 | `faster-whisper` confidence, `Silero VAD`, `Piper TTS` | G | `BT` | 실패 분기, 재시도 횟수, 타임아웃 복귀는 BT가 소유한다. |

### 4.2 위치추종

| SR ID | SR 정책 요약 | 매핑 기술 스택 | 근거 자료 | 1차 위임 문서 | 설계 메모 |
|---|---|---|---|---|---|
| `SR_B01` | 사전 맵과 목적지 좌표 기반 실내 자율이동 및 동적 장애물 회피 | `Nav2`, `slam_toolbox`, `AMCL`, `Cyclone DDS`, `PTP` | A, B, C | `SA` | SA가 Nav2, localization, planner, controller, base driver의 컴포넌트 분해와 연산 위치를 먼저 고정해야 한다. |
| `SR_B02` | 작업자 추종 중 위치 추정, 베이스 이동 중 양팔 Lock 및 Tucked Pose 강제 | `MediaPipe Pose`, `Nav2`, `ros2_control`, `MoveIt 2` | C, D, E, L | `SM` | 추종 모드 진입 시 arm lock, tucked pose, manip enable 플래그를 상태 횡단 변수로 정의해야 한다. |
| `SR_B03` | 추종 중 작업자 정지 시 1.0m~1.5m 안전 반경 유지 정지 | `Nav2 controller`, `costmap`, `PCL voxel layer`, `MediaPipe Pose` 기반 사람 거리 추정 | C, E, F, L | `PFL` | 사람 거리 기반 선속도 감쇠 함수와 정지 경계는 PFL에서 정량화해야 한다. |
| `SR_B04` | 사람/장애물 접근 시 속도 클램핑 및 충돌 위험 시 정지 | `Nav2 costmap`, `PCL`, `Open3D`, `Nav2 safety layer`, `software safety state machine` | C, F, L | `PFL` | 모바일 베이스 감속 함수, 임계 거리별 속도 상한, stop latch가 PFL 핵심이다. |
| `SR_B05` | 추종 타겟 3초 이상 분실 시 정지 및 재호출 안내 | `MediaPipe Pose`, 선택적으로 `DeepSORT`, `Piper TTS`, `Foxglove` 추적 디버깅 | E, G, K, L | `BT` | 분실 검출, 재시도, 포기, IDLE 복귀 흐름은 BT가 소유한다. |

### 4.3 공구입출고

| SR ID | SR 정책 요약 | 매핑 기술 스택 | 근거 자료 | 1차 위임 문서 | 설계 메모 |
|---|---|---|---|---|---|
| `SR_C01` | 공구 ID로 슬롯 좌표와 형상 데이터를 조회해 IK 파이프라인으로 출고 | `MoveIt 2`, `Pilz`, `MoveIt Task Constructor`, `AprilTag 3`, `wrist D405`, `Open3D`, `PCL`, `Hand-coded grasp` | D, E, F, H | `MS` | 공구 메타데이터는 ERD가 소유하되, 실제 pick pipeline stage는 MS가 소유한다. |
| `SR_C02` | 베이스 정지 및 위치 허용오차 만족 후에만 팔 동작 활성화 | `Nav2 goal status`, `AMCL pose`, `ros2_control`, `MoveIt 2` | C, D | `SM` | `base_motion_ok`, `manipulation_enable`, `arm_lock_reason` 같은 횡단 변수가 필요하다. |
| `SR_C04` | 반납 슬롯 점유 시 반납 중단 및 임시 트레이 거치 | `librealsense2`, `PCL`, `Open3D`, `AprilTag 3`, 선택적으로 `FoundationPose` | E, F | `BT` | 슬롯 검사 실패 분기, 임시 트레이 경유, 운영자 알림이 BT에서 결합된다. |
| `SR_C06` | 파지 오프셋, 3D 템플릿, 슬롯 위치 등 필수 메타데이터 사전 검증 | `AprilTag-anchored grasp offset`, `wrist D405`, `Open3D` 기반 표면 normal 보정 | F, H | `ERD` | 연구 자료는 DB 엔진을 고정하지 않았으므로 ERD는 백엔드 중립적으로 필수 필드와 검증 규칙을 고정해야 한다. |

### 4.4 공구전달

| SR ID | SR 정책 요약 | 매핑 기술 스택 | 근거 자료 | 1차 위임 문서 | 설계 메모 |
|---|---|---|---|---|---|
| `SR_D01` | 펼친 손 제스처를 감지하면 손 높이와 방향에 맞춰 공구 전달 자세 전개 | `MediaPipe Hands`, `MediaPipe Pose`, `MoveIt 2`, 선택적으로 `MoveIt Servo` | D, E | `IS` | 손 검출 결과 메시지, 좌표 프레임, 신뢰도, handover target pose 인터페이스를 IS가 먼저 고정해야 한다. |
| `SR_D02` | 핸드오버 중 TCP 선속도 250mm/s 이하 제한 | `Pilz LIN/CIRC/PTP`, `MoveIt Servo`, `ros2_control`, `ISO 10218` 정합 로직 | D, L | `PFL` | 속도 상한이 planner 단계와 controller 단계 어디서 강제되는지 PFL이 규정해야 한다. |
| `SR_D03` | 위험부를 작업자 반대 방향으로 유지하는 안전 방향 파지 | `Hand-coded grasp`, `AprilTag 6D pose`, `grasp offset schema`, 선택적으로 `FoundationPose` | F, H | `MS` | 공구별 handle axis, hazard axis, delivery axis 데이터 정의는 ERD와 MS가 공동 분담한다. |
| `SR_D04` | 외부 당김 또는 토크 임계값 초과 시 200ms 이내 릴리스 | `ros2_control` 1kHz 제어 루프, gripper effort/torque telemetry, `PTP` 기반 timestamp 정합 | B, D | `MS` | 연구 자료에 전용 F/T 센서는 고정되지 않았으므로 릴리스 검출 채널은 MS와 IS에서 명세해야 한다. |
| `SR_D06` | 작업자 회피 시 즉시 정지 후 전달 취소 및 안전 자세 복귀 | `MediaPipe Pose`, `MoveIt Servo` 또는 `Pilz stop`, `software safety state machine`, `Piper TTS` | D, E, G, L | `PFL` | 회피 상황 판정 거리, 속도, hysteresis, safe retreat 규칙이 PFL 핵심이다. |

### 4.5 안전

| SR ID | SR 정책 요약 | 매핑 기술 스택 | 근거 자료 | 1차 위임 문서 | 설계 메모 |
|---|---|---|---|---|---|
| `SR_E01` | 외부 충격 또는 과저항 감지 시 즉시 구동 출력 차단 또는 hold | `ros2_control hold`, `software safety state machine`, `Nav2 safety layer` | D, L | `PFL` | 이동계와 조작계의 충돌 감지 임계값을 분리해 정의해야 한다. |
| `SR_E02` | 물리 E-stop 또는 무선 리모컨 신호로 하드웨어 차단 | `Sub-1GHz wireless E-stop`, `hardware safety relay`, 후보 장비 `Steute/Schmersal/Pilz` | L | `IS` | E-stop 접점, GPIO 인터럽트, `/safety/estop_active` 토픽, TRANSIENT_LOCAL QoS가 인터페이스 핵심이다. |
| `SR_E03` | Heartbeat 누락, 배터리 저하, localization 실패 시 HALTED 진입 | `software safety state machine`, `Cyclone DDS` 상태 전파, `PTP` 기반 heartbeat 시간 판정, `BMS/UPS` | A, B, C, L | `SM` | HALTED는 전역 상태이며, 어떤 예외가 latch되는지와 복귀 권한 모델은 SM이 소유한다. |
| `SR_E06` | 베이스 이동 중 팔 잠금 및 궤적 명령 거부 | `ros2_control`, `MoveIt 2`, `Pilz`, `tucked pose` 유지 | D, L | `SM` | 이동 중 trajectory reject 정책과 hold controller 유지 방식이 상태 설계의 중심이다. |
| `SR_E07` | 야외 목표 거부 및 비인가 네트워크/API 차단 | `Nav2 map boundary`, `Cyclone DDS + Zenoh` 폐쇄 토폴로지, 네트워크 ACL/allowlist | A, C | `IS` | 연구 자료는 토폴로지만 고정했고 방화벽 구현체는 고정하지 않았으므로 IS가 허용 채널과 금지 채널만 먼저 규격화해야 한다. |

### 4.6 매핑 해석 요약

- 호출통신 계열은 `IS`와 `SM`, 예외 분기는 `BT`가 주 문서다.
- 위치추종 계열은 `SA`로 큰 배치를 고정한 뒤, 속도/거리 한계는 `PFL`, 추종 분실 복구는 `BT`로 분리하는 것이 맞다.
- 공구입출고와 공구전달은 `ERD + MS` 쌍으로 풀어야 하며, 안전 속도와 정지는 `PFL`이 상위 제약으로 덮는다.
- 안전 계열은 `IS`가 하드웨어 접점과 토픽을, `SM`이 HALTED 전역 정책을, `PFL`이 수치 한계를 각각 맡아야 중복이 없다.

## 5. Task 2: 상세설계 문서 작성 순서 및 전략

### 5.1 권장 작성 순서

1. `SA (System Architecture)`
2. `IS (Interface Specification)`
3. `ERD (Entity-Relationship Diagram)`
4. `SM (State Machine)`
5. `PFL (Safety PFL Spec)`
6. `MS (Manipulation Sequence)`
7. `BT (Behavior Tree)`

### 5.2 이 순서가 필요한 이유

| 순서 | 문서 | 먼저 써야 하는 이유 | 뒤 문서에 제공하는 산출물 |
|---|---|---|---|
| 1 | `SA` | 컴포넌트 경계, 노드 배치, 연산 위치, 기기별 책임을 먼저 고정하지 않으면 토픽과 상태가 흔들린다. 특히 `Dual-L1 + RPi5 + ESP32-S3 + RTX 5090` 분산 토폴로지를 확정해야 한다. | 노드 목록, 책임 분해, 배치도, 데이터 흐름 초안 |
| 2 | `IS` | SA가 정한 컴포넌트 간 계약을 토픽, 서비스, 액션, 포트, QoS, 페이로드로 고정해야 이후 상태/BT/MS가 같은 언어를 쓴다. | 메시지 계약, 토픽/서비스명, 안전 채널, 음성/비전 인터페이스 |
| 3 | `ERD` | 공구 ID, 슬롯, grasp offset, hazard axis, 임무 로그의 데이터 구조가 고정되어야 조작 시퀀스와 상태 이벤트가 같은 엔터티를 참조할 수 있다. | 엔터티 정의, 키/제약조건, 검증 규칙, 상태 로그 스키마 |
| 4 | `SM` | 상태와 횡단 변수는 IS의 이벤트와 ERD의 엔터티를 받아 전역 운용 규칙으로 묶는다. HALTED, TRACKING, MANIPULATION_ENABLE 같은 전역 정책이 먼저 고정돼야 안전과 조작 설계가 안정된다. | 상태도, 전환 조건, 전역 latch, 모드 플래그 |
| 5 | `PFL` | 속도/힘 제한은 상태 모델과 인터페이스 계약 위에 얹히는 상위 제약이다. PFL을 MS보다 먼저 써야 조작 시퀀스가 처음부터 안전 속도와 정지 규칙을 내재화한다. | 거리-속도 곡선, TCP 속도 상한, stop hierarchy, recovery gate |
| 6 | `MS` | 조작 시퀀스는 ERD의 메타데이터, IS의 perception 입력, SM의 모드 전환, PFL의 제한을 모두 사용한다. 그래서 선행 문서가 고정된 뒤에 작성해야 재작업이 적다. | pick/place/handover 단계, planner 분담, 릴리스 조건 |
| 7 | `BT` | BT는 음성, 이동, 안전, 조작, 오류 복구를 최종 조합하는 상위 오케스트레이션 문서다. 앞선 문서가 없으면 BT는 가짜 흐름만 만들게 된다. | 미션 트리, 예외 복구 트리, 재시도 정책, 종료 조건 |

### 5.3 작성 전략

- `SA`와 `IS`는 시스템 공통 언어를 고정하는 문서이므로 가장 먼저 리뷰를 받아야 한다.
- `ERD`는 공구 전달과 입출고의 설계 중심축이므로 `MS` 전에 잠가야 한다.
- `SM`과 `PFL`은 안전 정책의 두 층이다. `SM`은 상태적 안전, `PFL`은 연속값 기반 안전을 담당한다.
- `MS`는 `MoveIt 2`, `Pilz`, `MTC`, `AprilTag`, `D405`를 실제 임무 단계로 엮는 문서이므로 기술조사 자료의 구현성이 가장 직접적으로 반영된다.
- `BT`는 마지막에 작성하되, 실제 시나리오 데모와 예외 흐름 검증의 기준 문서가 되므로 테스트 케이스를 함께 포함하는 것이 바람직하다.

## 6. Task 3: 문서별 구체적 뼈대

아래 뼈대는 권장 작성 순서대로 정렬하였다. 각 문서는 H2, H3 수준까지의 기본 구조와 반드시 포함해야 할 설계 키워드를 명시한다.

---

## 6.1 SA (System Architecture)

### 문서 역할

FALCON-1 전체를 컴포넌트, 노드, 실행 위치, 통신 버스, 시뮬레이션 경계로 분해하는 최상위 설계 문서다.

### 위임받는 SR

`SR_B01`, `SR_G01`, `SR_G02`를 직접 받고, `SR_B02`, `SR_C01`, `SR_E03`, `SR_E07`의 상위 구조를 제공한다.

### 권장 목차

## 1. Scope and Assumptions
### 1.1 PoC 범위와 제외 범위
### 1.2 운영 환경 전제

핵심 키워드: `Ubuntu 24.04 LTS`, `ROS 2 Jazzy`, `Gazebo`, `Isaac Sim`, `OpenArm 4.1kg payload limit`, `indoor mapped area only`

## 2. Runtime Topology
### 2.1 Dual-L1, RPi5, ESP32-S3, RTX 5090 역할 분담
### 2.2 유선 RJ45와 Wi-Fi 6 통신 경계

핵심 키워드: `Cyclone DDS`, `Zenoh router`, `micro-ROS Agent`, `PTP master/slave`, `PREEMPT_RT`

## 3. Functional Component Decomposition
### 3.1 Voice and HRI subsystem
### 3.2 Navigation and Tracking subsystem
### 3.3 Manipulation and Grasp subsystem
### 3.4 Safety and Power subsystem
### 3.5 Simulation and Logging subsystem

핵심 키워드: `faster-whisper`, `Piper TTS`, `Nav2`, `slam_toolbox`, `AMCL`, `MoveIt 2`, `Pilz`, `MTC`, `ros2_control`, `YOLOv11`, `MediaPipe`, `AprilTag`, `librealsense2`, `Foxglove`, `MCAP`

## 4. Node Placement and Compute Budget
### 4.1 RPi5 resident nodes
### 4.2 L1-Right resident nodes
### 4.3 L1-Left resident nodes
### 4.4 Optional server-side training and sim nodes

핵심 키워드: `RPi5 Nav2 + safety`, `L1 perception`, `BRAVO whisper`, `RTX 5090 Isaac Sim only`

## 5. Cross-Cutting Architecture Constraints
### 5.1 Time synchronization architecture
### 5.2 Safety channel isolation
### 5.3 Logging and replay architecture

핵심 키워드: `linuxptp`, `chrony`, `TRANSIENT_LOCAL`, `MCAP replay`, `use_sim_time`

## 6. Design Allocation Matrix
### 6.1 SR-to-component allocation
### 6.2 Component-to-design-doc allocation

핵심 키워드: `SR allocation`, `doc ownership`, `interface ownership`

---

## 6.2 IS (Interface Specification)

### 문서 역할

모든 ROS 2 토픽, 서비스, 액션, 포트, 메시지, 안전 채널, 외부 접점을 고정하는 계약 문서다.

### 위임받는 SR

`SR_A01`, `SR_D01`, `SR_E02`, `SR_E07`을 직접 받고, `SR_A02`, `SR_D04`, `SR_E03`의 이벤트 인터페이스를 정의한다.

### 권장 목차

## 1. Interface Design Principles
### 1.1 SR과 인터페이스 경계
### 1.2 메시지 명명 규칙과 네임스페이스 규칙

핵심 키워드: `ROS 2 Jazzy`, `namespace`, `topic naming`, `service naming`, `action naming`

## 2. Middleware and Transport Profile
### 2.1 Cyclone DDS 기본 채널
### 2.2 Zenoh bridge 사용 채널
### 2.3 micro-ROS 장치 채널

핵심 키워드: `Cyclone DDS`, `Zenoh`, `zenoh-bridge-ros2dds`, `micro-ROS`, `TRANSIENT_LOCAL`, `RELIABLE`, `BEST_EFFORT`

## 3. Voice Command Interfaces
### 3.1 PTT audio ingress
### 3.2 STT request and transcript result
### 3.3 Command validation and acknowledgement

핵심 키워드: `ESP32-S3`, `audio stream`, `confidence`, `command whitelist`, `faster-whisper`, `Silero VAD`, `Piper TTS`

## 4. Navigation and Tracking Interfaces
### 4.1 Nav2 actions and feedback
### 4.2 Worker tracking pose stream
### 4.3 Localization and map services

핵심 키워드: `NavigateToPose`, `AMCL pose`, `worker_pose`, `tracking_lost`, `slam_toolbox map`

## 5. Manipulation and Perception Interfaces
### 5.1 AprilTag and hand pose messages
### 5.2 Tool metadata query API
### 5.3 Gripper command and release event

핵심 키워드: `AprilTagDetectionArray`, `MediaPipe Hands`, `MoveIt action`, `ros2_control`, `gripper_effort`, `tool_id`

## 6. Safety Interfaces
### 6.1 E-stop hardware ingress
### 6.2 Safety state topics
### 6.3 Battery, UPS, heartbeat, localization health

핵심 키워드: `/safety/estop_active`, `GPIO interrupt`, `wireless E-stop`, `BMS`, `UPS`, `heartbeat`, `HALTED`

## 7. Network Boundary and Security Interfaces
### 7.1 허용 네트워크 경로
### 7.2 금지 API 및 외부 접속 규칙
### 7.3 Logging and dashboard egress

핵심 키워드: `allowlist`, `closed LAN`, `Foxglove bridge`, `Zenoh dashboard channel`

## 8. QoS and Timing Contract
### 8.1 Safety topic QoS
### 8.2 Telemetry and logging QoS
### 8.3 Timestamp and clock source contract

핵심 키워드: `PTP`, `header.stamp`, `deadline`, `latched safety`, `MCAP`

---

## 6.3 ERD (Entity-Relationship Diagram)

### 문서 역할

공구, 슬롯, grasp offset, hazard orientation, 임무 이력, 안전 이벤트, 상태 로그를 표현하는 데이터 모델 문서다.

### 위임받는 SR

`SR_C01`, `SR_C06`, `SR_D03`을 직접 받고, `SR_C04`, `SR_G02`의 데이터 참조 기반을 제공한다.

### 권장 목차

## 1. Data Ownership and Persistence Scope
### 1.1 런타임 상태와 영속 데이터의 경계
### 1.2 백엔드 독립 원칙

핵심 키워드: `backend-agnostic`, `metadata store`, `runtime cache`

## 2. Core Tooling Entities
### 2.1 Tool
### 2.2 ToolVariant
### 2.3 StorageSlot
### 2.4 TemporaryTray

핵심 키워드: `tool_id`, `slot_id`, `slot_pose`, `tool_geometry`, `weight`, `handle_axis`, `hazard_axis`

## 3. Grasp and Handover Metadata
### 3.1 GraspPoseProfile
### 3.2 HandoverPoseProfile
### 3.3 ReleaseThresholdProfile

핵심 키워드: `AprilTag frame`, `grasp offset`, `approach vector`, `TCP speed limit`, `pull threshold`, `torque threshold`

## 4. Perception Reference Data
### 4.1 AprilTag registration
### 4.2 RGB-D reference asset
### 4.3 Optional model-free pose asset

핵심 키워드: `AprilTag family`, `tag pose`, `D405 capture`, `point cloud template`, `FoundationPose optional`

## 5. Mission and Safety Log Entities
### 5.1 MissionExecution
### 5.2 StateTransitionLog
### 5.3 SafetyEvent
### 5.4 TrackingLossEvent

핵심 키워드: `mission_id`, `state`, `event_type`, `timestamp_ptp`, `operator_ack`

## 6. Validation Rules
### 6.1 필수 메타데이터 completeness rule
### 6.2 payload and geometry constraints
### 6.3 handover safety orientation rule

핵심 키워드: `required fields`, `4.1kg limit`, `missing metadata reject`, `orientation invariant`

## 7. ERD and Interface Mapping
### 7.1 IS payload reference map
### 7.2 MS stage input/output map

핵심 키워드: `schema contract`, `query API`, `tool fetch plan`

---

## 6.4 SM (State Machine)

### 문서 역할

로봇 전역 운용 상태, 상태 전환, 전역 latch, 횡단 변수, 강제 정지 정책을 정의하는 문서다.

### 위임받는 SR

`SR_A02`, `SR_B02`, `SR_C02`, `SR_E03`, `SR_E06`을 직접 받고, `SR_A03`, `SR_B05`, `SR_D06`의 상위 상태 제약을 제공한다.

### 권장 목차

## 1. State Model Scope
### 1.1 전역 FSM 범위
### 1.2 하위 시퀀스와의 경계

핵심 키워드: `global FSM`, `BT boundary`, `MS boundary`

## 2. State Set Definition
### 2.1 IDLE and WAITING
### 2.2 ACKNOWLEDGED and NAVIGATING
### 2.3 TRACKING and HANDOVER_READY
### 2.4 MANIPULATION_ACTIVE and RETURNING
### 2.5 HALTED and ESTOP

핵심 키워드: `IDLE`, `WAITING`, `TRACKING`, `MANIPULATION`, `HALTED`, `ESTOP`

## 3. Transition Table
### 3.1 음성 이벤트 기반 전환
### 3.2 Nav2 상태 기반 전환
### 3.3 Safety 이벤트 기반 전환

핵심 키워드: `command_valid`, `goal_reached`, `tracking_lost`, `heartbeat_timeout`, `battery_low`, `localization_failed`

## 4. Cross-Cutting Variables
### 4.1 manipulation_enable
### 4.2 arm_lock_reason
### 4.3 estop_latched and halt_cause
### 4.4 previous_mission_context

핵심 키워드: `tucked_pose_required`, `base_stationary`, `safe_to_release`

## 5. Output Policy by State
### 5.1 LED and TTS policy
### 5.2 Arm lock and base control policy
### 5.3 Logging and operator intervention policy

핵심 키워드: `Piper TTS`, `helmet LED`, `ros2_control hold`, `Foxglove event marker`

## 6. Recovery and Manual Intervention
### 6.1 HALTED 복귀 권한 모델
### 6.2 ESTOP 후 재기동 절차
### 6.3 tracking loss 후 재호출 절차

핵심 키워드: `operator_ack`, `manual clear`, `safe pose`

## 7. Interface Hooks
### 7.1 IS 이벤트 매핑
### 7.2 BT leaf condition 매핑
### 7.3 PFL override 매핑

핵심 키워드: `event bus`, `state guard`, `safety override`

---

## 6.5 PFL (Safety PFL Spec)

### 문서 역할

ISO 10218-2 계열 안전 요구를 FALCON-1의 모바일 주행과 양팔 핸드오버에 맞게 속도, 거리, 정지, 복귀 규칙으로 구체화하는 문서다.

### 위임받는 SR

`SR_B03`, `SR_B04`, `SR_D02`, `SR_D06`, `SR_E01`을 직접 받고, `SR_E02`, `SR_E03`과 결합한다.

### 권장 목차

## 1. Safety Scope and Standard Mapping
### 1.1 PoC safety narrative와 인증 경계
### 1.2 ISO 10218-1/2, ISO 13849, IEC 62061 참조 방식

핵심 키워드: `ISO 10218`, `PLc to PLd path`, `PoC boundary`

## 2. Safety Function Catalog
### 2.1 Mobile speed clamp
### 2.2 TCP speed limit
### 2.3 Collision detect and hold
### 2.4 Flinch abort

핵심 키워드: `speed clamp`, `250 mm/s`, `hold`, `abort`, `safe retreat`

## 3. Sensor Inputs and Fusion Rules
### 3.1 MediaPipe Pose 기반 사람 거리
### 3.2 PCL voxel 기반 장애물 거리
### 3.3 ros2_control effort 기반 충돌 징후

핵심 키워드: `MediaPipe Pose`, `PCL`, `Open3D`, `joint effort`, `distance bands`

## 4. Quantitative Safety Profiles
### 4.1 추종 거리-속도 곡선
### 4.2 핸드오버 TCP 속도 프로파일
### 4.3 stop threshold와 hysteresis

핵심 키워드: `1.0m to 1.5m`, `clamping`, `hysteresis`, `soft stop`, `hard stop`

## 5. Stop Hierarchy
### 5.1 software stop
### 5.2 controller hold
### 5.3 hardware E-stop relay

핵심 키워드: `Nav2 cancel`, `ros2_control hold`, `wireless E-stop`, `safety relay`

## 6. Recovery Gate
### 6.1 자동 복귀 가능 조건
### 6.2 수동 승인 필요 조건
### 6.3 HALTED와 ESTOP 구분

핵심 키워드: `latched fault`, `operator clear`, `re-entry conditions`

## 7. Validation and Test Cases
### 7.1 Gazebo/Isaac safety regression
### 7.2 MCAP 기반 replay 검증
### 7.3 현장 burn-in 측정 항목

핵심 키워드: `Isaac Sim 4.5`, `Gazebo Harmonic`, `MCAP`, `Foxglove`

---

## 6.6 MS (Manipulation Sequence)

### 문서 역할

양팔 또는 단일팔의 공구 pick, carry, handover, stow 시퀀스를 단계별로 정의하는 조작 파이프라인 문서다.

### 위임받는 SR

`SR_C01`, `SR_D03`, `SR_D04`를 직접 받고, `SR_C04`, `SR_D01`, `SR_D02`, `SR_D06`을 상위 제약과 결합한다.

### 권장 목차

## 1. Sequence Scope
### 1.1 Pick and place 범위
### 1.2 Handover 범위
### 1.3 Bimanual 확장 범위

핵심 키워드: `single-arm first`, `bimanual extension`, `PoC scope`

## 2. Planning Stack Allocation
### 2.1 OMPL for free-space approach
### 2.2 Pilz LIN/CIRC/PTP for deterministic segments
### 2.3 MTC for staged task composition
### 2.4 MoveIt Servo for final reactive alignment

핵심 키워드: `MoveIt 2`, `OMPL`, `Pilz`, `MoveIt Task Constructor`, `MoveIt Servo`

## 3. Tool Fetch Sequence
### 3.1 Tool metadata query
### 3.2 AprilTag pose acquisition
### 3.3 wrist D405 fine alignment
### 3.4 grasp, lift, retreat

핵심 키워드: `tool_id`, `slot_pose`, `AprilTag 3`, `D405`, `Open3D normal`, `hand-coded grasp`

## 4. Slot Return Sequence
### 4.1 Slot occupancy verification
### 4.2 place or temporary tray fallback
### 4.3 retreat and verification

핵심 키워드: `PCL occupancy check`, `temporary tray`, `FoundationPose optional`

## 5. Handover Sequence
### 5.1 open hand detection
### 5.2 worker-relative target pose generation
### 5.3 constrained approach
### 5.4 pull detection and release
### 5.5 abort and safe retreat

핵심 키워드: `MediaPipe Hands`, `MediaPipe Pose`, `TCP limit`, `gripper effort`, `200ms release`

## 6. Orientation and Safety Constraints
### 6.1 hazard axis invariant
### 6.2 handle-first delivery rule
### 6.3 mobile base stationary precondition

핵심 키워드: `hazard_axis`, `handle_axis`, `base_stationary`, `tucked pose`

## 7. Failure Modes and Escalation
### 7.1 IK failure
### 7.2 perception confidence drop
### 7.3 grasp slip
### 7.4 release timeout

핵심 키워드: `IK retry`, `confidence threshold`, `slip detect`, `operator fallback`

## 8. Telemetry and Replay Points
### 8.1 Stage checkpoints
### 8.2 Foxglove overlays
### 8.3 MCAP evidence topics

핵심 키워드: `Foxglove`, `MCAP`, `planning scene`, `stage marker`

---

## 6.7 BT (Behavior Tree)

### 문서 역할

음성 호출부터 이동, 추종, 공구 조작, 공구 전달, 복귀, 실패 복구까지 복합 임무 흐름을 최종 오케스트레이션하는 문서다.

### 위임받는 SR

`SR_A03`, `SR_B05`, `SR_C04`, `SR_G02`를 직접 받고, `SR_A02`, `SR_B01`, `SR_C01`, `SR_D06`, `SR_E03`을 종합 운용 규칙으로 묶는다.

### 권장 목차

## 1. BT Scope and Runtime Boundary
### 1.1 전역 FSM과 BT의 책임 분리
### 1.2 Nav2 BT와 상위 임무 BT의 관계

핵심 키워드: `orchestration`, `Nav2 BT XML`, `state guard`

## 2. Mission Trees
### 2.1 Fetch tool mission
### 2.2 Follow worker mission
### 2.3 Return and stow mission

핵심 키워드: `voice command`, `navigate`, `pick`, `handover`, `return`

## 3. Exception Trees
### 3.1 low confidence voice rejection
### 3.2 tracking lost recovery
### 3.3 slot occupied fallback
### 3.4 handover flinch abort
### 3.5 localization or battery halt

핵심 키워드: `retry`, `fallback`, `HALTED`, `safe pose`, `temporary tray`

## 4. Retry and Timeout Policy
### 4.1 perception retry budget
### 4.2 navigation timeout
### 4.3 manipulation timeout

핵심 키워드: `retry count`, `timeout`, `cooldown`

## 5. Blackboard and Shared Context
### 5.1 tool_id
### 5.2 mission context
### 5.3 worker tracking state
### 5.4 safety latch

핵심 키워드: `blackboard`, `shared context`, `operator ack`

## 6. Observability Hooks
### 6.1 tree event logging
### 6.2 Foxglove visualization points
### 6.3 MCAP replay checkpoints

핵심 키워드: `tree status`, `MCAP`, `Foxglove panel`

## 7. Scenario Test Matrix
### 7.1 nominal fetch-handover-return
### 7.2 worker loss and recall
### 7.3 slot full fallback
### 7.4 emergency halt injection

핵심 키워드: `Gazebo`, `Isaac Sim`, `regression`, `burn-in`

## 7. 실행 권고안

문서 작성은 다음 세 묶음으로 끊어 진행하는 것이 가장 효율적이다.

1. `SA + IS`
   - 이유: 컴포넌트 경계와 인터페이스가 확정되어야 이후 문서들이 동일한 시스템 용어를 사용한다.
2. `ERD + SM + PFL`
   - 이유: 데이터 모델, 상태 모델, 안전 모델이 확정되어야 조작과 예외 복구 설계가 수치와 조건을 공유할 수 있다.
3. `MS + BT`
   - 이유: 마지막에 실제 임무 흐름과 조작 세부를 결합해 데모 시나리오와 회귀시험 케이스까지 연결할 수 있다.

## 8. 결론

FALCON-1의 상세설계는 단순히 7개 문서를 병렬로 쓰는 방식으로는 품질이 나오지 않는다. `ROS 2 Jazzy + Cyclone DDS + Zenoh + micro-ROS`가 통신 골격을 만들고, `PTP`가 시간 기준을 고정하며, `Nav2 + slam_toolbox + AMCL`이 이동을 맡고, `MoveIt 2 + Pilz + MTC + ros2_control`이 조작을 맡고, `MediaPipe + AprilTag + D405 + Open3D/PCL`이 작업자와 공구를 관찰하며, `faster-whisper + Piper`가 HRI를 담당하고, `wireless E-stop + safety state machine`이 시스템의 최종 안전 상한을 제공하는 구조로 문서군이 조립되어야 한다.

따라서 상세설계의 실제 착수 순서는 `SA → IS → ERD → SM → PFL → MS → BT`로 고정하는 것이 합리적이며, 이 순서는 SR의 정책을 구현 세부와 충돌 없이 분해하고, 이후 Gazebo 및 Isaac Sim 검증을 통과한 뒤에만 실기체 실행으로 이어지도록 하는 가장 재작업이 적은 경로다.
