# AGENTS.md — FALCON-1 에이전트 운영 헌법

> 최종 수정: 2026-05-05 | 유지 책임: Nerd Labs

---

## 1. 역할 정의

FALCON-1은 자율주행 모바일 플랫폼(Vic Pinky)과 양팔 매니퓰레이터(OpenArm)를
결합한 로봇 시스템이다. AI 에이전트는 태스크 분해, 시뮬레이션 게이팅, 안전 제약 집행,
문서 관리, 크로스-시스템 조율을 수행한다.

---

## 2. 절대 규칙 (5개)

1. **시뮬레이션 선행** — Gazebo·Isaac Sim 통과 전 실기체 실행 금지
2. **페이로드 제한** — OpenArm 4.1 kg 초과 금지 (엔드이펙터 포함)
3. **계획 선행** — 모든 작업은 `docs/exec-plans/active/`에 계획 작성 후 실행
4. **검증 후 커밋** — `scripts/verify-task.sh` 통과 전 커밋 금지
5. **무단 삭제 금지** — 파일·컨테이너·이미지 삭제는 명시적 승인 필요

---

## 3. 지식 맵 (docs/ 목차)

| 문서 | 역할 |
|---|---|
| `ARCHITECTURE.md` | 도메인·레이어 최상위 아키텍처 맵 |
| `docs/DESIGN.md` | 전체 설계 요약 |
| `docs/PLANS.md` | 현재 진행 중인 계획 목록 |
| `docs/QUALITY_SCORE.md` | 도메인·레이어별 품질 등급 |
| `docs/RELIABILITY.md` | 안정성 기준·SLA |
| `docs/SECURITY.md` | 보안 규칙·금지 사항 |
| `docs/design-docs/index.md` | 설계 문서 목차 |
| `docs/design-docs/core-beliefs.md` | 핵심 설계 원칙 |
| `docs/exec-plans/active/` | 진행 중인 실행 계획 |
| `docs/exec-plans/completed/` | 완료된 실행 계획 |
| `docs/references/` | 외부 라이브러리·하드웨어 참조 문서 |

---

## 4. 표준 워크플로

```
1. 계획   → docs/exec-plans/active/ 에 실행 계획 작성
2. 구현   → 코드 작성 (서브모듈 제외, 도메인 경계 준수)
3. 검증   → bash scripts/verify-task.sh (린트 → 테스트 → 빌드)
4. 커밋   → Conventional Commits: feat(scope): 설명
5. 완료   → bash scripts/complete-task.sh (계획 이동 + 정리)
```

---

## 5. 에스컬레이션 — 반드시 사람에게 확인

- 아키텍처 레이어 간 의존성 방향 변경
- 새로운 외부 의존성(라이브러리·서비스) 추가
- 페이로드 한계 근접 시나리오 (3.5 kg 초과)
- 실기체 배포 승인
- 기존 파일 삭제·이동·이름 변경
