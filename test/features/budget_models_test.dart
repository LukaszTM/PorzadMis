import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/features/budget/domain/budget_models.dart';

Expense e(String id, int amount, {String cat = 'food', String date = '2026-11-03'}) =>
    Expense(id: id, amount: amount, date: date, categoryId: cat);

void main() {
  group('formatPln', () {
    test('odstęp tysięcy, przecinek, dwa miejsca', () {
      expect(formatPln(142050), '1 420,50 zł');
      expect(formatPln(5), '0,05 zł');
      expect(formatPln(123456789), '1 234 567,89 zł');
      expect(formatPln(0), '0,00 zł');
      expect(formatPln(-250), '-2,50 zł');
    });
  });

  group('formatMoney', () {
    test('symbol waluty domu, PLN domyślnie', () {
      expect(formatMoney(142050), '1\u00A0420,50 zł');
      expect(formatMoney(142050, currency: 'EUR'), '1\u00A0420,50 €');
      expect(formatMoney(5, currency: 'XYZ'), '0,05 XYZ');
      expect(amountToText(2499), '24,99');
      expect(amountToText(0), '');
    });
  });

  group('parsePln', () {
    test('przecinek, kropka, spacje, zł', () {
      expect(parsePln('24,99'), 2499);
      expect(parsePln('24.5'), 2450);
      expect(parsePln('1 200'), 120000);
      expect(parsePln('12 zł'), 1200);
      expect(parsePln(''), isNull);
      expect(parsePln('abc'), isNull);
      expect(parsePln('-3'), isNull);
    });
    test('formatPln i parsePln są odwrotne', () {
      for (final v in [0, 1, 99, 100, 123456]) {
        expect(parsePln(formatPln(v)), v);
      }
    });
  });

  group('miesiące', () {
    test('monthKey / shiftMonth przechodzą przez granicę roku', () {
      expect(monthKey(DateTime(2026, 1, 15)), '2026-01');
      expect(shiftMonth('2026-01', -1), '2025-12');
      expect(shiftMonth('2026-12', 1), '2027-01');
    });
  });

  group('agregacje', () {
    final cats = seedCategories;
    test('totalsByCategory: sumy, udziały, malejąco', () {
      final t = totalsByCategory([e('a', 300), e('b', 100, cat: 'home'), e('c', 100)], cats);
      expect(t.map((x) => x.category.id), ['food', 'home']);
      expect(t.first.amount, 400);
      expect(t.first.share, closeTo(0.8, 1e-9));
      expect(t.last.share, closeTo(0.2, 1e-9));
    });
    test('nieznana kategoria nie wywraca agregacji', () {
      final t = totalsByCategory([e('a', 100, cat: 'zzz')], cats);
      expect(t.single.category.name, '?');
    });
    test('sortExpenses: data malejąco, kwota malejąco i rosnąco', () {
      final list = [e('a', 100, date: '2026-11-01'), e('b', 300, date: '2026-11-05'), e('c', 200, date: '2026-11-03')];
      expect(sortExpenses(list, ExpenseSort.dateDesc).map((x) => x.id), ['b', 'c', 'a']);
      expect(sortExpenses(list, ExpenseSort.amountDesc).map((x) => x.id), ['b', 'c', 'a']);
      expect(sortExpenses(list, ExpenseSort.amountAsc).map((x) => x.id), ['a', 'c', 'b']);
    });
  });

  group('planLevel', () {
    test('accent do 80 %, warning 80–100 %, danger powyżej; bez planu zawsze ok', () {
      expect(planLevel(79, 100), PlanLevel.ok);
      expect(planLevel(80, 100), PlanLevel.warning);
      expect(planLevel(100, 100), PlanLevel.warning);
      expect(planLevel(101, 100), PlanLevel.over);
      expect(planLevel(500, 0), PlanLevel.ok);
    });
    test('BudgetPlan.limitsSum', () {
      expect(const BudgetPlan(month: '2026-11', limits: {'a': 100, 'b': 250}).limitsSum, 350);
    });
  });
}
