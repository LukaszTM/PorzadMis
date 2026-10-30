import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/util/dates.dart';
import '../../../core/util/emoji.dart';
import '../../../l10n/app_localizations.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';
import '../../members/data/members_repository.dart';
import '../data/budget_repository.dart';
import '../domain/budget_models.dart';
import 'budget_sheets.dart';
import 'categories_sheet.dart';

/// Budżet domowy (GUI 6, 5.11): tylko Administrator. Plakietka pod tytułem zawsze widoczna.
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  String? _filterCategory;
  ExpenseSort _sort = ExpenseSort.dateDesc;
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final isAdmin = ref.watch(myRoleProvider) == Role.admin;
    final hid = ref.watch(householdIdProvider);

    if (!isAdmin) {
      return ScreenScaffold(
        title: l.budgetTitle,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: l.back,
        children: [Text(l.budgetMemberBlocked, style: text.bodyLarge, textAlign: TextAlign.center)],
      );
    }

    final currency = ref.watch(householdCurrencyProvider);
    String money(int g) => formatMoney(g, currency: currency);
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    if (!_seeded && hid != null && ref.watch(categoriesProvider).hasValue && categories.isEmpty) {
      _seeded = true;
      ref.read(budgetRepositoryProvider).seedCategoriesIfEmpty(hid).catchError((Object _) {});
    }
    final month = ref.watch(budgetMonthProvider);
    final expenses = ref.watch(monthExpensesProvider).value ?? const <Expense>[];
    final plan = ref.watch(monthPlanProvider).value;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final names = {for (final m in members) m.uid: m.displayName};
    final byId = {for (final c in categories) c.id: c};

    final totals = totalsByCategory(expenses, categories);
    final spent = sumAmounts(expenses);
    final filtered = _filterCategory == null ? expenses : expenses.where((e) => e.categoryId == _filterCategory).toList();
    final listed = sortExpenses(filtered, _sort);
    final planTotal = plan == null ? 0 : (plan.total > 0 ? plan.total : plan.limitsSum);
    final level = planLevel(spent, planTotal);
    final levelColor = switch (level) { PlanLevel.ok => t.accent, PlanLevel.warning => t.warning, PlanLevel.over => t.danger };
    final monthLabel = _capitalize(DateFormat('LLLL yyyy', 'pl').format(parseMonthKey(month)));
    final now = DateTime.now();

    return ScreenScaffold(
      title: l.budgetTitle,
      kicker: l.kickerAdmin,
      subtitle: l.budgetSubtitle,
      onBack: () => Navigator.of(context).maybePop(),
      backLabel: l.back,
      headerTrailing: IconButton(
        tooltip: l.categoriesTitle,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Icon(Icons.category_outlined, color: t.text),
        onPressed: () => showCategoriesSheet(context, ref),
      ),
      bottom: PrimaryButton(
        label: l.budgetAdd,
        onPressed: () => showExpenseSheet(context, ref, null, month: month),
      ),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l.budgetPrevMonth,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(Icons.chevron_left, size: 28, color: t.text),
              onPressed: () {
                ref.read(budgetMonthProvider.notifier).shift(-1);
                setState(() => _filterCategory = null);
              },
            ),
            Expanded(child: Text(monthLabel, style: text.titleLarge, textAlign: TextAlign.center)),
            IconButton(
              tooltip: l.budgetNextMonth,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(Icons.chevron_right, size: 28, color: t.text),
              onPressed: () {
                ref.read(budgetMonthProvider.notifier).shift(1);
                setState(() => _filterCategory = null);
              },
            ),
          ],
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 62,
                        sectionsSpace: 2,
                        startDegreeOffset: -90,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            if (!event.isInterestedForInteractions) return;
                            final i = response?.touchedSection?.touchedSectionIndex;
                            if (i == null || i < 0 || i >= totals.length) return;
                            setState(() {
                              final id = totals[i].category.id;
                              _filterCategory = _filterCategory == id ? null : id;
                            });
                          },
                        ),
                        sections: totals.isEmpty
                            ? [PieChartSectionData(value: 1, color: t.border, radius: 26, showTitle: false)]
                            : [
                                for (final ct in totals)
                                  PieChartSectionData(
                                    value: ct.amount.toDouble(),
                                    color: t.chart[ct.category.colorIndex].withValues(
                                      alpha: _filterCategory == null || _filterCategory == ct.category.id ? 1 : 0.4,
                                    ),
                                    radius: 26,
                                    showTitle: false,
                                  ),
                              ],
                      ),
                      duration: const Duration(milliseconds: 300),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(money(spent), style: text.headlineMedium),
                        Text(
                          planTotal > 0 ? 'z ${money(planTotal)}' : l.budgetSpent,
                          style: text.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final ct in totals)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: t.chart[ct.category.colorIndex], shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ct.category.name, style: text.bodyMedium)),
                      Text(money(ct.amount), style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              const AppDivider(),
              const SizedBox(height: 12),
              if (planTotal <= 0) ...[
                Text(l.budgetNoPlan, style: text.bodyMedium),
                const SizedBox(height: 8),
                SecondaryButton(label: l.budgetSetPlan, onPressed: () => showPlanSheet(context, ref, month: month)),
              ] else ...[
                _PlanBar(spent: spent, limit: planTotal, color: levelColor),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: Text(l.budgetOfPlan(money(spent), money(planTotal)), style: text.labelMedium)),
                    if (level == PlanLevel.warning) StatusChip(label: l.budgetWarn80, tone: ChipTone.warning),
                    if (level == PlanLevel.over) StatusChip(label: l.budgetOver, tone: ChipTone.warning, icon: Icons.warning_amber_outlined),
                  ],
                ),
                TertiaryButton(label: l.budgetEditPlan, onPressed: () => showPlanSheet(context, ref, month: month)),
              ],
            ],
          ),
        ),
        if (plan != null && plan.limits.isNotEmpty)
          AppCard(
            title: l.budgetByCategory,
            child: Column(
              children: [
                for (final c in categories.where((c) => (plan.limits[c.id] ?? 0) > 0))
                  Builder(builder: (context) {
                    final s = sumAmounts(expenses.where((e) => e.categoryId == c.id));
                    final lim = plan.limits[c.id]!;
                    final lv = planLevel(s, lim);
                    final col = switch (lv) { PlanLevel.ok => t.accent, PlanLevel.warning => t.warning, PlanLevel.over => t.danger };
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(c.name, style: text.bodyMedium)),
                              Text(l.categoryLimit(money(s), money(lim)), style: text.labelMedium),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _PlanBar(spent: s, limit: lim, color: col),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        AppCard(
          title: l.budgetRecent,
          trailing: _filterCategory == null
              ? null
              : TertiaryButton(label: l.budgetClearFilter, onPressed: () => setState(() => _filterCategory = null)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedSwitch<ExpenseSort>(
                options: [
                  SegmentOption(ExpenseSort.dateDesc, l.budgetSortDate),
                  SegmentOption(ExpenseSort.amountDesc, l.budgetSortAmountDesc),
                  SegmentOption(ExpenseSort.amountAsc, l.budgetSortAmountAsc),
                ],
                value: _sort,
                onChanged: (v) => setState(() => _sort = v),
              ),
              if (_filterCategory != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(label: l.budgetFilterChip(byId[_filterCategory]?.name ?? ''), tone: ChipTone.accent),
                ),
              ],
              const SizedBox(height: 8),
              if (listed.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l.budgetEmpty, style: text.bodyMedium, textAlign: TextAlign.center),
                ),
              for (var i = 0; i < listed.length; i++) ...[
                if (i > 0) const AppDivider(),
                InkWell(
                  onTap: () => showExpenseSheet(context, ref, listed[i], month: month),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 60),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: t.chart[(byId[listed[i].categoryId]?.colorIndex ?? 4)].withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emojiFor(listed[i].note, fallback: _categoryEmoji(listed[i].categoryId)),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                listed[i].note.isNotEmpty ? listed[i].note : (byId[listed[i].categoryId]?.name ?? ''),
                                style: text.bodyLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                l.paidByMeta(
                                  names[listed[i].paidBy] ?? l.expensePaidNobody,
                                  formatRelativeDay(l, listed[i].day, now),
                                ),
                                style: text.labelMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(money(listed[i].amount), style: text.bodyLarge),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

String _categoryEmoji(String id) => switch (id) {
      'food' => '🛒',
      'bills' => '💡',
      'home' => '🏠',
      'transport' => '🚗',
      'health' => '❤️',
      'kids' => '👶',
      'fun' => '🎬',
      _ => '📦',
    };

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Pasek „wydano / plan” (GUI 5.11): 10 dp, zaokrąglony.
class _PlanBar extends StatelessWidget {
  const _PlanBar({required this.spent, required this.limit, required this.color});

  final int spent;
  final int limit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ratio = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    return Semantics(
      label: '${(ratio * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          height: 10,
          child: Stack(
            children: [
              Container(color: t.border),
              FractionallySizedBox(widthFactor: ratio, child: Container(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
