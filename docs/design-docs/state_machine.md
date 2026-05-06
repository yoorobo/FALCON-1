# FALCON-1 State Machine (SM)

- 기준: `docs/design-docs/FALCON-1_Detailed_Design_Master_Plan.md` §3.4
- 선행 참조: `docs/design-docs/interface_specification.md`, `docs/design-docs/erd.md`

## SR 매핑표

| 위임 SR ID | SR 내용 요약 |
|---|---|
| SR-06 | 유효 명령 등록 후 피드백 및 실행 진입 |
| SR-07 | 비상정지 시 일반 피드백 억제 |
| SR-14 | arm_lock_active 진입/해제 |
| SR-15 | 잠금 중 양팔 안전자세 고정 및 궤적 거부 |
| SR-25 | 베이스 미정지 시 파지 시퀀스 거부 |
| SR-30 | 매니퓰레이션 모드 진입 가드 |
| SR-31 | 정지 충족 시 잠금 해제 및 조작 활성 |
| SR-32 | 조작 중 베이스 주행 명령 거부 |
| SR-40 | handover_active 진입/해제 정의 |
| SR-50 | 파지 완료 후 handover_active 해제 |
| SR-65 | heartbeat 누락 전역전환 |
| SR-66 | 배터리 부족 전역전환 |
| SR-67 | localization 이상 전역전환 |
| SR-71 | 비상정지 판정 로직 활성 시점 |
| SR-72 | 주행/추종 중 팔 안전자세 유지 |
| SR-73 | 베이스 미정지 매니퓰레이션 거부 |

## 1. State Set and Semantics

### 1.1 전역 상태 enum 정의
- `BOOT`: 시스템 초기화
- `IDLE`: 대기/명령 수신
- `VOICE_ACK`: 명령 확인 피드백 처리(SR-06)
- `NAVIGATING`: 목적지 이동
- `FOLLOWING`: 작업자 추종
- `MANIP_PREPARE`: 조작 전 가드 판정(SR-30)
- `MANIP_ACTIVE`: 공구 파지/반납 수행
- `HANDOVER_ACTIVE`: 전달 시퀀스 수행
- `RETURNING`: 복귀 시퀀스
- `EMERGENCY_STOP`: 전역 안전 정지

### 1.2 모드별 허용/금지 동작
| 상태 | 허용 | 금지 |
|---|---|---|
| FOLLOWING | `/falcon1/navigation/*` 제어, 추종 | 팔 궤적 명령(SR-72) |
| MANIP_ACTIVE | 팔 궤적, 그리퍼 제어 | 베이스 주행 명령(SR-32) |
| HANDOVER_ACTIVE | 손 제스처/외력 감지, 제한 속도 동작 | 자동 재시도 시작(SR-56 연계) |
| EMERGENCY_STOP | 안전 원인 알림, 관리자 리셋 | 모든 자율 모션 명령 |

## 2. Transition Matrix

### 2.1 정상 전환 트리거
| From | To | Trigger | Guard |
|---|---|---|---|
| BOOT | IDLE | `boot_ready` | SR-71 활성 시점 도달 |
| IDLE | VOICE_ACK | `cmd_valid` | SR-01/SR-03 통과 |
| VOICE_ACK | NAVIGATING | `ack_done` | SR-06 |
| NAVIGATING | FOLLOWING | `worker_lock` | 작업자 추종 가능 |
| FOLLOWING | MANIP_PREPARE | `tool_task_start` | 베이스 정지 필요 |
| MANIP_PREPARE | MANIP_ACTIVE | `base_stationary` | SR-30 통과 |
| MANIP_ACTIVE | HANDOVER_ACTIVE | `handover_start` | SR-39/41 통과 |
| HANDOVER_ACTIVE | RETURNING | `handover_done` | SR-50 |
| RETURNING | IDLE | `mission_complete` | 복귀 완료 |

### 2.2 전역전환(E-stop/heartbeat/battery/localization)
| From | To | Trigger | Source Topic |
|---|---|---|---|
| `*` | EMERGENCY_STOP | `estop_chassis` | `/falcon1/safety/estop/chassis` |
| `*` | EMERGENCY_STOP | `estop_worker_remote` | `/falcon1/safety/estop/worker_remote` |
| `*` | EMERGENCY_STOP | `estop_safety_remote` | `/falcon1/safety/estop/safety_remote` |
| `*` | EMERGENCY_STOP | `heartbeat_timeout` | `/falcon1/system/heartbeat` (SR-65) |
| `*` | EMERGENCY_STOP | `battery_critical` | `/falcon1/system/battery_state` (SR-66) |
| `*` | EMERGENCY_STOP | `localization_invalid` | `/falcon1/navigation/localization_status` (SR-67) |

ShopPinkki 차용 패턴:
- 전역전환 테이블을 정상 전환과 분리
- 횡단 변수는 상태와 별도 정의

## 3. Cross-Cutting Variables

### 3.1 arm_lock_active 정의/진입/해제
- 정의: 베이스 이동 중 양팔의 매니퓰레이션 궤적 차단 플래그.
- 진입: 상태가 `NAVIGATING` 또는 `FOLLOWING`에 진입할 때.
- 해제: `MANIP_PREPARE`에서 SR-30 조건 충족 후 `MANIP_ACTIVE` 전환 시.
- 연계 정책: true일 때 `manipulation/gripper_wrench`는 read-only 감시, 궤적 명령 reject.

### 3.2 handover_active 정의/진입/해제
- 정의: 전달 시퀀스 중 안전 제약 및 외력 판정을 활성화하는 플래그.
- 진입: `MANIP_ACTIVE -> HANDOVER_ACTIVE` 전환 시점(SR-40).
- 해제: 공구 릴리스 완료 또는 회피 트리거/중단 처리 완료 시(SR-50, SR-52, SR-53).
- 연계 정책: true일 때 TCP 속도 제한과 회피 판정 우선 적용.

## 4. Callback and Guard Contracts

### 4.1 on_enter/on_exit 콜백 책임
- `on_enter_VOICE_ACK`: LED/TTS 피드백 트리거, 비상정지 상태면 억제(SR-07).
- `on_enter_FOLLOWING`: `arm_lock_active=true` 설정.
- `on_enter_MANIP_ACTIVE`: 베이스 주행 명령 차단 활성화.
- `on_enter_HANDOVER_ACTIVE`: `handover_active=true`, 회피 감시 타이머 시작.
- `on_enter_EMERGENCY_STOP`: 모션 정지, 알람 발행, 안전 로그 작성.
- `on_exit_EMERGENCY_STOP`: 관리자 리셋 완료 검증 후 변수 초기화.

### 4.2 전이 가드(베이스 정지, 재개 명령, 잠금 조건)
- SR-30 가드: `|v_linear|=0`, `|v_angular|=0`, `pose_error<=P-30`.
- SR-25/SR-73 가드: 베이스 미정지 상태에서 조작 명령 즉시 거부.
- 재개 가드: `EMERGENCY_STOP -> IDLE`은 `/falcon1/srv/safety/estop_reset` 성공 이후만 허용.
- 임계값 TBD: P-67/P-67b(로컬라이제이션), P-27/P-48(조작 임계)는 PoC 측정 후 확정.
