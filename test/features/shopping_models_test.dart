import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/features/shopping/domain/shopping_models.dart';

ShoppingItem item(
  String name, {
  StoreCategory category = StoreCategory.other,
  int minute = 0,
  String quantity = '',
  String unit = '',
}) =>
    ShoppingItem(
      id: name,
      name: name,
      category: category,
      checked: false,
      addedBy: 'u1',
      createdAt: DateTime.utc(2026, 10, 30, 12, minute),
      quantity: quantity,
      unit: unit,
    );

HistoryEntry entry(String name, int count, {StoreCategory category = StoreCategory.other}) =>
    HistoryEntry(key: historyKey(name), name: name, count: count, category: category);

void main() {
  group('historyKey', () {
    test('ignoruje wielkość liter i nadmiarowe spacje', () {
      expect(historyKey('  Mleko   3,2% '), 'mleko 3,2%');
      expect(historyKey('MLEKO'), historyKey('mleko'));
    });
    test('usuwa ukośnik, który zepsułby ścieżkę dokumentu', () {
      expect(historyKey('Ser/Szynka'), 'ser-szynka');
    });
  });

  group('ShoppingItem', () {
    test('quantityLabel składa ilość i jednostkę', () {
      expect(item('Jabłka', quantity: '2', unit: 'kg').quantityLabel, '2 kg');
      expect(item('Jabłka', quantity: '2').quantityLabel, '2');
      expect(item('Jabłka', unit: 'kg').quantityLabel, 'kg');
      expect(item('Jabłka').quantityLabel, '');
    });
    test('StoreCategory.parse zna wszystkie działy, a nieznany daje „inne”', () {
      for (final c in StoreCategory.values) {
        expect(StoreCategory.parse(c.id), c);
      }
      expect(StoreCategory.parse('cokolwiek'), StoreCategory.other);
      expect(StoreCategory.parse(null), StoreCategory.other);
    });
  });

  group('groupByCategory', () {
    test('działy w stałej kolejności, pozycje od najstarszej, puste pomijane', () {
      final groups = groupByCategory([
        item('Mleko', category: StoreCategory.dairy, minute: 5),
        item('Chleb', category: StoreCategory.bakery, minute: 3),
        item('Ser', category: StoreCategory.dairy, minute: 1),
        item('Coś', minute: 2),
      ]);
      expect(groups.map((g) => g.$1), [StoreCategory.bakery, StoreCategory.dairy, StoreCategory.other]);
      expect(groups[1].$2.map((i) => i.name), ['Ser', 'Mleko']);
    });
    test('pusta lista daje pusty wynik', () {
      expect(groupByCategory(const []), isEmpty);
    });
  });

  group('suggestionsFor', () {
    final history = [entry('Mleko', 5), entry('Masło', 9), entry('Chleb', 2), entry('Mąka', 1)];

    test('pasuje po początku nazwy, najczęstsze pierwsze', () {
      expect(suggestionsFor('m', history).map((e) => e.name), ['Masło', 'Mleko', 'Mąka']);
    });
    test('pasuje też po początku dowolnego słowa', () {
      final h = [entry('Mleko owsiane', 3)];
      expect(suggestionsFor('owsi', h).map((e) => e.name), ['Mleko owsiane']);
    });
    test('pomija to, co już jest na liście do kupienia', () {
      expect(
        suggestionsFor('m', history, onList: {historyKey('Masło')}).map((e) => e.name),
        ['Mleko', 'Mąka'],
      );
    });
    test('pusty tekst daje najczęściej kupowane, z limitem', () {
      expect(suggestionsFor('', history, limit: 2).map((e) => e.name), ['Masło', 'Mleko']);
    });
    test('brak dopasowania daje pustą listę', () {
      expect(suggestionsFor('xyz', history), isEmpty);
    });
  });
}
