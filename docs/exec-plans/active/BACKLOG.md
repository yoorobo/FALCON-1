## [2026-05-05 발견] falcon1_perception 빌드 실패

**증상**: `colcon build --packages-select falcon1_perception` 실패
**원인**: `src/falcon1_perception/resource/shoppinkki_perception` 마커 파일 이름이
패키지명(`falcon1_perception`)과 일치하지 않음
**setup.py 동작**: `'resource/' + package_name`을 찾는데 실제로는 `shoppinkki_perception`만 존재
**해결 방법 후보**:
  1. `git mv resource/shoppinkki_perception resource/falcon1_perception`
  2. setup.py의 마커 파일 경로를 명시적 지정
**우선순위**: 중 (개발 중 즉시 영향 없으면 SR/디자인 단계 후 처리)
**관련 작업**: shoppinkki_perception 이동 작업(2026-05-05) 중 발견
