import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/util/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';
import '../../members/data/members_repository.dart';
import '../data/budget_repository.dart';
import '../domain/budget_models.dart';

/// Arkusz wydatku (GUI 5.9): kwota, data (domyślnie dziś), kategoria, opis, kto zapłacił.
Future<void> showExpenseSheet(BuildContext context, WidgetRef ref, Expense? expense, {required String month}) async {
  final l = AppLocalizations.of(context);
  final hid = ref.read(householdIdProvider);
  final uid = ref.read(authStateProvider).value?.uid;
  if (hid == null || uid == null) return;
  final repo = ref.read(budgetRepositoryProvider);
  final categories = ref.read(categoriesProvider).value ?? const <Category>[];
  final members = ref.read(membersProvider).value ?? const <Member>[];

  // Nowy wydatek: dziś, jeśli oglądamy bieżący miesiąc; inaczej pierwszy dzień tego miesiąca.
  final today = DateTime.now();
  final defaultDay = monthKey(today) == month ? today : parseMonthKey(month);
  final draft = expense ??
      Expense(
        id: repo.newId(),
        amount: 0,
        date: dayKey(defaultDay),
        categoryId: categories.isEmpty ? 'other' : categories.first.id,
        paidBy: uid,
      );

  final result = await showAppSheet<_ExpenseResult>(
    context,
    title: expense == null ? l.expenseNewTitle : l.expenseEditTitle,
    builder: (_) => _ExpenseForm(expense: draft, isNew: expense == null, categories: categories, members: members),
  );
  if (result == null || !context.mounted) return;
  if (result.deleted != null) {
    final removed = result.deleted!;
    repo.deleteExpense(hid, removed.id).catchError((Object _) {});
    showAppToast(
      context,
      l.toastExpenseRemoved,
      actionLabel: l.toastUndo,
      onAction: () => repo.saveExpense(hid: hid, uid: uid, e: removed, isNew: false).catchError((Object _) {}),
    );
    return;
  }
  if (result.saved != null) {
    repo.saveExpense(hid: hid, uid: uid, e: result.saved!, isNew: expense == null).catchError((Object _) {});
  }
}

class _ExpenseResult {
  const _ExpenseResult({this.saved, this.deleted});

  final Expense? saved;
  final Expense? deleted;
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm({required this.expense, required this.isNew, required this.categories, required this.members});

  final Expense expense;
  final bool isNew;
  final List<Category> categories;
  final List<Member> members;

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  late final _amount = TextEditingController(text: amountToText(widget.expense.amount));
  late final _note = TextEditingController(text: widget.expense.note);
  late DateTime _date = widget.expense.day;
  late String _category = widget.expense.categoryId;
  late String? _paidBy = widget.expense.paidBy;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final l = AppLocalizations.of(context);
    final amount = parsePln(_amount.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = l.errExpenseAmount);
      return;
    }
    if (_category.isEmpty) {
      setState(() => _error = l.errExpenseCategory);
      return;
    }
    Navigator.of(context).pop(_ExpenseResult(
      saved: widget.expense.copyWith(
        amount: amount,
        date: dayKey(_date),
        categoryId: _category,
        note: _note.text,
        paidBy: _paidBy,
        clearPaidBy: _paidBy == null,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    Widget label(String s) => Padding(padding: const EdgeInsets.only(top: 14, bottom: 8), child: Text(s, style: text.labelMedium));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _amount,
          label: l.expenseAmountLabel,
          hint: l.expenseAmountHint,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 .,]'))],
          autofocus: widget.isNew,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: Text(l.expenseDateLabel, style: text.bodyMedium)),
            TertiaryButton(
              label: formatDayShort(_date),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(DateTime.now().year - 3),
                  lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                  locale: const Locale('pl'),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
          ],
        ),
        label(l.expenseCategoryLabel),
        ChoiceChips<String>(
          options: [for (final c in widget.categories) ChoiceOption(c.id, c.name)],
          selected: {_category},
          onToggle: (v) => setState(() => _category = v),
        ),
        label(l.expenseNoteLabel),
        AppTextField(controller: _note, hint: l.expenseNoteHint, textCapitalization: TextCapitalization.sentences),
        label(l.expensePaidByLabel),
        ChoiceChips<String?>(
          options: [
            for (final m in widget.members) ChoiceOption(m.uid, m.displayName),
            ChoiceOption(null, l.expensePaidNobody),
          ],
          selected: {_paidBy},
          onToggle: (v) => setState(() => _paidBy = v),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: text.labelMedium!.copyWith(color: t.danger)),
        ],
        const SizedBox(height: 20),
        PrimaryButton(label: l.itemDone, onPressed: _save),
        if (!widget.isNew) ...[
          const SizedBox(height: 4),
          TertiaryButton(
            label: l.expenseDelete,
            danger: true,
            onPressed: () => Navigator.of(context).pop(_ExpenseResult(deleted: widget.expense)),
          ),
        ],
      ],
    );
  }
}

