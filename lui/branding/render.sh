#!/bin/sh
# Render the Fernhilfe icon (lui/branding/icon.svg, icon-small.svg for 16/24 px) into
#  - lui/branding/hicolor/<size>/de.linuxundich.Fernhilfe.png (AppImage, menu entry)
#  - the places upstream reads icons from (res/, flutter/assets/icon.svg)
# Needs rsvg-convert. Commit the results with git add -f (*.png/*.svg are ignored upstream).
set -eu
cd "$(dirname "$0")/../.."
B=lui/branding
ID=de.linuxundich.Fernhilfe
rm -rf "$B/hicolor"
for s in 16 24; do
  mkdir -p "$B/hicolor/${s}x${s}/apps"
  rsvg-convert -w $s -h $s "$B/icon-small.svg" -o "$B/hicolor/${s}x${s}/apps/$ID.png"
done
for s in 32 48 64 128 256 512; do
  mkdir -p "$B/hicolor/${s}x${s}/apps"
  rsvg-convert -w $s -h $s "$B/icon.svg" -o "$B/hicolor/${s}x${s}/apps/$ID.png"
done
mkdir -p "$B/hicolor/scalable/apps"
cp "$B/icon.svg" "$B/hicolor/scalable/apps/$ID.svg"

cp "$B/hicolor/32x32/apps/$ID.png" res/32x32.png
cp "$B/hicolor/64x64/apps/$ID.png" res/64x64.png
cp "$B/hicolor/128x128/apps/$ID.png" res/128x128.png
cp "$B/hicolor/256x256/apps/$ID.png" res/128x128@2x.png
cp "$B/hicolor/512x512/apps/$ID.png" res/icon.png
cp "$B/icon.svg" res/scalable.svg
cp "$B/icon.svg" flutter/assets/icon.svg
