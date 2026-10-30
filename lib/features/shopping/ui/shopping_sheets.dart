import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../household/data/household_repository.dart';
import '../data/shopping_repository.dart';
import '../domain/shopping_models.dart';

String categoryLabel(AppLocalizations l, StoreCategory c) => switch (c) {
      StoreCategory.produce => l.catProduce,
      StoreCategory.bakery => l.catBakery,
      StoreCategory.dairy => l.catDairy,
      StoreCategory.meat => l.catMeat,
      StoreCategory.drinks => l.catDrinks,
      StoreCategory.household => l.catHousehold,
      StoreCategory.other => l.catOther,
    };

/// Arkusz edycji pozycji (GUI 5.9): nazwa, ilość, jednostka, dział, „Gotowe” i „Usuń”.
/// Usunięcie działa od razu, z komunikatem „Cofnij” (GUI 8) pokazanym z ekranu wywołującego.
Future<void> showEditItemSheet(BuildContext context, WidgetRef ref, ShoppingItem item) async {
  final l = AppLocalizations.of(context);
  final deleted = await showAppSheet<bool>(
    context,
    title: l.itemEditTitle,
    builder: (sheetContext) => _EditItemForm(item: item, ref: ref),
  );
  if (deleted != true || !context.mounted) return;
  final hid = ref.read(householdIdProvider);
  if (hid == null) return;
  final repo = ref.read(shoppingRepositoryProvider);
  repo.delete(hid, item.id).catchError((Object _) {});
  showAppToast(
    context,
    l.toastRemoved,
    actionLabel: l.toastUndo,
    onAction: () => repo.restore(hid, [item]).catchError((Object _) {}),
  );
}

class _EditItemForm extends StatefulWidget {
  const _EditItemForm({required this.item, required this.ref});

  final ShoppingItem item;
  final WidgetRef ref;

  @override
  State<_EditItemForm> createState() => _EditItemFormState();
}

class _EditItemFormState extends State<_EditItemForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.item.name);
  late final _quantity = TextEditingController(text: widget.item.quantity);
  late final _unit = TextEditingController(text: widget.item.unit);
  late StoreCategory _category = widget.item.category;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _unit.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final hid = widget.ref.read(householdIdProvider);
    if (hid == null) return;
    final updated = widget.item.copyWith(
      name: _name.text.trim(),
      quantity: _quantity.text.trim(),
      unit: _unit.text.trim(),
      category: _category,
    );
    // Bez czekania na serwer: w trybie offline zapis dojdzie później.
    widget.ref.read(shoppingRepositoryProvider).update(hid, updated).catchError((Object _) {});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _name,
            label: l.itemNameLabel,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? l.errShoppingName : null,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  controller: _quantity,
                  label: l.itemQuantityLabel,
                  hint: l.itemQuantityHint,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _unit,
                  label: l.itemUnitLabel,
                  hint: l.itemUnitHint,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(l.itemCategoryLabel, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in StoreCategory.values)
                _CategoryChoice(
                  label: categoryLabel(l, c),
                  selected: c == _category,
                  onTap: () => setState(() => _category = c),
                ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: l.itemDone, onPressed: _save),
          const SizedBox(height: 4),
          TertiaryButton(
            label: l.itemDelete,
            danger: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

class _CategoryChoice extends StatelessWidget {
  const _CategoryChoice({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? t.accent : t.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? t.accent : t.border, width: 2)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: selected ? t.onAccent : t.text,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
