import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/core/theme/app_theme.dart';
import 'package:porzadmis/core/theme/app_tokens.dart';
import 'package:porzadmis/core/ui/ui.dart';
import 'package:porzadmis/features/auth/data/auth_repository.dart';
import 'package:porzadmis/features/household/data/household_repository.dart';
import 'package:porzadmis/features/household/domain/household_models.dart';
import 'package:porzadmis/features/members/data/members_repository.dart';
import 'package:porzadmis/features/shopping/data/shopping_repository.dart';
import 'package:porzadmis/features/shopping/domain/shopping_models.dart';
import 'package:porzadmis/features/shopping/ui/shopping_screen.dart';
import 'package:porzadmis/l10n/app_localizations.dart';

class _FakeUser implements User {
  @override
  String get uid => 'u1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pamięciowe repozytorium: te same operacje co prawdziwe, bez Firebase.
class _FakeShoppingRepository implements ShoppingRepository {
  _FakeShoppingRepository({List<ShoppingItem> items = const [], this.history = const []})
      : _items = List.of(items);

  final List<ShoppingItem> _items;
  final List<HistoryEntry> history;
  final _changes = StreamController<List<ShoppingItem>>.broadcast(sync: true);
  int _next = 0;

  List<ShoppingItem> get items => List.unmodifiable(_items);

  void _emit() => _changes.add(List.of(_items));

  @override
  Stream<List<ShoppingItem>> watchItems(String hid) async* {
    yield List.of(_items);
    yield* _changes.stream;
  }

  @override
  Stream<List<HistoryEntry>> watchHistory(String hid) => Stream.value(history);

  @override
  Future<void> add({
    required String hid,
    required String uid,
    required String name,
    required StoreCategory category,
    String quantity = '',
    String unit = '',
  }) async {
    _items.add(ShoppingItem(
      id: 'n${_next++}',
      name: name,
      category: category,
      checked: false,
      addedBy: uid,
      createdAt: DateTime.utc(2026, 10, 30, 12, _next),
      quantity: quantity,
      unit: unit,
    ));
    _emit();
  }

  @override
  Future<void> setChecked({
    required String hid,
    required String id,
    required String uid,
    required bool checked,
  }) async {
    final i = _items.indexWhere((e) => e.id == id);
    final o = _items[i];
    _items[i] = ShoppingItem(
      id: o.id,
      name: o.name,
      category: o.category,
      checked: checked,
      addedBy: o.addedBy,
      createdAt: o.createdAt,
      quantity: o.quantity,
      unit: o.unit,
      checkedBy: checked ? uid : null,
    );
    _emit();
  }

  @override
  Future<void> update(String hid, ShoppingItem item) async {
    final i = _items.indexWhere((e) => e.id == item.id);
    _items[i] = item;
    _emit();
  }

  @override
  Future<void> delete(String hid, String id) async {
    _items.removeWhere((e) => e.id == id);
    _emit();
  }

  @override
  Future<void> deleteAll(String hid, List<ShoppingItem> toDelete) async {
    final ids = {for (final i in toDelete) i.id};
    _items.removeWhere((e) => ids.contains(e.id));
    _emit();
  }

