#!/bin/bash
set -e

# O Xcode fornece ${SRCROOT} (pasta do projeto)
# e ${BUILT_PRODUCTS_DIR} (onde o .app está a ser montado)
SMC_SOURCE_DIR="${SRCROOT}/Summer/smc-source"
# O output agora vai para a pasta de ficheiros temporários do Xcode
# Isso joga o binário dentro da pasta do App em tempo de build
SMC_OUTPUT="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources/smc"

# Garante que a pasta Resources exista antes de compilar
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

# 2. Copia o binário diretamente para dentro do .app que está a ser gerado
# O sub-caminho depende de onde queres o binário (geralmente Resources)
DEST_PATH="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources/smc"
cp "$SMC_OUTPUT" "$DEST_PATH"
chmod +x "$DEST_PATH"

echo "✅ SMC compilado e copiado para: $DEST_PATH"
