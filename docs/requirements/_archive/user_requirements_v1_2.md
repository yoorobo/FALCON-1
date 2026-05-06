# Smart Assistant — User Requirements
**현장 양팔 로봇 보조 시스템**

| 항목 | 내용 |
| --- | --- |
| **Project** | Smart Assistant — 현장 양팔 로봇 보조 시스템 |
| **Date** | 2026-04-29 |
| **Hardware** | OpenArm Bimanual (Enactic, 7+1 DoF × 2, nominal 4.1kg/arm) + Vic Pinky (PinkLab Light AMR, 고정 마운트 통합) |
| **Scope** | 단일 작업자 / 단일 임무 큐 / 등록 공구 3종(rigid) / 사전 매핑 단층 실내 / 결정적 벽부형 수납장 1대 / 통제된 PoC 환경 |
| **Standards** | ISO 10218-2:2025 (Annex M, PFL mode) · EN ISO 13850 · PLd 이상 |

## User Requirements
**Reporter 범례**: 🔸 User (작업자) | 🔹 Admin (관리자) | 🛡️ Safety (안전관리자)

| UR ID | 카테고리 | Description | Reporter | Acceptance Criteria |
| --- | --- | --- | --- | --- |
| UR_A01 | A. 호출 & 통신 | User는 PTT 마이크로 화이트리스트된 명령(공구 호출/회수/정지/복귀)만 발화하여 시스템에 임무를 부여한다. | 🔸 User | 인식 정확도 ≥ 95% (95dB SPL 환경), 응답 latency ≤ 2초 |
| UR_A02 | A. 호출 & 통신 | User가 호출 시 시스템은 호출 확인을 음성/LED로 피드백한다. | 🔸 User | 피드백 latency ≤ 1초 |
| UR_A03 | A. 호출 & 통신 | 명령 인식 실패 시 시스템은 "다시 말해주세요" 피드백 후 재대기한다. 임의 동작 금지. | 🔸 User | 미인식 = 절대 동작 시작 안 함 (false-positive ≤ 0.1%) |
| UR_B01 | B. 위치 & 추종 | 시스템은 사전 매핑된 단일층 통로(폭 ≥ 800mm, 단차 ≤ 20mm)에서 자율 주행한다. | 🔹 Admin | 자기위치 오차 ≤ 100mm, 통로 외 진입 0건 |
| UR_B02 | B. 위치 & 추종 | 시스템은 User를 시각·LiDAR 기반으로 추종한다. 추종 중 양팔은 tucked pose로 고정한다. | 🔸 User | 추종 거리 1.0~2.0m 유지, 추종 분실율 ≤ 5%/시간 |
| UR_B03 | B. 위치 & 추종 | 추종 중 User가 정지하면 시스템은 1.0m 이상 거리를 두고 정지한다. | 🔸 User | 정지 거리 1.0~1.5m, 침범 0건 |
| UR_B04 | B. 위치 & 추종 | 추종 중 사람·구조물 근접 시 속도를 자동 클램프한다(≤ 0.5 m/s). | 🔹 Admin | ISO 10218-2 SSM 기준 충족 |
| UR_B05 | B. 위치 & 추종 | 추종 분실 시 시스템은 마지막 알려진 위치에서 정지하고 User에게 음성으로 알린다. | 🔸 User | 분실 후 임의 탐색 0건 |
| UR_B06 | B. 위치 & 추종 | 시스템은 벽부형 수납장에 사전 정의된 도킹 좌표로 자동 정렬한다 (AprilTag 기반). | 🔹 Admin | 도킹 정렬 오차 ≤ ±20mm / ±2°, 성공률 ≥ 98% |
| UR_C01 | C. 공구 입출고 | 시스템은 등록된 공구 N종(v1.0=3종)을 수납장의 결정적 슬롯에서 OpenArm으로 픽한다. | 🔸 User | 픽 성공률 ≥ 98%, 평균 사이클 ≤ 20초 |
| UR_C02 | C. 공구 입출고 | 픽 동작은 모바일 베이스 정지 + 도킹 정렬 완료 후에만 시작한다. | 🔹 Admin | 베이스 이동 중 arm 동작 0건 |
| UR_C03 | C. 공구 입출고 | 픽 실패 시 시스템은 최대 2회 재시도 후 User에게 음성 알림 + Admin에게 대시보드 알림한다. | 🔹 Admin | 무한 재시도 0건 |
| UR_C04 | C. 공구 입출고 | 시스템은 회수받은 공구를 원래 슬롯에 stow한다. 슬롯이 점유 상태면 stow 거부 + 알림. | 🔸 User | stow 성공률 ≥ 98%, 오슬롯 stow 0건 |
| UR_C05 | C. 공구 입출고 | 미등록·오염·파손 공구를 회수받으면 시스템은 stow를 거부하고 별도 임시 트레이로 격리한다. | 🔸 User | 미등록 거부율 100% |
| UR_C06 | C. 공구 입출고 | 모든 공구는 사전 등록(마커 + grasp pose + 슬롯 매핑) 후에만 호출/회수 가능. | 🔹 Admin | 등록 워크플로우 별도 정의, 등록 시간 ≤ 30분/공구 |
| UR_D01 | D. Handover | User가 PTT로 공구 호출 + 손 펴기 자세를 보이면, 모바일 매니퓰레이터는 User까지 이동 후 정지 정렬, 양팔 비동기형 협응으로 OpenArm 한쪽 팔이 공구를 handover한다. | 🔸 User | 호출~grasp 완료 ≤ 30초 (이동 포함), handover 성공률 ≥ 95% |
| UR_D02 | D. Handover | Handover 중 OpenArm 끝단 속도는 ≤ 250 mm/s로 제한한다. | 🔹 Admin | ISO 10218-2 Annex M PFL 한도 준수 |
| UR_D03 | D. Handover | Handover 시 공구는 안전 방향으로 제시한다(핸들 우선, 날끝/타격면 반대). | 🔸 User | 모든 등록 공구에 대해 사전 정의된 handover orientation 보유 |
| UR_D04 | D. Handover | Grip-state 감지(접촉력 또는 시각) 후에만 OpenArm은 공구를 release한다. | 🔸 User | 사전 release 0건, release latency ≤ 500ms |
| UR_D05 | D. Handover | User가 사용 후 공구를 receive zone(트레이 또는 직접 handover)에 놓으면 OpenArm이 회수한다. | 🔸 User | 회수 성공률 ≥ 95% |
| UR_D06 | D. Handover | Handover 중 User가 후퇴/회피 동작 시 OpenArm은 즉시 정지하고 hold pose로 복귀한다. | 🔸 User | 정지 반응 ≤ 200ms |
| UR_E01 | E. 안전 | 시스템은 ISO 10218-2:2025 Annex M (구 ISO/TS 15066) PFL 모드를 준수한다. | 🛡️ Safety | 사전 risk assessment 문서, 충돌 force/pressure 시험 보고서 |
| UR_E02 | E. 안전 | E-stop은 모바일 매니퓰레이터 4면 + User 휴대형 무선 + Safety Officer 휴대형으로 제공된다. | 🛡️ Safety | 누름~정지 ≤ 200ms, EN ISO 13850 준수, PLd 이상 |
| UR_E03 | E. 안전 | 통신 단절(>2초), 배터리 <15%, 자기위치 신뢰도 저하 시 시스템은 Cat 1 정지 후 safe pose로 진입한다. | 🛡️ Safety | safe-state 진입 ≤ 10초, 자율 재기동 0건 |
| UR_E04 | E. 안전 | 시스템은 활성 공사 구역 geofence를 침범하지 않는다. | 🛡️ Safety | geofence 침범 0건 |
| UR_E05 | E. 안전 | 사고/근접 사고 시 사고 직전 30초 + 직후 10초의 영상·LiDAR·관절 로그를 black-box에 저장한다. | 🛡️ Safety | 로그 저장률 100%, 저장기간 ≥ 90일 |
| UR_E06 | E. 안전 | 양팔은 이동 모드에서 tucked pose로 강제 유지, manipulation 모드에서만 전개된다. | 🛡️ Safety | 모드 전이 결정적, 위반 0건 |
| UR_E07 | E. 안전 | 본 시스템은 "통제된 실내 모사 환경에서의 PoC"로 한정 운용. 산업 현장 정식 배포 시 별도 인증 필요. | 🛡️ Safety | 운용 범위 문서 명시, 외부 배포 차단 |
| UR_F01 | F. 운영 & 관리 | Admin은 대시보드에서 모바일 매니퓰레이터 위치/배터리/임무 상태/공구 인벤토리를 1Hz 이상으로 확인한다. | 🔹 Admin | latency ≤ 500ms, 동시 표시 항목 ≥ 10 |
| UR_F02 | F. 운영 & 관리 | Admin은 shared-autonomy 모드로 직접 조작 가능하며, User 근접 시 속도 자동 클램프된다. | 🔹 Admin | 클램프 응답 ≤ 100ms |
| UR_F03 | F. 운영 & 관리 | 시스템은 배터리 <20% 시 자동 도킹 스테이션으로 복귀한다. | 🔹 Admin | 자동 복귀 성공률 ≥ 98% |
| UR_F04 | F. 운영 & 관리 | Severity 1~4 알림은 대시보드 + 모바일 푸시로 발송된다. Severity 1은 60초 내 도달. | 🔹 Admin | 알림 누락 0건 |
| UR_F05 | F. 운영 & 관리 | 모든 임무·동작·이벤트는 시계열 로그로 기록되며, 30일 이상 조회 가능. | 🔹 Admin | 로그 손실율 ≤ 0.01% |
| UR_G01 | G. 비기능 | 자율 운용 시간 ≥ 4시간, 충전 ≥ 1시간 | 🔹 Admin | 사이클 측정 |
| UR_G02 | G. 비기능 | 1회 임무(호출~handover~stow 완료) 평균 사이클 ≤ 90초 | 🔹 Admin | 측정 보고서 |
| UR_G03 | G. 비기능 | 1주 연속 운용 시 평균 임무 성공률 ≥ 90% | 🔹 Admin | 7일 burn-in 시험 |
| UR_G04 | G. 비기능 | 시스템 부팅~운용 준비 ≤ 5분 | 🔹 Admin | 시간 측정 |
| UR_G05 | G. 비기능 | 신규 공구 등록 워크플로우 완료 ≤ 30분 | 🔹 Admin | 시간 측정 |

**총 38건 (A:3 / B:6 / C:6 / D:6 / E:7 / F:5 / G:5)**
