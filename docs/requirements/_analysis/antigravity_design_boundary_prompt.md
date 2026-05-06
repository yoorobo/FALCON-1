# Antigravity 채팅창 프롬프트 — ShopPinkki 상세설계 2종 분석

> 이 프롬프트 전체를 Antigravity 채팅창에 그대로 붙여넣으세요.
> Antigravity가 로컬 ShopPinkki 파일을 직접 읽고 분석 보고서를 만들어, 우리 FALCON-1의 SR 작성 가이드라인 완성에 사용합니다.

---

## 📋 프롬프트 (복사해서 붙여넣기)

```
ShopPinkki의 상세설계 문서 2종을 정독해서 "SR과 상세설계의 경계선이 어디에 그어져 있는지" 추출하는 작업이야.
이 분석 결과는 우리 FALCON-1 프로젝트의 SR 작성 가이드라인을 완성하는 데 직접 사용돼.

## 작업 배경 (꼭 먼저 읽기)

지금 우리는 FALCON-1 SR 작성 가이드라인을 만드는 중이고,
교수님이 강조하신 5가지 원칙을 ShopPinkki가 어떻게 구현했는지 분석하고 있어.

교수님 원칙:
1. UR/SR 기능·비기능 명확 구분
2. 기술 종속 금지 (현재 알고 있는 기술에 매몰되지 말 것)
3. 상세설계로 위임 (구체 구현은 SR이 아닌 상세설계 영역)
4. 부가 상황 망라 (UR→SR 도출 시 모든 분기·예외 감안)
5. 기능분기 추적성 (SR↔상세설계 양방향 추적 가능)

이미 분석 완료:
- ShopPinkki UR (user_requirements.md): 부가 상황을 UR 단계부터 펼치는 패턴 확인됨
- ShopPinkki SR 56건 (system_requirements.md): 5가지 부가상황 펼치기 패턴 추출 완료
- ShopPinkki 체크리스트 도구 (system_requirements_checklist.html): 이진 판정 가능성·자동 파싱 호환성 확인

지금 분석할 것: ShopPinkki가 SR에서 외부 위임한 두 핵심 상세설계 문서.
이게 마지막 퍼즐이고, 이걸 봐야 "SR에 적을 것 vs 상세설계로 보낼 것"의 경계가 정확히 그어져.

## 분석 대상 파일 (둘 다 정독 필수)

1. /home/yoo/Falcon-1/ShopPinkki/docs/state_machine.md
2. /home/yoo/Falcon-1/ShopPinkki/docs/interface_specification.md

두 파일을 모두 끝까지 읽어. 표·코드 스니펫·다이어그램 모두 포함. 길어도 건너뛰지 말 것.

## 분석 산출물 — 다음 5개 보고서를 순서대로 작성

### 보고서 1: 두 문서의 정체와 SR과의 관계

각 문서에 대해 다음을 답변:
- 이 문서가 SR의 어떤 항목들을 위임받아 처리하는가? (SR-13, SR-22 등 구체 SR ID 매핑)
- SR이 "참조"라고만 적고 넘긴 내용 중 이 문서에서 처음 정의되는 것은?
- 이 문서가 없었다면 SR만 보고 시스템을 구현 가능했을까?

### 보고서 2: SR과 상세설계의 경계선 매트릭스 ⭐ 가장 중요

다음 표를 채워줘. 각 항목이 "SR에 명시" / "상세설계에 명시" / "둘 다 명시" 중 어디에 있는지:

| 정보 유형 | SR (system_requirements.md) | 상세설계 (state_machine.md / interface_specification.md) | 경계 원칙 |
|---|---|---|---|
| 상태 enum 이름 | ? | ? | ? |
| 상태 전환 트리거 이름 (예: enter_halted) | ? | ? | ? |
| 전환 조건 (언제 전환되는가) | ? | ? | ? |
| 전역 전환 (source='*') 존재 여부 | ? | ? | ? |
| 횡단 변수 (is_locked_return 등) 존재 | ? | ? | ? |
| 횡단 변수의 수명주기·우선순위 규칙 | ? | ? | ? |
| 상태별 LED 색상표 | ? | ? | ? |
| 상태별 LCD 표시 | ? | ? | ? |
| 콜백 함수명 (on_enter_LOCKED 등) | ? | ? | ? |
| 콜백 코드 스니펫 (Python) | ? | ? | ? |
| 라이브러리명 (transitions, pinkylib) | ? | ? | ? |
| 채널 이름 (A~H) | ? | ? | ? |
| 포트 번호 (5005, 8080, :9000 등) | ? | ? | ? |
| 프로토콜 (TCP/UDP/SocketIO/REST) | ? | ? | ? |
| 메시지 페이로드 포맷 (JSON 키 이름) | ? | ? | ? |
| ROS 토픽명 (/robot_<id>/status 등) | ? | ? | ? |
| ROS 메시지 타입 (std_msgs/String 등) | ? | ? | ? |
| 토픽 발행 주기 (1~2Hz 등) | ? | ? | ? |
| QoS 설정 (RELIABLE 등) | ? | ? | ? |
| Nav2 액션명 (navigate_to_pose) | ? | ? | ? |
| DB 스키마 / 컬럼명 | ? | ? | ? |
| API 엔드포인트 경로 (/zones 등) | ? | ? | ? |
| 매직 넘버 (배터리 20% 등) | ? | ? | ? |
| Detection·CartItem 등 데이터클래스 정의 | ? | ? | ? |
| Protocol 인터페이스 (DollDetectorInterface 등) | ? | ? | ? |
| 커넥션 등록 메시지 형식 ({type:register, role:...}) | ? | ? | ? |

각 행 마지막 "경계 원칙" 컬럼에는 한 줄로 패턴 도출:
- 예: "이름·존재만 SR, 구체 값·코드는 상세설계"
- 예: "비즈니스 의미는 SR, 기술 구현은 상세설계"

### 보고서 3: 우리 SR 가이드라인에 추가할 경계 원칙 (5~8개)

보고서 2의 "경계 원칙" 컬럼을 종합해서, 일반화된 원칙 5~8개로 정리.
예시 형태:

> **원칙 X:** 상태머신은 SR에서 "상태 enum 이름·전환 트리거 이름·전환 조건"까지만 다루고,
> 콜백 코드·라이브러리 선택·횡단 변수 구현은 상세설계로 위임한다.

각 원칙마다:
- 원칙 한 줄
- ShopPinkki 근거 (어느 SR이 어떻게 했는지)
- FALCON-1 적용 시 주의점

### 보고서 4: ShopPinkki가 이 경계를 잘 못 지킨 사례

보고서 2 분석 중 발견한 "SR에 들어가면 안 됐는데 들어간 것" 또는 "상세설계에 있어야 하는데 SR에 누락된 것"이 있다면 모두 나열.

이전 분석에서 이미 식별된 것:
- SR-01: "ST7789, 2.4인치" — 모델명이 SR에 박힘
- SR-09: "TCP:5005" — 포트번호가 SR에 박힘
- SR-10: "YOLOv8n", "Docker 컨테이너" — 모델명·런타임이 SR에 박힘
- SR-11: "HSV 색상 히스토그램" — 알고리즘 디테일이 SR에 박힘
- SR-22: "P-Control" — 제어 알고리즘이 SR에 박힘
- SR-23: "RPLiDAR C1" — 센서 모델명이 SR에 박힘
- SR-37, SR-48: 라이브러리·API명이 SR에 박힘
- SR-56: "20%" 매직넘버가 SR에 박힘

추가로 발견한 것이 있으면 더 나열하고, 위 리스트에 대해 "어떻게 다시 쓰면 좋을지" 한두 건 예시 제시.
예시 형식:
- (현재) SR-22: "추종 주행은 인식된 인형의 bbox 중심·크기를 기반으로 P-Control을 사용한다"
- (개선) SR-22: "추종 주행은 인식된 주인 인형의 위치(중심·크기)를 입력으로 하는 추종 제어 알고리즘으로 수행한다.
  구체 알고리즘 선택은 상세설계 docs/design-docs/control_strategy.md 참조"

### 보고서 5: FALCON-1이 만들어야 할 상세설계 문서 목록

ShopPinkki가 가진 상세설계는 state_machine.md, interface_specification.md, behavior_tree.md, erd.md 등이야.
FALCON-1도 비슷한 상세설계 문서 세트가 필요해.

ShopPinkki 패턴 + FALCON-1 도메인 특수성(양팔 OpenArm, 공구 핸드오버, PFL 안전, 음성 인터페이스)을 고려해서
FALCON-1이 만들어야 할 상세설계 문서 목록을 추천:

| 문서명 | 위치 (제안) | 다룰 내용 | ShopPinkki 대응 문서 | 우선순위 |
|---|---|---|---|---|
| state_machine.md | docs/design-docs/ | FSM 전환 테이블 + 횡단 변수 | state_machine.md (있음) | 높음 |
| interface_specification.md | docs/design-docs/ | ROS 토픽·채널 명세 | interface_specification.md (있음) | 높음 |
| ... | ... | ... | ... | ... |

각 문서가 어떤 SR에서 위임받게 될지 미리 매핑하면 더 좋음.

## 산출물 형식

위 5개 보고서를 모두 합친 단일 마크다운 파일로 작성:

- 파일명: shoppinkki_design_boundary_analysis.md
- 위치: /home/yoo/Falcon-1/FALCON-1/docs/requirements/_analysis/shoppinkki_design_boundary_analysis.md
  (디렉토리 없으면 만들기)
- 헤더: 분석 일시, 분석 대상 파일 경로, 보고서 5개 목차

작성 후 git stage만 두고 커밋은 하지 마.

## 보고 시 첨부

마지막에 다음 3가지 한눈에 정리:
1. 보고서 2 매트릭스에서 도출된 가장 강한 경계 패턴 3가지 (한 줄씩)
2. 보고서 4에서 식별된 ShopPinkki SR의 기술 종속 사례 총 건수
3. 보고서 5에서 추천한 FALCON-1 상세설계 문서 개수

## 작업 원칙

- ShopPinkki 두 파일을 끝까지 정독할 것 (요약/생략 금지)
- 보고서 2 매트릭스는 비워두지 말고 모든 행을 채울 것
- 추정·환각 금지. 근거를 못 찾으면 "근거 없음" 명시
- FALCON-1 도메인 무관한 ShopPinkki 고유 디테일은 짧게 요약만 (예: 결제구역, 인형 ReID는 우리에게 직접 적용 안 됨 — 그냥 패턴만 추출)
- 하드웨어/구현 가정 금지 — ShopPinkki에 적힌 사실만 다룰 것

다 끝나면 결과 보고하고, 내가 다음 단계(SR 작성 가이드라인 정식 문서화)를 지시할 때까지 대기.
```

