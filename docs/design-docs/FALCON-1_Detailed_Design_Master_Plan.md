# FALCON-1 상세설계 마스터 플랜 v2.0

- 기준 문서: `docs/requirements/system_requirements.md` (v2.0, 81건)
- 작성 가이드: `docs/requirements/sr_authoring_guideline.md` (v1.2)
- 목적: SR v2.0의 `상세설계 위임/참조` 컬럼을 기준으로 7종 상세설계 문서의 작성 범위와 순서를 확정한다.

## 1. 적용 원칙

- SR 매핑은 `system_requirements.md`의 `상세설계 위임/참조` 컬럼에서만 추출한다.
- SR에 없는 기술 종속 정보(토픽명, 라이브러리명, 모델명)는 이 마스터 플랜에서 "상세설계에 배치할 항목"으로만 다룬다.
- 임계값 표의 TBD 5건(P-27, P-48, P-59, P-67, P-67b 관련)은 상세설계에서 값 확정하지 않고 PoC 측정 과제로 유지한다.
- 아키텍처 계층/의존성은 `ARCHITECTURE.md`의 레이어 규칙을 따른다.

## 2. 문서 작성 순서(3묶음) 및 의존성

1. 묶음 1: SA + IS
- 이유: 노드/레이어/채널 경계를 먼저 확정해야 이후 데이터·상태·시퀀스 명세의 인터페이스 충돌을 방지할 수 있다.

2. 묶음 2: ERD + SM + PFL
- 이유: IS가 확정된 채널을 기반으로 데이터 모델(ERD), 전역 상태 전환(SM), 안전 제약(PFL)을 고정한다.

3. 묶음 3: MS + BT
- 이유: 조작 시퀀스(MS)와 임무 오케스트레이션(BT)은 앞선 인터페이스/상태/안전 제약을 입력으로 구체화된다.

## 3. 문서별 작성 계획

## 3.1 SA — `system_architecture.md`

### SR 매핑표
| 항목 | 내용 |
|---|---|
| 위임 SR ID | SR-74, SR-80 |
| 매핑 근거 | `system_requirements.md`의 `상세설계 위임/참조` 컬럼 |

### H2/H3 목차 뼈대
## 1. Scope and Layer Boundaries
### 1.1 PoC 운용 범위와 비범위
### 1.2 ARCHITECTURE 레이어 매핑(Runtime/Service/Interface/Hardware)

## 2. Runtime Topology
### 2.1 Vic Pinky + OpenArm 노드 배치
### 2.2 데이터 흐름(음성/내비/매니퓰레이션/안전)

## 3. Cross-Layer Contracts
### 3.1 Service-Interface 경계 규칙
### 3.2 안전/전원 관리 책임 분리(SR-74)

## 4. Infrastructure & Operation Boundary
### 4.1 통제된 실내 시험 운용 표기 정책(SR-80)
### 4.2 관제/로그/시뮬레이션 연계 경계

### ShopPinkki 차용 포인트
- 상위 채널/모듈 경계를 먼저 고정하고 상세 규격은 IS로 위임한 문서 분리 방식

### 기술조사 참조
- `docs/references/Technology -Research/FALCON-1_A-미들웨어-통신_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_B-시간 동기화_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_K-Sim-CI-Logging_v0.1.pdf`

### 작성 순서와 의존성
- 묶음 1에서 IS와 동시 작성
- 선행 입력: `ARCHITECTURE.md`, SR-74/SR-80
- 후속 영향: ERD/SM/PFL/MS/BT의 범위 경계

## 3.2 IS — `interface_specification.md`

### SR 매핑표
| 항목 | 내용 |
|---|---|
| 위임 SR ID | SR-01, SR-03, SR-12, SR-13, SR-26, SR-27, SR-33, SR-36, SR-39, SR-41, SR-48, SR-52, SR-53, SR-60, SR-61, SR-62, SR-63, SR-64, SR-78, SR-79 |
| 매핑 근거 | `system_requirements.md`의 `상세설계 위임/참조` 컬럼 |

### H2/H3 목차 뼈대
## 1. Interface Scope and Naming Rules
### 1.1 ROS2 topic/service/action 네이밍
### 1.2 외부(JSON/TCP/UDP) 인터페이스 명명

## 2. ROS2 Interface Contracts
### 2.1 음성/명령 입력 채널
### 2.2 추종/위치/슬롯/핸드오버 센서 채널
### 2.3 E-stop/heartbeat/battery/localization 상태 채널

## 3. External Protocol Contracts
### 3.1 관제 연동 JSON 페이로드
### 3.2 무선 E-stop 채널 및 리셋 절차 인터페이스

## 4. Network and Security Boundary
### 4.1 허용 포트/세그먼트/주체
### 4.2 비인가 네트워크 차단 규칙(SR-79)

### ShopPinkki 차용 포인트
- 인터페이스 문서를 채널 단위로 분리하고 페이로드 예시(JSON)까지 명세하는 방식

