import 'package:flutter/material.dart';

/// Tokeny kolorów motywu (patrz docs/GUI.md, sekcja 4). Jedyne źródło kolorów w widgetach.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.id,
    required this.name,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.warning,
    required this.danger,
    required this.success,
    required this.chart,
  });

  final String id;
  final String name;
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color warning;
  final Color danger;
  final Color success;

  /// chart1…chart5 – kolory wykresu budżetu.
  final List<Color> chart;

  factory AppTokens.fromJson(Map<String, dynamic> json) {
    final t = json['tokens'] as Map<String, dynamic>;
    Color c(String key) => parseHexColor(t[key] as String);
    return AppTokens(
      id: json['id'] as String,
      name: json['name'] as String,
      brightness: json['brightness'] == 'dark' ? Brightness.dark : Brightness.light,
      background: c('background'),
      surface: c('surface'),
      text: c('text'),
      textMuted: c('textMuted'),
      border: c('border'),
      accent: c('accent'),
      onAccent: c('onAccent'),
      accentSoft: c('accentSoft'),
      warning: c('warning'),
      danger: c('danger'),
      success: c('success'),
      chart: [for (var i = 1; i <= 5; i++) c('chart$i')],
    );
  }

  /// Kolor tła „pola kodu QR”: moduły ciemne na jasnym, niezależnie od motywu.
  Color get qrLight => brightness == Brightness.light ? surface : text;
  Color get qrDark => brightness == Brightness.light ? text : background;

  @override
  AppTokens copyWith({Color? accent, Color? onAccent}) => AppTokens(
        id: id,
        name: name,
        brightness: brightness,
        background: background,
        surface: surface,
        text: text,
        textMuted: textMuted,
        border: border,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        accentSoft: accentSoft,
        warning: warning,
        danger: danger,
        success: success,
        chart: chart,
      );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return t < 0.5 ? this : other;
  }
}

/// Zamienia „#RRGGBB” z pliku motywu na [Color].
Color parseHexColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  assert(cleaned.length == 6, 'Oczekiwano #RRGGBB, jest: $hex');
  final value = int.parse(cleaned, radix: 16);
  return Color.fromARGB(255, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
