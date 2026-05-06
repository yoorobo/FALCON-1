# FALCON-1 Entity Relationship Design (ERD)

- 기준: `docs/design-docs/FALCON-1_Detailed_Design_Master_Plan.md` §3.3
- 선행 참조: `docs/design-docs/interface_specification.md`

## SR 매핑표

| 위임 SR ID | SR 내용 요약 |
|---|---|
| SR-02 | 부팅 시 명령 집합 적재 정책 |
| SR-10 | 매핑 데이터 적재 전제 |
| SR-24 | 공구 메타데이터 조회 기반 파지 |
| SR-28 | 파지 실패 사유 로그 스키마 |
| SR-34 | 슬롯 점유 시 임시 트레이 대체 데이터 |
| SR-35 | 임시 트레이 거치 사유 로그 |
| SR-36 | 공구 등록 필수 메타데이터 |
| SR-44 | 전달 방향 벡터 필수 메타데이터 |
| SR-70 | 다중 비상정지 사유 로그 무결성 |
| SR-77 | 임무 시간 초과 사유 로그 무결성 |

## 1. Data Domain Scope

### 1.1 명령 집합/공구 메타데이터/로그 범위
- 명령 집합 도메인: 음성 명령 토큰, 명령 타입, 허용 상태, 우선순위.
- 공구 메타데이터 도메인: 공구 ID, 슬롯 위치, 파지 포즈, 3D 매칭 참조, 전달 방향 벡터.
- 운영 로그 도메인: 임무 수행 로그, 실패 코드, 안전 이벤트, 운영 범위 태그.

### 1.2 런타임 상태 vs 영속 데이터 분리
- 런타임 상태(메모리): `arm_lock_active`, `handover_active`, 현재 임무 컨텍스트, 최신 센서 스냅샷.
- 영속 데이터(DB/파일): 공구 등록 정보, 슬롯 맵, 명령 사전, 임무/안전 이벤트 이력.
- MCAP 스트림: 시계열 원시 데이터(토픽 기반), ERD는 색인/요약 레코드만 저장.

## 2. Core Entities

### 2.1 CommandSet / MissionContext

`CommandSet`
| 필드 | 타입 | 제약 |
|---|---|---|
| command_id | UUID | PK |
| phrase_ko | VARCHAR(64) | UNIQUE, NOT NULL |
| intent | ENUM(`CALL_TOOL`,`RETURN_TOOL`,`STOP`,`RETURN_BASE`) | NOT NULL |
| enabled | BOOLEAN | default=true |
| loaded_at | TIMESTAMP | 부팅 시점 기록(SR-02) |

`MissionContext`
| 필드 | 타입 | 제약 |
|---|---|---|
| mission_id | UUID | PK |
| tool_id | VARCHAR(32) | FK -> Tool.tool_id |
| mission_type | ENUM(`FETCH`,`RETURN`,`HANDOVER`,`RECOVERY`) | NOT NULL |
| state_code | ENUM 참조 | NOT NULL |
| created_at | TIMESTAMP | NOT NULL |
| closed_at | TIMESTAMP | NULL 허용 |

### 2.2 Tool / Slot / TemporaryTray

`Tool`
| 필드 | 타입 | 제약 |
|---|---|---|
| tool_id | VARCHAR(32) | PK |
| tool_name | VARCHAR(64) | NOT NULL |
| grasp_profile_id | UUID | FK -> GraspProfile |
| handover_vector_id | UUID | FK -> HandoverVector |
| slot_id | VARCHAR(32) | FK -> Slot.slot_id |
| is_active | BOOLEAN | default=true |

`Slot`
| 필드 | 타입 | 제약 |
|---|---|---|
| slot_id | VARCHAR(32) | PK |
| frame_id | VARCHAR(64) | NOT NULL |
| pos_x,pos_y,pos_z | FLOAT | NOT NULL |
| qx,qy,qz,qw | FLOAT | NOT NULL |
| occupancy_state | ENUM(`EMPTY`,`OCCUPIED`,`UNKNOWN`) | NOT NULL |

