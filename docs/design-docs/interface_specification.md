# FALCON-1 Interface Specification (IS)

- 기준: `docs/design-docs/FALCON-1_Detailed_Design_Master_Plan.md` §3.2
- 참조: SR v2.0 `interface_specification.md` 위임 항목

## SR 매핑표

| 위임 SR ID | SR 내용 요약 |
|---|---|
| SR-01 | PTT 음성 입력 처리 및 명령 매칭 통신 규약 |
| SR-03 | PTT 활성 상태에서만 오디오 수신 |
| SR-12 | 운용영역 밖 목적지 거부 인터페이스 |
| SR-13 | 작업자 상대 위치 센서 융합 인터페이스 |
| SR-26 | 슬롯 미식별 비전 인터페이스 |
| SR-27 | 파지 토크 임계 판정 인터페이스 |
| SR-33 | 반납 슬롯 점유 판별 비전 인터페이스 |
| SR-36 | 공구 등록 절차 인터페이스 |
| SR-39 | 손 펼침 감지 기반 핸드오버 인터페이스 |
| SR-41 | 손 제스처 안정 감지 시간 인터페이스 |
| SR-48 | 핸드오버 외력/토크 임계 판정 인터페이스 |
| SR-52 | 작업자 후퇴 거리 감지 인터페이스 |
| SR-53 | 손 제스처 미감지 회피 인터페이스 |
| SR-60 | 본체 물리 E-stop 하드웨어 접점 인터페이스 |
| SR-61 | 작업자용 무선 E-stop 채널 인터페이스 |
| SR-62 | 안전관리자용 무선 E-stop 채널 인터페이스 |
| SR-63 | 무선 E-stop 페어링/헬스체크 인터페이스 |
| SR-64 | 비상정지 해제(리셋) 절차 인터페이스 |
| SR-78 | 매핑 좌표계 외 목표 거부 인터페이스 |
| SR-79 | 비인가 네트워크 차단 인터페이스 |

## 1. Interface Scope and Naming Rules

### 1.1 ROS2 topic/service/action 네이밍
- 네임스페이스: `/falcon1/<domain>/<component>/<signal>`
- 토픽:
  - 상태: `/falcon1/system/state/*`
  - 명령: `/falcon1/command/*`
  - 안전: `/falcon1/safety/*`
  - 인지: `/falcon1/perception/*`
- 서비스: `/falcon1/srv/<domain>/<action>`
- 액션: `/falcon1/action/<domain>/<mission>`
- 메시지 타입 규칙:
  - 표준형 우선(`std_msgs`, `geometry_msgs`, `sensor_msgs`)
  - 도메인 특화는 `falcon1_interfaces/msg|srv|action` 사용

### 1.2 외부(JSON/TCP/UDP) 인터페이스 명명
- 관제 API 엔벨로프:
  - `type`: 메시지 종류
  - `ts`: ISO-8601 UTC timestamp
  - `robot_id`: 장치 식별자
  - `payload`: 실제 데이터
- 이벤트 명명: `<domain>.<event>` (예: `safety.estop_triggered`)
- 에러 코드: `FALCON1-<DOMAIN>-<NNN>`

## 2. ROS2 Interface Contracts

### 2.1 음성/명령 입력 채널

| 채널 | Topic/Action/Service | Msg Type | QoS | 주기/타임아웃 | 관련 SR |
|---|---|---|---|---|---|
| PTT 상태 입력 | `/falcon1/hri/ptt_state` | `std_msgs/Bool` | Reliable, KeepLast(10) | event-driven | SR-03 |
| 헬멧 오디오 입력 | `/falcon1/hri/audio_in` | `audio_common_msgs/AudioData` | BestEffort, KeepLast(5) | stream 16kHz | SR-01, SR-03 |
| 음성 인지 결과 | `/falcon1/hri/asr_result` | `falcon1_interfaces/msg/AsrResult` | Reliable, KeepLast(10) | <= 1.0s 응답 목표 | SR-01 |
| 명령 디스패치 | `/falcon1/command/mission_request` | `falcon1_interfaces/msg/MissionRequest` | Reliable, KeepLast(10) | event-driven | SR-01 |
| 명령 집합 조회 | `/falcon1/srv/command_registry/get` | `falcon1_interfaces/srv/GetCommandSet` | Reliable | request/response | SR-01 |

