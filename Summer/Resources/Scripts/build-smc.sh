#!/bin/bash
set -e

SMC_SOURCE_DIR="${SRCROOT}/Summer/Resources/SMC"

SMC_OUTPUT="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources/smc"

mkdir -p "$(dirname "$SMC_OUTPUT")"

if [ ! -f "$SMC_SOURCE_DIR/smc.c" ]; then
    echo "❌ smc.c não encontrado em $SMC_SOURCE_DIR"
    exit 1
fi

echo "🍎 Compilando SMC para a pasta build..."

cd "$SMC_SOURCE_DIR"
clang -arch arm64 \
    -mmacosx-version-min=13.0 \
    -O3 \
    -framework IOKit \
    -DCMD_TOOL_BUILD \
    -Wno-deprecated-declarations \
    -o "$SMC_OUTPUT" \
    smc.c

DEST_PATH="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources/smc"
cp "$SMC_OUTPUT" "$DEST_PATH"
chmod +x "$DEST_PATH"

echo "✅ SMC compilado e copiado para: $DEST_PATH"