`TemporaryTray`
| 필드 | 타입 | 제약 |
|---|---|---|
| tray_id | VARCHAR(32) | PK |
| frame_id | VARCHAR(64) | NOT NULL |
| pos_x,pos_y,pos_z | FLOAT | NOT NULL |
| capacity | INT | CHECK(capacity>0) |

### 2.3 HandoverVector / SafetyEventLog

`HandoverVector`
| 필드 | 타입 | 제약 |
|---|---|---|
| handover_vector_id | UUID | PK |
| tool_id | VARCHAR(32) | UNIQUE FK -> Tool.tool_id |
| vx,vy,vz | FLOAT | NOT NULL, norm>0 |
| hazard_axis_rule | VARCHAR(128) | NOT NULL |

`SafetyEventLog`
| 필드 | 타입 | 제약 |
|---|---|---|
| safety_event_id | UUID | PK |
| mission_id | UUID | FK -> MissionContext.mission_id |
| trigger_source | ENUM(`ESTOP_CHASSIS`,`ESTOP_WORKER`,`ESTOP_SAFETY`,`HEARTBEAT`,`BATTERY`,`LOCALIZATION`,`COLLISION`) | NOT NULL |
| first_trigger_ts | TIMESTAMP | NOT NULL |
| all_causes_json | JSONB | 다중 사유 기록(SR-70) |
| recovery_required | BOOLEAN | NOT NULL |

## 3. State and Code Definitions

### 3.1 상태 코드(enum) 정의
`state_code`
- `BOOT`, `IDLE`, `VOICE_ACK`, `NAVIGATING`, `FOLLOWING`, `MANIP_PREPARE`, `MANIP_ACTIVE`, `HANDOVER_ACTIVE`, `RETURNING`, `EMERGENCY_STOP`

`mission_outcome`
- `SUCCESS`, `FAILED_RETRY_BLOCKED`, `FAILED_SAFETY_STOP`, `FAILED_PERCEPTION`, `FAILED_MANIPULATION`

### 3.2 실패 사유 코드 및 감사 로그 스키마
`failure_code`
- `E-ASR-LOWCONF` (SR-04 연계)
- `E-TOOL-NOT-REGISTERED` (SR-37 연계)
- `E-SLOT-NOT-FOUND` (SR-26)
- `E-GRASP-TORQUE-LOW` (SR-27, P-27 TBD)
- `E-HANDOVER-FORCE-LOW` (SR-48, P-48 TBD)
- `E-HEARTBEAT-TIMEOUT` (SR-65)
- `E-BATTERY-LOW` (SR-66)
- `E-LOCALIZATION-INVALID` (SR-67, P-67/P-67b TBD)
- `E-COLLISION-TORQUE` (SR-59, P-59 TBD)

`AuditLog`
| 필드 | 타입 | 제약 |
|---|---|---|
| audit_id | UUID | PK |
| ts | TIMESTAMP | NOT NULL |
| source_topic | VARCHAR(128) | IS의 토픽명 사용 |
| event_type | VARCHAR(64) | NOT NULL |
| event_payload | JSONB | NOT NULL |
| hash_chain | VARCHAR(128) | [TBD: 기술조사 미반영] |

## 4. Integrity and Validation Rules

### 4.1 등록 필수 메타데이터 제약(SR-36, SR-44)
- 공구 등록 승인 조건:
  - `Tool.grasp_profile_id` NOT NULL
  - `Tool.slot_id` NOT NULL
  - `HandoverVector(vx,vy,vz)` 존재
  - 3D 매칭 템플릿 참조 존재(`[TBD: 기술조사 미반영]` 저장 경로 규약)
- 미충족 시 `E-TOOL-NOT-REGISTERED` 반환 및 등록 거부.

### 4.2 임무·안전 이벤트 로그 무결성(SR-70, SR-77)
- SR-70: 다중 비상정지 원인 발생 시 `first_trigger_ts` 단일 기준 + `all_causes_json` 전체 원인 보존.
- SR-77: 임무 목표시간 초과 시 임무 종료 전 로그 레코드 강제 flush.
- 동기 기준: PTP 기준시각 사용(영역 B), timestamp drift 기준 `[TBD: 기술조사 미반영]`.
- MCAP 연계: `mission_id`로 이벤트 로그와 토픽 재생 데이터 연결(영역 K).
