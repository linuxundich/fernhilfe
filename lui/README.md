# Fernhilfe – Remote Help by Linux und Ich

Fernhilfe is a fork of [RustDesk](https://github.com/rustdesk/rustdesk) for one job:
someone who needs help starts it, reads out a number and clicks **Allow**.

- connects to `rustdesk.linuxandi.net` only – no server, key or proxy settings
- incoming only: it can be controlled, it cannot control other computers
- every session needs a click on **Allow**, there is no password and no unattended access
- no installation, no root, no system service: help only works while the window is open
- runs next to an installed RustDesk without touching it (own app name, config and socket)
- Linux x86_64, Ubuntu 24.04 or newer (glibc 2.39), X11 and Wayland

Everything specific to Fernhilfe lives in `lui/` and in a few files marked `// LUI:`.
The rest of this repository is upstream RustDesk, unchanged.

## Download

Get it from <https://support.linuxandi.net/>. The one-liner there downloads the AppImage
to `~/.local/share/fernhilfe/` and adds a menu entry; you can also run the AppImage directly.

## Repository layout

| Path | Content |
|---|---|
| `lui/config.json` | built-in client configuration (server, incoming only, hidden settings) |
| `src/lui.rs` | applies `lui/config.json` instead of a signed `custom.txt` |
| `flutter/lib/lui/` | start screen and CI colours/type |
| `flutter/assets/lui-fonts/` | Inter, Space Grotesk, JetBrains Mono (OFL) |
| `lui/branding/` | icon source and `render.sh` |
| `lui/packaging/` | AppRun, .desktop, AppStream metadata |
| `lui/build.sh`, `lui/build/` | container build (Ubuntu 24.04) and AppImage packaging |
| `lui/update-upstream.sh` | move the Fernhilfe commits onto a new RustDesk release |
| `lui/UPSTREAM.md` | every place where Fernhilfe hooks into upstream code |

## Building

Needs Podman. The first run builds the image and all vcpkg libraries (an hour or more);
later runs reuse the caches in `~/.cache/fernhilfe-build`.

```sh
lui/build.sh            # -> lui/dist/Fernhilfe-<version>-x86_64.AppImage
lui/build.sh --image    # rebuild the container image first
```

## Branches and updates

| Branch / tag | Meaning |
|---|---|
| `master` | mirror of `rustdesk/rustdesk` (remote `upstream`) |
| `fernhilfe` | upstream release tag + the Fernhilfe commits |
| `fernhilfe-<version>` | previous state, kept by the update script |
| `<upstream>-lui.<n>` | Fernhilfe releases, e.g. `1.5.0-lui.1` |

To follow a new RustDesk release:

```sh
lui/update-upstream.sh 1.5.1   # rebase onto the new tag, print upstream's tool versions
lui/build.sh --image           # after adjusting lui/build/Containerfile if versions changed
```

Keep Fernhilfe changes in their own files where possible. Where upstream code must change,
keep the hook short and mark it with `// LUI:` (or `# LUI:`), and list it in `lui/UPSTREAM.md`.

## Testing a build

1. Start the AppImage on Ubuntu 24.04+ (VM): status "Ready", the help number appears.
2. Connect from a RustDesk that has the server key: a request appears; **Allow** → control works,
   on Wayland after the portal dialog.
3. Close the window: the session ends, the number is no longer reachable.
4. With a normal RustDesk running at the same time, both work independently.
5. `lui/test/distros.sh` checks that the AppImage's libraries resolve on Ubuntu, Debian, Fedora,
   Arch and openSUSE containers.

## License

AGPL-3.0, like RustDesk. Fernhilfe is not affiliated with or endorsed by the RustDesk project.
