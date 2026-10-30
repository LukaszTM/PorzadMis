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
import '../data/chores_repository.dart';
import '../domain/chore_models.dart';
import 'chore_sheet.dart';

/// Obowiązki (GUI 6): pasek tygodnia z kropkami, „Moje · dzień”, „Inni domownicy”.
class ChoresScreen extends ConsumerStatefulWidget {
  const ChoresScreen({super.key});

  @override
  ConsumerState<ChoresScreen> createState() => _ChoresScreenState();
}

class _ChoresScreenState extends ConsumerState<ChoresScreen> {
  DateTime _selected = DateTime.now();

  void _toggle(ChoreOccurrence o) {
    final hid = ref.read(householdIdProvider);
    final uid = ref.read(authStateProvider).value?.uid;
    if (hid == null || uid == null) return;
    ref
        .read(choresRepositoryProvider)
        .setStatus(hid: hid, id: o.id, uid: uid, status: o.isDone ? ChoreStatus.todo : ChoreStatus.done)
        .catchError((Object _) {
      if (mounted) showAppToast(context, AppLocalizations.of(context).errGeneric, error: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final isAdmin = ref.watch(myRoleProvider) == Role.admin;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final names = {for (final m in members) m.uid: m.displayName};
    final all = ref.watch(choreOccurrencesProvider).value ?? const <ChoreOccurrence>[];
    final rules = ref.watch(choreRulesProvider).value ?? const <ChoreRule>[];
    final rulesById = {for (final r in rules) r.id: r};
    final day = dayKey(_selected);
    final split = splitForDay(all, day, uid);
    final now = DateTime.now();

    String who(ChoreOccurrence o) => o.assigneeId == null ? l.choresSomeone : (names[o.assigneeId] ?? '');

    Widget row(ChoreOccurrence o, {required bool showWho}) {
      final rule = rulesById[o.ruleId];
      final meta = [
        if (showWho) who(o),
        if (o.isDone && o.doneBy != null && o.doneBy != o.assigneeId) l.choresDoneBy(names[o.doneBy] ?? ''),
      ].join(' · ');
      final can = o.canToggle(uid, isAdmin: isAdmin);
      return CheckRow(
        title: o.title,
        checked: o.isDone,
        meta: meta.isEmpty ? null : meta,
        minHeight: 64,
        onChanged: can ? (_) => _toggle(o) : (_) {},
        onLongPress: isAdmin && rule != null ? () => showChoreSheet(context, ref, rule) : null,
        trailing: isAdmin && rule != null
            ? IconButton(
                tooltip: l.choreEditTitle,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(Icons.edit_outlined, size: 22, color: t.textMuted),
                onPressed: () => showChoreSheet(context, ref, rule),
              )
            : null,
      );
    }

    return ScreenScaffold(
      title: l.choresTitle,
      headerTrailing: isAdmin
          ? SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () => showChoreSheet(context, ref, null, initialDay: _selected),
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: t.onAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                icon: const Icon(Icons.add, size: 22),
                label: Text(l.choreNew, style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w800, color: t.onAccent)),
              ),
            )
          : null,
      children: [
        _WeekStrip(
          selected: _selected,
          now: now,
          openCount: (d) => openCountOn(all, dayKey(d)),
          onSelect: (d) => setState(() => _selected = d),
        ),
        AppCard(
          title: l.choresMine(formatRelativeDay(l, _selected, now)),
          child: split.mine.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      const MisMark(size: 96, resting: true),
                      const SizedBox(height: 12),
                      Text(l.choresEmptyMine, style: text.bodyLarge, textAlign: TextAlign.center),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < split.mine.length; i++) ...[
                      if (i > 0) const AppDivider(),
                      row(split.mine[i], showWho: split.mine[i].assigneeId == null),
                    ],
                  ],
                ),
        ),
        if (members.length > 1)
          AppCard(
            title: l.choresOthers,
            child: split.others.isEmpty
                ? Text(l.choresEmptyOthers, style: text.bodyMedium)
                : Column(
                    children: [
                      for (var i = 0; i < split.others.length; i++) ...[
                        if (i > 0) const AppDivider(),
                        row(split.others[i], showWho: true),
                      ],
                    ],
                  ),
          ),
        if (!isAdmin)
          Text(l.adminOnlyChores, style: text.labelMedium, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Pasek tygodnia: 7 kafelków od poniedziałku, dziś w akcencie, kropka = coś do zrobienia.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.selected,
    required this.now,
    required this.openCount,
    required this.onSelect,
  });

  final DateTime selected;
  final DateTime now;
  final int Function(DateTime) openCount;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final monday = DateTime(selected.year, selected.month, selected.day).subtract(Duration(days: selected.weekday - 1));
    final labels = [l.weekdayMon, l.weekdayTue, l.weekdayWed, l.weekdayThu, l.weekdayFri, l.weekdaySat, l.weekdaySun];
    final today = DateTime(now.year, now.month, now.day);
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Builder(builder: (context) {
              final d = monday.add(Duration(days: i));
              final isToday = d == today;
              final isSelected = d == DateTime(selected.year, selected.month, selected.day);
              final open = openCount(d);
              return Semantics(
                button: true,
                selected: isSelected,
                label: formatDayLong(d),
                excludeSemantics: true,
                child: Material(
                  color: isToday ? t.accent : (isSelected ? t.accentSoft : Colors.transparent),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onSelect(d),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelected && !isToday ? t.accent : Colors.transparent, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(labels[i], style: text.labelSmall!.copyWith(color: isToday ? t.onAccent : t.textMuted)),
                          Text('${d.day}', style: text.bodyLarge!.copyWith(color: isToday ? t.onAccent : t.text)),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: open > 0 ? (isToday ? t.onAccent : t.chart[1]) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}