### 기술조사 참조
- `docs/references/Technology -Research/FALCON-1_A-미들웨어-통신_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_G-HRI-음성_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_L-Safety-Power_v0.1.pdf`

### 작성 순서와 의존성
- 묶음 1에서 SA와 동시 작성
- 선행 입력: SA의 채널 경계
- 후속 영향: ERD, SM, PFL, MS, BT 전 문서의 I/O 기준

## 3.3 ERD — `erd.md`

### SR 매핑표
| 항목 | 내용 |
|---|---|
| 위임 SR ID | SR-02, SR-10, SR-24, SR-28, SR-34, SR-35, SR-36, SR-44, SR-70, SR-77 |
| 매핑 근거 | `system_requirements.md`의 `상세설계 위임/참조` 컬럼 |

### H2/H3 목차 뼈대
## 1. Data Domain Scope
### 1.1 명령 집합/공구 메타데이터/로그 범위
### 1.2 런타임 상태 vs 영속 데이터 분리

## 2. Core Entities
### 2.1 CommandSet / MissionContext
### 2.2 Tool / Slot / TemporaryTray
### 2.3 HandoverVector / SafetyEventLog

## 3. State and Code Definitions
### 3.1 상태 코드(enum) 정의
### 3.2 실패 사유 코드 및 감사 로그 스키마

## 4. Integrity and Validation Rules
### 4.1 등록 필수 메타데이터 제약(SR-36, SR-44)
### 4.2 임무·안전 이벤트 로그 무결성(SR-70, SR-77)

### ShopPinkki 차용 포인트
- 인터페이스 문서와 ERD를 분리하고 이벤트 로그 엔터티를 별도 관리한 패턴

### 기술조사 참조
- `docs/references/Technology -Research/FALCON-1_D-Manipulation 제어_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_H-Grasp Planning_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_K-Sim-CI-Logging_v0.1.pdf`

### 작성 순서와 의존성
- 묶음 2
- 선행 입력: IS의 메시지/페이로드 계약
- 후속 영향: SM 상태코드, BT 실패코드, 관제 로그 분석

## 3.4 SM — `state_machine.md`

### SR 매핑표
| 항목 | 내용 |
|---|---|
| 위임 SR ID | SR-06, SR-07, SR-14, SR-15, SR-25, SR-30, SR-31, SR-32, SR-40, SR-50, SR-65, SR-66, SR-67, SR-71, SR-72, SR-73 |
| 매핑 근거 | `system_requirements.md`의 `상세설계 위임/참조` 컬럼 |

### H2/H3 목차 뼈대
## 1. State Set and Semantics
### 1.1 전역 상태 enum 정의
### 1.2 모드별 허용/금지 동작

## 2. Transition Matrix
### 2.1 정상 전환 트리거
### 2.2 전역전환(E-stop/heartbeat/battery/localization)

## 3. Cross-Cutting Variables
### 3.1 arm_lock_active 정의/진입/해제
### 3.2 handover_active 정의/진입/해제

## 4. Callback and Guard Contracts
### 4.1 on_enter/on_exit 콜백 책임
### 4.2 전이 가드(베이스 정지, 재개 명령, 잠금 조건)

### ShopPinkki 차용 포인트
- 전역전환과 일반전환을 별도 표로 분리
- 횡단 플래그(`is_locked_return`류)를 상태와 분리해 정의하는 방식

### 기술조사 참조
- `docs/references/Technology -Research/FALCON-1_C-모바일-SLAM_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_D-Manipulation 제어_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_L-Safety-Power_v0.1.pdf`

### 작성 순서와 의존성
- 묶음 2
- 선행 입력: IS(이벤트 입출력), ERD(상태코드)
- 후속 영향: MS/BT 분기 조건

## 3.5 PFL — `safety_pfl_spec.md`

### SR 매핑표
| 항목 | 내용 |
|---|---|
| 위임 SR ID | SR-18, SR-19, SR-43, SR-57, SR-58, SR-59, SR-68 |
| 매핑 근거 | `system_requirements.md`의 `상세설계 위임/참조` 컬럼 |

### H2/H3 목차 뼈대
## 1. Safety Scope and Standards
### 1.1 ISO 10218-2 PFL 적용 범위
### 1.2 PoC 안전 게이트와 인증 경계

## 2. Quantitative Safety Profiles
### 2.1 베이스 속도 클램프/정지 조건
### 2.2 TCP 속도 제한 프로파일
### 2.3 충돌 감지 토크/정지 계층

## 3. Stop and Recovery Logic
### 3.1 즉시 정지(Cat 0/1) 인터락
### 3.2 안전 자세 복귀 정책(SR-68)

## 4. Validation Plan
### 4.1 Gazebo/Isaac safety test 항목
### 4.2 TBD 파라미터 측정 계획(P-27/P-48/P-59/P-67/P-67b)

### ShopPinkki 차용 포인트
- 안전 기능을 시나리오 단위가 아닌 "정량 프로파일 + 정지 계층"으로 분리하는 방식

