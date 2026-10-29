import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/core/theme/app_theme.dart';
import 'package:porzadmis/core/theme/app_tokens.dart';
import 'package:porzadmis/core/ui/ui.dart';

AppTokens _load(String name) => AppTokens.fromJson(
      jsonDecode(File('assets/themes/$name.json').readAsStringSync()) as Map<String, dynamic>,
    );

Widget _host(AppTokens tokens, Widget child) => MaterialApp(
      theme: buildTheme(tokens),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  for (final name in ['porzadmis_kremowy', 'porzadmis_noc']) {
    group('komponenty w motywie $name', () {
      final tokens = _load(name);

      testWidgets('PrimaryButton ma 56 dp i wywołuje akcję', (tester) async {
        var tapped = 0;
        await tester.pumpWidget(_host(tokens, PrimaryButton(label: 'Dodaj', onPressed: () => tapped++)));
        expect(tester.getSize(find.byType(PrimaryButton)).height, 56);
        await tester.tap(find.text('Dodaj'));
        expect(tapped, 1);
      });

      testWidgets('PrimaryButton w stanie ładowania pokazuje kropki i nie reaguje', (tester) async {
        var tapped = 0;
        await tester.pumpWidget(
          _host(tokens, PrimaryButton(label: 'Dodaj', loading: true, onPressed: () => tapped++)),
        );
        expect(find.text('•••'), findsOneWidget);
        await tester.tap(find.byType(PrimaryButton));
        expect(tapped, 0);
      });

      testWidgets('CheckRow przełącza całym wierszem i ma min. 56 dp', (tester) async {
        var checked = false;
        await tester.pumpWidget(_host(
          tokens,
          StatefulBuilder(
            builder: (context, setState) => CheckRow(
              title: 'Mleko',
              checked: checked,
              meta: 'Tomek',
              onChanged: (v) => setState(() => checked = v),
            ),
          ),
        ));
        expect(tester.getSize(find.byType(CheckRow)).height, greaterThanOrEqualTo(56));
        await tester.tap(find.text('Mleko'));
        await tester.pump();
        expect(checked, isTrue);
      });

      testWidgets('SegmentedSwitch zmienia wartość', (tester) async {
        var value = false;
        await tester.pumpWidget(_host(
          tokens,
          StatefulBuilder(
            builder: (context, setState) => SegmentedSwitch<bool>(
              options: const [SegmentOption(false, 'Jednorazowe'), SegmentOption(true, 'Wielokrotne')],
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ));
        await tester.tap(find.text('Wielokrotne'));
        await tester.pump();
        expect(value, isTrue);
      });

      testWidgets('AppCard z onTap pokazuje strzałkę, StatusChip i MisMark się renderują', (tester) async {
        await tester.pumpWidget(_host(
          tokens,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppCard(title: 'Domownicy', onTap: () {}, child: const Text('3 osoby')),
              const StatusChip(label: 'tylko Administrator', tone: ChipTone.neutral),
              const MisMark(size: 96, resting: true),
            ],
          ),
        ));
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.text('tylko Administrator'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('AppTextField pokazuje błąd walidacji', (tester) async {
        final form = GlobalKey<FormState>();
        await tester.pumpWidget(_host(
          tokens,
          Form(
            key: form,
            child: AppTextField(
              controller: TextEditingController(),
              hint: 'np. chleb',
              validator: (v) => (v == null || v.isEmpty) ? 'Wpisz nazwę produktu' : null,
            ),
          ),
        ));
        form.currentState!.validate();
        await tester.pump();
        expect(find.text('Wpisz nazwę produktu'), findsOneWidget);
      });

      testWidgets('confirmSheet zwraca true po „Tak” i false po „Wróć”', (tester) async {
        bool? result;
        await tester.pumpWidget(_host(
          tokens,
          Builder(
            builder: (context) => PrimaryButton(
              label: 'Otwórz',
              onPressed: () async => result = await confirmSheet(
                context,
                title: 'Usunąć z domu?',
                body: 'Ania straci dostęp do wspólnych danych.',
                confirmLabel: 'Tak',
                cancelLabel: 'Wróć',
                danger: true,
              ),
            ),
          ),
        ));
        await tester.tap(find.text('Otwórz'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tak'));
        await tester.pumpAndSettle();
        expect(result, isTrue);

        await tester.tap(find.text('Otwórz'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Wróć'));
        await tester.pumpAndSettle();
        expect(result, isFalse);
      });
    });
  }
}
