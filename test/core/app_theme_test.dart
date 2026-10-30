import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/core/router/app_router.dart';
import 'package:porzadmis/core/theme/app_theme.dart';
import 'package:porzadmis/core/theme/app_tokens.dart';

AppThemes _loadAll() => AppThemes([
      for (final f in Directory('assets/themes').listSync().whereType<File>())
        AppTokens.fromJson(jsonDecode(f.readAsStringSync()) as Map<String, dynamic>),
    ]);

void main() {
  final themes = _loadAll();

  test('13 motywów ma unikalne identyfikatory i trzy grupy z PLAN.md', () {
    expect(themes.all.map((t) => t.id).toSet().length, 13);
    expect(themes.groups.keys.toList(), ['Domyślne', 'Inspirowane PyCharm', 'Różowe']);
    expect(themes.groups['Domyślne']!.length, 2);
    expect(themes.groups['Inspirowane PyCharm']!.length, 8);
    expect(themes.groups['Różowe']!.length, 3);
  });

  test('resolveThemePair: wybrany jasny + domyślny ciemny, wybrany ciemny + domyślny jasny', () {
    final light = resolveThemePair(themes, 'solarized_light');
    expect(light.light.id, 'solarized_light');
    expect(light.dark.id, defaultDarkThemeId);
    final dark = resolveThemePair(themes, 'dracula');
    expect(dark.light.id, defaultLightThemeId);
    expect(dark.dark.id, 'dracula');
  });

  test('nieznany lub brakujący motyw daje domyślne', () {
    final pair = resolveThemePair(themes, 'nie-ma');
    expect(pair.light.id, defaultLightThemeId);
    expect(pair.dark.id, defaultDarkThemeId);
    expect(resolveThemePair(themes, null).light.id, defaultLightThemeId);
  });

  test('AppThemeMode.parse i mapowanie na ThemeMode', () {
    expect(AppThemeMode.parse('dark').themeMode, ThemeMode.dark);
    expect(AppThemeMode.parse('light').themeMode, ThemeMode.light);
    expect(AppThemeMode.parse(null).themeMode, ThemeMode.system);
    expect(AppThemeMode.parse('cokolwiek').themeMode, ThemeMode.system);
  });

  group('onboarding w przekierowaniach', () {
    String? r(String loc, {bool done = false, String? hid}) =>
        resolveRedirect(location: loc, loading: false, signedIn: true, householdId: hid, onboardingDone: done);
    test('bez onboardingu wszystko prowadzi na /onboarding', () {
      expect(r('/home', hid: 'h'), '/onboarding');
      expect(r('/start'), '/onboarding');
      expect(r('/onboarding'), isNull);
    });
    test('po onboardingu /onboarding prowadzi do startu albo domu', () {
      expect(r('/onboarding', done: true), '/start');
      expect(r('/onboarding', done: true, hid: 'h'), '/home');
    });
    test('niezalogowany nie trafia na onboarding', () {
      expect(resolveRedirect(location: '/onboarding', loading: false, signedIn: false, householdId: null), '/login');
    });
  });
}
