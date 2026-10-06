// Fernhilfe (Linux und Ich): colours and type from the Linux und Ich CI
// (lui-theme: theme.json, custom.css). Used by the lui/ widgets.
import 'dart:io';

import 'package:flutter/material.dart';

const kLuiOrange = Color(0xFFFF6600);
const kLuiOrangeDark = Color(0xFFCC5200);
const kLuiInk = Color(0xFF1A1A1A);

const kLuiFontBody = 'Inter';
const kLuiFontHeading = 'SpaceGrotesk';
const kLuiFontMono = 'JetBrainsMono';

/// German if the system language is German, otherwise English.
/// Same lookup order as RustDesk (sys-locale: LC_ALL, LC_CTYPE, LANG), so the Fernhilfe texts
/// and RustDesk's own texts never end up in different languages.
bool get luiIsGerman {
  final env = Platform.environment;
  String? pick(String k) => (env[k] ?? '').isEmpty ? null : env[k];
  final lang = pick('LC_ALL') ?? pick('LC_CTYPE') ?? pick('LANG') ?? '';
  final l = lang.isNotEmpty ? lang : Platform.localeName;
  return l.toLowerCase().startsWith('de');
}

String lt(String de, String en) => luiIsGerman ? de : en;

class LuiColors {
  final Color surface, surface2, text, muted, line, accentText, ok;
  const LuiColors._(this.surface, this.surface2, this.text, this.muted,
      this.line, this.accentText, this.ok);

  static const light = LuiColors._(
      Color(0xFFFFFFFF),
      Color(0xFFF5F4F2),
      Color(0xFF1A1A1A),
      Color(0xFF63625F),
      Color(0xFFE3E1DD),
      kLuiOrangeDark,
      Color(0xFF16A34A));
  static const dark = LuiColors._(
      Color(0xFF1E1E1E),
      Color(0xFF262626),
      Color(0xFFF2F1ED),
      Color(0xFFA19E97),
      Color(0xFF383838),
      kLuiOrange,
      Color(0xFF4ADE80));

  static LuiColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

class LuiText {
  static TextStyle heading(LuiColors c) => TextStyle(
      fontFamily: kLuiFontHeading,
      fontSize: 21,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: c.text);
  static TextStyle body(LuiColors c, {bool muted = false}) => TextStyle(
      fontFamily: kLuiFontBody,
      fontSize: 14,
      height: 1.4,
      color: muted ? c.muted : c.text);
  static TextStyle label(LuiColors c) => TextStyle(
      fontFamily: kLuiFontMono,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.9,
      color: c.muted);
  static TextStyle number(LuiColors c) => TextStyle(
      fontFamily: kLuiFontMono,
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
      color: c.text);
  static TextStyle badge() => const TextStyle(
      fontFamily: kLuiFontHeading,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: kLuiInk);
}

/// Header card of the connection request window (upstream: blue gradient).
const kLuiCmHeaderGradient = [Color(0xFF3A3939), Color(0xFF1A1A1A)];

/// White text on orange fails WCAG contrast; the CI uses dark text on orange.
Color? luiButtonTextColor(Color? background, Color? text) {
  if (background == null) return text;
  final rgb = background.value & 0xFFFFFF;
  if (rgb == 0xFF6600 || rgb == 0xCC5200) return kLuiInk;
  return text;
}
