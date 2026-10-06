#!/bin/bash
# Build Fernhilfe for Linux x86_64 inside the Ubuntu 24.04 build container.
#
#   lui/build.sh            full build: vcpkg deps, bridge, Rust library, Flutter bundle, AppImage
#   lui/build.sh --image    (re)build the container image first
#
# Caches live in ~/.cache/fernhilfe-build (cargo registry, vcpkg binaries, pub cache),
# build output in target/ and flutter/build/ of this checkout, the AppImage in lui/dist/.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
UPSTREAM=$(sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -1)
IMAGE=fernhilfe-build:$UPSTREAM
CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/fernhilfe-build

if [ "${1:-}" = --image ] || ! podman image exists "$IMAGE"; then
  podman build -t "$IMAGE" -f lui/build/Containerfile lui/build
fi

mkdir -p "$CACHE"/{cargo-registry,cargo-git,vcpkg-bin,vcpkg-downloads,pub-cache} lui/dist
podman run --rm -i \
  --userns=keep-id:uid=0,gid=0 \
  -v "$ROOT":/src:z \
  -v "$CACHE/cargo-registry":/opt/cargo/registry:z \
  -v "$CACHE/cargo-git":/opt/cargo/git:z \
  -v "$CACHE/vcpkg-bin":/root/.cache/vcpkg/archives:z \
  -v "$CACHE/vcpkg-downloads":/opt/vcpkg/downloads:z \
  -v "$CACHE/pub-cache":/root/.pub-cache:z \
  -e JOBS="${JOBS:-}" \
  "$IMAGE" bash /src/lui/build/inside.sh
# flutter pub get (Flutter 3.24.5) re-resolves the lock file; keep upstream's
git checkout -- flutter/pubspec.lock
