# DESIGN.md — FALCON-1 전체 설계 요약

> 최종 수정: 2026-05-05

---

## 시스템 개요

FALCON-1은 **자율주행 + 양팔 매니퓰레이션**을 결합한 로봇 시스템이다.

- **모바일 베이스**: Vic Pinky (differential drive + Nav2 + SLAM)
- **매니퓰레이터**: OpenArm 양팔 (MoveIt 2 + ros2_control)
- **인식**: 카메라 기반 도구/객체 탐지 (falcon1_perception)
- **오케스트레이션**: AI Agent Harness (BT 기반 태스크 분해)

## 아키텍처

전체 아키텍처는 [ARCHITECTURE.md](../ARCHITECTURE.md) 참조.

```
Runtime → Service → Interface → Hardware → Description → Config → Types
```

## 주요 설계 결정

| 결정 | 선택 | 근거 |
|---|---|---|
| 미들웨어 | ROS 2 Jazzy | Ubuntu 24.04 LTS 공식 지원 |
| 빌드 | colcon | ROS 2 표준 빌드 시스템 |
| Python 린터 | ruff | 속도, ROS 2 생태계 호환 |
| 시뮬레이션 | Gazebo + Isaac Sim | 이중 게이팅으로 안전성 확보 |
| 양팔 제어 | MoveIt 2 | 산업 표준 모션 플래닝 |
| OpenArm 통합 | 서브모듈 (읽기 전용) | 업스트림 추적, 포크 방지 |

## 핵심 설계 원칙

상세 내용은 [core-beliefs.md](design-docs/core-beliefs.md) 참조.

1. 에이전트가 볼 수 없는 것은 존재하지 않는다
2. 문서는 목차지 백과사전이 아니다
3. 아키텍처 제약은 린터로 강제한다
4. 가비지 컬렉션은 지속적으로 한다
5. 수정 비용은 저렴하게 유지한다
