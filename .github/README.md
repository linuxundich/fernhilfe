<p align="center">
  <img src="/lui/branding/icon.svg" width="96" height="96" alt="Fernhilfe icon">
</p>

<h1 align="center">Fernhilfe – Remote Help by Linux und Ich</h1>

<p align="center">
  A RustDesk build for one job: someone who needs help starts it, reads out a number and clicks <b>Accept</b>.
</p>

<p align="center">
  <img src="/lui/screenshots/start-en.webp" width="320" alt="Remote Help window with the help number and the status Ready">
  &nbsp;
  <img src="/lui/screenshots/request-en.webp" width="196" alt="Connection request: Toff wants to help, with Decline and Accept">
</p>

## What it does

- **Nothing to set up.** Connects to the Linux und Ich support server and nothing else – no server, key or proxy settings.
- **Incoming only.** It can be controlled, it cannot control other computers.
- **You decide.** Every session needs a click on *Accept*. There is no password and no unattended access.
- **Leaves no trace.** No installation, no root, no system service. Help only works while the window is open.
- **Plays nice.** Runs next to an installed RustDesk without touching it (own app name, config folder and socket).
- **German or English**, following your system language. Light and dark follow your desktop.

Linux x86_64 with glibc 2.39 or newer: Ubuntu 24.04+, Linux Mint 22, Debian 13, Fedora, openSUSE Tumbleweed, Arch. X11 and Wayland.

## Get it

Remote Help is meant for people I help personally. The one-liner and instructions (German and English) are at
**[support.linuxandi.net](https://support.linuxandi.net/)**:

```sh
wget -qO- https://support.linuxandi.net/fernhilfe.sh | sh
```

It downloads the AppImage to `~/.local/share/fernhilfe/`, adds a menu entry with a *Remove* action and starts it.

## How it's made

Fernhilfe is a fork of [RustDesk](https://github.com/rustdesk/rustdesk) 1.5.0. Branch `fernhilfe` is the upstream release
tag plus a handful of commits; `master` mirrors upstream. Everything specific to Fernhilfe lives in [`lui/`](/lui),
[`src/lui.rs`](/src/lui.rs) and [`flutter/lib/lui/`](/flutter/lib/lui), plus a few hooks marked `// LUI:` that are listed in
[`lui/UPSTREAM.md`](/lui/UPSTREAM.md).

- The client configuration is compiled in from [`lui/config.json`](/lui/config.json) instead of a signed `custom.txt`.
- Build: `lui/build.sh` (Podman, Ubuntu 24.04 container) → AppImage.
- Following upstream: `lui/update-upstream.sh <version>`.

Details: [`lui/README.md`](/lui/README.md) · Changes: [`lui/CHANGELOG.md`](/lui/CHANGELOG.md)

## License

AGPL-3.0, like RustDesk. Fernhilfe is not affiliated with or endorsed by the RustDesk project.
Fonts: Inter, Space Grotesk, JetBrains Mono (SIL Open Font License).
