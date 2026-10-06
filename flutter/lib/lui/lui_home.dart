// Fernhilfe (Linux und Ich): start screen for the incoming-only client.
//
// Replaces the ID/password board of upstream's incoming-only home page with one
// big help number and three steps. Hooked in from desktop_home_page.dart (// LUI:).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';

import 'lui_style.dart';

/// Width of the main window's content (upstream: 280).
const double kLuiHomeWidth = 420;

/// Name shown in the instructions: the person who helps.
const String kLuiHelperName = 'Christoph';

/// "482913076" -> "482 913 076"
String luiFormatId(String id) {
  final s = id.replaceAll(' ', '');
  if (s.isEmpty || int.tryParse(s) == null) return id;
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return b.toString();
}

List<Widget> buildLuiHome(BuildContext context) => [const LuiHome()];

class LuiHome extends StatelessWidget {
  const LuiHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = LuiColors.of(context);
    final model = gFFI.serverModel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(lt('Hallo! Gleich kann dir jemand helfen.',
                  'Hi! Someone can help you in a moment.'),
              style: LuiText.heading(c)),
          const SizedBox(height: 4),
          Text(
              lt('Lass dieses Fenster offen, solange die Hilfe läuft.',
                  'Keep this window open while you get help.'),
              style: LuiText.body(c, muted: true)),
          const SizedBox(height: 18),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: model.serverId,
            builder: (context, value, _) => _IdBox(id: value.text),
          ),
          const SizedBox(height: 18),
          _Step(
              n: 1,
              text: lt(
                  'Sag $kLuiHelperName diese Nummer – am Telefon oder per Nachricht.',
                  'Tell $kLuiHelperName this number, by phone or message.')),
          _Step(
              n: 2,
              text: lt('Es erscheint eine Anfrage. Klick auf „Akzeptieren“.',
                  'A request appears. Click “Accept”.')),
          _Step(
              n: 3,
              text: lt('Fertig? Schließ einfach dieses Fenster.',
                  'Done? Just close this window.')),
        ],
      ),
    );
  }
}

class _IdBox extends StatelessWidget {
  final String id;
  const _IdBox({required this.id});

  @override
  Widget build(BuildContext context) {
    final c = LuiColors.of(context);
    final ready = id.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: c.surface2,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(lt('DEINE HILFE-NUMMER', 'YOUR HELP NUMBER'),
              style: LuiText.label(c)),
          const SizedBox(height: 4),
          SelectableText(ready ? luiFormatId(id) : '…',
              style: LuiText.number(c), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          TextButton(
            onPressed: ready
                ? () {
                    Clipboard.setData(
                        ClipboardData(text: id.replaceAll(' ', '')));
                    showToast(lt('Nummer kopiert', 'Number copied'));
                  }
                : null,
            style: TextButton.styleFrom(foregroundColor: c.accentText),
            child: Text(lt('Nummer kopieren', 'Copy number'),
                style: LuiText.body(c).copyWith(
                    color: c.accentText, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int n;
  final String text;
  const _Step({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = LuiColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: kLuiOrange, shape: BoxShape.circle),
            child: Text('$n', style: LuiText.badge()),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: LuiText.body(c))),
        ],
      ),
    );
  }
}
