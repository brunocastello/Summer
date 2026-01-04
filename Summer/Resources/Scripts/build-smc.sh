#!/bin/bash
set -e

# Xcode provides ${SRCROOT} (project folder)
# and ${BUILT_PRODUCTS_DIR} (where the .app is being assembled)
SMC_SOURCE_DIR="${SRCROOT}/Summer/Resources/SMC"
# Output goes to Xcode's temporary files folder
# This places the binary inside the App bundle at build time
SMC_OUTPUT="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources/smc"

# Ensure Resources folder exists before compiling
mkdir -p "$(dirname "$SMC_OUTPUT")"

if [ ! -f "$SMC_SOURCE_DIR/smc.c" ]; then
    echo "❌ smc.c not found at $SMC_SOURCE_DIR"
    exit 1
fi

echo "🍎 Compiling SMC for build folder..."

cd "$SMC_SOURCE_DIR"
clang -arch arm64 \
    -mmacosx-version-min=13.0 \
    -O3 \
    -framework IOKit \
    -DCMD_TOOL_BUILD \
    -Wno-deprecated-declarations \
    -o "$SMC_OUTPUT" \
    smc.c

# Copy binary directly into the .app being generated
# Subdirectory depends on where you want the binary (usually Resources)
DEST_PATH="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources/smc"
cp "$SMC_OUTPUT" "$DEST_PATH"
chmod +x "$DEST_PATH"

# Sign the binary with Hardened Runtime
echo "🔐 Signing SMC binary with Hardened Runtime..."
codesign --force --sign - --options runtime "$DEST_PATH"

echo "✅ SMC compiled, copied, and signed: $DEST_PATH"
