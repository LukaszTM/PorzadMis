import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_tokens.dart';

const _kremowyAsset = 'assets/themes/porzadmis_kremowy.json';
const _nocAsset = 'assets/themes/porzadmis_noc.json';

/// Motywy wczytane przy starcie. Wybór motywu przez użytkownika dojdzie w etapie 7.
class AppThemes {
  const AppThemes({required this.light, required this.dark});

  final AppTokens light;
  final AppTokens dark;

  static Future<AppThemes> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    Future<AppTokens> read(String path) async =>
        AppTokens.fromJson(jsonDecode(await b.loadString(path)) as Map<String, dynamic>);
    final results = await Future.wait([read(_kremowyAsset), read(_nocAsset)]);
    return AppThemes(light: results[0], dark: results[1]);
  }
}

final appThemesProvider = Provider<AppThemes>(
  (ref) => throw UnimplementedError('appThemesProvider musi być nadpisany w main()'),
);

TextStyle _style(double size, FontWeight weight, Color color) => TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.35,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

ThemeData buildTheme(AppTokens t) {
  final scheme = ColorScheme(
    brightness: t.brightness,
    primary: t.accent,
    onPrimary: t.onAccent,
    secondary: t.accent,
    onSecondary: t.onAccent,
    error: t.danger,
    onError: t.onAccent,
    surface: t.surface,
    onSurface: t.text,
    outline: t.border,
  );
  final textTheme = TextTheme(
    headlineLarge: _style(28, FontWeight.w800, t.text),
    headlineMedium: _style(26, FontWeight.w800, t.text),
    titleLarge: _style(20, FontWeight.w800, t.text),
    titleMedium: _style(17, FontWeight.w800, t.textMuted),
    bodyLarge: _style(18, FontWeight.w700, t.text),
    bodyMedium: _style(16, FontWeight.w500, t.text),
    labelLarge: _style(18, FontWeight.w800, t.text),
    labelMedium: _style(14, FontWeight.w700, t.textMuted),
    labelSmall: _style(13, FontWeight.w800, t.text),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: t.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.background,
    canvasColor: t.background,
    textTheme: textTheme,
    dividerColor: t.border,
    splashFactory: InkRipple.splashFactory,
    extensions: [t],
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.surface,
      contentTextStyle: textTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: t.border),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.surface,
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}