기술 근거:
- HRI 파이프라인(PTT primary + VAD fallback, ASR/TTS 분리): 영역 G BLUF

### 2.2 추종/위치/슬롯/핸드오버 센서 채널

| 채널 | Topic/Action/Service | Msg Type | QoS | 주기/타임아웃 | 관련 SR |
|---|---|---|---|---|---|
| 작업자 추종 추정 | `/falcon1/perception/worker_pose` | `geometry_msgs/PoseStamped` | BestEffort, KeepLast(5) | 10-30Hz [TBD: 기술조사 미반영] | SR-13 |
| 로컬라이제이션 상태 | `/falcon1/navigation/localization_status` | `falcon1_interfaces/msg/LocalizationHealth` | Reliable, KeepLast(10) | 5Hz | SR-12, SR-78 |
| 경로 목표 액션 | `/falcon1/action/navigation/go_to_pose` | `nav2_msgs/action/NavigateToPose` | Reliable | action timeout [TBD: 기술조사 미반영] | SR-12, SR-78 |
| 슬롯 인식 결과 | `/falcon1/perception/slot_detection` | `falcon1_interfaces/msg/SlotDetection` | Reliable, KeepLast(10) | event-driven | SR-26, SR-33 |
| 공구 등록 서비스 | `/falcon1/srv/tool/register` | `falcon1_interfaces/srv/RegisterTool` | Reliable | request/response | SR-36 |
| 손 제스처 상태 | `/falcon1/perception/hand_open_state` | `falcon1_interfaces/msg/HandGestureState` | BestEffort, KeepLast(5) | 15-30Hz [TBD: 기술조사 미반영] | SR-39, SR-41, SR-53 |
| 핸드오버 거리 | `/falcon1/perception/worker_distance` | `std_msgs/Float32` | BestEffort, KeepLast(5) | 15Hz [TBD: 기술조사 미반영] | SR-52 |
| 그리퍼 외력/토크 | `/falcon1/manipulation/gripper_wrench` | `geometry_msgs/WrenchStamped` | Reliable, KeepLast(20) | 50-100Hz [TBD: 기술조사 미반영] | SR-27, SR-48 |

### 2.3 E-stop/heartbeat/battery/localization 상태 채널

| 채널 | Topic/Service | Msg Type | QoS | 주기/타임아웃 | 관련 SR |
|---|---|---|---|---|---|
| 본체 E-stop 입력 | `/falcon1/safety/estop/chassis` | `std_msgs/Bool` | Reliable, KeepLast(10) | event-driven | SR-60 |
| 작업자 무선 E-stop | `/falcon1/safety/estop/worker_remote` | `std_msgs/Bool` | Reliable, KeepLast(10) | event-driven | SR-61 |
| 안전관리자 무선 E-stop | `/falcon1/safety/estop/safety_remote` | `std_msgs/Bool` | Reliable, KeepLast(10) | event-driven | SR-62 |
| 무선 E-stop 페어링 상태 | `/falcon1/safety/estop/pairing_status` | `falcon1_interfaces/msg/EstopPairingStatus` | Reliable, KeepLast(10) | 1Hz | SR-63 |
| E-stop 리셋 서비스 | `/falcon1/srv/safety/estop_reset` | `falcon1_interfaces/srv/ResetEstop` | Reliable | request/response | SR-64 |
| 통신 heartbeat | `/falcon1/system/heartbeat` | `std_msgs/Header` | Reliable, KeepLast(10) | 2Hz (P-65 평가 기준) | SR-63, SR-64 |
| 배터리 상태 | `/falcon1/system/battery_state` | `sensor_msgs/BatteryState` | Reliable, KeepLast(10) | 1Hz | SR-63 |

