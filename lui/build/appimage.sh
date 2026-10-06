#!/bin/bash
# Pack the Flutter bundle into lui/dist/Fernhilfe-<version>-x86_64.AppImage.
# Runs inside the build container (called by inside.sh).
set -euo pipefail
cd /src
ID=de.linuxundich.Fernhilfe
UPSTREAM=$(sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -1)
VERSION=$(sed -n 's/^## \[\([0-9][^]]*\)\].*/\1/p' lui/CHANGELOG.md | head -1)
VERSION=${VERSION:-$UPSTREAM-lui.0}
BUNDLE=flutter/build/linux/x64/release/bundle
APPDIR=/tmp/AppDir

# Libraries the client needs that many desktops don't install by default
# (checked per distro by lui/test/distros.sh). Taken from Ubuntu 24.04.
BUNDLE_LIBS="libxdo.so.3"

rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/share/fernhilfe" "$APPDIR/usr/lib"
cp -a "$BUNDLE"/. "$APPDIR/usr/share/fernhilfe/"
for lib in $BUNDLE_LIBS; do
  cp -L "$(ldconfig -p | awk -v l="$lib" '$1==l && /x86-64/ {print $NF; exit}')" "$APPDIR/usr/lib/"
done

mkdir -p "$APPDIR/usr/share/icons"
cp -r lui/branding/hicolor "$APPDIR/usr/share/icons/"
cp lui/branding/hicolor/256x256/apps/$ID.png "$APPDIR/$ID.png"
cp lui/branding/hicolor/256x256/apps/$ID.png "$APPDIR/.DirIcon"

install -Dm644 lui/packaging/$ID.desktop "$APPDIR/$ID.desktop"
install -Dm644 lui/packaging/$ID.desktop "$APPDIR/usr/share/applications/$ID.desktop"
install -Dm644 lui/packaging/$ID.metainfo.xml "$APPDIR/usr/share/metainfo/$ID.appdata.xml"
install -Dm755 lui/packaging/AppRun "$APPDIR/AppRun"
echo "$VERSION" > "$APPDIR/usr/share/fernhilfe/VERSION"

OUT=lui/dist/Fernhilfe-$VERSION-x86_64.AppImage
APPIMAGE_EXTRACT_AND_RUN=1 ARCH=x86_64 appimagetool --no-appstream "$APPDIR" "$OUT"
(cd lui/dist && sha256sum "$(basename "$OUT")" > "$(basename "$OUT").sha256")
ls -la lui/dist
