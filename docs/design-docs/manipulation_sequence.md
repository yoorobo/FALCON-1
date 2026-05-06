# FALCON-1 Manipulation Sequence (MS)

- 기준: `docs/design-docs/FALCON-1_Detailed_Design_Master_Plan.md` §3.6
- 선행 참조: `docs/design-docs/interface_specification.md`, `docs/design-docs/erd.md`, `docs/design-docs/state_machine.md`, `docs/design-docs/safety_pfl_spec.md`

## SR 매핑표

| 위임 SR ID | SR 내용 요약 |
|---|---|
| SR-15 | 이동/추종 중 양팔 안전자세 유지 및 궤적 거부 |
| SR-24 | 슬롯 좌표+메타데이터 기반 공구 파지 |
| SR-33 | 반납 슬롯 점유 확인 후 거치 |
| SR-39 | 손 제스처 감지 후 핸드오버 전개 |
| SR-45 | 전달 방향 벡터 정렬 전달 |
| SR-46 | 정렬 불가 시 중단 및 안전자세 복귀 |
| SR-49 | 외력 판정 후 그리퍼 릴리스/복귀 |
| SR-54 | 회피 트리거 시 궤적 중단·파지 유지 복귀 |
| SR-68 | 비상정지 시 모션 중단 및 안전자세 복귀 |

## 1. Sequence Scope and Preconditions

### 1.1 공구 출고/반납/전달 시퀀스 범위
- 범위 A: Tool Fetch (수납 슬롯에서 공구 출고)
- 범위 B: Tool Return (슬롯 반납 또는 임시 트레이 분기)
- 범위 C: Handover (작업자 전달, 릴리스, 회피 중단)
- 공통 I/O 채널:
  - `/falcon1/perception/slot_detection`
  - `/falcon1/perception/hand_open_state`
  - `/falcon1/manipulation/gripper_wrench`
  - `/falcon1/command/mission_request`

### 1.2 베이스 정지 및 안전자세 전제조건
- SR-30 가드 충족 필수:
  - `|v_linear| = 0`
  - `|v_angular| = 0`
  - `pose_error <= P-30`
- `arm_lock_active=true` 상태(FOLLOWING/NAVIGATING)에서는 조작 명령 거부(SR-15, SR-72).
- PFL 연계 전제:
  - 핸드오버 전개 시 `|v_tcp| <= P-43`
  - 베이스/팔 속도 상한 `P-57`

## 2. Tool Fetch and Return Sequences

### 2.1 슬롯 접근-파지-복귀

Fetch Sequence (입출력 조건 포함)
1. Stage F1: Mission Ingest
- 입력: `MissionContext(tool_id, mission_type=FETCH)`
- 조건: SM 상태 `MANIP_PREPARE -> MANIP_ACTIVE`
- 출력: `Tool`, `Slot`, `GraspProfile` 로드

2. Stage F2: Slot Localization
- 입력: `Slot(frame_id, pose)` + `/falcon1/perception/slot_detection`
- 조건: 슬롯 인식 유효(SR-26 예외 분기 전)
- 출력: 목표 접근 포즈

3. Stage F3: Approach + Pregrasp
- 입력: 목표 접근 포즈, Hand-coded grasp anchor (영역 H MUST)
- 조건: MoveIt2 + Pilz 계획 성공(영역 D MUST)
- 출력: pregrasp pose 도달

4. Stage F4: Grasp & Lift
- 입력: 그리퍼 명령 + `/falcon1/manipulation/gripper_wrench`
- 조건: 파지 토크 임계(P-27, TBD) 판정
- 출력: grasp success 또는 `E-GRASP-TORQUE-LOW`

5. Stage F5: Retreat to Safe Pose
- 입력: grasp 결과
- 조건: 성공 시 공구 파지 유지
- 출력: Tucked Pose 복귀 준비

### 2.2 슬롯 점유 예외 및 임시 트레이 분기

Return Sequence
1. Stage R1: Return Mission Load
- 입력: `MissionContext(mission_type=RETURN)`
- 출력: 대상 `Slot`, `TemporaryTray`

2. Stage R2: Slot Occupancy Check
- 입력: `/falcon1/perception/slot_detection`
- 조건 A: `occupancy_state=EMPTY` -> 슬롯 거치 진행(SR-33)
- 조건 B: `occupancy_state=OCCUPIED|UNKNOWN` -> 임시 트레이 분기(SR-34)

3. Stage R3A: Slot Place
- 입력: 슬롯 포즈, 공구 포즈
- 출력: 슬롯 거치 완료 로그

4. Stage R3B: Temporary Tray Place
- 입력: `TemporaryTray(frame_id, pose)`
- 출력: 임시 거치 완료 + 원인 로그(`E-SLOT-OCCUPIED`)

5. Stage R4: Post-Place Retreat
- 출력: 안전자세 복귀, `MissionContext` 종료

## 3. Handover Sequences

### 3.1 손 제스처 확인-전개-정렬
1. Stage H1: Gesture Qualification
- 입력: `/falcon1/perception/hand_open_state`
- 조건: 안정 감지 시간 >= P-41
- 실패: 타임아웃(P-42) 시 중단 분기

2. Stage H2: Arm Deploy
- 입력: 작업자 손 위치/방향
- 조건: `handover_active=true` 진입
- 출력: 전개 포즈 도달

3. Stage H3: Orientation Align
- 입력: `HandoverVector(vx,vy,vz)`
- 조건: 손잡이 방향 정렬 가능
- 실패: 정렬 불가 시 SR-46 경로(중단 후 안전자세)

### 3.2 외력 감지-릴리스-복귀
1. Stage H4: Pull/Force Detect
- 입력: `/falcon1/manipulation/gripper_wrench`
- 조건: 외력/토크 >= P-48 (TBD)

2. Stage H5: Gripper Release
- 조건: 판정 성공 후 P-49 이내 릴리스
- 출력: 공구 인계 완료

3. Stage H6: Safe Return
- 출력: `handover_active=false`, Tucked Pose 복귀

### 3.3 회피 트리거 중단-안전자세 복귀
- 트리거 A: 작업자 거리 > P-52
- 트리거 B: 손 제스처 미검출 >= P-53
- 동작:
  1. 모든 관절 궤적 즉시 중단
  2. 그리퍼 파지 유지
  3. 안전자세 복귀(SR-54)
  4. 동일 임무 자동 재시도 금지(SR-56)

## 4. Motion Constraints

### 4.1 전달 방향 벡터 정렬 제약
- 제약 정의:
  - `tool_handle_axis · worker_hand_axis >= cos(theta_max)`
  - `hazard_axis`는 작업자 반대 방향 유지
- 벡터 소스: `ERD.HandoverVector`
- 정렬 실패 처리: SR-46 중단 경로
- `theta_max`: [TBD: 기술조사 미반영]

### 4.2 안전 속도/관절 한계/PFL 연동
- 핸드오버 활성 중 TCP 속도 `P-43=250 mm/s` 상한 적용
- 베이스/팔 전체 안전 속도 `P-57=250 mm/s` 상한 적용
- 정지 계층:
  - `SoftStop` -> `ControlledStop` -> `PowerCut`
- 비상정지(SR-68) 시:
  - 베이스 속도 0
  - 팔 궤적 중단
  - Tucked Pose 복귀

## TBD 임계값 관리
- P-27, P-48, P-59, P-67, P-67b는 PoC 측정 후 확정
