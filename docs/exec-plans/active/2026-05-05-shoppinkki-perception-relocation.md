# shoppinkki_perception을 references로 이동

## 목적
외부 레퍼런스 코드가 src 트리에 섞여 있어 자동화 룰이 오작동.
docs/references/로 이동시켜 우리 코드와 외부 코드를 명확히 분리.

## 변경 대상
1. 이동: src/falcon1_perception/falcon1_perception/shoppinkki_perception/
       → docs/references/shoppinkki_perception/
2. doc-gardening.sh: docs/references/* 제외 룰 추가
3. verify-task.sh: docs/references/* 제외 룰 추가
4. .ruff.toml: extend-exclude에 docs/references 추가, shoppinkki_perception per-file-ignores 제거
5. ci.yml: ruff exclude 동일하게 반영

## 변경 전후

### 1. doc-gardening.sh
**변경 전:**
```bash
    if [ "$LINES" -gt 500 ]; then
        echo -e "  ${YELLOW}⚠️  ${file} — ${LINES}줄${NC}"
        OVERSIZED=1
    fi
done < <(find src/ -path src/openarm_ros2 -prune -o \( -name '*.py' -o -name '*.cpp' -o -name '*.hpp' \) -print 2>/dev/null || true)
```

**변경 후:**
```bash
    if [ "$LINES" -gt 500 ]; then
        echo -e "  ${YELLOW}⚠️  ${file} — ${LINES}줄${NC}"
        OVERSIZED=1
    fi
done < <(find src/ -path src/openarm_ros2 -prune -o -path docs/references -prune -o \( -name '*.py' -o -name '*.cpp' -o -name '*.hpp' \) -print 2>/dev/null || true)
```

### 2. verify-task.sh
**변경 전:**
```bash
    if [ "$LINES" -gt 500 ]; then
        echo -e "${YELLOW}  ⚠️  ${file} — ${LINES}줄 (500줄 초과)${NC}"
        OVERSIZED=1
    fi
done < <(find src/ -path src/openarm_ros2 -prune -o \( -name '*.py' -o -name '*.cpp' -o -name '*.hpp' \) -print 2>/dev/null || true)
```

**변경 후:**
```bash
    if [ "$LINES" -gt 500 ]; then
        echo -e "${YELLOW}  ⚠️  ${file} — ${LINES}줄 (500줄 초과)${NC}"
        OVERSIZED=1
    fi
done < <(find src/ -path src/openarm_ros2 -prune -o -path docs/references -prune -o \( -name '*.py' -o -name '*.cpp' -o -name '*.hpp' \) -print 2>/dev/null || true)
```

### 3. .ruff.toml
**변경 전:**
```toml
[lint.per-file-ignores]
# 레거시 shoppinkki_perception 코드: 줄 길이(E501), 세미콜론(E702) 완화
"src/falcon1_perception/falcon1_perception/shoppinkki_perception/*.py" = ["E402", "E501", "E702"]

[format]
```

**변경 후:**
```toml
extend-exclude = ["docs/references"]

[lint.per-file-ignores]

[format]
```

### 4. ci.yml
**변경 전:**
```yaml
      - name: Python Lint (ruff)
        run: ruff check src/ --exclude src/openarm_ros2
```

**변경 후:**
```yaml
      - name: Python Lint (ruff)
        run: ruff check src/ --exclude src/openarm_ros2 --exclude docs/references
```

### 5. 디렉토리 구조
**변경 전:**
```
src/falcon1_perception/falcon1_perception/
├── shoppinkki_perception/   ← 1153줄 외부 레퍼런스
└── (기타 우리 코드)
```

**변경 후:**
```
docs/references/
└── shoppinkki_perception/   ← 외부 레퍼런스 (자동화 룰 제외)

src/falcon1_perception/falcon1_perception/
└── (기타 우리 코드)
```

## 검증 방법
- bash scripts/doc-gardening.sh → references 안 잡는지
- bash scripts/verify-task.sh → 통과
- colcon build --packages-select falcon1_perception → 빌드 영향 없는지

## 롤백 방법
- git revert <commit-hash>
- 또는 git mv 역방향 실행

## 영향 범위
- falcon1_perception 패키지 빌드: 영향 없음 (Phase 1.5에서 미사용 확인)
- import 구문: 없음
