#!/bin/bash
# ============================================================
# CPAS Sandbox Plugin Builder
# - .claude-plugin/plugin.json 누락 방지 (백업 자동 복구)
# - 빌드 전 검증 → zip 패키징 → 빌드 후 검증
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$SCRIPT_DIR"
META_DIR="$PLUGIN_DIR/.claude-plugin"
META_FILE="$META_DIR/plugin.json"
BACKUP_FILE="$PLUGIN_DIR/plugin-meta-backup.json"

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "  CPAS Sandbox Plugin Builder"
echo "=========================================="

# ── Step 1: .claude-plugin/plugin.json 존재 확인 ──
if [ ! -f "$META_FILE" ]; then
    echo -e "${YELLOW}[WARNING] .claude-plugin/plugin.json 누락 감지!${NC}"

    if [ -f "$BACKUP_FILE" ]; then
        echo -e "${GREEN}[RECOVER] plugin-meta-backup.json에서 복구 중...${NC}"
        mkdir -p "$META_DIR"
        cp "$BACKUP_FILE" "$META_FILE"
        echo -e "${GREEN}[RECOVER] 복구 완료!${NC}"
    else
        echo -e "${RED}[ERROR] 백업 파일도 없습니다! .claude-plugin/plugin.json을 수동으로 만들어주세요.${NC}"
        exit 1
    fi
fi

# ── Step 2: 버전 읽기 ──
VERSION=$(python3 -c "import json; print(json.load(open('$META_FILE'))['version'])" 2>/dev/null)
if [ -z "$VERSION" ]; then
    echo -e "${RED}[ERROR] plugin.json에서 version을 읽을 수 없습니다.${NC}"
    exit 1
fi
echo "  Version: $VERSION"

# ── Step 3: 백업 동기화 (plugin.json → backup) ──
cp "$META_FILE" "$BACKUP_FILE"
echo -e "${GREEN}[SYNC] plugin-meta-backup.json 동기화 완료${NC}"

# ── Step 4: 출력 파일명 결정 ──
OUTPUT_NAME="${1:-cpas-sandbox.plugin}"
OUTPUT_PATH="$(dirname "$PLUGIN_DIR")/$OUTPUT_NAME"
echo "  Output: $OUTPUT_PATH"

# ── Step 5: zip 빌드 ──
cd "$PLUGIN_DIR"
rm -f "$OUTPUT_PATH"

zip -r "$OUTPUT_PATH" \
    .claude-plugin/ \
    agents/ \
    commands/ \
    skills/ \
    README.md \
    plugin-meta-backup.json \
    -x "build-plugin.sh"

echo ""

# ── Step 6: 빌드 후 검증 ──
echo "── Post-build verification ──"

# 6a. .claude-plugin/plugin.json 포함 확인
if unzip -l "$OUTPUT_PATH" | grep -q ".claude-plugin/plugin.json"; then
    echo -e "${GREEN}  [OK] .claude-plugin/plugin.json 포함됨${NC}"
else
    echo -e "${RED}  [FAIL] .claude-plugin/plugin.json 누락! 빌드 실패.${NC}"
    rm -f "$OUTPUT_PATH"
    exit 1
fi

# 6b. 버전 일치 확인
ZIP_VERSION=$(unzip -p "$OUTPUT_PATH" .claude-plugin/plugin.json | python3 -c "import json,sys; print(json.load(sys.stdin)['version'])")
if [ "$ZIP_VERSION" = "$VERSION" ]; then
    echo -e "${GREEN}  [OK] 버전 일치: $ZIP_VERSION${NC}"
else
    echo -e "${RED}  [FAIL] 버전 불일치: 소스=$VERSION, zip=$ZIP_VERSION${NC}"
    exit 1
fi

# 6c. 핵심 디렉토리 확인
for DIR in agents/ commands/ skills/; do
    if unzip -l "$OUTPUT_PATH" | grep -q "$DIR"; then
        echo -e "${GREEN}  [OK] $DIR 포함됨${NC}"
    else
        echo -e "${RED}  [FAIL] $DIR 누락!${NC}"
        exit 1
    fi
done

echo ""
echo -e "${GREEN}=========================================="
echo "  BUILD SUCCESS: $OUTPUT_NAME (v$VERSION)"
echo "==========================================${NC}"
