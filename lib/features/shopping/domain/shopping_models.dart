/// Identyfikator jedynej listy zakupów w etapie 2 (kilka list dojdzie po MVP).
const defaultShoppingListId = 'main';

/// Dział sklepowy do grupowania pozycji. W bazie zapisywany jako [id].
enum StoreCategory {
  produce,
  bakery,
  dairy,
  meat,
  drinks,
  household,
  other;

  String get id => name;

  static StoreCategory parse(Object? value) {
    for (final c in StoreCategory.values) {
      if (c.name == value) return c;
    }
    return StoreCategory.other;
  }
}

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.checked,
    required this.addedBy,
    required this.createdAt,
    this.quantity = '',
    this.unit = '',
    this.checkedBy,
  });

  final String id;
  final String name;
  final StoreCategory category;
  final bool checked;
  final String addedBy;
  final DateTime createdAt;
  final String quantity;
  final String unit;
  final String? checkedBy;

  /// „2 szt”, „500 g”, albo pusty tekst, gdy nie podano ilości.
  String get quantityLabel => [quantity, unit].where((s) => s.isNotEmpty).join(' ');

  String get key => historyKey(name);

  ShoppingItem copyWith({String? name, String? quantity, String? unit, StoreCategory? category}) =>
      ShoppingItem(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        checked: checked,
        addedBy: addedBy,
        createdAt: createdAt,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        checkedBy: checkedBy,
      );
}

/// Wpis historii: nazwa, którą ktoś w domu już kiedyś dopisał.
class HistoryEntry {
  const HistoryEntry({
    required this.key,
    required this.name,
    required this.count,
    required this.category,
    this.quantity = '',
    this.unit = '',
  });

  final String key;
  final String name;
  final int count;
  final StoreCategory category;
  final String quantity;
  final String unit;
}

/// Klucz dokumentu historii: małe litery, jedna spacja między słowami, bez „/”.
String historyKey(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').replaceAll('/', '-');

/// Pozycje „do kupienia” pogrupowane po dziale; działy w stałej kolejności, a w dziale
/// pozycje od najstarszej. Puste działy są pomijane.
List<(StoreCategory, List<ShoppingItem>)> groupByCategory(List<ShoppingItem> items) {
  final result = <(StoreCategory, List<ShoppingItem>)>[];
  for (final category in StoreCategory.values) {
    final inCategory = items.where((i) => i.category == category).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (inCategory.isNotEmpty) result.add((category, inCategory));
  }
  return result;
}

/// Podpowiedzi z historii: pasują do początku nazwy lub któregokolwiek słowa; bez tego,
/// co już jest na liście do kupienia; najczęściej kupowane pierwsze.
List<HistoryEntry> suggestionsFor(
  String query,
  List<HistoryEntry> history, {
  Set<String> onList = const {},
  int limit = 5,
}) {
  final q = historyKey(query);
  bool matches(HistoryEntry e) {
    if (onList.contains(e.key)) return false;
    if (q.isEmpty) return true;
    return e.key.startsWith(q) || e.key.split(' ').any((w) => w.startsWith(q));
  }

  final found = history.where(matches).toList()
    ..sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  return found.take(limit).toList();
}
