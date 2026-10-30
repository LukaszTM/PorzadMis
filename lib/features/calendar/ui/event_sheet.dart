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
import '../data/events_repository.dart';
import '../domain/event_models.dart';

/// Arkusz tworzenia / edycji wydarzenia (GUI 5.9). Zapis bez czekania na serwer.
Future<void> showEventSheet(
  BuildContext context,
  WidgetRef ref,
  CalendarEvent? event, {
  required DateTime initialDay,
}) async {
  final l = AppLocalizations.of(context);
  final hid = ref.read(householdIdProvider);
  final uid = ref.read(authStateProvider).value?.uid;
  if (hid == null || uid == null) return;
  final isAdmin = ref.read(myRoleProvider) == Role.admin;
  final members = ref.read(membersProvider).value ?? const <Member>[];
  final readOnly = event != null && !event.isPrivate && event.createdBy != uid && !isAdmin;
  final repo = ref.read(eventsRepositoryProvider);

  final start = DateTime(initialDay.year, initialDay.month, initialDay.day, 9);
  final draft = event ??
      CalendarEvent(
        id: repo.newId(),
        title: '',
        start: start,
        end: start.add(const Duration(hours: 1)),
        allDay: false,
        isPrivate: false,
        participants: [uid],
      );

  final result = await showAppSheet<_EventResult>(
    context,
    title: event == null ? l.eventNewTitle : l.eventEditTitle,
    builder: (_) => _EventForm(event: draft, isNew: event == null, readOnly: readOnly, members: members),
  );
  if (result == null || !context.mounted) return;

  if (result.deleted != null) {
    final removed = result.deleted!;
    repo.delete(hid: hid, uid: uid, event: removed).catchError((Object _) {});
    showAppToast(
      context,
      l.toastEventRemoved,
      actionLabel: l.toastUndo,
      onAction: () => repo.restore(hid: hid, uid: uid, event: removed).catchError((Object _) {}),
    );
    return;
  }
  if (result.saved != null) {
    repo.save(hid: hid, uid: uid, event: result.saved!, previous: event).catchError((Object _) {});
  }
}

class _EventResult {
  const _EventResult({this.saved, this.deleted});

  final CalendarEvent? saved;
  final CalendarEvent? deleted;
}

class _EventForm extends StatefulWidget {
  const _EventForm({required this.event, required this.isNew, required this.readOnly, required this.members});

  final CalendarEvent event;
  final bool isNew;
  final bool readOnly;
  final List<Member> members;