### 기술조사 참조
- `docs/references/Technology -Research/FALCON-1_L-Safety-Power_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_D-Manipulation 제어_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_C-모바일-SLAM_v0.1.pdf`

### 작성 순서와 의존성
- 묶음 2
- 선행 입력: IS(센서/안전 채널), SM(전역전환)
- 후속 영향: MS/BT의 타임아웃·중단 정책

## 3.6 MS — `manipulation_sequence.md`

### SR 매핑표
| 항목 | 내용 |
|---|---|
| 위임 SR ID | SR-15, SR-24, SR-33, SR-39, SR-45, SR-46, SR-49, SR-54, SR-68 |
| 매핑 근거 | `system_requirements.md`의 `상세설계 위임/참조` 컬럼 |

### H2/H3 목차 뼈대
## 1. Sequence Scope and Preconditions
### 1.1 공구 출고/반납/전달 시퀀스 범위
### 1.2 베이스 정지 및 안전자세 전제조건

## 2. Tool Fetch and Return Sequences
### 2.1 슬롯 접근-파지-복귀
### 2.2 슬롯 점유 예외 및 임시 트레이 분기

## 3. Handover Sequences
### 3.1 손 제스처 확인-전개-정렬
### 3.2 외력 감지-릴리스-복귀
### 3.3 회피 트리거 중단-안전자세 복귀

## 4. Motion Constraints
### 4.1 전달 방향 벡터 정렬 제약
### 4.2 안전 속도/관절 한계/PFL 연동

### ShopPinkki 차용 포인트
- 상태(SM)와 시퀀스(MS)를 분리하고, 단계별 입출력 조건을 명시한 패턴

### 기술조사 참조
- `docs/references/Technology -Research/FALCON-1_D-Manipulation 제어_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_F-Perception Depth 3D_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_H-Grasp Planning_v0.1.pdf`

### 작성 순서와 의존성
- 묶음 3
- 선행 입력: ERD(메타데이터), SM(모드 가드), PFL(속도 제한)
- 후속 영향: BT leaf 시퀀스/예외 처리

## 3.7 BT — `behavior_tree.md`

### SR 매핑표
| 항목 | 내용 |
|---|---|
| 위임 SR ID | SR-04, SR-05, SR-11, SR-16, SR-20, SR-23, SR-29, SR-34, SR-37, SR-42, SR-56, SR-75, SR-76 |
| 매핑 근거 | `system_requirements.md`의 `상세설계 위임/참조` 컬럼 |

### H2/H3 목차 뼈대
## 1. BT Scope and Runtime Boundary
### 1.1 FSM-SM과 BT의 책임 경계
### 1.2 임무 단위 트리 구성 원칙

## 2. Mission Trees
### 2.1 호출-이동-출고-전달-복귀 기본 트리
### 2.2 추종 임무 트리

## 3. Exception and Fallback Trees
### 3.1 음성 미인식/미등록 거부 분기
### 3.2 추종 분실/슬롯 점유/미등록 공구 분기
### 3.3 핸드오버 타임아웃/회피 취소 분기

## 4. Timeout, Retry, Resume Policies
### 4.1 자동 재시도 금지 정책 반영(SR-29, SR-56)
### 4.2 재개 명령 기반 재진입 정책(SR-20, SR-23, SR-75)

### ShopPinkki 차용 포인트
- 정상 트리와 예외 트리를 분리해 추적성 높이는 패턴
- 타임아웃/재개 정책을 leaf 조건으로 명시하는 방식

### 기술조사 참조
- `docs/references/Technology -Research/FALCON-1_C-모바일-SLAM_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_E-Perception Vision_v0.1.pdf`
- `docs/references/Technology -Research/FALCON-1_G-HRI-음성_v0.1.pdf`

### 작성 순서와 의존성
- 묶음 3
- 선행 입력: SM(전이), MS(매니퓰레이션 단계), PFL(중단 조건)
- 후속 영향: 통합 시뮬레이션 시나리오 및 검증 스크립트

## 4. SR 매핑 누락 점검

- 본 7종 문서 기준으로 `상세설계 위임/참조`가 없는 SR: 없음
- 단, 일부 SR은 해당 컬럼에 상세설계 문서명이 명시되지 않거나(`-`) "본 SR 정의"로 표기되어 있어 문서 위임 대상이 아닌 정책 확정 항목으로 유지한다.

## 5. 작성 실행 체크리스트

- 묶음 1 완료 기준: SA/IS 초안 + SR 추적표 + 인터페이스 네이밍 규칙 확정
- 묶음 2 완료 기준: ERD/SM/PFL 초안 + 상태/안전/데이터 상호 참조 링크 확정
- 묶음 3 완료 기준: MS/BT 초안 + 예외 분기/타임아웃 정책 + Gazebo/Isaac 테스트 항목 연결
- 모든 문서는 SR 본문이 아닌 상세설계 문서에서 기술 종속 정보를 확정한다.
