import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../household/data/household_repository.dart';
import '../data/events_repository.dart';
import '../domain/event_models.dart';

/// Arkusz Administratora: lista typów z nazwą i kolorem, dodawanie i usuwanie.
Future<void> showEventTypesSheet(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  await showAppSheet<void>(
    context,
    title: l.eventTypesTitle,
    builder: (_) => const _EventTypesEditor(),
  );
}

class _EventTypesEditor extends ConsumerStatefulWidget {
  const _EventTypesEditor();

  @override
  ConsumerState<_EventTypesEditor> createState() => _EventTypesEditorState();
}

class _EventTypesEditorState extends ConsumerState<_EventTypesEditor> {
  final _newName = TextEditingController();
  int _newColor = 0;
  String? _error;

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  void _add(List<EventType> existing) {
    final l = AppLocalizations.of(context);
    final hid = ref.read(householdIdProvider);
    if (hid == null) return;
    if (_newName.text.trim().isEmpty) {
      setState(() => _error = l.errEventTypeName);
      return;
    }
    final repo = ref.read(eventTypesRepositoryProvider);
    repo
        .save(hid, EventType(id: repo.newId(), name: _newName.text, colorIndex: _newColor, order: existing.length))
        .catchError((Object _) {});
    setState(() {
      _newName.clear();
      _error = null;
    });
  }

  Future<void> _delete(EventType t) async {
    final l = AppLocalizations.of(context);
    final hid = ref.read(householdIdProvider);
    if (hid == null) return;
    final ok = await confirmSheet(
      context,
      title: l.eventTypeDelete,
      body: l.eventTypeDeleteBody(t.name),
      confirmLabel: l.confirmYes,
      cancelLabel: l.back,
      danger: true,
    );
    if (!ok || !mounted) return;
    final repo = ref.read(eventTypesRepositoryProvider);
    repo.delete(hid, t.id).catchError((Object _) {});
    showAppToast(context, l.toastEventTypeRemoved, actionLabel: l.toastUndo, onAction: () => repo.save(hid, t).catchError((Object _) {}));
  }

  void _recolor(EventType t, int color) {
    final hid = ref.read(householdIdProvider);
    if (hid == null) return;
    ref
        .read(eventTypesRepositoryProvider)
        .save(hid, EventType(id: t.id, name: t.name, colorIndex: color, order: t.order))
        .catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final types = ref.watch(eventTypesProvider).value ?? const <EventType>[];

    Widget colorPicker(int selected, ValueChanged<int> onPick, {double size = 32}) => Row(
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
        Text(l.eventTypesHint, style: text.labelMedium),
        const SizedBox(height: 12),
        for (final (i, type) in types.indexed) ...[
          if (i > 0) const AppDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: t.chart[type.colorIndex], shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Text(type.name, style: text.bodyLarge)),
                colorPicker(type.colorIndex, (c) => _recolor(type, c), size: 26),
                IconButton(
                  tooltip: l.eventTypeDelete,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: Icon(Icons.delete_outline, color: t.danger),
                  onPressed: () => _delete(type),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        AppTextField(controller: _newName, hint: l.eventTypeNameHint, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.done, onSubmitted: (_) => _add(types)),
        const SizedBox(height: 10),
        colorPicker(_newColor, (c) => setState(() => _newColor = c)),
        if (_error != null) ...[const SizedBox(height: 6), Text(_error!, style: text.labelMedium!.copyWith(color: t.danger))],
        const SizedBox(height: 12),
        PrimaryButton(label: l.eventTypeAdd, onPressed: () => _add(types)),
      ],
    );
  }
}
