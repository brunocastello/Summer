#!/bin/bash
set -e

APP_NAME="Summer"
VERSION="1.0"
APP_PATH="./Summer.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="${APP_NAME}"

# Limpar builds anteriores
rm -rf build-dmg
rm -f "${DMG_NAME}"

# Criar pasta temporária
mkdir -p build-dmg
cp -r "${APP_PATH}" build-dmg/

# Criar link simbólico para Applications
ln -s /Applications build-dmg/Applications

# Criar DMG temporário (read-write)
hdiutil create -volname "${VOLUME_NAME}" \
  -srcfolder build-dmg \
  -ov -format UDRW \
  temp.dmg

# Montar DMG
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen temp.dmg | grep "/Volumes/${VOLUME_NAME}" | awk '{print $1}')

# Esperar montar
sleep 2

# Configurar aparência do DMG
echo '
   tell application "Finder"
     tell disk "'${VOLUME_NAME}'"
           open
           set current view of container window to icon view
           set toolbar visible of container window to false
           set statusbar visible of container window to false
           set the bounds of container window to {400, 100, 1000, 500}
           set viewOptions to the icon view options of container window
           set arrangement of viewOptions to not arranged
           set icon size of viewOptions to 128
           set position of item "'${APP_NAME}'.app" of container window to {175, 120}
           set position of item "Applications" of container window to {425, 120}
           close
           open
           update without registering applications
           delay 2
     end tell
   end tell
' | osascript

# Sincronizar
sync

# Desmontar
hdiutil detach "${DEVICE}"

# Converter para read-only comprimido
hdiutil convert temp.dmg \
  -format UDZO \
  -imagekey zlib-level=9 \
  -o "${DMG_NAME}"

# Limpar
rm -f temp.dmg
rm -rf build-dmg

echo "✅ DMG criado: ${DMG_NAME}"
