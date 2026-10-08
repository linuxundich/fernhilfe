# Hooks into upstream code

Every change to an upstream file. Search for `LUI:` to find them. Keep this list current.

| File | Hook | Why |
|---|---|---|
| `src/lib.rs` | `mod lui;` | registers `src/lui.rs` |
| `src/common.rs` `load_custom_client()` | calls `lui::apply()` and returns | built-in config instead of `custom.txt` |
| `src/common.rs` `read_custom_client()` | calls `lui::apply()` and returns | ignore configs passed from elsewhere |
| `src/common.rs` `read_custom_client_advanced_settings` | `pub(crate)` | reused by `lui.rs` |
| `flutter/lib/desktop/pages/desktop_home_page.dart` | import, `buildLuiHome()` in `buildLeftPane`, width `kLuiHomeWidth` | Fernhilfe start screen |
| `flutter/lib/desktop/pages/server_page.dart` | imports, `buildLuiConnectionCard()` at the top of `buildConnectionCard` (remote sessions), header gradient `kLuiCmHeaderGradient`, `luiButtonTextColor()` in `buildButton` | Fernhilfe request window and session bar; CI colours for the remaining upstream cards |
| `flutter/lib/common.dart` `MyTheme` | `accent*`, `button` colours | CI orange |
| `flutter/pubspec.yaml` | font families Inter, SpaceGrotesk, JetBrainsMono | CI fonts |
| `flutter/linux/my_application.cc` | `g_set_prgname`, icon name | own WM_CLASS and window icon |
| `res/*.png`, `res/scalable.svg`, `flutter/assets/icon.svg` | replaced by `lui/branding/render.sh` (sources `icon.svg`, `icon-small.svg`) | icon |

`src/lui.rs` mirrors the parsing in `common::read_custom_client`. If upstream changes that
function (new sections besides `default-settings`/`override-settings`), port it.
