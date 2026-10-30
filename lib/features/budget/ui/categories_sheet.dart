import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../household/data/household_repository.dart';
import '../data/budget_repository.dart';
import '../domain/budget_models.dart';

/// Arkusz Administratora: kategorie wydatków (nazwa + kolor), dodawanie, usuwanie.
Future<void> showCategoriesSheet(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  await showAppSheet<void>(context, title: l.categoriesTitle, builder: (_) => const _CategoriesEditor());
}

class _CategoriesEditor extends ConsumerStatefulWidget {
  const _CategoriesEditor();

  @override
  ConsumerState<_CategoriesEditor> createState() => _CategoriesEditorState();
}

class _CategoriesEditorState extends ConsumerState<_CategoriesEditor> {
  final _newName = TextEditingController();
  int _newColor = 0;
  String? _error;

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  void _add(List<Category> existing) {
    final l = AppLocalizations.of(context);
    final hid = ref.read(householdIdProvider);
    if (hid == null) return;
    if (_newName.text.trim().isEmpty) {
      setState(() => _error = l.errCategoryName);
      return;
    }
    final repo = ref.read(budgetRepositoryProvider);
    repo
        .saveCategory(hid, Category(id: repo.newId(), name: _newName.text.trim(), icon: 'other', colorIndex: _newColor, order: existing.length))
        .catchError((Object _) {});
    setState(() {
      _newName.clear();
      _error = null;
    });
  }

  Future<void> _delete(Category c) async {
    final l = AppLocalizations.of(context);
    final hid = ref.read(householdIdProvider);
    if (hid == null) return;
    final ok = await confirmSheet(
      context,
      title: l.categoryDelete,
      body: l.categoryDeleteBody(c.name),
      confirmLabel: l.confirmYes,
      cancelLabel: l.back,
      danger: true,
    );
    if (!ok || !mounted) return;
    final repo = ref.read(budgetRepositoryProvider);
    repo.deleteCategory(hid, c.id).catchError((Object _) {});
    showAppToast(context, l.toastCategoryRemoved, actionLabel: l.toastUndo, onAction: () => repo.saveCategory(hid, c).catchError((Object _) {}));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];

    Widget colors(int selected, ValueChanged<int> onPick, {double size = 26}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onPick(i),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: t.chart[i],
                      shape: BoxShape.circle,
                      border: Border.all(color: selected == i ? t.text : Colors.transparent, width: 3),
                    ),
                  ),
                ),
              ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.categoriesHint, style: text.labelMedium),
        const SizedBox(height: 12),
        for (final (i, c) in categories.indexed) ...[
          if (i > 0) const AppDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(c.name, style: text.bodyLarge)),
                colors(c.colorIndex, (col) {
                  final hid = ref.read(householdIdProvider);
                  if (hid == null) return;
                  ref.read(budgetRepositoryProvider).saveCategory(hid, Category(id: c.id, name: c.name, icon: c.icon, colorIndex: col, order: c.order)).catchError((Object _) {});
                }),
                IconButton(
                  tooltip: l.categoryDelete,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: Icon(Icons.delete_outline, color: t.danger),
                  onPressed: () => _delete(c),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        AppTextField(controller: _newName, hint: l.categoryNameHint, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.done, onSubmitted: (_) => _add(categories)),
        const SizedBox(height: 10),
        colors(_newColor, (c) => setState(() => _newColor = c), size: 32),
        if (_error != null) ...[const SizedBox(height: 6), Text(_error!, style: text.labelMedium!.copyWith(color: t.danger))],
        const SizedBox(height: 12),
        PrimaryButton(label: l.categoryAdd, onPressed: () => _add(categories)),
      ],
    );
  }
}
