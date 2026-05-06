# FALCON-1 Safety PFL Specification

- 기준: `docs/design-docs/FALCON-1_Detailed_Design_Master_Plan.md` §3.5
- 선행 참조: `docs/design-docs/interface_specification.md`, `docs/design-docs/state_machine.md`

## SR 매핑표

| 위임 SR ID | SR 내용 요약 |
|---|---|
| SR-18 | 근접도 기반 베이스 속도 감속 클램프 |
| SR-19 | 충돌 임박 거리 내 즉시 정지 |
| SR-43 | 핸드오버 중 TCP 속도 상한 강제 |
| SR-57 | 베이스/팔 인체 충돌 안전 속도 제한 |
| SR-58 | 위험성 평가 완료 후 운용 개시 |
| SR-59 | 충돌 토크 임계 초과 시 구동 차단 |
| SR-68 | 비상정지 시 모션 중단 및 안전자세 복귀 |

## 1. Safety Scope and Standards

### 1.1 ISO 10218-2 PFL 적용 범위
- 적용 객체: Vic Pinky 베이스, OpenArm 양팔, 핸드오버 TCP 구간.
- 적용 모드: FOLLOWING, MANIP_ACTIVE, HANDOVER_ACTIVE.
- 기준:
  - SR-43: TCP 최대 선속도 `P-43=250 mm/s`
  - SR-57: 베이스/관절 속도 상한 `P-57=250 mm/s`
- 참고 표준: ISO 10218-2, ISO 13849(영역 L narrative).

### 1.2 PoC 안전 게이트와 인증 경계
- PoC 게이트:
  1. Gazebo/Isaac 안전 시나리오 통과
  2. E-stop 3경로(본체/작업자/안전관리자) 동작 확인
  3. 비상정지 후 안전자세 복귀 검증
- 인증 경계:
  - v1.0: PoC 안전 내러티브 수준
  - v1.1+: Safety PLC + 인증기관 시험 [TBD: 기술조사 미반영]

## 2. Quantitative Safety Profiles

### 2.1 베이스 속도 클램프/정지 조건
| 조건 | 제어 |
|---|---|
| 장애물 거리 > P-19 | 정상 속도 프로파일 |
| 장애물 거리 <= P-19 + hysteresis | 속도 선형 감속(SR-18) |
| 장애물 거리 <= P-19 (0.3m) | 즉시 정지(SR-19) |

입력 채널:
- `/falcon1/perception/worker_distance`
- `/falcon1/navigation/localization_status`

### 2.2 TCP 속도 제한 프로파일
- 핸드오버 활성 중 `|v_tcp| <= P-43` 강제.
- MoveIt2/Pilz 궤적 생성 시 속도 스케일 clamp 적용.
- 궤적 실행 중 주기 감시: `/falcon1/manipulation/gripper_wrench` + 조인트 상태.
- 정렬 실패/회피 트리거 발생 시 즉시 중단 후 안전자세 복귀.

### 2.3 충돌 감지 토크/정지 계층
정지 계층:
1. `SoftStop`: 속도 0으로 감속 후 hold
2. `ControlledStop`: 컨트롤러 모션 즉시 중단
3. `PowerCut`: 하드웨어 E-stop(Cat 0/1)

- SR-59 토크 임계(P-59)는 현재 TBD.
- 임계 초과 시 `ControlledStop -> PowerCut` 순서 적용.
- P-27/P-48(그리퍼 계열) 또한 PoC 측정 전까지 고정치 미사용.

## 3. Stop and Recovery Logic

### 3.1 즉시 정지(Cat 0/1) 인터락
- 트리거:
  - `/falcon1/safety/estop/chassis`
  - `/falcon1/safety/estop/worker_remote`
  - `/falcon1/safety/estop/safety_remote`
  - heartbeat timeout(SR-65), battery critical(SR-66), localization invalid(SR-67)
- 인터락 정책:
  - EMERGENCY_STOP 진입 시 모든 궤적 인터페이스 disable
  - 재개는 `/falcon1/srv/safety/estop_reset` 성공 후만 가능

### 3.2 안전 자세 복귀 정책(SR-68)
- 목표: 양팔 Tucked Pose 복귀, 베이스 정지 유지.
- 복귀 순서:
  1. 베이스 속도 명령 0
  2. 팔 궤적 중단
  3. 안전 자세 목표 송신
  4. 상태 확인 후 IDLE 복귀 가능
- 실패 시 처리: [TBD: 기술조사 미반영] (재시도 횟수/수동介입 규칙)

## 4. Validation Plan

### 4.1 Gazebo/Isaac safety test 항목
- T1: 장애물 급접근 시 SR-18 감속, SR-19 정지 검증
- T2: 핸드오버 중 TCP 속도 상한(P-43) 초과 미발생 검증
- T3: E-stop 3경로 입력별 EMERGENCY_STOP 전환 검증
- T4: heartbeat/battery/localization 이상 주입 시 전역전환 검증
- T5: 정지 후 안전자세 복귀(SR-68) 검증
- 로그 증적: MCAP + SafetyEventLog 동시 확보(영역 K)

### 4.2 TBD 파라미터 측정 계획(P-27/P-48/P-59/P-67/P-67b)
- P-27(파지 토크), P-48(핸드오버 외력), P-59(충돌 토크), P-67/67b(로컬라이제이션 임계)는 PoC 측정 후 확정.
- 측정 환경:
  - 통제된 실내, 표준 공구 4종, 반복 30회 이상 [TBD: 기술조사 미반영]
- 산출물:
  - 임계값 캘리브레이션 리포트
  - SR 임계값 표 업데이트 제안
