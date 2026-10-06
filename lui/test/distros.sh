#!/bin/bash
# Check that the AppImage's binaries load on current distributions.
# For each distro container: install the libraries a typical desktop has (GTK 3, GStreamer base,
# PulseAudio client, VA-API, ALSA), then list unresolved libraries of the Fernhilfe binaries.
# The client itself can't start without a display; this only checks linking.
#
#   lui/test/distros.sh lui/dist/Fernhilfe-*.AppImage
set -euo pipefail
APPIMAGE=$(readlink -f "${1:?usage: lui/test/distros.sh <AppImage>}")
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
(cd "$WORK" && "$APPIMAGE" --appimage-extract >/dev/null)
ROOT=$WORK/squashfs-root

echo "Highest glibc symbol version needed:"
find "$ROOT/usr" -type f \( -name '*.so*' -o -name rustdesk \) -exec objdump -T {} + 2>/dev/null \
  | grep -o 'GLIBC_[0-9.]*' | sort -uV | tail -1

CHECK='cd /app && LD_LIBRARY_PATH=/app/usr/lib:/app/usr/share/fernhilfe/lib \
  ldd usr/share/fernhilfe/rustdesk usr/share/fernhilfe/lib/*.so 2>&1 | grep "not found" | sort -u || echo "  all libraries found"'

run() {
  local name=$1 image=$2 install=$3
  echo; echo "== $name ($image)"
  podman run --rm -v "$ROOT":/app:ro,z "$image" sh -c "$install >/dev/null 2>&1; $CHECK"
}
run "Ubuntu 24.04"  docker.io/library/ubuntu:24.04 \
  'apt-get update && apt-get install -y libgtk-3-0t64 libgstreamer-plugins-base1.0-0 libpulse0 libva2 libva-drm2 libva-x11-2 libasound2t64'
run "Debian 13"     docker.io/library/debian:13 \
  'apt-get update && apt-get install -y libgtk-3-0t64 libgstreamer-plugins-base1.0-0 libpulse0 libva2 libva-drm2 libva-x11-2 libasound2t64'
run "Fedora 43"     registry.fedoraproject.org/fedora:43 \
  'dnf install -y gtk3 gstreamer1-plugins-base pulseaudio-libs libva alsa-lib'
run "Arch"          docker.io/library/archlinux:latest \
  'pacman -Sy --noconfirm gtk3 gst-plugins-base-libs libpulse libva alsa-lib'
run "openSUSE Tumbleweed" registry.opensuse.org/opensuse/tumbleweed:latest \
  'zypper -n in libgtk-3-0 libgstreamer-1_0-0 gstreamer-plugins-base libpulse0 libva2 libva-drm2 libva-x11-2 libasound2'
