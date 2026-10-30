import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/core/ui/app_icon.dart';

void main() {
  test('każda ikona z enumu ma plik SVG 24 × 24 z kolorem currentColor', () {
    for (final icon in AppIcons.values) {
      final file = File(icon.asset);
      expect(file.existsSync(), isTrue, reason: '${icon.asset} nie istnieje');
      final svg = file.readAsStringSync();
      expect(svg, contains('viewBox="0 0 24 24"'), reason: icon.asset);
      expect(svg, contains('currentColor'), reason: icon.asset);
    }
  });

  testWidgets('AppIcon rysuje się w zadanym rozmiarze', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: AppIcon(AppIcons.today, size: 26, color: Colors.black))),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(AppIcon)), const Size(26, 26));
    expect(tester.takeException(), isNull);
  });
}
