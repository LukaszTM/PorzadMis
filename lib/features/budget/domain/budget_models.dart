import '../../chores/domain/chore_models.dart' show parseDayKey;

export '../../chores/domain/chore_models.dart' show dayKey, parseDayKey;

/// Miesiąc jako tekst `yyyy-MM`.
String monthKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

DateTime parseMonthKey(String s) {
  final p = s.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1]);
}

String shiftMonth(String key, int delta) {
  final d = parseMonthKey(key);
  return monthKey(DateTime(d.year, d.month + delta));
}

/// Symbole walut obsługiwanych w ustawieniach domu.
const currencySymbols = {'PLN': 'zł', 'EUR': '€', 'USD': '\$', 'GBP': '£', 'CZK': 'Kč'};

/// „1 420,50 zł” w walucie domu (GUI 3): odstęp tysięcy, przecinek, dwa miejsca.
String formatMoney(int grosze, {String currency = 'PLN'}) =>
    formatPln(grosze).replaceFirst(RegExp(r' zł$'), ' ${currencySymbols[currency] ?? currency}');

/// Kwota bez symbolu do pola tekstowego: „24,99”.
String amountToText(int grosze) => grosze == 0 ? '' : (grosze / 100).toStringAsFixed(2).replaceAll('.', ',');

/// „1 420,50 zł”: odstęp tysięcy, przecinek, zawsze dwa miejsca po przecinku.
String formatPln(int grosze) {
  final negative = grosze < 0;
  final abs = grosze.abs();
  final zl = abs ~/ 100;
  final gr = abs % 100;
  final digits = zl.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    buf.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
  }
  return '${negative ? '-' : ''}$buf,${gr.toString().padLeft(2, '0')} zł';
}

/// Zamienia tekst z pola („12,50”, „12.5”, „1 200”) na grosze; null, gdy nie da się odczytać.
int? parsePln(String text) {
  final cleaned = text.replaceAll(RegExp(r'[\s zł]'), '').replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value.isNaN || value < 0) return null;
  return (value * 100).round();
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorIndex,
    required this.order,
  });

  final String id;
  final String name;
  final String icon;

  /// 0–4: indeks koloru z tokenów chart1…chart5.
  final int colorIndex;
  final int order;
}

/// Zestaw startowy (PLAN.md); identyfikatory stałe, żeby plan dało się kopiować między domami testowymi.
const seedCategories = [
  Category(id: 'food', name: 'Jedzenie', icon: 'food', colorIndex: 0, order: 0),
  Category(id: 'bills', name: 'Rachunki', icon: 'bills', colorIndex: 1, order: 1),
  Category(id: 'home', name: 'Dom', icon: 'home', colorIndex: 2, order: 2),
  Category(id: 'transport', name: 'Transport', icon: 'transport', colorIndex: 3, order: 3),
  Category(id: 'health', name: 'Zdrowie', icon: 'health', colorIndex: 4, order: 4),
  Category(id: 'kids', name: 'Dzieci', icon: 'kids', colorIndex: 0, order: 5),
  Category(id: 'fun', name: 'Rozrywka', icon: 'fun', colorIndex: 1, order: 6),
  Category(id: 'other', name: 'Inne', icon: 'other', colorIndex: 4, order: 7),
];

class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note = '',
    this.paidBy,
    this.createdBy,
    this.createdAt,
  });

  final String id;

  /// Grosze, zawsze int.
  final int amount;

  /// `yyyy-MM-dd`.
  final String date;
  final String categoryId;
  final String note;
  final String? paidBy;
  final String? createdBy;
  final DateTime? createdAt;

  String get month => date.substring(0, 7);
  DateTime get day => parseDayKey(date);

  Expense copyWith({int? amount, String? date, String? categoryId, String? note, String? paidBy, bool clearPaidBy = false}) =>
      Expense(
        id: id,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        categoryId: categoryId ?? this.categoryId,
        note: note ?? this.note,
        paidBy: clearPaidBy ? null : (paidBy ?? this.paidBy),
        createdBy: createdBy,
        createdAt: createdAt,
      );
}

class BudgetPlan {
  const BudgetPlan({required this.month, this.limits = const {}, this.total = 0});

  final String month;
  final Map<String, int> limits;
  final int total;

  /// Suma limitów kategorii; `total` może być większy (rezerwa), nigdy mniejszy w UI.
  int get limitsSum => limits.values.fold(0, (a, b) => a + b);

  BudgetPlan copyWith({Map<String, int>? limits, int? total}) =>
      BudgetPlan(month: month, limits: limits ?? this.limits, total: total ?? this.total);
}

enum ExpenseSort { dateDesc, amountDesc, amountAsc }

class CategoryTotal {
  const CategoryTotal({required this.category, required this.amount, required this.share});

  final Category category;
  final int amount;

  /// Udział w sumie miesiąca, 0–1.
  final double share;
}

/// Suma wydatków po kategoriach (malejąco), tylko kategorie z wydatkami.
List<CategoryTotal> totalsByCategory(List<Expense> expenses, List<Category> categories) {
  final sums = <String, int>{};
  for (final e in expenses) {
    sums[e.categoryId] = (sums[e.categoryId] ?? 0) + e.amount;
  }
  final total = sums.values.fold(0, (a, b) => a + b);
  final byId = {for (final c in categories) c.id: c};
  final result = [
    for (final entry in sums.entries)
      CategoryTotal(
        category: byId[entry.key] ?? Category(id: entry.key, name: '?', icon: 'other', colorIndex: 4, order: 99),
        amount: entry.value,
        share: total == 0 ? 0 : entry.value / total,
      ),
  ]..sort((a, b) => b.amount.compareTo(a.amount));
  return result;
}

int sumAmounts(Iterable<Expense> expenses) => expenses.fold(0, (a, e) => a + e.amount);

List<Expense> sortExpenses(List<Expense> expenses, ExpenseSort sort) {
  final list = List.of(expenses);
  switch (sort) {
    case ExpenseSort.dateDesc:
      list.sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
      });
    case ExpenseSort.amountDesc:
      list.sort((a, b) => b.amount.compareTo(a.amount));
    case ExpenseSort.amountAsc:
      list.sort((a, b) => a.amount.compareTo(b.amount));
  }
  return list;
}

enum PlanLevel { ok, warning, over }

/// Poziom paska „wydano / plan” (GUI 5.11): accent do 80 %, warning 80–100 %, danger powyżej.
PlanLevel planLevel(int spent, int limit) {
  if (limit <= 0) return PlanLevel.ok;
  final ratio = spent / limit;
  if (ratio > 1) return PlanLevel.over;
  if (ratio >= 0.8) return PlanLevel.warning;
  return PlanLevel.ok;
}
