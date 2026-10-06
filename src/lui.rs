//! Fernhilfe (Linux und Ich): built-in client configuration.
//!
//! Upstream reads a custom-client configuration from a `custom.txt` signed by RustDesk.
//! Fernhilfe compiles its configuration in (`lui/config.json`) and ignores any `custom.txt`,
//! so nobody can point the client at another server by dropping a file next to it.
//!
//! The parsing mirrors `common::read_custom_client` minus the signature check.
//! Keep both in sync on upstream updates (see lui/UPSTREAM.md).

use base::config::keys;
use hbb_common::{config, log};
use std::collections::HashMap;

/// Always true; a constant so the upstream code paths after the hooks stay compiled and checked.
pub const ENABLED: bool = true;

const CONFIG: &str = include_str!("../lui/config.json");

pub fn apply() {
    let Ok(mut data) = serde_json::from_str::<HashMap<String, serde_json::Value>>(CONFIG) else {
        // lui/config.json is checked by the unit test below, so this cannot happen in a release
        log::error!("Fernhilfe: invalid built-in configuration");
        return;
    };
    if let Some(app_name) = data.remove("app-name").and_then(|v| v.as_str().map(str::to_owned)) {
        *config::APP_NAME.write().unwrap() = app_name;
    }
    fn map(list: &'static [&'static str]) -> HashMap<String, &'static &'static str> {
        list.iter().map(|s| (s.replace('_', "-"), s)).collect()
    }
    let display = map(keys::KEYS_DISPLAY_SETTINGS);
    let local = map(keys::KEYS_LOCAL_SETTINGS);
    let settings = map(keys::KEYS_SETTINGS);
    let buildin = map(keys::KEYS_BUILDIN_SETTINGS);
    for (name, is_override) in [("default-settings", false), ("override-settings", true)] {
        if let Some(v) = data.remove(name) {
            crate::common::read_custom_client_advanced_settings(
                v,
                &display,
                &local,
                &settings,
                &buildin,
                is_override,
            );
        }
    }
    let mut hard = config::HARD_SETTINGS.write().unwrap();
    for (k, v) in data {
        if let Some(v) = v.as_str() {
            hard.insert(k, v.to_owned());
        }
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn config_is_valid() {
        let v: serde_json::Value = serde_json::from_str(super::CONFIG).unwrap();
        assert_eq!(v["app-name"], "Fernhilfe");
        assert_eq!(v["conn-type"], "incoming");
        assert_eq!(v["override-settings"]["key"], "");
    }
}
