import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/util/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../chores/data/chores_repository.dart';
import '../../chores/domain/chore_models.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';
import '../../members/data/members_repository.dart';
import '../../household/ui/home_top_bar.dart';
import '../data/events_repository.dart';
import '../domain/event_models.dart';
import 'event_sheet.dart';

enum _View { month, week }

/// Kalendarz domowy (GUI 5.10, 6): siatka miesiąca lub tygodnia, lista dnia pod spodem.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  _View _view = _View.month;
  DateTime _focused = DateTime.now();
  DateTime _selected = dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final events = ref.watch(allEventsProvider);
    final chores = ref.watch(choreOccurrencesProvider).value ?? const <ChoreOccurrence>[];
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final names = {for (final m in members) m.uid: m.displayName};
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final isAdmin = ref.watch(myRoleProvider) == Role.admin;
    final dayItems = occurrencesOnDay(events, _selected);
    final dayChores = chores.where((c) => c.date == dayKey(_selected)).toList()
      ..sort((a, b) => (a.isDone ? 1 : 0).compareTo(b.isDone ? 1 : 0));
    final now = DateTime.now();

    void toggleChore(ChoreOccurrence o) {
      final hid = ref.read(householdIdProvider);
      if (hid == null) return;
      ref
          .read(choresRepositoryProvider)
          .setStatus(hid: hid, id: o.id, uid: uid, status: o.isDone ? ChoreStatus.todo : ChoreStatus.done)
          .catchError((Object _) {});
    }

    return ScreenScaffold(
      title: l.calendarTitle,
      kicker: l.kickerHome,
      subtitle: l.calendarSubtitle,
      topBar: const HomeTopBar(),
      headerTrailing: SizedBox(
        height: 48,
        child: FilledButton.icon(
          onPressed: () => showEventSheet(context, ref, null, initialDay: _selected),
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: t.onAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon: const Icon(Icons.add, size: 22),
          label: Text(l.eventNew, style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w800, color: t.onAccent)),
        ),
      ),
      children: [
        SegmentedSwitch<_View>(
          options: [SegmentOption(_View.month, l.calendarMonth), SegmentOption(_View.week, l.calendarWeek)],
          value: _view,
          onChanged: (v) => setState(() => _view = v),
        ),
        AppCard(
          child: Column(
            children: [
              TableCalendar<Object>(
                locale: 'pl_PL',
                firstDay: DateTime(now.year - 2, 1, 1),
                lastDay: DateTime(now.year + 3, 12, 31),
                focusedDay: _focused,
                calendarFormat: _view == _View.month ? CalendarFormat.month : CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableGestures: AvailableGestures.horizontalSwipe,
                rowHeight: 48,
                selectedDayPredicate: (d) => isSameDay(d, _selected),
                onDaySelected: (sel, foc) => setState(() {
                  _selected = dateOnly(sel);
                  _focused = foc;
                }),
                onPageChanged: (foc) => _focused = foc,
                eventLoader: (day) => [
                  ...occurrencesOnDay(events, day),
                  ...chores.where((c) => c.date == dayKey(day) && !c.isDone),
                ],
                calendarBuilders: CalendarBuilders<Object>(
                  // Kropka accent = wydarzenie, kropka chart2 = obowiazek; maks. 2 (GUI 5.10).
                  markerBuilder: (context, day, items) {
                    if (items.isEmpty) return null;
                    final firstEvent = items.whereType<EventOccurrence>().firstOrNull;
                    final hasEvent = firstEvent != null;
                    final hasChore = items.any((i) => i is ChoreOccurrence);
                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasEvent) _dot(t.chart[firstEvent.event.colorIndex]),
                          if (hasEvent && hasChore) const SizedBox(width: 3),
                          if (hasChore) _dot(t.chart[1]),
                        ],
                      ),
                    );
                  },
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: text.titleLarge!,
                  leftChevronIcon: Icon(Icons.chevron_left, color: t.text, size: 28),
                  rightChevronIcon: Icon(Icons.chevron_right, color: t.text, size: 28),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: text.labelSmall!.copyWith(color: t.textMuted),
                  weekendStyle: text.labelSmall!.copyWith(color: t.textMuted),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: text.bodyMedium!,
                  weekendTextStyle: text.bodyMedium!,
                  outsideTextStyle: text.bodyMedium!.copyWith(color: t.textMuted.withValues(alpha: 0.5)),
                  todayTextStyle: text.bodyMedium!.copyWith(color: t.onAccent, fontWeight: FontWeight.w800),
                  todayDecoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12)),
                  selectedTextStyle: text.bodyMedium!.copyWith(color: t.text, fontWeight: FontWeight.w800),
                  selectedDecoration: BoxDecoration(
                    color: t.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.accent, width: 2),
                  ),
                  defaultDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  weekendDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  outsideDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  markerDecoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
                  markersMaxCount: 2,
                  markerSize: 6,
                  markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: t.accent, label: l.calendarLegendEvent),
                  const SizedBox(width: 16),
                  _LegendDot(color: t.chart[1], label: l.calendarLegendChore),
                ],
              ),
            ],
          ),
        ),
        Text(formatDayLong(_selected), style: text.titleMedium),
        if (dayChores.isNotEmpty)
          AppCard(
            title: l.navChores,
            child: Column(
              children: [
                for (var i = 0; i < dayChores.length; i++) ...[
                  if (i > 0) const AppDivider(),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 44,
                        decoration: BoxDecoration(color: t.chart[1], borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CheckRow(
                          title: dayChores[i].title,
                          checked: dayChores[i].isDone,
                          meta: dayChores[i].assigneeId == null ? l.choresSomeone : names[dayChores[i].assigneeId],
                          onChanged: dayChores[i].canToggle(uid, isAdmin: isAdmin) ? (_) => toggleChore(dayChores[i]) : (_) {},
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        if (dayItems.isEmpty && dayChores.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                const IllustrationImage(Illustration.bearResting, height: 110),
                const SizedBox(height: 12),
                Text(l.calendarEmptyDay, textAlign: TextAlign.center, style: text.bodyLarge),
              ],
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < dayItems.length; i++) ...[
                  if (i > 0) const AppDivider(),
                  _OccurrenceRow(
                    occurrence: dayItems[i],
                    onTap: () => showEventSheet(context, ref, dayItems[i].event, initialDay: _selected),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

Widget _dot(Color color) =>
    Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      );
}

class _OccurrenceRow extends StatelessWidget {
  const _OccurrenceRow({required this.occurrence, required this.onTap});

  final EventOccurrence occurrence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final e = occurrence.event;
    final when = e.allDay
        ? l.allDayLabel
        : '${formatTime(occurrence.start)}–${formatTime(occurrence.end)}';
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(color: t.chart[e.colorIndex], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, style: text.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    [when, if (e.location.isNotEmpty) e.location, if (e.recurrence != null) l.repeatsLabel].join(' · '),
                    style: text.labelMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(
              label: e.isPrivate ? l.visibilityMe : l.visibilityAll,
              tone: e.isPrivate ? ChipTone.neutral : ChipTone.accent,
              icon: e.isPrivate ? Icons.lock_outline : null,
            ),
          ],
        ),
      ),
    );
  }
}
