import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/util/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';
import '../../members/data/members_repository.dart';
import '../data/chores_repository.dart';
import '../domain/chore_models.dart';

/// Arkusz „Nowy obowiązek” / edycja (GUI 6): nazwa → kto → kiedy → cykl → przypomnienie.
Future<void> showChoreSheet(
  BuildContext context,
  WidgetRef ref,
  ChoreRule? rule, {
  DateTime? initialDay,
}) async {
  final l = AppLocalizations.of(context);
  final hid = ref.read(householdIdProvider);
  final uid = ref.read(authStateProvider).value?.uid;
  if (hid == null || uid == null) return;
  final members = ref.read(membersProvider).value ?? const <Member>[];
  final repo = ref.read(choresRepositoryProvider);

  final draft = rule ??
      ChoreRule(
        id: repo.newId(),
        title: '',
        mode: ChoreMode.once,
        startDate: dayKey(initialDay ?? DateTime.now()),
        assigneeId: uid,
      );

  final result = await showAppSheet<_ChoreResult>(
    context,
    title: rule == null ? l.choreNewTitle : l.choreEditTitle,
    builder: (_) => _ChoreForm(rule: draft, isNew: rule == null, members: members),
  );
  if (result == null || !context.mounted) return;

  if (result.deleted != null) {
    final removed = result.deleted!;
    final ok = await confirmSheet(
      context,
      title: l.choreDelete,
      body: l.choreDeleteBody(removed.title),
      confirmLabel: l.confirmYes,
      cancelLabel: l.back,
      danger: true,
    );
    if (!ok || !context.mounted) return;
    repo.deleteRule(hid, removed.id).catchError((Object _) {});
    showAppToast(
      context,
      l.toastChoreRemoved,
      actionLabel: l.toastUndo,
      onAction: () => repo.saveRule(hid: hid, uid: uid, rule: removed).catchError((Object _) {}),
    );
    return;
  }
  if (result.saved != null) {
    repo.saveRule(hid: hid, uid: uid, rule: result.saved!, isNew: rule == null).catchError((Object _) {});
  }
}

class _ChoreResult {
  const _ChoreResult({this.saved, this.deleted});

  final ChoreRule? saved;
  final ChoreRule? deleted;
}

class _ChoreForm extends StatefulWidget {
  const _ChoreForm({required this.rule, required this.isNew, required this.members});

  final ChoreRule rule;
  final bool isNew;
  final List<Member> members;

  @override
  State<_ChoreForm> createState() => _ChoreFormState();
}

