#!/bin/bash
# Runs inside the build container (see lui/build.sh). Mirrors upstream's Linux CI job.
set -euo pipefail
cd /src
git config --global --add safe.directory '*'
FEATURES=hwcodec,flutter,unix-file-copy-paste
step() { printf '\n=== %s ===\n' "$*"; }

step "vcpkg dependencies"
"$VCPKG_ROOT"/vcpkg install --triplet x64-linux --x-install-root="$VCPKG_ROOT/installed" \
  || { find "$VCPKG_ROOT/buildtrees" -name '*.log' -newer /src/Cargo.toml -exec tail -n 40 {} \; ; exit 1; }

step "Flutter patch from upstream"
git -C /opt/flutter-app apply --check /src/.github/patches/flutter_3.24.4_dropdown_menu_enableFilter.diff 2>/dev/null \
  && git -C /opt/flutter-app apply /src/.github/patches/flutter_3.24.4_dropdown_menu_enableFilter.diff || true

step "Rust <-> Dart bridge (Flutter ${BRIDGE_FLUTTER:-3.22.3})"
# Like upstream: extended_text 14 needs a newer Dart than the bridge Flutter has.
# pubspec.yaml is changed in place only for this step and restored even on failure –
# don't commit while a build runs.
cp flutter/pubspec.yaml /tmp/pubspec.yaml
cp flutter/pubspec.lock /tmp/pubspec.lock 2>/dev/null || true
restore_pubspec() { cp /tmp/pubspec.yaml flutter/pubspec.yaml; [ -f /tmp/pubspec.lock ] && cp /tmp/pubspec.lock flutter/pubspec.lock || true; }
trap restore_pubspec EXIT
sed -i -e 's/extended_text: 14.0.0/extended_text: 13.0.0/g' flutter/pubspec.yaml
(cd flutter && PATH=/opt/flutter-bridge/bin:$PATH flutter pub get)
PATH=/opt/flutter-bridge/bin:$PATH flutter_rust_bridge_codegen --rust-input ./src/flutter_ffi.rs \
  --dart-output ./flutter/lib/generated_bridge.dart --c-output ./flutter/macos/Runner/bridge_generated.h
cp ./flutter/macos/Runner/bridge_generated.h ./flutter/ios/Runner/bridge_generated.h
restore_pubspec
trap - EXIT
# workaround ffigen (build.py: ffi_bindgen_function_refactor)
sed -i "s/ffi.NativeFunction<ffi.Bool Function(DartPort/ffi.NativeFunction<ffi.Uint8 Function(DartPort/g" flutter/lib/generated_bridge.dart

step "Rust library"
export CARGO_INCREMENTAL=0
cargo build --locked --lib ${JOBS:+--jobs $JOBS} --features "$FEATURES" --release

step "Flutter bundle"
(cd flutter && PATH=/opt/flutter-app/bin:$PATH flutter build linux --release)

step "AppImage"
bash /src/lui/build/appimage.sh