기술 근거:
- Sub-1GHz wireless E-stop MUST, BMS/UPS MUST: 영역 L BLUF

## 3. External Protocol Contracts

### 3.1 관제 연동 JSON 페이로드

Control Command (`TCP :8080`)
```json
{
  "type": "command.request",
  "ts": "2026-05-06T12:00:00Z",
  "robot_id": "falcon1-01",
  "payload": {
    "cmd": "navigate_to",
    "mission_id": "msn-20260506-001",
    "target": {"x": 12.4, "y": -3.1, "yaw": 1.57},
    "mode": "follow|handover|return"
  }
}
```

Control Ack
```json
{
  "type": "command.ack",
  "ts": "2026-05-06T12:00:00Z",
  "robot_id": "falcon1-01",
  "payload": {
    "mission_id": "msn-20260506-001",
    "accepted": true,
    "reason": null
  }
}
```

Safety Event
```json
{
  "type": "safety.estop_triggered",
  "ts": "2026-05-06T12:00:02Z",
  "robot_id": "falcon1-01",
  "payload": {
    "source": "chassis|worker_remote|safety_remote|heartbeat|battery|localization",
    "latched": true,
    "recovery_required": true
  }
}
```

### 3.2 무선 E-stop 채널 및 리셋 절차 인터페이스
- 물리 채널: Sub-1GHz 무선 E-stop (영역 L 근거)
- 인터페이스 요구:
  - `link_alive`
  - `pairing_state`
  - `last_seen_ms`
  - `channel_id`
- 리셋 절차:
  1. 원인 확인(관제 + 로컬)
  2. 물리 E-stop 해제
  3. `estop_reset` 서비스 호출
  4. 페어링/heartbeat 정상 확인
  5. 수동 승인 후 임무 수락 재개
- 인증 방식: [TBD: 기술조사 미반영]

## 4. Network and Security Boundary

### 4.1 허용 포트/세그먼트/주체

| 구간 | 프로토콜/포트 | 허용 주체 | 비고 |
|---|---|---|---|
| ROS2 DDS | UDP multicast + unicast | 내부 제어망(Vic Pinky/RPi5/L1) | Cyclone DDS |
| NTP fallback | UDP 123 | 내부 시간원/관리 노드 | 영역 B |
| PTP | IEEE 1588 (L2) | RPi5(master), L1(slave) | 영역 B |
| 관제 명령 | TCP 8080 | 승인된 Admin UI/Control Service | ShopPinkki 패턴 차용 |
| LLM 연동 | HTTP 8000 | 내부 서비스망만 | [TBD: 기술조사 미반영] |
| 로깅/시각화 | [TBD: 기술조사 미반영] | 내부 관제망 | 영역 K는 Foxglove/MCAP MUST |

### 4.2 비인가 네트워크 차단 규칙(SR-79)
- 기본 정책: default deny (허용 목록 외 전부 차단).
- 허용 목록:
  - 사전 등록된 관제 서버 IP/세그먼트
  - 내부 제어망 장치(RPi5, L1, Vic Pinky, OpenArm)
- 차단 대상:
  - 외부 API 직접 호출
  - 미등록 Wi-Fi SSID/클라이언트
  - 임의 포트 스캔/원격 쉘 접근
- 감사 로그:
  - 차단 이벤트 `security.blocked_connection`
  - 출발지/대상/포트/사유 저장

## 기술조사 근거 메모
- 미들웨어: ROS2 Jazzy + Cyclone DDS + Zenoh + micro-ROS MUST (영역 A)
- 시간 동기화: PTP MUST, NTP fallback UDP 123 (영역 B)
- 음성: PTT primary + VAD fallback, ASR/TTS 파이프라인 (영역 G)
- 안전 전원: Sub-1GHz E-stop, BMS, UPS MUST (영역 L)
