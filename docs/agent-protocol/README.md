# Agent Protocol

FALCON-1에서 새 AI 세션을 시작하거나 컨텍스트 품질 저하로 세션을 재시작할 때 사용하는 문서 모음이다.

## Files

- [SESSION_BOOTSTRAP.md](SESSION_BOOTSTRAP.md) — 새 세션 첫 입력용 짧은 부트스트랩 프롬프트
- [bootstrap-short.txt](bootstrap-short.txt) — `fs` alias에 연결할 복붙 전용 짧은 프롬프트
- [bootstrap-long.txt](bootstrap-long.txt) — `fsl` alias에 연결할 복붙 전용 긴 프롬프트
- [end-check.txt](end-check.txt) — `fe` alias에 연결할 종료 전 체크리스트

## Rules

- 고정 텍스트의 원본은 GitHub 레포에 둔다.
- 세션 시작 프롬프트에는 버전 번호나 임시 상태 정보를 하드코딩하지 않는다.
- 실제 상태는 프롬프트가 지정한 파일과 git 명령 결과를 읽어 확인한다.

## Terminal Usage

기본 출력:

```bash
bash scripts/show-bootstrap.sh short
bash scripts/show-bootstrap.sh long
bash scripts/show-end-check.sh
```

권장 alias:

```bash
alias fs='cd ~/Falcon-1/FALCON-1 && bash scripts/show-bootstrap.sh short'
alias fsl='cd ~/Falcon-1/FALCON-1 && bash scripts/show-bootstrap.sh long'
alias fe='cd ~/Falcon-1/FALCON-1 && bash scripts/show-end-check.sh'
```
