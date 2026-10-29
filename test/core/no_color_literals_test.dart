import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CLAUDE.md: żadnych hexów w widgetach. Wyjątek: sygnet misia (stałe kolory we wszystkich motywach).
const _allowedFiles = {'lib/core/ui/mis_mark.dart', 'lib/firebase_options.dart'};

void main() {
  test('kod aplikacji nie zawiera literałów Color(0x…) ani Colors.* poza dozwolonymi', () {
    final offenders = <String>[];
    final literal = RegExp(r'Color\(\s*0x|Colors\.(?!transparent\b)');
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll('\\', '/');
      if (_allowedFiles.contains(path) || path.contains('/l10n/')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (literal.hasMatch(lines[i])) offenders.add('$path:${i + 1}: ${lines[i].trim()}');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
