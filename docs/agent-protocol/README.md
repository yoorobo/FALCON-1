# Agent Protocol

FALCON-1에서 새 AI 세션을 시작하거나 컨텍스트 품질 저하로 세션을 재시작할 때 사용하는 문서 모음이다.

## Files

- [SESSION_BOOTSTRAP.md](SESSION_BOOTSTRAP.md) — 새 세션 첫 입력용 짧은 부트스트랩 프롬프트

## Rules

- 고정 텍스트의 원본은 GitHub 레포에 둔다.
- 세션 시작 프롬프트에는 버전 번호나 임시 상태 정보를 하드코딩하지 않는다.
- 실제 상태는 프롬프트가 지정한 파일과 git 명령 결과를 읽어 확인한다.
