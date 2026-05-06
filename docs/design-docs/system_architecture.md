# FALCON-1 System Architecture (SA)

- 기준: `docs/design-docs/FALCON-1_Detailed_Design_Master_Plan.md` §3.1
- 상위 규칙: `ARCHITECTURE.md`
- 연계 SR: SR-74, SR-80

## SR 매핑표

| 위임 SR ID | SR 내용 요약 |
|---|---|
| SR-74 | PoC 부하(자율이동+매니퓰레이션+핸드오버)에서 최소 운용시간(P-74) 확보를 위한 전원 관리/대기 전력 제한 로직 |
| SR-80 | "통제된 실내 환경 시험 운용, 현장 배포 미인증" 운용 범위 표기 정책 |

## 1. Scope and Layer Boundaries

### 1.1 PoC 운용 범위와 비범위
- 범위: UR Must 24건 대응 기능(호출/추종/공구 입출고/핸드오버/안전정지)과 운영 계측(로그, 관제).
- 환경: 통제된 실내 시험 운용(SR-80, SR-81).
- 비범위: 현장 배포 인증(PLd 정식 인증, 현장 안전 승인), Post-PoC 항목(UR Should/Could 일부).
- 시뮬레이션 게이트: Gazebo/Isaac Sim 통과 전 실기체 실행 금지.

### 1.2 ARCHITECTURE 레이어 매핑(Runtime/Service/Interface/Hardware)
- Runtime Layer: Behavior Tree 기반 임무 오케스트레이션, 모드 전환 호출, 예외 재개/중단 제어.
- Service Layer: Navigation(Nav2), Manipulation(MoveIt2), Perception(음성/비전/센서융합).
- Interface Layer: `falcon1_interfaces`의 msg/srv/action 계약.
- Hardware Layer: Vic Pinky 구동부, OpenArm `ros2_control`, E-stop 하드웨어 입력.
- 하위 레이어(Description/Config/Types): URDF/xacro, 파라미터, 공통 타입 정의.
- 의존성 규칙: `Types → Config → Description → Interface → Hardware → Service → Runtime` 단방향 유지.

## 2. Runtime Topology

### 2.1 Vic Pinky + OpenArm 노드 배치
- Onboard Compute(RPi5): ROS2 core, state manager, safety monitor, base control, telemetry publisher.
- Edge Compute(L1 GPU): ASR/TTS 처리, 비전 추론(핸드/공구/작업자), 매니퓰레이션 계획 보조.
- Control Plane: 관제 대시보드/관리자 UI, 임무 명령·상태 수집.
- OpenArm HW: joint control, gripper torque/force feedback, safe pose execution.
- Network: RJ45 Gigabit + Wi-Fi 6 5GHz 혼합 운용(영역 A 기술조사 BLUF).

### 2.2 데이터 흐름(음성/내비/매니퓰레이션/안전)
```text
[Worker PTT/Voice]
  -> (Audio Ingress)
  -> [ASR + Command Validation]
  -> [Mission Queue / Runtime Orchestrator]
  -> [Nav2 Goal + Follow Control]
  -> [Manipulation Planner + OpenArm Controller]
  -> [Handover Monitor (gesture/force)]
  -> [Mission Result + Telemetry]
  -> [Dashboard/Logs/MCAP]

[Safety Inputs: E-stop, Heartbeat, Battery, Localization]
  -> [Safety Monitor]
  -> [Global Transition to Emergency Stop]
  -> [Actuator Power Cut / Motion Halt]
  -> [Alarm + Cause Logging]
```

## 3. Cross-Layer Contracts

### 3.1 Service-Interface 경계 규칙
- Service Layer는 Interface Layer에 선언된 타입만 사용한다.
- Runtime Layer는 Service 내부 구현(라이브러리 내부 API)에 직접 의존하지 않는다.
- 하드웨어 이벤트(E-stop, 배터리, 토크)는 Interface 이벤트로 정규화 후 Runtime으로 전달한다.
- 인터페이스 변경은 반드시 `interface_specification.md` 선반영 후 구현한다.

### 3.2 안전/전원 관리 책임 분리(SR-74)
- Runtime 책임: 새 임무 수락/거부 정책, 저전력 상태 전환, 임무 중단 우선순위 결정.
- Service 책임: 모션/추론 컴포넌트의 부하 제어(주기, 처리율, sleep policy) 적용.
- Hardware 책임: BMS 상태 신호 제공, UPS 전원 이벤트 전달, 구동계 차단.
- 관제 책임: 잔량, 운용시간, 임무 사이클 로그 수집 및 경보 노출.
- P-74(4h), P-75(25%), P-66(15%)는 운영 정책 기준값으로 적용하며 TBD 항목은 PoC 측정 후 확정.

## 4. Infrastructure & Operation Boundary

### 4.1 통제된 실내 시험 운용 표기 정책(SR-80)
- 본체 스티커/디스플레이 고정 문구:
  - "통제된 실내 환경 시험 운용"
  - "현장 배포 미인증"
- 관제 UI 상단 상태 배너 동일 문구 노출.
- 로그 헤더에 운용 범위 태그 `operation_scope=poc_indoor_only` 저장.

### 4.2 관제/로그/시뮬레이션 연계 경계
- 관제 경계: 운영 명령/상태 조회/알람 확인까지 허용, 안전 우회 명령 금지.
- 로깅 경계: MCAP + 이벤트 로그(Foxglove 시각화) 수집, 안전 이벤트는 별도 심각도 태깅.
- 시뮬레이션 경계: Gazebo/Isaac에서 검증된 시나리오만 실기체 이관.
- 포렌식 데이터: [TBD: 기술조사 미반영] (보존 기간/암호화 정책은 별도 보안 문서 확정 필요).

## 기술조사 근거 메모
- 미들웨어/통신: ROS2 Jazzy + Cyclone DDS + Zenoh + micro-ROS MUST (영역 A BLUF)
- 시간 동기화: PTP(linuxptp) MUST, RPi5 master/L1 slave, 목표 <100us (영역 B BLUF)
- 로깅/관측: Foxglove + MCAP MUST (영역 K BLUF)
- 안전/전원: Sub-1GHz E-stop, 48V Li-ion BMS, UPS MUST (영역 L BLUF)
