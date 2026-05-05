# Exec Plans — 실행 계획 관리

FALCON-1 실행 계획 문서 보관 폴더입니다.

## 구조

```
exec-plans/
├── active/      ← 진행 중인 실행 계획
├── completed/   ← 완료된 실행 계획
└── README.md    ← 이 파일
```

## 규칙

- 새 계획: `active/YYYY-MM-DD-exec-plan-NNN.md` 형식으로 작성
- 완료 시: `completed/`로 이동 + `docs/PLANS.md` 업데이트
- 30일 이상 비활성 계획: 검토 후 완료 처리 또는 폐기
