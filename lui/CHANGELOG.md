# Changelog

All notable changes to Fernhilfe. Versions are `<RustDesk version>-lui.<n>`.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [1.5.0-lui.1]

### Added
- Fork of RustDesk 1.5.0 with a built-in configuration: server `rustdesk.linuxandi.net`
  without key, incoming only, approval by click, all settings hidden, no installation,
  no update check against rustdesk.com, external `custom.txt` ignored.
- Own app name "Fernhilfe": own config folder and IPC socket, runs next to RustDesk.
- Start screen with the help number and three steps, German or English by system language.
- Connection request window: dark header instead of the blue gradient, dark text on orange buttons.
- No device registration (`register-device = N`): no API calls to port 21114.
- Linux und Ich colours, fonts (Inter, Space Grotesk, JetBrains Mono) and icon.
- Container build on Ubuntu 24.04 and AppImage packaging.
- `lui/update-upstream.sh` to follow new RustDesk releases.
