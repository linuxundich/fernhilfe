# Changelog

All notable changes to Fernhilfe. Versions are `<RustDesk version>-lui.<n>`.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [1.5.0-lui.6]

### Changed
- Back to the normal type size of lui.4 (start screen 480 px wide, text 14 px, help number 48 px; request
  window at upstream's 300 x 490 px, smaller session bar). The larger type of lui.5 is reverted, so the
  hooks in `consts.dart` and `connection_page.dart` are gone again.

### Kept
- The plain-words hint on Wayland sessions that the computer asks once more for screen sharing.

## [1.5.0-lui.5]

### Changed
- Larger type throughout for people with weaker eyes: start screen 560 px wide, headings 26 px,
  text 17 px, help number 56 px, status line 17 px; request window opens at 420 x 700 px with bigger
  buttons, icons and text; the session bar grows accordingly. The card width (closed chat) is now
  420 px, so the wider window no longer shows the empty chat panel next to the card.

### Added
- On Wayland sessions the start screen and the request window say in plain words that the computer
  asks once more for screen sharing, and what to click there.

## [1.5.0-lui.4]

### Changed
- The support site moved to hilfe.linuxandi.net; update check and "Update now" use the new address.
  The old address keeps serving downloads, so earlier versions still find updates.
- Bigger help number on the start screen (48 px instead of 34 px, window 480 px wide); it scales down
  instead of being cut off.

## [1.5.0-lui.3]

### Fixed
- Fernhilfe texts pick their language like RustDesk does (LC_ALL, LC_CTYPE, LANG). Before, English
  systems with German formats showed English Fernhilfe texts next to German RustDesk texts.

### Changed
- GitHub page screenshots from a real Ubuntu 26.04 installation.

## [1.5.0-lui.2]

### Added
- Connection request in Fernhilfe style: who wants to help, what they can do once accepted,
  a reminder to accept only while talking to them, "Decline" / "Accept".
- After "Accept" the request window shrinks to a small always-on-top bar with duration and "End"
  instead of minimizing; after the session it shows "Connection ended" / "Close".
- Update hint on the start screen when support.linuxandi.net has a newer version; "Update now"
  reruns the one-liner in the background and restarts Fernhilfe (one-liner installs only).

### Changed
- New icon from the Linux und Ich mark: terminal window with a foreign orange mouse pointer,
  separate 16/24 px version, full hicolor set in the AppImage.

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
