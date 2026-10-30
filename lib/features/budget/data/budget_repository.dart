import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';
import '../../members/data/members_repository.dart';
import '../domain/budget_models.dart';

class BudgetRepository {
  BudgetRepository(this._db, this._newId);

  final FirebaseFirestore _db;
  final String Function() _newId;

  CollectionReference<Map<String, dynamic>> _categories(String hid) => _db.collection('households/$hid/categories');
  CollectionReference<Map<String, dynamic>> _expenses(String hid) => _db.collection('households/$hid/expenses');
  CollectionReference<Map<String, dynamic>> _plans(String hid) => _db.collection('households/$hid/budgetPlans');

  String newId() => _newId();

  Stream<List<Category>> watchCategories(String hid) => _categories(hid).snapshots().map((s) {
        final list = [
          for (final d in s.docs)
            Category(
              id: d.id,
              name: (d.data()['name'] as String?) ?? '',
              icon: (d.data()['icon'] as String?) ?? 'other',
              colorIndex: ((d.data()['colorIndex'] as num?)?.toInt() ?? 4).clamp(0, 4),
              order: (d.data()['order'] as num?)?.toInt() ?? 0,
            ),
        ]..sort((a, b) => a.order.compareTo(b.order));
        return list;
      });

  /// Zestaw startowy, gdy dom nie ma jeszcze kategorii (jedna paczka).
  Future<void> seedCategoriesIfEmpty(String hid) async {
    final existing = await _categories(hid).limit(1).get();
    if (existing.docs.isNotEmpty) return;
    final batch = _db.batch();
    for (final c in seedCategories) {
      batch.set(_categories(hid).doc(c.id), {
        'name': c.name,
        'icon': c.icon,
        'colorIndex': c.colorIndex,
        'order': c.order,
      });
    }
    await batch.commit();
  }

  Stream<List<Expense>> watchExpenses(String hid, String month) =>
      _expenses(hid).where('month', isEqualTo: month).snapshots().map(
            (s) => [
              for (final d in s.docs)
                Expense(
                  id: d.id,
                  amount: (d.data()['amount'] as num?)?.toInt() ?? 0,
                  date: (d.data()['date'] as String?) ?? '$month-01',
                  categoryId: (d.data()['categoryId'] as String?) ?? 'other',
                  note: (d.data()['note'] as String?) ?? '',
                  paidBy: d.data()['paidBy'] as String?,
                  createdBy: d.data()['createdBy'] as String?,
                  createdAt: (d.data()['createdAt'] as Timestamp?)?.toDate(),
                ),
            ],
          );

  Future<void> saveExpense({required String hid, required String uid, required Expense e, required bool isNew}) =>
      _expenses(hid).doc(e.id).set({
        'amount': e.amount,
        'date': e.date,
        'month': e.month,
        'categoryId': e.categoryId,
        'note': e.note.trim(),
        'paidBy': e.paidBy,
        'createdBy': e.createdBy ?? uid,
        'createdAt': isNew ? FieldValue.serverTimestamp() : Timestamp.fromDate(e.createdAt ?? DateTime.now()),
      });

  Future<void> deleteExpense(String hid, String id) => _expenses(hid).doc(id).delete();

  Stream<BudgetPlan?> watchPlan(String hid, String month) => _plans(hid).doc(month).snapshots().map((d) {
        if (!d.exists) return null;
        final limits = (d.data()!['limits'] as Map?)?.map((k, v) => MapEntry(k as String, (v as num).toInt())) ?? {};
        return BudgetPlan(month: month, limits: Map<String, int>.from(limits), total: (d.data()!['total'] as num?)?.toInt() ?? 0);
      });

  Future<BudgetPlan?> getPlan(String hid, String month) => watchPlan(hid, month).first;

  Future<void> savePlan(String hid, BudgetPlan plan) => _plans(hid).doc(plan.month).set({
        'limits': plan.limits,
        'total': plan.total,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(ref.watch(firestoreProvider), ref.watch(uuidProvider).v4),
);

/// Bieżący miesiąc widoku budżetu (`yyyy-MM`).
final budgetMonthProvider = NotifierProvider<BudgetMonth, String>(BudgetMonth.new);

class BudgetMonth extends Notifier<String> {
  @override
  String build() => monthKey(DateTime.now());

  void shift(int delta) => state = shiftMonth(state, delta);
}

bool _isAdmin(Ref ref) => ref.watch(myRoleProvider) == Role.admin;

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null) return Stream.value(const []);
  return ref.watch(budgetRepositoryProvider).watchCategories(hid);
});

/// Wydatki miesiąca; dla Domownika zawsze pusty strumień (reguły i tak odrzuciłyby odczyt).
final monthExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null || !_isAdmin(ref)) return Stream.value(const []);
  return ref.watch(budgetRepositoryProvider).watchExpenses(hid, ref.watch(budgetMonthProvider));
});

final monthPlanProvider = StreamProvider<BudgetPlan?>((ref) {
  final hid = ref.watch(householdIdProvider);
  if (hid == null || !_isAdmin(ref)) return Stream.value(null);
  return ref.watch(budgetRepositoryProvider).watchPlan(hid, ref.watch(budgetMonthProvider));
});
