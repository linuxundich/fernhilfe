#!/bin/sh
# Render the Fernhilfe icon into the places upstream reads icons from.
# Needs rsvg-convert. Run after changing icon.svg, then commit the results (git add -f: *.png/*.svg are ignored upstream).
set -eu
cd "$(dirname "$0")/../.."
SVG=lui/branding/icon.svg
for s in 32 64 128; do rsvg-convert -w $s -h $s "$SVG" -o res/${s}x${s}.png; done
rsvg-convert -w 256 -h 256 "$SVG" -o res/128x128@2x.png
rsvg-convert -w 512 -h 512 "$SVG" -o res/icon.png
cp "$SVG" res/scalable.svg
cp "$SVG" flutter/assets/icon.svg
