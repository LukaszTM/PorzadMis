import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../household/data/household_repository.dart';
import '../domain/shopping_models.dart';

/// Dostęp do listy zakupów. Metody zapisu zwracają `Future` zakończony dopiero po potwierdzeniu
/// przez serwer; w trybie offline UI **nie czeka** na niego (kolejka wyśle zapis później).
class ShoppingRepository {
  ShoppingRepository(this._db, this._newId);

  final FirebaseFirestore _db;
  final String Function() _newId;

  CollectionReference<Map<String, dynamic>> _items(String hid, [String listId = defaultShoppingListId]) =>
      _db.collection('households/$hid/shoppingLists/$listId/items');

  CollectionReference<Map<String, dynamic>> _lists(String hid) =>
      _db.collection('households/$hid/shoppingLists');

  String newId() => _newId();

  /// Dodatkowe listy (bez podstawowej), od najstarszej. Sortuje klient: zapis offline
  /// nie ma jeszcze `createdAt` z serwera.
  Stream<List<ShoppingList>> watchLists(String hid) => _lists(hid).snapshots().map((snap) {
        final docs = snap.docs.where((d) => d.id != defaultShoppingListId).toList()
          ..sort((a, b) {
            final ta = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final tb = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            return ta.compareTo(tb);
          });
        return [for (final d in docs) ShoppingList(id: d.id, name: (d.data()['name'] as String?) ?? '')];
      });

  Future<void> createList(String hid, String id, String name) => _lists(hid).doc(id).set({
        'name': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> renameList(String hid, String id, String name) =>
      _lists(hid).doc(id).update({'name': name.trim()});

  /// Usuwa listę razem z jej pozycjami (jedna paczka; lista ma ich niewiele).
  Future<void> deleteList(String hid, String id) async {
    final items = await _items(hid, id).get();
    final batch = _db.batch();
    for (final d in items.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_lists(hid).doc(id));
    return batch.commit();
  }

  CollectionReference<Map<String, dynamic>> _history(String hid) =>
      _db.collection('households/$hid/shoppingHistory');

  Stream<List<ShoppingItem>> watchItems(String hid, {String listId = defaultShoppingListId}) => _items(hid, listId)
      .orderBy('createdAt')
      .snapshots()
      .map((snap) => [for (final d in snap.docs) _itemFrom(d.id, d.data())]);

  Stream<List<HistoryEntry>> watchHistory(String hid) =>
      _history(hid).orderBy('lastAddedAt', descending: true).limit(200).snapshots().map(
            (snap) => [
              for (final d in snap.docs)
                HistoryEntry(
                  key: d.id,
                  name: (d.data()['name'] as String?) ?? d.id,
                  count: (d.data()['count'] as num?)?.toInt() ?? 1,
                  category: StoreCategory.parse(d.data()['storeCategory']),
                  quantity: (d.data()['quantity'] as String?) ?? '',
                  unit: (d.data()['unit'] as String?) ?? '',
                ),
            ],
          );

  /// Dopisuje pozycję i zapamiętuje ją w historii (jedna paczka zapisów).
  Future<void> add({
    required String hid,
    required String uid,
    required String name,
    required StoreCategory category,
    String quantity = '',
    String unit = '',
    String listId = defaultShoppingListId,
  }) {
    final cleanName = name.trim();
    final batch = _db.batch();
    batch.set(_items(hid, listId).doc(_newId()), {
      'name': cleanName,
      'quantity': quantity,
      'unit': unit,
      'storeCategory': category.id,
      'checked': false,
      'checkedBy': null,
      'addedBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      _history(hid).doc(historyKey(cleanName)),
      {
        'name': cleanName,
        'count': FieldValue.increment(1),
        'lastAddedAt': FieldValue.serverTimestamp(),
        'storeCategory': category.id,
        'quantity': quantity,
        'unit': unit,
      },
      SetOptions(merge: true),
    );
    return batch.commit();
  }

  Future<void> setChecked({
    required String hid,
    required String id,
    required String uid,
    required bool checked,
    String listId = defaultShoppingListId,
  }) =>
      _items(hid, listId).doc(id).update({'checked': checked, 'checkedBy': checked ? uid : null});

  Future<void> update(String hid, ShoppingItem item, {String listId = defaultShoppingListId}) =>
      _items(hid, listId).doc(item.id).update({
        'name': item.name.trim(),
        'quantity': item.quantity,
        'unit': item.unit,
        'storeCategory': item.category.id,
      });

  Future<void> delete(String hid, String id, {String listId = defaultShoppingListId}) =>
      _items(hid, listId).doc(id).delete();

  /// „Wyczyść kupione”: usuwa podane pozycje jedną paczką. Historia zostaje.
  Future<void> deleteAll(String hid, List<ShoppingItem> items, {String listId = defaultShoppingListId}) {
    final batch = _db.batch();
    for (final item in items) {
      batch.delete(_items(hid, listId).doc(item.id));
    }
    return batch.commit();
  }

  /// „Cofnij” po wyczyszczeniu: przywraca pozycje z ich dawnym stanem.
  Future<void> restore(String hid, List<ShoppingItem> items, {String listId = defaultShoppingListId}) {
    final batch = _db.batch();
    for (final item in items) {
      batch.set(_items(hid, listId).doc(item.id), {
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'storeCategory': item.category.id,
        'checked': item.checked,
        'checkedBy': item.checked ? item.checkedBy : null,
        'addedBy': item.addedBy,
        'createdAt': Timestamp.fromDate(item.createdAt),
      });
    }
    return batch.commit();
  }

  ShoppingItem _itemFrom(String id, Map<String, dynamic> d) => ShoppingItem(
        id: id,
        name: (d['name'] as String?) ?? '',
        quantity: (d['quantity'] as String?) ?? '',
        unit: (d['unit'] as String?) ?? '',
        category: StoreCategory.parse(d['storeCategory']),
        checked: d['checked'] == true,
        checkedBy: d['checkedBy'] as String?,
        addedBy: (d['addedBy'] as String?) ?? '',
        // Zapis oczekujący (offline) nie ma jeszcze czasu z serwera: pokazujemy go jako najnowszy.
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}

final shoppingRepositoryProvider = Provider<ShoppingRepository>(
  (ref) => ShoppingRepository(ref.watch(firestoreProvider), ref.watch(uuidProvider).v4),
);

/// Pozycje wskazanej listy.
final shoppingListItemsProvider = StreamProvider.family<List<ShoppingItem>, String>((ref, listId) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(shoppingRepositoryProvider).watchItems(hid, listId: listId);
});

/// Pozycje listy podstawowej: z niej liczą się karta na ekranie głównym i widżet.
final shoppingItemsProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(shoppingRepositoryProvider).watchItems(hid);
});

/// Dodatkowe listy domu (bez podstawowej).
final shoppingListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(shoppingRepositoryProvider).watchLists(hid);
});

class SelectedShoppingList extends Notifier<String> {
  @override
  String build() => defaultShoppingListId;

  void select(String id) => state = id;
}

/// Lista otwarta na ekranie Zakupy (lokalny wybór, nie zapisuje się w bazie).
final selectedShoppingListProvider = NotifierProvider<SelectedShoppingList, String>(SelectedShoppingList.new);

final shoppingHistoryProvider = StreamProvider<List<HistoryEntry>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(shoppingRepositoryProvider).watchHistory(hid);
});
