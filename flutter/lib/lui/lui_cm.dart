// Fernhilfe (Linux und Ich): connection request window.
//
// Replaces upstream's connection card (header, permission board, control panel) for remote
// sessions. Before the user answers it explains who wants to connect and what they can do;
// after "Accept" the window shrinks to a small always-on-top bar with "End" instead of
// minimizing. Hooked in from buildConnectionCard() in desktop/pages/server_page.dart (// LUI:).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../models/platform_model.dart';
import '../models/server_model.dart';
import 'lui_home.dart' show luiFormatId;
import 'lui_style.dart';

/// Window size of the session bar (tab bar + one row). 420 = kConnectionManagerWindowSizeClosedChat.
const Size kLuiCmBarSize = Size(420, kDesktopRemoteTabBarHeight + 100);

/// Window size while asking (upstream: 300 x 490). Larger type for people with weaker eyes.
const Size kLuiCmRequestSize =
    Size(420, 700);

/// Only plain remote-control sessions get the Fernhilfe card; file transfer, terminal and
/// the like keep upstream's card.
bool luiHandlesClient(Client client) => client.type_() == ClientType.remote;

Widget buildLuiConnectionCard(Client client) =>
    LuiConnectionCard(key: ValueKey(client.id), client: client);

class LuiConnectionCard extends StatefulWidget {
  final Client client;
  const LuiConnectionCard({Key? key, required this.client}) : super(key: key);

  @override
  State<LuiConnectionCard> createState() => _LuiConnectionCardState();
}

class _LuiConnectionCardState extends State<LuiConnectionCard> {
  Client get client => widget.client;
  Timer? _timer;
  int _seconds = 0;
  bool _isBar = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (client.authorized && !client.disconnected && mounted) {
        setState(() => _seconds++);
      }
    });
    // main.dart sizes the window right after showing it; enlarge it a moment later
    if (!client.authorized) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && !_isBar) {
          windowManager.setSizeAlignment(kLuiCmRequestSize, Alignment.topRight);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toBar() {
    if (_isBar) return;
    _isBar = true;
    windowManager.setSizeAlignment(kLuiCmBarSize, Alignment.topRight);
  }

  void _accept(BuildContext context) {
    Provider.of<ServerModel>(context, listen: false)
        .sendLoginResponse(client, true);
    _toBar();
  }

  void _end() => bind.cmCloseConnection(connId: client.id);

  Future<void> _close() async {
    await bind.cmRemoveDisconnectedConnection(connId: client.id);
    if (await bind.cmGetClientsLength() == 0) {
      windowManager.close();
    }
  }

  String get _name => client.name.trim().isNotEmpty ? client.name.trim() : '?';

  @override
  Widget build(BuildContext context) {
    return Consumer<ServerModel>(builder: (context, _, __) {
      final c = LuiColors.of(context);
      if (client.authorized && !client.disconnected) {
        // also when accepted elsewhere (e.g. after a reconnect)
        WidgetsBinding.instance.addPostFrameCallback((_) => _toBar());
        return _buildBar(c);
      }
      if (client.disconnected) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _toBar());
        return _buildEnded(c);
      }
      return _buildRequest(context, c);
    });
  }

  Widget _avatar({double size = 60, bool grey = false}) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: grey ? const Color(0xFF8A8883) : kLuiOrange,
            shape: BoxShape.circle),
        child: Text(_name.characters.first.toUpperCase(),
            style: TextStyle(
                fontFamily: kLuiFontHeading,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.42,
                color: kLuiInk)),
      );

  Widget _button(String text,
      {required VoidCallback onTap,
      bool primary = false,
      bool danger = false,
      required LuiColors c}) {
    final fg = primary
        ? kLuiInk
        : danger
            ? const Color(0xFFDC2626)
            : c.text;
    return SizedBox(
      height: 50,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: primary ? kLuiOrange : Colors.transparent,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: primary ? BorderSide.none : BorderSide(color: c.line),
          ),
        ),
        child: Text(text,
            style: TextStyle(
                fontFamily: kLuiFontBody,
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: fg)),
      ),
    );
  }

  Widget _perm(IconData icon, String text, LuiColors c) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(icon, size: 22, color: c.accentText),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: LuiText.body(c))),
        ]),
      );

  Widget _buildRequest(BuildContext context, LuiColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            _avatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lt('$_name möchte helfen', '$_name wants to help'),
                      style: LuiText.heading(c).copyWith(fontSize: 22)),
                  const SizedBox(height: 2),
                  Text(lt('von Gerät ', 'from device ') + luiFormatId(client.peerId),
                      style: LuiText.body(c, muted: true)
                          .copyWith(fontSize: 15)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 18),
          Text(lt('Wenn du akzeptierst, kann $_name:', 'If you accept, $_name can:'),
              style: LuiText.body(c, muted: true)),
          const SizedBox(height: 8),
          _perm(Icons.visibility_outlined,
              lt('deinen Bildschirm sehen', 'see your screen'), c),
          if (client.keyboard)
            _perm(Icons.mouse_outlined,
                lt('Maus und Tastatur benutzen', 'use mouse and keyboard'), c),
          if (client.file)
            _perm(Icons.swap_vert,
                lt('Dateien übertragen', 'transfer files'), c),
          if (client.clipboard)
            _perm(Icons.content_paste_outlined,
                lt('die Zwischenablage nutzen', 'use the clipboard'), c),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: c.surface2, borderRadius: BorderRadius.circular(6)),
            child: Text(
                lt('Akzeptiere nur, wenn du gerade mit $_name sprichst.',
                        'Only accept if you’re talking to $_name right now.') +
                    (luiIsWayland
                        ? lt(
                            '\n\nDanach fragt dein Rechner noch einmal, ob er den Bildschirm teilen darf. Erlaube das auch dort.',
                            '\n\nYour computer then asks once more whether it may share the screen. Allow that too.')
                        : ''),
                style: LuiText.body(c, muted: true).copyWith(fontSize: 15)),
          ),
          const Spacer(),
          Row(children: [
            Expanded(
                flex: 2,
                child: _button(lt('Ablehnen', 'Decline'), onTap: _end, c: c)),
            const SizedBox(width: 10),
            Expanded(
                flex: 3,
                child: _button(lt('Akzeptieren', 'Accept'),
                    onTap: () => _accept(context), primary: true, c: c)),
          ]),
        ],
      ),
    );
  }

  String get _duration {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return _seconds >= 3600 ? '${_seconds ~/ 3600}:$m:$s' : '$m:$s';
  }

  Widget _buildBar(LuiColors c) {
    final doing =
        client.keyboard ? lt('steuert', 'controlling') : lt('schaut zu', 'watching');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        _avatar(size: 44),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lt('$_name ist verbunden', '$_name is connected'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuiText.heading(c).copyWith(fontSize: 18)),
              const SizedBox(height: 2),
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFFDC2626), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('$doing · $_duration',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuiText.body(c, muted: true).copyWith(
                          fontSize: 15,
                          fontFeatures: const [FontFeature.tabularFigures()])),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _button(lt('Beenden', 'End'), onTap: _end, danger: true, c: c),
      ]),
    );
  }

  Widget _buildEnded(LuiColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        _avatar(size: 44, grey: true),
        const SizedBox(width: 10),
        Expanded(
          child: Text(lt('Verbindung beendet', 'Connection ended'),
              style: LuiText.heading(c).copyWith(fontSize: 18)),
        ),
        _button(lt('Schließen', 'Close'), onTap: _close, c: c),
      ]),
    );
  }
}
