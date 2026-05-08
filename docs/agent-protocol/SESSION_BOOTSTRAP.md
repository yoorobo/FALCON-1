# FALCON-1 Session Bootstrap

새 AI 세션을 시작할 때 긴 헌법 전체를 복붙하지 말고, 아래 짧은 프롬프트를 먼저 사용한다. 에이전트는 이 프롬프트를 받은 뒤 레포의 최신 문서를 직접 읽어야 한다.

## Short Prompt

```text
FALCON-1 이어가기.

먼저 아래 순서대로 읽고 현재 상태를 보고해줘.
1. AGENTS.md
2. CLAUDE.md
3. docs/OPERATIONS.md
4. docs/exec-plans/active/
5. README.md

그 다음 아래를 보고해줘.
- 현재 브랜치
- git status
- 최근 커밋 5개
- 진행 중 실행 계획
- 다음 작업 후보 3개

추측하지 말고 파일과 명령 결과 기준으로만 답해줘.
범위를 벗어나는 추가 작업은 먼저 제안하고 확인받아.
```

## Long Prompt

```text
FALCON-1 프로젝트 세션 시작.

응답 시작 전 아래 파일을 우선순위대로 읽어 최신 운영 규칙을 확인해줘.
- AGENTS.md
- CLAUDE.md
- docs/OPERATIONS.md
- docs/exec-plans/active/
- README.md

그 다음 현재 저장소 상태를 확인해줘.
- 현재 브랜치
- git status --short --branch
- 최근 커밋 5개
- 진행 중 실행 계획 파일 목록

보고 형식은 아래 순서를 따라줘.
1. 현재 상태 요약
2. 진행 중 작업
3. 확인된 제약 사항
4. 다음 작업 후보 3개

작업 규칙:
- 추측 금지
- 범위 밖 작업은 제안 후 승인
- git 작업은 실제 실행 기준
- 불확실하면 [TBD: 기술조사 미반영] 표기
```

## Why This Exists

- Confluence나 개인 메모에서 긴 고정 프롬프트를 중복 관리하지 않기 위해
- 새 PC나 새 AI 세션에서도 GitHub만으로 동일한 시작 절차를 재현하기 위해
- 버전 번호나 낡은 경로를 프롬프트에 고정하지 않고, 최신 파일을 읽게 만들기 위해

## Update Rules

- 프로젝트 구조가 바뀌어 읽어야 할 핵심 파일 순서가 변할 때만 수정한다.
- 도구 버전, 임시 브랜치, 특정 태스크 이름은 이 문서에 넣지 않는다.
- 민감 정보, 인증 정보, 비밀번호는 절대 포함하지 않는다.
