#!/bin/bash
set -e

# Xcode provides ${SRCROOT} (project folder)
# and ${BUILT_PRODUCTS_DIR} (where the .app is being assembled)
SMC_SOURCE_DIR="${SRCROOT}/Summer/Resources/SMC"

# Temporary output location
TEMP_OUTPUT="/tmp/smc-build-$$"

# Final destination inside the App bundle
DEST_PATH="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources/smc"

# Ensure Resources folder exists before compiling
mkdir -p "$(dirname "$DEST_PATH")"

if [ ! -f "$SMC_SOURCE_DIR/smc.c" ]; then
    echo "❌ smc.c not found at $SMC_SOURCE_DIR"
    exit 1
fi

echo "🍎 Compiling SMC for build folder..."

cd "$SMC_SOURCE_DIR"

# Compile to temporary location
clang -arch arm64 -arch x86_64 \
    -mmacosx-version-min=13.0 \
    -O3 \
    -framework IOKit \
    -DCMD_TOOL_BUILD \
    -Wno-deprecated-declarations \
    -o "$TEMP_OUTPUT" \
    smc.c

# Copy to final destination
cp "$TEMP_OUTPUT" "$DEST_PATH"
chmod +x "$DEST_PATH"

# Sign the binary with Hardened Runtime
echo "🔐 Signing SMC binary with Hardened Runtime..."
codesign --force --sign - --options runtime "$DEST_PATH"

# Clean up temporary file
rm -f "$TEMP_OUTPUT"

echo "✅ SMC compiled, copied, and signed: $DEST_PATH"
