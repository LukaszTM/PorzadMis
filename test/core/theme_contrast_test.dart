import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/core/theme/app_tokens.dart';
import 'package:porzadmis/core/theme/contrast.dart';

void main() {
  final files = Directory('assets/themes')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  test('jest 13 motywów z PLAN.md', () {
    expect(files.length, 13);
  });

  for (final file in files) {
    final tokens =
        AppTokens.fromJson(jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);

    group('motyw ${tokens.id}', () {
      test('tekst na tle i powierzchni ma kontrast ≥ 4,5:1', () {
        expect(contrastRatio(tokens.text, tokens.background), greaterThanOrEqualTo(4.5));
        expect(contrastRatio(tokens.text, tokens.surface), greaterThanOrEqualTo(4.5));
        expect(contrastRatio(tokens.textMuted, tokens.background), greaterThanOrEqualTo(4.5));
        expect(contrastRatio(tokens.textMuted, tokens.surface), greaterThanOrEqualTo(4.5));
      });
      test('tekst na przycisku (onAccent na accent) ma kontrast ≥ 4,5:1', () {
        expect(contrastRatio(tokens.onAccent, tokens.accent), greaterThanOrEqualTo(4.5));
      });
      test('akcent na plakietce (accentSoft) ma kontrast ≥ 4,5:1', () {
        expect(contrastRatio(tokens.accent, tokens.accentSoft), greaterThanOrEqualTo(4.5));
      });
      test('ikony i akcenty mają kontrast ≥ 3:1 względem tła', () {
        for (final c in [tokens.accent, tokens.warning, tokens.danger, tokens.success]) {
          expect(contrastRatio(c, tokens.background), greaterThanOrEqualTo(3));
        }
      });
      test('ma 5 kolorów wykresu', () {
        expect(tokens.chart, hasLength(5));
      });
    });
  }

  test('contrastRatio: czerń na bieli to 21:1', () {
    expect(
      contrastRatio(parseHexColor('#000000'), parseHexColor('#FFFFFF')),
      closeTo(21, 0.01),
    );
  });
}
