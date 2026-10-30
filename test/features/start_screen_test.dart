import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/core/theme/app_theme.dart';
import 'package:porzadmis/core/theme/app_tokens.dart';
import 'package:porzadmis/features/auth/data/auth_repository.dart';
import 'package:porzadmis/features/household/data/household_repository.dart';
import 'package:porzadmis/features/household/ui/start_screens.dart';
import 'package:porzadmis/l10n/app_localizations.dart';

class _FakeHouseholdRepository implements HouseholdRepository {
  final created = <({String name, String displayName})>[];

  @override
  Future<void> createHousehold({required String name, required String displayName}) async {
    created.add((name: name, displayName: displayName));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final tokens = AppTokens.fromJson(
    jsonDecode(File('assets/themes/porzadmis_kremowy.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  Future<_FakeHouseholdRepository> pumpStart(WidgetTester tester) async {
    final repo = _FakeHouseholdRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          householdRepositoryProvider.overrideWithValue(repo),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(
          theme: buildTheme(tokens),
          locale: const Locale('pl'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const StartScreen(),
        ),
      ),
    );
    await tester.pump();
    return repo;
  }

  testWidgets('ekran startowy oferuje tryb solo, dom z rodziną, dołączenie i wylogowanie', (tester) async {
    await pumpStart(tester);
    expect(find.text('Zacznij tylko dla siebie'), findsOneWidget);
    expect(find.text('Załóż dom z rodziną'), findsOneWidget);
    expect(find.text('Dołącz do domu'), findsOneWidget);
    expect(find.text('Wyloguj'), findsOneWidget);
  });

  testWidgets('„Zacznij tylko dla siebie” zakłada dom „Mój dom” jednym dotknięciem', (tester) async {
    final repo = await pumpStart(tester);
    await tester.tap(find.text('Zacznij tylko dla siebie'));
    await tester.pumpAndSettle();
    expect(repo.created, hasLength(1));
    expect(repo.created.single.name, 'Mój dom');
  });
}
