# QUALITY_SCORE.md — 도메인·레이어별 품질 등급

> 최종 수정: 2026-05-05
> 품질 등급: 🟢 A (우수) | 🟡 B (양호) | 🟠 C (개선 필요) | 🔴 D (미달)

---

## 도메인별 품질

| 도메인 | 패키지 | 린트 | 테스트 | 문서 | 종합 |
|---|---|---|---|---|---|
| Description | `falcon1_description` | 🟡 B | 🔴 D | 🟠 C | 🟠 C |
| Interfaces | `falcon1_interfaces` | 🟢 A | N/A | 🟡 B | 🟡 B |
| Perception | `falcon1_perception` | 🟡 B | 🟡 B | 🟠 C | 🟡 B |
| Manipulation | (미구현) | — | — | — | 🔴 D |
| Navigation | (미구현) | — | — | — | 🔴 D |
| Orchestration | (미구현) | — | — | — | 🔴 D |
| OpenArm HW | `openarm_ros2` (서브모듈) | N/A | N/A | N/A | — |

## 레이어별 품질

| 레이어 | 상태 | 비고 |
|---|---|---|
| Types | 🟠 C | 공유 타입 정의 부족 |
| Config | 🟡 B | launch 파일 일부 존재 |
| Description | 🟡 B | URDF/xacro 기본 구조 완성 |
| Interface | 🟡 B | msg/srv/action 정의 완료 |
| Hardware | 🟠 C | 서브모듈 의존, 자체 HW 인터페이스 미구현 |
| Service | 🔴 D | Nav2/MoveIt 통합 미시작 |
| Runtime | 🔴 D | BT/오케스트레이션 미시작 |

---

> 매 스프린트 종료 시 업데이트한다.
