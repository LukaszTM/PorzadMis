import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/util/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';
import '../../members/data/members_repository.dart';
import '../data/notes_repository.dart';
import '../domain/note_models.dart';

/// Notatnik (GUI 6): przełącznik Wszystkie / Wspólne / Tylko moje, szukanie, lista kart.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  NotesFilter _filter = NotesFilter.all;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final uid = ref.watch(authStateProvider).value?.uid;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final names = {for (final m in members) m.uid: m.displayName};
    final all = ref.watch(allNotesProvider);
    final notes = filterNotes(all, filter: _filter, query: _search.text);
    final now = DateTime.now();

    return ScreenScaffold(
      title: l.notesTitle,
      headerTrailing: _HeaderButton(
        label: l.noteNew,
        onPressed: () => showNoteSheet(context, ref, null),
      ),
      children: [
        SegmentedSwitch<NotesFilter>(
          options: [
            SegmentOption(NotesFilter.all, l.notesFilterAll),
            SegmentOption(NotesFilter.shared, l.notesFilterShared),
            SegmentOption(NotesFilter.mine, l.notesFilterMine),
          ],
          value: _filter,
          onChanged: (v) => setState(() => _filter = v),
        ),
        AppTextField(controller: _search, hint: l.notesSearchHint, textInputAction: TextInputAction.search),
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const MisMark(size: 96, resting: true),
                const SizedBox(height: 16),
                Text(
                  all.isEmpty ? l.notesEmpty : l.notesNoResults,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge,
                ),
              ],
            ),
          ),
        for (final n in notes)
          AppCard(
            onTap: () => showNoteSheet(context, ref, n),
            semanticsLabel: n.displayTitle,
            backgroundColor: n.isPrivate ? t.background : null,
            borderColor: n.pinned ? t.accent : null,
            borderWidth: n.pinned ? 2 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (n.pinned) ...[
                      Icon(Icons.push_pin, size: 18, color: t.accent),
                      const SizedBox(width: 6),
                    ],
                    Expanded(child: Text(n.displayTitle, style: text.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: n.isPrivate ? l.visibilityMe : l.visibilityAll,
                      tone: n.isPrivate ? ChipTone.neutral : ChipTone.accent,
                      icon: n.isPrivate ? Icons.lock_outline : null,
                    ),
                  ],
                ),
                if (n.body.trim().isNotEmpty && n.title.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(n.body.trim(), style: text.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 8),
                Text(
                  l.noteMeta(
                    n.isPrivate ? (names[uid] ?? '') : (names[n.createdBy] ?? ''),
                    formatRelativeDay(l, n.updatedAt, now),
                  ),
                  style: text.labelMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Przycisk w nagłówku ekranu (GUI 5.4: 48 dp, skrót „Nowy / Dodaj”).
class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: t.onAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: const Icon(Icons.add, size: 22),
        label: Text(label, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w800, color: t.onAccent)),
      ),
    );
  }
}

/// Arkusz tworzenia / edycji notatki. Cudzej wspólnej notatki Domownik nie edytuje (GUI, PLAN).
Future<void> showNoteSheet(BuildContext context, WidgetRef ref, Note? note) async {
  final l = AppLocalizations.of(context);
  final hid = ref.read(householdIdProvider);
  final uid = ref.read(authStateProvider).value?.uid;
  if (hid == null || uid == null) return;
  final isAdmin = ref.read(myRoleProvider) == Role.admin;
  final readOnly = note != null && !note.isPrivate && note.createdBy != uid && !isAdmin;
  final repo = ref.read(notesRepositoryProvider);

  final result = await showAppSheet<_NoteResult>(
    context,
    title: note == null ? l.noteNewTitle : l.noteEditTitle,
    builder: (_) => _NoteForm(
      note: note ?? Note(id: repo.newId(), title: '', body: '', pinned: false, updatedAt: DateTime.now(), isPrivate: false),
      isNew: note == null,
      readOnly: readOnly,
    ),
  );
  if (result == null || !context.mounted) return;

  if (result.deleted != null) {
    final removed = result.deleted!;
    repo.delete(hid: hid, uid: uid, note: removed).catchError((Object _) {});
    showAppToast(
      context,
      l.toastNoteRemoved,
      actionLabel: l.toastUndo,
      onAction: () => repo.restore(hid: hid, uid: uid, note: removed).catchError((Object _) {}),
    );
    return;
  }
  if (result.saved != null) {
    repo.save(hid: hid, uid: uid, note: result.saved!, previous: note).catchError((Object _) {});
  }
}

class _NoteResult {
  const _NoteResult({this.saved, this.deleted});

  final Note? saved;
  final Note? deleted;
}

class _NoteForm extends StatefulWidget {
  const _NoteForm({required this.note, required this.isNew, required this.readOnly});

  final Note note;
  final bool isNew;
  final bool readOnly;

  @override
  State<_NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<_NoteForm> {
  late final _title = TextEditingController(text: widget.note.title);
  late final _body = TextEditingController(text: widget.note.body);
  late bool _private = widget.note.isPrivate;
  late bool _pinned = widget.note.pinned;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    final l = AppLocalizations.of(context);
    final note = widget.note.copyWith(
      title: _title.text,
      body: _body.text,
      pinned: _pinned,
      isPrivate: _private,
    );
    if (note.isEmpty) {
      setState(() => _error = l.errNoteEmpty);
      return;
    }
    Navigator.of(context).pop(_NoteResult(saved: note));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final ro = widget.readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ro) ...[
          StatusChip(label: l.readOnlyNote, tone: ChipTone.neutral, icon: Icons.lock_outline),
          const SizedBox(height: 12),
        ],
        AppTextField(
          controller: _title,
          hint: l.noteTitleHint,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          readOnly: ro,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _body,
          hint: l.noteBodyHint,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          minLines: 5,
          maxLines: 12,
          readOnly: ro,
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(_error!, style: text.labelMedium!.copyWith(color: t.danger)),
        ],
        if (!ro) ...[
          const SizedBox(height: 14),
          Text(l.noteVisibilityLabel, style: text.labelMedium),
          const SizedBox(height: 8),
          SegmentedSwitch<bool>(
            options: [SegmentOption(false, l.visibilityAll), SegmentOption(true, l.visibilityMe)],
            value: _private,
            onChanged: (v) => setState(() => _private = v),
          ),
          const SizedBox(height: 12),
          ChoiceChips<bool>(
            options: [ChoiceOption(true, _pinned ? l.noteUnpin : l.notePin, icon: Icons.push_pin_outlined)],
            selected: {if (_pinned) true},
            onToggle: (_) => setState(() => _pinned = !_pinned),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: l.noteSave, onPressed: _save),
          if (!widget.isNew) ...[
            const SizedBox(height: 4),
            TertiaryButton(
              label: l.noteDelete,
              danger: true,
              onPressed: () => Navigator.of(context).pop(_NoteResult(deleted: widget.note)),
            ),
          ],
        ] else ...[
          const SizedBox(height: 20),
          PrimaryButton(label: l.back, onPressed: () => Navigator.of(context).pop()),
        ],
      ],
    );
  }
}
