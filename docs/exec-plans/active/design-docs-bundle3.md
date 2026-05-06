# 실행 계획: design-docs-bundle3

> 생성일: 2026-05-06 | 브랜치: feat/design-docs-bundle3

## 목표
상세설계 묶음 3(MS, BT) 초안을 SR v2.0 기반으로 작성한다.

## 접근법
마스터 플랜 §3.6/§3.7의 SR 매핑·목차를 고정 입력으로 사용하고, SA/IS/ERD/SM/PFL 산출물과 기술조사 근거를 직접 참조한다.

## 단계별 계획
- [ ] 1. 입력 자료 읽기 및 MS/BT 위임 SR 확인
- [ ] 2. `docs/design-docs/manipulation_sequence.md` 작성
- [ ] 3. `docs/design-docs/behavior_tree.md` 작성
- [ ] 4. `bash scripts/verify-task.sh` 실행
- [ ] 5. 지정 파일 add/commit/push

## 완료 기준
- MS/BT 상단 SR 매핑표 포함
- 마스터 플랜 H2/H3 구조 반영
- BT 텍스트 트리(Sequence/Fallback/Condition/Action) 포함
- TBD 5건 PoC 측정 후 확정 표기 반영

## 제약 사항
- 근거 없는 값은 `[TBD: 기술조사 미반영]` 명시
- 지시 범위를 벗어나는 산출물 작성 금지

## 예상 소요 시간
반나절