/// Arkusz planu miesiąca: limit na kategorię i suma; „Skopiuj z poprzedniego miesiąca”.
Future<void> showPlanSheet(BuildContext context, WidgetRef ref, {required String month}) async {
  final l = AppLocalizations.of(context);
  final hid = ref.read(householdIdProvider);
  if (hid == null) return;
  final repo = ref.read(budgetRepositoryProvider);
  final categories = ref.read(categoriesProvider).value ?? const <Category>[];
  final current = ref.read(monthPlanProvider).value ?? BudgetPlan(month: month);

  final saved = await showAppSheet<BudgetPlan>(
    context,
    title: l.planTitle,
    builder: (_) => _PlanForm(
      plan: current,
      categories: categories,
      loadPrevious: () => repo.getPlan(hid, shiftMonth(month, -1)),
    ),
  );
  if (saved == null || !context.mounted) return;
  repo.savePlan(hid, saved).catchError((Object _) {});
}

class _PlanForm extends StatefulWidget {
  const _PlanForm({required this.plan, required this.categories, required this.loadPrevious});

  final BudgetPlan plan;
  final List<Category> categories;
  final Future<BudgetPlan?> Function() loadPrevious;

  @override
  State<_PlanForm> createState() => _PlanFormState();
}

class _PlanFormState extends State<_PlanForm> {
  late final Map<String, TextEditingController> _limits = {
    for (final c in widget.categories)
      c.id: TextEditingController(text: _zl(widget.plan.limits[c.id] ?? 0)),
  };
  late final _total = TextEditingController(text: _zl(widget.plan.total));
  bool _copying = false;

  static String _zl(int grosze) => grosze == 0 ? '' : (grosze % 100 == 0 ? '${grosze ~/ 100}' : (grosze / 100).toStringAsFixed(2).replaceAll('.', ','));

  @override
  void dispose() {
    for (final c in _limits.values) {
      c.dispose();
    }
    _total.dispose();
    super.dispose();
  }

  Future<void> _copyPrevious() async {
    final l = AppLocalizations.of(context);
    setState(() => _copying = true);
    final prev = await widget.loadPrevious();
    if (!mounted) return;
    setState(() => _copying = false);
    if (prev == null) {
      showAppToast(context, l.planNoPrevious, error: true);
      return;
    }
    setState(() {
      for (final entry in _limits.entries) {
        entry.value.text = _zl(prev.limits[entry.key] ?? 0);
      }
      _total.text = _zl(prev.total);
    });
    if (mounted) showAppToast(context, l.planCopied);
  }

  void _save() {
    final limits = <String, int>{};
    for (final entry in _limits.entries) {
      final v = parsePln(entry.value.text) ?? 0;
      if (v > 0) limits[entry.key] = v;
    }
    var total = parsePln(_total.text) ?? 0;
    final sum = limits.values.fold(0, (a, b) => a + b);
    if (total < sum) total = sum;
    Navigator.of(context).pop(widget.plan.copyWith(limits: limits, total: total));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final amountFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9 .,]'))];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _total,
          label: l.planTotalLabel,
          hint: l.planCategoryHint,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: amountFormatters,
        ),
        const SizedBox(height: 8),
        for (final c in widget.categories) ...[
          const SizedBox(height: 10),
          AppTextField(
            controller: _limits[c.id]!,
            label: c.name,
            hint: l.planCategoryHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: amountFormatters,
          ),
        ],
        const SizedBox(height: 16),
        SecondaryButton(
          label: l.planCopyPrevious,
          icon: Icons.content_copy_outlined,
          onPressed: _copying ? null : _copyPrevious,
        ),
        const SizedBox(height: 12),
        PrimaryButton(label: l.planSave, onPressed: _save),
        const SizedBox(height: 4),
        Text(l.budgetAdminBadge, style: text.labelMedium, textAlign: TextAlign.center),
      ],
    );
  }
}
