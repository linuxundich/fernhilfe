// Fernhilfe (Linux und Ich): update hint.
//
// Compares the bundled VERSION file with https://hilfe.linuxandi.net/download/fernhilfe-version.txt.
// If Fernhilfe was set up by the one-liner (~/.local/share/fernhilfe/app), "Update now" runs the
// one-liner again in the background: it waits until this process has exited, installs the new
// version and starts it. A directly started AppImage only gets the hint.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String kLuiDownloadBase = 'https://hilfe.linuxandi.net';
const String _kInstallDir = '/.local/share/fernhilfe/app/';

class LuiUpdate {
  final String current;
  final String latest;
  const LuiUpdate(this.current, this.latest);
}

/// Compares "1.5.0-lui.2"-style versions by their numbers: 1.5.1-lui.1 > 1.5.0-lui.3.
int luiCompareVersions(String a, String b) {
  List<int> parts(String v) => RegExp(r'\d+')
      .allMatches(v)
      .map((m) => int.tryParse(m.group(0)!) ?? 0)
      .toList();
  final pa = parts(a), pb = parts(b);
  for (var i = 0; i < pa.length || i < pb.length; i++) {
    final x = i < pa.length ? pa[i] : 0, y = i < pb.length ? pb[i] : 0;
    if (x != y) return x < y ? -1 : 1;
  }
  return 0;
}

String get _exeDir => File(Platform.resolvedExecutable).parent.path;

/// The user's real home if this copy was installed by fernhilfe.sh, else null.
/// (The launcher points HOME at ~/.local/share/fernhilfe/home, so derive it from the path.)
String? get luiInstalledHome {
  final exe = Platform.resolvedExecutable;
  final i = exe.indexOf(_kInstallDir);
  return i > 0 ? exe.substring(0, i) : null;
}

/// Network errors (e.g. right after login, before the network is up) are retried twice.
Future<LuiUpdate?> luiCheckUpdate() async {
  final String current;
  try {
    current = (await File('$_exeDir/VERSION').readAsString()).trim();
  } catch (_) {
    return null; // not an AppImage build
  }
  if (current.isEmpty) return null;
  for (var attempt = 1; attempt <= 3; attempt++) {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final req = await client
          .getUrl(Uri.parse('$kLuiDownloadBase/download/fernhilfe-version.txt'));
      final res = await req.close().timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;
      final latest =
          (await res.transform(utf8.decoder).join()).trim().split('\n').first;
      if (latest.length > 40 || luiCompareVersions(latest, current) <= 0) {
        return null;
      }
      return LuiUpdate(current, latest);
    } catch (e) {
      print('Fernhilfe update check, attempt $attempt: $e');
      if (attempt < 3) await Future.delayed(const Duration(seconds: 20));
    } finally {
      client.close(force: true);
    }
  }
  return null;
}

/// Starts the one-liner detached and quits Fernhilfe. Returns false if that isn't possible.
Future<bool> luiRunUpdate() async {
  final home = luiInstalledHome;
  if (home == null) return false;
  const url = '$kLuiDownloadBase/fernhilfe.sh';
  final script = '(command -v curl >/dev/null 2>&1 && curl -fsSL $url || wget --no-hsts -qO- $url) | sh';
  final env = Map<String, String>.from(Platform.environment)
    ..['HOME'] = home
    ..['FERNHILFE_WAIT_PID'] = '$pid'
    ..remove('XDG_CONFIG_HOME')
    ..remove('XDG_DATA_HOME')
    ..remove('XDG_CACHE_HOME')
    ..remove('XDG_STATE_HOME');
  try {
    await Process.start('sh', ['-c', script],
        environment: env,
        includeParentEnvironment: false,
        mode: ProcessStartMode.detached);
  } catch (_) {
    return false;
  }
  exit(0);
}
