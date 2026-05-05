# ARCHITECTURE.md — FALCON-1 아키텍처 최상위 맵

> 최종 수정: 2026-05-05 | 유지 책임: Nerd Labs

---

## 1. 레이어 구조

```
┌─────────────────────────────────────────────────────────────────┐
│                        Runtime Layer                            │
│   Behavior Trees · Task Orchestration · AI Agent Harness        │
├─────────────────────────────────────────────────────────────────┤
│                       Service Layer                             │
│   Navigation (Nav2) · Manipulation (MoveIt 2) · Perception      │
├─────────────────────────────────────────────────────────────────┤
│                      Interface Layer                            │
│   falcon1_interfaces (msg / srv / action)                       │
├─────────────────────────────────────────────────────────────────┤
│                      Hardware Layer                             │
│   ros2_control · OpenArm HW Interface · Vic Pinky Drivers       │
├─────────────────────────────────────────────────────────────────┤
│                     Description Layer                           │
│   URDF / xacro · Meshes · Joint Limits · Sensor Config          │
├─────────────────────────────────────────────────────────────────┤
│                       Config Layer                              │
│   ROS 2 Parameters · Launch Files · MoveIt Config               │
├─────────────────────────────────────────────────────────────────┤
│                       Types Layer                               │
│   Constants · Enums · Data Classes · Shared Type Definitions    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 도메인 목록

| 도메인 | 패키지 | 역할 |
|---|---|---|
| **Description** | `falcon1_description` | URDF/xacro 모델, 메시, 센서 설정 |
| **Interfaces** | `falcon1_interfaces` | ROS 2 커스텀 msg/srv/action 정의 |
| **Perception** | `falcon1_perception` | 카메라 기반 도구 인식, 객체 탐지 |
| **Manipulation** | (예정) | MoveIt 2 기반 양팔 pick-and-place |
| **Navigation** | (예정) | Nav2 기반 자율 주행, SLAM |
| **Orchestration** | (예정) | BT 기반 태스크 오케스트레이션 |
| **OpenArm HW** | `openarm_ros2` (서브모듈) | ros2_control 하드웨어 인터페이스 |

---

## 3. 허용된 의존성 방향

```
Types → Config → Description → Interface → Hardware → Service → Runtime
                                                                  ↑
                                                      (Perception, Navigation,
                                                       Manipulation 은 Service)
```

### 규칙
- **상위 → 하위**: 허용 (Runtime은 Service를 사용 가능)
- **하위 → 상위**: **금지** (Interface가 Runtime에 의존 불가)
- **동일 레이어 간**: Interface Layer를 통해서만 통신
- **서브모듈(openarm_ros2)**: 읽기 전용 의존, 수정 금지

---

## 4. 외부 의존성

| 의존성 | 용도 | 버전 |
|---|---|---|
| ROS 2 Jazzy | 미들웨어 | Jazzy Jalisco |
| Nav2 | 자율 주행 | Jazzy 호환 |
| MoveIt 2 | 매니퓰레이션 | Jazzy 호환 |
| slam_toolbox | SLAM | Jazzy 호환 |
| Gazebo | 시뮬레이션 | Harmonic |
| Isaac Sim | 고충실도 시뮬레이션 | 최신 |
| OpenArm ROS 2 | 하드웨어 인터페이스 | 서브모듈 |
| ruff | Python 린터 | latest |
| clang-tidy | C++ 린터 | 시스템 패키지 |
| pytest | 테스트 프레임워크 | latest |
| ACT / LeRobot | 모방 학습 | 연구용 |

---

## 5. 금지된 패턴

| # | 패턴 | 이유 |
|---|---|---|
| 1 | 순환 의존성 | 빌드 실패, 디버깅 불가 |
| 2 | 하위 레이어에서 상위 레이어 import | 레이어 역전 — 아키텍처 붕괴 |
| 3 | 하드코딩된 토픽명/서비스명 | 유지보수 불가, 재사용 불가 |
| 4 | God 노드 (단일 노드에 모든 로직) | 테스트·분리 불가, 500줄 제한 위반 |
| 5 | 서브모듈 직접 수정 | 업스트림 충돌, 머지 불가 |
| 6 | 시뮬레이션 없는 하드웨어 코드 배포 | 안전 위반 |
| 7 | 테스트 없는 로직 코드 커밋 | 품질 보증 불가 |