---

## 📌 이 프롬프트의 설계 의도 (참고용)

| 설계 결정 | 이유 |
|---|---|
| **Antigravity가 직접 파일 읽게 함** | 두 문서가 길어서 채팅창 컨텍스트 한도 절약 + 로컬 파일 읽는 게 정확 |
| **5개 보고서를 순서대로** | 매트릭스(보고서 2)가 핵심이고 나머지는 그것의 가공·일반화 |
| **보고서 2 매트릭스를 26행으로 미리 채움** | "알아서 정리해" 대신 명확한 슬롯 제공 → 결과 품질 안정성 |
| **보고서 4에 기존 발견 8건 나열** | Antigravity가 이걸 출발점으로 더 많이 찾도록 자극 |
| **출력을 단일 md + 레포 내 위치 지정** | 다음 단계(가이드라인 작성)에서 바로 참조 가능 |
| **`docs/requirements/_analysis/` 폴더** | UR/SR과는 구분되는 분석 자료. 영구 자산화 |
| **stage만, 커밋 X** | 사용자 검토 권한 보장 |

---

## 🔗 다음 단계 (이 작업이 끝난 후)

Antigravity가 보고서 끝내면, 그 결과를 받아서 다음 단계로:

1. 가이드라인 정식 문서화 (`docs/requirements/sr_authoring_guideline.md`)
2. 가이드라인 검증용 샘플 SR 1~2건 작성 (UR_E03, UR_D06)
3. 검증 통과 시 → Antigravity에 PoC Must 24건 전체 SR 재작성 지시

세션 한도가 임박했으니, **이 프롬프트 보내고 Antigravity 보고 결과는 다음 새 채팅**에서 받으시는 걸 권장합니다. 새 채팅 시작 시 다음만 알려주시면 바로 이어집니다:

> "FALCON-1 SR 작성 가이드라인 작업 이어가기. ShopPinkki 경계 분석 보고서가 docs/requirements/_analysis/에 생성됨. 다음 단계: 가이드라인 정식 문서화."

이 한 줄 + Antigravity 보고서 첨부면 컨텍스트 복원됩니다.
