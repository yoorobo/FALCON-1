# GitHub-Centric Operations

FALCON-1의 실행 기준점은 GitHub이다. 코드는 물론이고 작업 단위, 검증 흔적, 의사결정 연결점도 GitHub에서 먼저 추적 가능해야 한다.

## Source of Truth

- GitHub: 실행 기준점
  - Issue: 해야 할 일, 배경, 완료 기준
  - Branch: 작업 단위 격리
  - PR: 변경 이유, 검증 결과, 리뷰 기록
  - `docs/`: 설계 문서, 운영 규칙, 실행 계획
- Notion: 운영 요약
  - 일일 작업일지
  - 회의 메모
  - 의사결정 배경
  - GitHub 링크 모음

같은 내용을 GitHub와 Notion에 중복으로 길게 작성하지 않는다. 상세 변경 내용은 GitHub에 남기고, Notion에는 요약과 링크만 남긴다.

## Standard Flow

1. Issue를 만든다.
2. 완료 기준과 관련 문서를 Issue에 적는다.
3. 브랜치를 만든다.
4. `docs/exec-plans/active/`에 실행 계획을 작성한다.
5. 구현 및 검증을 수행한다.
6. PR을 열고 변경 이유, 검증 결과, 관련 Issue를 연결한다.
7. Notion 작업일지에 요약과 GitHub 링크를 남긴다.
8. 머지 후 실행 계획을 `completed/`로 정리한다.

## Required Links

모든 의미 있는 작업은 아래 링크 중 최소 하나 이상으로 서로 연결되어야 한다.

- Issue -> PR
- PR -> 실행 계획 문서
- PR -> 관련 설계 문서
- Notion 작업일지 -> Issue 또는 PR

가능하면 Notion 작업일지에는 아래 형식을 사용한다.

```text
- GitHub Issue: <link>
- GitHub PR: <link>
- GitHub Commit: <link>
- 관련 문서: <repo path or link>
```

## AI Collaboration Rule

- Claude: 기획 보조, 구현, 통합 검토
- Codex: 교차 검증, 구조 점검, 문서/템플릿 보강
- 최종 기준은 특정 AI 세션이 아니라 GitHub 산출물이다.

PR 또는 작업일지에는 아래 중 하나를 남긴다.

- `AI Assist: Claude`
- `AI Assist: Codex`
- `AI Assist: Mixed`

## Notion Logging Rule

Notion에는 아래만 간결하게 남긴다.

- 오늘 한 일
- 왜 그렇게 했는가
- 막힌 점 또는 결정 사항
- 관련 GitHub 링크
- 다음 작업

비밀 정보, 인증 정보, 복구 코드 같은 민감 정보는 프로젝트 허브 본문에 직접 두지 않는다. 제한된 별도 저장 위치에 보관하고, 허브에는 접근 안내만 남긴다.

## Portability Check

새 PC나 새 AI 세션에서도 아래 질문에 GitHub만으로 답할 수 있어야 한다.

- 지금 해야 할 다음 작업은 무엇인가?
- 어떤 브랜치와 PR이 관련되어 있는가?
- 완료 기준은 무엇인가?
- 어떤 검증을 통과했는가?
- 어떤 설계 문서를 기준으로 구현했는가?

이 질문에 답이 안 나오면 Notion 의존도가 과한 것이다.
