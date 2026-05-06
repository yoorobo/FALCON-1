# 실행 계획: design-docs-bundle2

> 생성일: 2026-05-06 | 브랜치: feat/design-docs-bundle2

## 목표
상세설계 묶음 2(ERD, SM, PFL) 초안을 SR v2.0 기반으로 작성한다.

## 접근법
마스터 플랜 §3.3~§3.5의 SR 매핑과 목차를 고정 입력으로 사용하고, SA/IS 선행 산출물과 기술조사 PDF 근거를 반영한다.

## 단계별 계획
- [ ] 1. 입력 자료 읽기 및 ERD/SM/PFL SR 위임 목록 확인
- [ ] 2. `docs/design-docs/erd.md` 작성
- [ ] 3. `docs/design-docs/state_machine.md` 작성
- [ ] 4. `docs/design-docs/safety_pfl_spec.md` 작성
- [ ] 5. `bash scripts/verify-task.sh` 실행
- [ ] 6. 지정 파일 add/commit/push

## 완료 기준
- ERD/SM/PFL 문서 상단에 SR 매핑표 포함
- 마스터 플랜 H2/H3 구조 반영
- TBD 5건(P-27, P-48, P-59, P-67, P-67b) PoC 측정 후 확정 표기
- 검증 스크립트 실행 기록 확보 및 커밋 생성

## 제약 사항
- 근거 없는 수치는 `[TBD: 기술조사 미반영]`로 표기
- 지시 범위 밖 산출물 생성 금지

## 예상 소요 시간
반나절