class _ChoreFormState extends State<_ChoreForm> {
  late final _title = TextEditingController(text: widget.rule.title);
  late final _description = TextEditingController(text: widget.rule.description);
  late final _interval = TextEditingController(text: '${widget.rule.recurrence?.interval ?? 1}');
  late final _monthDay = TextEditingController(
    text: '${widget.rule.recurrence?.monthDay ?? parseDayKey(widget.rule.startDate).day}',
  );
  late String? _assignee = widget.rule.assigneeId;
  late ChoreMode _mode = widget.rule.mode;
  late DateTime _start = parseDayKey(widget.rule.startDate);
  late ChoreRecurrenceType _type = widget.rule.recurrence?.type ?? ChoreRecurrenceType.weekly;
  late final Set<int> _weekdays = (widget.rule.recurrence?.weekdays ?? const []).toSet();
  late final Set<String> _dates = (widget.rule.recurrence?.dates ?? const []).toSet();
  late DateTime? _until = widget.rule.recurrence?.until == null ? null : parseDayKey(widget.rule.recurrence!.until!);
  late String? _reminder = widget.rule.reminderTime;
  DateTime _calendarFocus = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _interval.dispose();
    _monthDay.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 3, 12, 31),
        locale: const Locale('pl'),
      );

  void _save() {
    final l = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) {
      setState(() => _error = l.errChoreTitle);
      return;
    }
    ChoreRecurrence? recurrence;
    if (_mode == ChoreMode.recurring) {
      final interval = int.tryParse(_interval.text.trim()) ?? 0;
      if (_type != ChoreRecurrenceType.customDates && interval < 1) {
        setState(() => _error = l.errChoreInterval);
        return;
      }
      if (_type == ChoreRecurrenceType.weekly && _weekdays.isEmpty) {
        setState(() => _error = l.errChoreWeekdays);
        return;
      }
      if (_type == ChoreRecurrenceType.customDates && _dates.isEmpty) {
        setState(() => _error = l.errChoreDates);
        return;
      }
      final monthDay = (int.tryParse(_monthDay.text.trim()) ?? _start.day).clamp(1, 31);
      recurrence = ChoreRecurrence(
        type: _type,
        interval: _type == ChoreRecurrenceType.customDates ? 1 : interval,
        weekdays: (_weekdays.toList()..sort()),
        monthDay: monthDay,
        dates: (_dates.toList()..sort()),
        until: _until == null ? null : dayKey(_until!),
      );
    }
    final startDate = _type == ChoreRecurrenceType.customDates && _mode == ChoreMode.recurring && _dates.isNotEmpty
        ? (_dates.toList()..sort()).first
        : dayKey(_start);
    Navigator.of(context).pop(_ChoreResult(
      saved: ChoreRule(
        id: widget.rule.id,
        title: _title.text,
        description: _description.text,
        assigneeId: _assignee,
        mode: _mode,
        startDate: startDate,
        recurrence: recurrence,
        reminderTime: _reminder,
        createdBy: widget.rule.createdBy,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    Widget label(String s) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(s, style: text.labelMedium),
        );

    Widget pickRow(String name, String value, VoidCallback onTap) => Row(
          children: [
            Expanded(child: Text(name, style: text.bodyMedium)),
            TertiaryButton(label: value, onPressed: onTap),
          ],
        );

    final weekdayLabels = [l.weekdayMon, l.weekdayTue, l.weekdayWed, l.weekdayThu, l.weekdayFri, l.weekdaySat, l.weekdaySun];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _title,
          hint: l.choreTitleHint,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
        ),
        label(l.choreDescriptionLabel),
        AppTextField(controller: _description, keyboardType: TextInputType.multiline, minLines: 1, maxLines: 4),
        label(l.choreWhoLabel),
        ChoiceChips<String?>(
          options: [
            ChoiceOption(null, l.choresSomeone),
            for (final m in widget.members) ChoiceOption(m.uid, m.displayName),
          ],
          selected: {_assignee},
          onToggle: (v) => setState(() => _assignee = v),
        ),
        label(l.choreWhenLabel),
        SegmentedSwitch<ChoreMode>(
          options: [SegmentOption(ChoreMode.once, l.choreOnce), SegmentOption(ChoreMode.recurring, l.choreRecurring)],
          value: _mode,
          onChanged: (v) => setState(() => _mode = v),
        ),
        const SizedBox(height: 8),
        if (_mode == ChoreMode.once)
          pickRow(l.choreDay, formatDayShort(_start), () async {
            final d = await _pickDate(_start);
            if (d != null) setState(() => _start = d);
          })
        else ...[
          label(l.choreCycleLabel),
          ChoiceChips<ChoreRecurrenceType>(
            options: [
              ChoiceOption(ChoreRecurrenceType.daily, l.cycleDaily),
              ChoiceOption(ChoreRecurrenceType.weekly, l.cycleWeekly),
              ChoiceOption(ChoreRecurrenceType.monthly, l.cycleMonthly),
              ChoiceOption(ChoreRecurrenceType.customDates, l.cycleCustom),
            ],
            selected: {_type},
            onToggle: (v) => setState(() => _type = v),
          ),
          const SizedBox(height: 8),
          if (_type != ChoreRecurrenceType.customDates) ...[
            pickRow(l.choreFirstDay, formatDayShort(_start), () async {
              final d = await _pickDate(_start);
              if (d != null) setState(() => _start = d);
            }),
            AppTextField(
              controller: _interval,
              label: switch (_type) {
                ChoreRecurrenceType.daily => l.choreIntervalDays,
                ChoreRecurrenceType.weekly => l.choreIntervalWeeks,
                _ => l.choreIntervalMonths,
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
            ),
          ],
          if (_type == ChoreRecurrenceType.weekly) ...[
            label(l.choreWeekdaysLabel),
            ChoiceChips<int>(
              options: [for (var i = 1; i <= 7; i++) ChoiceOption(i, weekdayLabels[i - 1])],
              selected: _weekdays,
              onToggle: (d) => setState(() {
                if (!_weekdays.remove(d)) _weekdays.add(d);
              }),
            ),
          ],
          if (_type == ChoreRecurrenceType.monthly) ...[
            const SizedBox(height: 12),
            AppTextField(
              controller: _monthDay,
              label: l.choreMonthDay,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
            ),
          ],
          if (_type == ChoreRecurrenceType.customDates) ...[
            label(l.chorePickDates),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: t.border),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(6),
              child: TableCalendar<void>(
                locale: 'pl_PL',
                firstDay: DateTime(DateTime.now().year - 1),
                lastDay: DateTime(DateTime.now().year + 3, 12, 31),
                focusedDay: _calendarFocus,
                startingDayOfWeek: StartingDayOfWeek.monday,
                rowHeight: 44,
                availableGestures: AvailableGestures.horizontalSwipe,
                selectedDayPredicate: (d) => _dates.contains(dayKey(d)),
                onDaySelected: (d, foc) => setState(() {
                  final k = dayKey(d);
                  if (!_dates.remove(k)) _dates.add(k);
                  _calendarFocus = foc;
                }),
                onPageChanged: (foc) => _calendarFocus = foc,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: text.bodyLarge!,
                  leftChevronIcon: Icon(Icons.chevron_left, color: t.text),
                  rightChevronIcon: Icon(Icons.chevron_right, color: t.text),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: text.labelSmall!.copyWith(color: t.textMuted),
                  weekendStyle: text.labelSmall!.copyWith(color: t.textMuted),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: text.bodyMedium!,
                  weekendTextStyle: text.bodyMedium!,
                  outsideTextStyle: text.bodyMedium!.copyWith(color: t.textMuted.withValues(alpha: 0.5)),
                  todayTextStyle: text.bodyMedium!.copyWith(fontWeight: FontWeight.w800),
                  todayDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.textMuted),
                  ),
                  selectedTextStyle: text.bodyMedium!.copyWith(color: t.text, fontWeight: FontWeight.w800),
                  selectedDecoration: BoxDecoration(
                    color: t.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.accent, width: 2),
                  ),
                  defaultDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  weekendDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  outsideDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(l.choreDatesCount(_dates.length), style: text.labelMedium),
          ],
          label(l.choreUntilLabel),
          Row(
            children: [
              Expanded(
                child: ChoiceChips<bool>(
                  options: [ChoiceOption(false, l.choreUntilNone), ChoiceOption(true, _until == null ? l.choreUntilPick : formatDayShort(_until!))],
                  selected: {_until != null},
                  onToggle: (v) async {
                    if (!v) {
                      setState(() => _until = null);
                      return;
                    }
                    final d = await _pickDate(_until ?? _start.add(const Duration(days: 90)));
                    if (d != null) setState(() => _until = d);
                  },
                ),
              ),
            ],
          ),
        ],
        label(l.choreReminderLabel),
        ChoiceChips<String?>(
          options: [
            ChoiceOption(null, l.choreReminderNone),
            const ChoiceOption('07:00', '07:00'),
            const ChoiceOption('08:00', '08:00'),
            const ChoiceOption('18:00', '18:00'),
          ],
          selected: {_reminder},
          onToggle: (v) => setState(() => _reminder = v),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: text.labelMedium!.copyWith(color: t.danger)),
        ],
        if (!widget.isNew) ...[
          const SizedBox(height: 8),
          Text(l.ruleEditHint, style: text.labelMedium),
        ],
        const SizedBox(height: 20),
        PrimaryButton(label: l.itemDone, onPressed: _save),
        if (!widget.isNew) ...[
          const SizedBox(height: 4),
          TertiaryButton(
            label: l.choreDelete,
            danger: true,
            onPressed: () => Navigator.of(context).pop(_ChoreResult(deleted: widget.rule)),
          ),
        ],
      ],
    );
  }
}
