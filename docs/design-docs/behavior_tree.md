# FALCON-1 Behavior Tree (BT)

- 기준: `docs/design-docs/FALCON-1_Detailed_Design_Master_Plan.md` §3.7
- 선행 참조: `docs/design-docs/state_machine.md`, `docs/design-docs/manipulation_sequence.md`, `docs/design-docs/safety_pfl_spec.md`

## SR 매핑표

| 위임 SR ID | SR 내용 요약 |
|---|---|
| SR-04 | 음성 저신뢰 입력 거부 분기 |
| SR-05 | 미등록 발화 거부 분기 |
| SR-11 | 매핑 좌표 기반 이동 경로 실행 |
| SR-16 | 작업자 정지 판정 시 안전 이격 정지 |
| SR-20 | 장애물 이탈 후 자동 재개 금지 |
| SR-23 | 추종 분실 후 재호출 기반 재개 |
| SR-29 | 파지 실패 자동 재시도 금지 |
| SR-34 | 슬롯 점유 시 임시 트레이 분기 |
| SR-37 | 미등록 공구 즉시 거부 |
| SR-42 | 핸드오버 타임아웃 취소 |
| SR-56 | 회피 취소 후 자동 재시도 금지 |
| SR-75 | 예비 배터리 임계 시 신규 임무 거부 |
| SR-76 | 임무 사이클 시간 최적화 |

## 1. BT Scope and Runtime Boundary

### 1.1 FSM-SM과 BT의 책임 경계
- SM 책임: 상태 전환, 전역 안전 전환, 모드 가드.
- BT 책임: 각 상태 내 미션 흐름(정상/예외/재개).
- 원칙:
  - BT는 SM 상태를 바꾸지 않고 이벤트를 발행한다.
  - 상태 전환 최종 권한은 SM에 있다.

### 1.2 임무 단위 트리 구성 원칙
- 상위 트리는 `Sequence` 중심으로 정상 흐름 구성.
- 예외는 `Fallback` 노드에서 분기 처리.
- 모든 Leaf는 명시적 입력/출력 조건을 가진다.
- timeout/retry 정책은 데코레이터로 분리 표기.

## 2. Mission Trees

### 2.1 호출-이동-출고-전달-복귀 기본 트리
```text
Sequence MissionRoot
  Condition SystemReady
  Fallback VoiceCommandGate
    Condition VoiceConfidence>=P-04
    Action RejectLowConfidence (SR-04)
  Fallback RegisteredCommandGate
    Condition CommandInRegistry
    Action RejectUnknownCommand (SR-05)
  Action DispatchMissionRequest
  Action NavigateToWorkZone (SR-11)
  Action ExecuteToolFetch (MS Stage F1~F5)
  Action ExecuteHandover (MS Stage H1~H6)
  Action ReturnToStandby
  Action RecordMissionCycleTime (SR-76)
```

SM 매핑:
- `IDLE -> VOICE_ACK -> NAVIGATING -> MANIP_ACTIVE -> HANDOVER_ACTIVE -> RETURNING -> IDLE`

### 2.2 추종 임무 트리
```text
Sequence FollowMission
  Condition FollowCommandActive
  Action EnterFollowingMode
  Fallback KeepSafeDistance
    Condition WorkerStoppedDetected (SR-16)
    Action DecelerateAndStopAtSafeDistance
  Fallback LostWorkerHandling
    Condition WorkerTrackingHealthy
    Action HoldAndAnnounceLoss (SR-23)
  Fallback ResumePolicy
    Condition RecallCommandReceived
    Action ResumeFollow
```

## 3. Exception and Fallback Trees

### 3.1 음성 미인식/미등록 거부 분기
```text
Fallback VoiceExceptionTree
  Condition VoiceConfidence>=P-04
  Action RejectLowConfidenceAndPrompt (SR-04)
  Fallback CommandRegistryTree
    Condition CommandRegistered
    Action RejectUnregisteredUtterance (SR-05)
```

### 3.2 추종 분실/슬롯 점유/미등록 공구 분기
```text
Fallback TaskExceptionTree
  Fallback WorkerLostTree
    Condition WorkerTrackingHealthy
    Action StopAndWaitRecall (SR-23)
  Fallback SlotOccupancyTree
    Condition SlotEmpty
    Action PlaceToTemporaryTray (SR-34)
  Fallback ToolRegistryTree
    Condition ToolRegistered
    Action RejectToolMission (SR-37)
```

### 3.3 핸드오버 타임아웃/회피 취소 분기
```text
Fallback HandoverExceptionTree
  Condition HandPoseDetectedWithinP42
  Action AbortHandoverAndSafePose (SR-42)
  Fallback AvoidanceCancelTree
    Condition AvoidanceNotTriggered
    Action CancelAndHoldGrip_NoAutoRetry (SR-56)
```

## 4. Timeout, Retry, Resume Policies

### 4.1 자동 재시도 금지 정책 반영(SR-29, SR-56)
- 파지 실패: 동일 미션 자동 재시도 금지, 신규 호출/관리자 재시도 명령 필요.
- 핸드오버 회피 취소: 동일 미션 자동 재개 금지.
- BT 구현:
  - `RetryUntilSuccessful` 데코레이터 미사용
  - 실패 후 `AwaitExternalResume` 액션으로 종료

### 4.2 재개 명령 기반 재진입 정책(SR-20, SR-23, SR-75)
- 장애물 이탈 후 자동 주행 재개 금지(SR-20).
- 추종 분실 후 재호출 수신 시에만 재진입(SR-23).
- 배터리 예비 임계 도달 시 신규 임무 수락 금지(SR-75).

정책 트리:
```text
Fallback ResumePolicyTree
  Condition ExternalResumeCommandReceived
  Condition BatteryAboveReserveThreshold(P-75)
  Action ReEnterMissionFromCheckpoint
```

## 기술 근거 메모
- Nav2 + slam_toolbox + AMCL MUST (영역 C)
- MoveIt2 + Pilz + MTC + ros2_control MUST (영역 D)
- YOLOv11 + MediaPipe Hands + AprilTag MUST (영역 E)
- librealsense2 + Open3D + PCL MUST (영역 F)
- PTT primary + VAD fallback + faster-whisper/Piper TTS MUST (영역 G)

## TBD 임계값 관리
- P-27, P-48, P-59, P-67, P-67b는 PoC 측정 후 확정
