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

  CollectionReference<Map<String, dynamic>> _items(String hid) =>
      _db.collection('households/$hid/shoppingLists/$defaultShoppingListId/items');

  CollectionReference<Map<String, dynamic>> _history(String hid) =>
      _db.collection('households/$hid/shoppingHistory');

  Stream<List<ShoppingItem>> watchItems(String hid) => _items(hid)
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
  }) {
    final cleanName = name.trim();
    final batch = _db.batch();
    batch.set(_items(hid).doc(_newId()), {
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
  }) =>
      _items(hid).doc(id).update({'checked': checked, 'checkedBy': checked ? uid : null});

  Future<void> update(String hid, ShoppingItem item) => _items(hid).doc(item.id).update({
        'name': item.name.trim(),
        'quantity': item.quantity,
        'unit': item.unit,
        'storeCategory': item.category.id,
      });

  Future<void> delete(String hid, String id) => _items(hid).doc(id).delete();

  /// „Wyczyść kupione”: usuwa podane pozycje jedną paczką. Historia zostaje.
  Future<void> deleteAll(String hid, List<ShoppingItem> items) {
    final batch = _db.batch();
    for (final item in items) {
      batch.delete(_items(hid).doc(item.id));
    }
    return batch.commit();
  }

  /// „Cofnij” po wyczyszczeniu: przywraca pozycje z ich dawnym stanem.
  Future<void> restore(String hid, List<ShoppingItem> items) {
    final batch = _db.batch();
    for (final item in items) {
      batch.set(_items(hid).doc(item.id), {
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

final shoppingItemsProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(shoppingRepositoryProvider).watchItems(hid);
});

final shoppingHistoryProvider = StreamProvider<List<HistoryEntry>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(shoppingRepositoryProvider).watchHistory(hid);
});