  @override
  Future<void> restore(String hid, List<ShoppingItem> toRestore) async {
    _items.addAll(toRestore);
    _emit();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ShoppingItem _item(String id, String name, {bool checked = false, int minute = 0}) => ShoppingItem(
      id: id,
      name: name,
      category: StoreCategory.other,
      checked: checked,
      checkedBy: checked ? 'u1' : null,
      addedBy: 'u1',
      createdAt: DateTime.utc(2026, 10, 30, 12, minute),
    );

void main() {
  final tokens = AppTokens.fromJson(
    jsonDecode(File('assets/themes/porzadmis_kremowy.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  Future<_FakeShoppingRepository> pumpShopping(
    WidgetTester tester, {
    List<ShoppingItem> items = const [],
    List<HistoryEntry> history = const [],
  }) async {
    final repo = _FakeShoppingRepository(items: items, history: history);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingRepositoryProvider.overrideWithValue(repo),
          householdIdProvider.overrideWithValue('h1'),
          householdProvider.overrideWith((ref) => Stream.value(const Household(id: 'h1', name: 'Dom testowy'))),
          authStateProvider.overrideWith((ref) => Stream.value(_FakeUser())),
          membersProvider.overrideWith(
            (ref) => Stream.value(const [
              Member(uid: 'u1', displayName: 'Ala', role: Role.admin),
            ]),
          ),
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
          home: const ShoppingScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return repo;
  }

  Future<void> addByTyping(WidgetTester tester, String name) async {
    await tester.enterText(find.byType(TextFormField), name);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
  }

  testWidgets('pusta lista pokazuje misia i zachętę', (tester) async {
    await pumpShopping(tester);
    expect(find.text('Lista pusta – dopisz pierwszą rzecz.'), findsOneWidget);
    expect(find.textContaining('Do kupienia'), findsNothing);
  });

  testWidgets('dopisanie produktu dodaje go do „Do kupienia” i czyści pole', (tester) async {
    final repo = await pumpShopping(tester);
    await addByTyping(tester, 'Chleb');
    expect(repo.items.single.name, 'Chleb');
    expect(find.text('Do kupienia'), findsOneWidget);
    expect(find.widgetWithText(StatusChip, '1'), findsOneWidget);
    expect(find.text('Chleb'), findsOneWidget);
    expect(tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text, isEmpty);
  });

  testWidgets('pusta nazwa pokazuje błąd i niczego nie dodaje', (tester) async {
    final repo = await pumpShopping(tester);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('Wpisz nazwę produktu'), findsOneWidget);
    expect(repo.items, isEmpty);
  });

  testWidgets('duplikat niekupionej pozycji jest odrzucany z komunikatem', (tester) async {
    final repo = await pumpShopping(tester, items: [_item('a', 'Mleko')]);
    await addByTyping(tester, '  mleko ');
    expect(find.text('Już jest na liście'), findsOneWidget);
    expect(repo.items, hasLength(1));
  });

  testWidgets('ponowne dopisanie kupionej pozycji przywraca ją na listę', (tester) async {
    final repo = await pumpShopping(tester, items: [_item('a', 'Mleko', checked: true)]);
    expect(find.text('Kupione · 1'), findsOneWidget);
    await addByTyping(tester, 'Mleko');
    expect(repo.items, hasLength(1));
    expect(repo.items.single.checked, isFalse);
    expect(find.text('Do kupienia'), findsOneWidget);
    expect(find.widgetWithText(StatusChip, '1'), findsOneWidget);
  });

  testWidgets('dotknięcie wiersza odhacza pozycję i przenosi ją do „Kupione”', (tester) async {
    final repo = await pumpShopping(tester, items: [_item('a', 'Mleko'), _item('b', 'Chleb', minute: 1)]);
    await tester.tap(find.text('Mleko'));
    await tester.pumpAndSettle();
    expect(repo.items.firstWhere((i) => i.id == 'a').checked, isTrue);
    expect(find.text('Do kupienia'), findsOneWidget);
    expect(find.widgetWithText(StatusChip, '1'), findsOneWidget);
    expect(find.text('Kupione · 1'), findsOneWidget);
  });

  testWidgets('„Wyczyść” usuwa kupione, a „Cofnij” je przywraca', (tester) async {
    final repo = await pumpShopping(
      tester,
      items: [_item('a', 'Mleko', checked: true), _item('b', 'Chleb', minute: 1)],
    );
    await tester.tap(find.text('Wyczyść'));
    await tester.pumpAndSettle();
    expect(repo.items.map((i) => i.name), ['Chleb']);
    expect(find.text('Wyczyszczono kupione'), findsOneWidget);

    await tester.tap(find.text('Cofnij'));
    await tester.pumpAndSettle();
    expect(repo.items.map((i) => i.name), containsAll(['Chleb', 'Mleko']));
    expect(find.text('Kupione · 1'), findsOneWidget);
  });

  testWidgets('podpowiedź z historii dodaje produkt jednym dotknięciem', (tester) async {
    final repo = await pumpShopping(
      tester,
      history: const [
        HistoryEntry(key: 'mleko', name: 'Mleko', count: 4, category: StoreCategory.dairy),
        HistoryEntry(key: 'chleb', name: 'Chleb', count: 2, category: StoreCategory.bakery),
      ],
    );
    await tester.enterText(find.byType(TextFormField), 'ml');
    await tester.pump();
    expect(find.widgetWithText(ActionChip, 'Mleko'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Chleb'), findsNothing);

    await tester.tap(find.widgetWithText(ActionChip, 'Mleko'));
    await tester.pumpAndSettle();
    expect(repo.items.single.name, 'Mleko');
    expect(repo.items.single.category, StoreCategory.dairy);
  });

  testWidgets('pozycje są grupowane po działach', (tester) async {
    await pumpShopping(tester, items: [
      ShoppingItem(
        id: 'a',
        name: 'Ser',
        category: StoreCategory.dairy,
        checked: false,
        addedBy: 'u1',
        createdAt: DateTime.utc(2026, 10, 30),
      ),
      _item('b', 'Coś'),
    ]);
    expect(find.text('Nabiał'), findsAtLeastNWidgets(1));
    expect(find.text('Inne'), findsAtLeastNWidgets(1));
  });
}
