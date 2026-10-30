import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_tokens.dart';

const defaultLightThemeId = 'porzadmis_kremowy';
const defaultDarkThemeId = 'porzadmis_noc';

/// Wszystkie motywy z `assets/themes/*.json` (nowy motyw = nowy plik, bez zmian w ekranach).
class AppThemes {
  const AppThemes(this.all);

  final List<AppTokens> all;

  AppTokens byId(String? id) => all.firstWhere(
        (t) => t.id == id,
        orElse: () => all.firstWhere((t) => t.id == defaultLightThemeId, orElse: () => all.first),
      );

  AppTokens get defaultLight => byId(defaultLightThemeId);
  AppTokens get defaultDark => byId(defaultDarkThemeId);

  /// Motywy pogrupowane w kolejności: Domyślne, Inspirowane PyCharm, Różowe.
  Map<String, List<AppTokens>> get groups {
    const order = ['Domyślne', 'Inspirowane PyCharm', 'Różowe'];
    final map = <String, List<AppTokens>>{};
    for (final t in all) {
      map.putIfAbsent(t.group, () => []).add(t);
    }
    final sorted = <String, List<AppTokens>>{};
    for (final g in [...order, ...map.keys.where((k) => !order.contains(k))]) {
      if (map[g] != null) sorted[g] = map[g]!;
    }
    return sorted;
  }

  static Future<AppThemes> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    final manifest = await AssetManifest.loadFromAssetBundle(b);
    final paths = manifest.listAssets().where((p) => p.startsWith('assets/themes/') && p.endsWith('.json')).toList()
      ..sort();
    final tokens = <AppTokens>[];
    for (final path in paths) {
      tokens.add(AppTokens.fromJson(jsonDecode(await b.loadString(path)) as Map<String, dynamic>));
    }
    // Domyślne na początek, reszta alfabetycznie po nazwie.
    tokens.sort((a, b) {
      int rank(AppTokens t) => t.id == defaultLightThemeId ? 0 : (t.id == defaultDarkThemeId ? 1 : 2);
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.name.compareTo(b.name);
    });
    return AppThemes(tokens);
  }
}

final appThemesProvider = Provider<AppThemes>(
  (ref) => throw UnimplementedError('appThemesProvider musi być nadpisany w main()'),
);

enum AppThemeMode {
  light,
  dark,
  auto;

  static AppThemeMode parse(Object? v) =>
      AppThemeMode.values.firstWhere((m) => m.name == v, orElse: () => AppThemeMode.auto);

  ThemeMode get themeMode => switch (this) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.auto => ThemeMode.system,
      };
}

/// Para motywów dla MaterialApp: wybrany motyw w swojej jasności, a w drugiej – domyślny.
({AppTokens light, AppTokens dark}) resolveThemePair(AppThemes themes, String? themeId) {
  final chosen = themes.byId(themeId);
  return chosen.brightness == Brightness.light
      ? (light: chosen, dark: themes.defaultDark)
      : (light: themes.defaultLight, dark: chosen);
}

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
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: t.accent.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 26,
          color: states.contains(WidgetState.selected) ? t.accent : t.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => _style(
          13,
          FontWeight.w700,
          states.contains(WidgetState.selected) ? t.accent : t.textMuted,
        ),
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