  @override
  State<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  late final _title = TextEditingController(text: widget.event.title);
  late final _location = TextEditingController(text: widget.event.location);
  late final _description = TextEditingController(text: widget.event.description);
  late bool _allDay = widget.event.allDay;
  late DateTime _start = widget.event.start;
  // Dla całodziennych trzymamy w formularzu ostatni dzień (włącznie), w modelu koniec wyłączny.
  late DateTime _end = widget.event.allDay
      ? widget.event.end.subtract(const Duration(days: 1))
      : widget.event.end;
  late bool _private = widget.event.isPrivate;
  late RecurrenceType? _repeat = widget.event.recurrence?.type;
  late int? _reminder = widget.event.reminderMinutes;
  late final Set<String> _participants = widget.event.participants.toSet();
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(DateTime.now().year - 2),
        lastDate: DateTime(DateTime.now().year + 3, 12, 31),
        locale: const Locale('pl'),
      );

  Future<TimeOfDay?> _pickTime(DateTime initial) => showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      );

  Future<void> _changeStartDate() async {
    final d = await _pickDate(_start);
    if (d == null) return;
    setState(() {
      final duration = _end.difference(_start);
      _start = DateTime(d.year, d.month, d.day, _start.hour, _start.minute);
      _end = _start.add(duration);
    });
  }

  Future<void> _changeEndDate() async {
    final d = await _pickDate(_end);
    if (d == null) return;
    setState(() => _end = DateTime(d.year, d.month, d.day, _end.hour, _end.minute));
  }

  Future<void> _changeStartTime() async {
    final tod = await _pickTime(_start);
    if (tod == null) return;
    setState(() {
      final duration = _end.difference(_start);
      _start = DateTime(_start.year, _start.month, _start.day, tod.hour, tod.minute);
      _end = _start.add(duration);
    });
  }

  Future<void> _changeEndTime() async {
    final tod = await _pickTime(_end);
    if (tod == null) return;
    setState(() => _end = DateTime(_end.year, _end.month, _end.day, tod.hour, tod.minute));
  }

  void _save() {
    final l = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) {
      setState(() => _error = l.errEventTitle);
      return;
    }
    final DateTime start;
    final DateTime end;
    if (_allDay) {
      start = dateOnly(_start);
      end = dateOnly(_end).add(const Duration(days: 1));
    } else {
      start = _start;
      end = _end;
    }
    if (!end.isAfter(start)) {
      setState(() => _error = l.errEventEnd);
      return;
    }
    final saved = widget.event.copyWith(
      title: _title.text,
      start: start,
      end: end,
      allDay: _allDay,
      isPrivate: _private,
      location: _location.text,
      description: _description.text,
      participants: _private ? const [] : _participants.toList(),
      reminderMinutes: _reminder,
      clearReminder: _reminder == null,
      recurrence: _repeat == null ? null : Recurrence(type: _repeat!),
      clearRecurrence: _repeat == null,
    );
    Navigator.of(context).pop(_EventResult(saved: saved));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final ro = widget.readOnly;
    final showParticipants = !_private && widget.members.length > 1;

    Widget label(String s) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(s, style: text.labelMedium),
        );

    Widget pickRow(String name, String value, VoidCallback onTap) => Row(
          children: [
            Expanded(child: Text(name, style: text.bodyMedium)),
            TertiaryButton(label: value, onPressed: ro ? null : onTap),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ro) ...[
          StatusChip(label: l.readOnlyEvent, tone: ChipTone.neutral, icon: Icons.lock_outline),
          const SizedBox(height: 12),
        ],
        AppTextField(
          controller: _title,
          hint: l.eventTitleHint,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          readOnly: ro,
        ),
        const SizedBox(height: 12),
        SegmentedSwitch<bool>(
          options: [SegmentOption(false, l.eventTimed), SegmentOption(true, l.eventAllDay)],
          value: _allDay,
          onChanged: ro ? (_) {} : (v) => setState(() => _allDay = v),
        ),
        const SizedBox(height: 8),
        if (_allDay) ...[
          pickRow(l.eventDateLabel, formatDayShort(_start), _changeStartDate),
          pickRow(l.eventEndDateLabel, formatDayShort(_end), _changeEndDate),
        ] else ...[
          pickRow(l.eventDateLabel, formatDayShort(_start), _changeStartDate),
          pickRow(l.eventStartLabel, formatTime(_start), _changeStartTime),
          pickRow(l.eventEndLabel, formatTime(_end), _changeEndTime),
        ],
        if (_error != null) Text(_error!, style: text.labelMedium!.copyWith(color: t.danger)),
        label(l.eventLocationLabel),
        AppTextField(controller: _location, hint: l.eventLocationHint, textCapitalization: TextCapitalization.sentences, readOnly: ro),
        label(l.eventDescriptionLabel),
        AppTextField(controller: _description, keyboardType: TextInputType.multiline, minLines: 2, maxLines: 5, readOnly: ro),
        if (!ro) ...[
          label(l.eventRepeatLabel),
          ChoiceChips<RecurrenceType?>(
            options: [
              ChoiceOption(null, l.repeatNone),
              ChoiceOption(RecurrenceType.weekly, l.repeatWeekly),
              ChoiceOption(RecurrenceType.monthly, l.repeatMonthly),
              ChoiceOption(RecurrenceType.yearly, l.repeatYearly),
            ],
            selected: {_repeat},
            onToggle: (v) => setState(() => _repeat = v),
          ),
          label(l.eventReminderLabel),
          ChoiceChips<int?>(
            options: [
              ChoiceOption(null, l.reminderNone),
              ChoiceOption(0, l.reminderAtTime),
              ChoiceOption(60, l.reminderHour),
              ChoiceOption(1440, l.reminderDay),
            ],
            selected: {_reminder},
            onToggle: (v) => setState(() => _reminder = v),
          ),
          label(l.noteVisibilityLabel),
          SegmentedSwitch<bool>(
            options: [SegmentOption(false, l.visibilityAll), SegmentOption(true, l.visibilityMe)],
            value: _private,
            onChanged: (v) => setState(() => _private = v),
          ),
          if (showParticipants) ...[
            label(l.eventParticipantsLabel),
            ChoiceChips<String>(
              options: [for (final m in widget.members) ChoiceOption(m.uid, m.displayName)],
              selected: _participants,
              onToggle: (uid) => setState(() {
                if (!_participants.remove(uid)) _participants.add(uid);
              }),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(label: l.itemDone, onPressed: _save),
          if (!widget.isNew) ...[
            const SizedBox(height: 4),
            TertiaryButton(
              label: l.eventDelete,
              danger: true,
              onPressed: () => Navigator.of(context).pop(_EventResult(deleted: widget.event)),
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
