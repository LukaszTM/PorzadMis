import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/util/emoji.dart';
import '../../household/ui/home_top_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../../members/data/members_repository.dart';
import '../data/shopping_repository.dart';
import '../domain/shopping_models.dart';
import 'shopping_sheets.dart';

/// Wspólna lista zakupów (GUI 6): pole „Co dopisać?” u góry, „Do kupienia” i „Kupione”.
class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  final _form = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
    _focus.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Zapisy idą bez czekania na serwer (offline); błąd pokazujemy tylko, gdy serwer go odrzuci.
  void _fire(Future<void> write) {
    final l = AppLocalizations.of(context);
    write.catchError((Object _) {
      if (mounted) showAppToast(context, l.errGeneric, error: true);
    });
  }

  void _submit([String? suggested]) {
    if (suggested == null && !_form.currentState!.validate()) return;
    final name = (suggested ?? _controller.text).trim();
    final hid = ref.read(householdIdProvider);
    final uid = ref.read(authStateProvider).value?.uid;
    if (name.isEmpty || hid == null || uid == null) return;

    final l = AppLocalizations.of(context);
    final repo = ref.read(shoppingRepositoryProvider);
    final items = ref.read(shoppingItemsProvider).value ?? const <ShoppingItem>[];
    final key = historyKey(name);
    final same = items.where((i) => i.key == key).toList();
    _controller.clear();

    if (same.any((i) => !i.checked)) {
      showAppToast(context, l.errShoppingDuplicate, error: true);
      return;
    }
    if (same.isNotEmpty) {
      // Było już kupione: wraca na listę zamiast tworzyć duplikat.
      _fire(repo.setChecked(hid: hid, id: same.first.id, uid: uid, checked: false));
      return;
    }
    final history = ref.read(shoppingHistoryProvider).value ?? const <HistoryEntry>[];
    final known = history.where((h) => h.key == key);
    _fire(repo.add(
      hid: hid,
      uid: uid,
      name: name,
      category: known.isEmpty ? StoreCategory.other : known.first.category,
    ));
  }

  void _toggle(ShoppingItem item, bool checked) {
    final hid = ref.read(householdIdProvider);
    final uid = ref.read(authStateProvider).value?.uid;
    if (hid == null || uid == null) return;
    _fire(ref.read(shoppingRepositoryProvider).setChecked(
          hid: hid,
          id: item.id,
          uid: uid,
          checked: checked,
        ));
  }

  void _clearBought(List<ShoppingItem> bought) {
    final hid = ref.read(householdIdProvider);
    if (hid == null || bought.isEmpty) return;
    final l = AppLocalizations.of(context);
    final repo = ref.read(shoppingRepositoryProvider);
    _fire(repo.deleteAll(hid, bought));
    showAppToast(
      context,
      l.toastCleared,
      actionLabel: l.toastUndo,
      onAction: () => repo.restore(hid, bought).catchError((Object _) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    // Sesja jest potrzebna do zapisów (kto dodał / odhaczył); obserwujemy ją, żeby była aktywna.
    ref.watch(authStateProvider);
    final items = ref.watch(shoppingItemsProvider).value ?? const <ShoppingItem>[];
    final history = ref.watch(shoppingHistoryProvider).value ?? const <HistoryEntry>[];
    final members = ref.watch(membersProvider).value ?? const [];
    final names = {for (final m in members) m.uid: m.displayName};
    final showWho = members.length > 1;

    final toBuy = items.where((i) => !i.checked).toList();
    final bought = items.where((i) => i.checked).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final showSuggestions = _focus.hasFocus || _controller.text.trim().isNotEmpty;
    final suggestions = showSuggestions
        ? suggestionsFor(_controller.text, history, onList: {for (final i in toBuy) i.key})
        : const <HistoryEntry>[];

    String meta(ShoppingItem i) => [
          categoryLabel(l, i.category),
          if (showWho && names[i.addedBy] != null) l.shoppingAddedByMeta(names[i.addedBy]!),
        ].join(' · ');

    Widget row(ShoppingItem i) => CheckRow(
          title: i.name,
          checked: i.checked,
          leading: Text(emojiFor(i.name, fallback: _categoryEmoji(i.category)), style: const TextStyle(fontSize: 22)),
          meta: meta(i).isEmpty ? null : meta(i),
          onChanged: (v) => _toggle(i, v),
          onLongPress: () => showEditItemSheet(context, ref, i),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (i.quantityLabel.isNotEmpty) StatusChip(label: i.quantityLabel, tone: ChipTone.neutral),
              IconButton(
            tooltip: l.itemEditAction,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Icon(Icons.edit_outlined, size: 22, color: t.textMuted),
            onPressed: () => showEditItemSheet(context, ref, i),
          ),
            ],
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(20, 10, 20, 0), child: HomeTopBar()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.kickerShared, style: text.labelSmall!.copyWith(color: t.accent, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Text(l.shoppingTitle, style: text.headlineLarge),
                  const SizedBox(height: 4),
                  Text(l.shoppingSubtitle, style: text.bodyMedium!.copyWith(color: t.textMuted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _form,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _controller,
                        hint: l.shoppingAddHint,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? l.errShoppingName : null,
                        focusNode: _focus,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Semantics(
                      button: true,
                      label: l.shoppingAddAction,
                      excludeSemantics: true,
                      child: SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            backgroundColor: t.accent,
                            foregroundColor: t.onAccent,
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.add, size: 24),
                          label: Text(l.shoppingAdd, style: text.bodyLarge!.copyWith(color: t.onAccent)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (suggestions.isNotEmpty)
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  itemCount: suggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ActionChip(
                    label: Text(suggestions[i].name),
                    onPressed: () => _submit(suggestions[i].name),
                    backgroundColor: t.accentSoft,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    labelStyle: text.bodyMedium!.copyWith(
                      color: t.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                children: [
                  if (toBuy.isEmpty)
                    _EmptyState(message: items.isEmpty ? l.shoppingEmpty : l.shoppingAllBought)
                  else
                    AppCard(
                      title: l.shoppingToBuyTitle,
                      trailing: StatusChip(label: '${toBuy.length}', tone: ChipTone.accent),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l.shoppingListMeta(members.length), style: text.labelMedium),
                          for (final (category, group) in groupByCategory(toBuy)) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 6, bottom: 2),
                              child: Text(categoryLabel(l, category), style: text.titleMedium),
                            ),
                            for (var n = 0; n < group.length; n++) ...[
                              if (n > 0) const AppDivider(),
                              row(group[n]),
                            ],
                          ],
                        ],
                      ),
                    ),
                  if (bought.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    AppCard(
                      title: l.shoppingBought(bought.length),
                      trailing: TertiaryButton(
                        label: l.shoppingClear,
                        onPressed: () => _clearBought(bought),
                      ),
                      child: Column(
                        children: [
                          for (var n = 0; n < bought.length; n++) ...[
                            if (n > 0) const AppDivider(),
                            row(bought[n]),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _categoryEmoji(StoreCategory c) => switch (c) {
      StoreCategory.produce => emojiProduce,
      StoreCategory.bakery => emojiBakery,
      StoreCategory.dairy => emojiDairy,
      StoreCategory.meat => emojiMeat,
      StoreCategory.drinks => emojiDrinks,
      StoreCategory.household => emojiHousehold,
      StoreCategory.other => emojiOther,
    };

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const IllustrationImage(Illustration.bearResting, height: 120),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
