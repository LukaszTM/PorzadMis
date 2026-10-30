import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/util/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../calendar/data/events_repository.dart';
import '../../calendar/domain/event_models.dart';
import '../../calendar/ui/event_sheet.dart';
import '../../chores/data/chores_repository.dart';
import '../../chores/domain/chore_models.dart';
import '../../chores/ui/chore_sheet.dart';
import '../../members/data/members_repository.dart';
import '../../notes/ui/notes_screen.dart';
import '../../shopping/data/shopping_repository.dart';
import '../data/household_repository.dart';
import '../domain/household_models.dart';
import 'start_screens.dart';

/// Pulpit: powitanie, karta-bohater z gradientem, kafelki liczb, lista zadań na dziś.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _toggleChore(WidgetRef ref, ChoreOccurrence o) {
    final hid = ref.read(householdIdProvider);
    final uid = ref.read(authStateProvider).value?.uid;
    if (hid == null || uid == null) return;
    ref
        .read(choresRepositoryProvider)
        .setStatus(hid: hid, id: o.id, uid: uid, status: o.isDone ? ChoreStatus.todo : ChoreStatus.done)
        .catchError((Object _) {});
  }

  Future<void> _quickAdd(BuildContext context, WidgetRef ref, {required bool isAdmin}) async {
    final l = AppLocalizations.of(context);
    final choice = await showAppSheet<String>(
      context,
      title: l.quickAddTitle,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (key, icon, label) in [
            ('shopping', AppIcons.shopping, l.quickAddShopping),
            if (isAdmin) ('chore', AppIcons.chores, l.quickAddChore),
            ('event', AppIcons.calendar, l.quickAddEvent),
            ('note', AppIcons.notes, l.quickAddNote),
          ])
            _QuickAddRow(icon: icon, label: label, onTap: () => Navigator.of(sheetContext).pop(key)),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case 'shopping':
        context.go('/shopping');
      case 'chore':
        await showChoreSheet(context, ref, null, initialDay: DateTime.now());
      case 'event':
        await showEventSheet(context, ref, null, initialDay: DateTime.now());
      case 'note':
        await showNoteSheet(context, ref, null);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid ?? '';
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final names = {for (final m in members) m.uid: m.displayName};
    final isAdmin = ref.watch(myRoleProvider) == Role.admin;
    final now = DateTime.now();

    final chores = ref.watch(choreOccurrencesProvider).value ?? const <ChoreOccurrence>[];
    final rules = {for (final r in ref.watch(choreRulesProvider).value ?? const <ChoreRule>[]) r.id: r};
    final myToday = splitForDay(chores, dayKey(now), uid).mine;
    final openToday = myToday.where((o) => !o.isDone).length;
    final toBuy = (ref.watch(shoppingItemsProvider).value ?? const []).where((i) => !i.checked).length;
    final events = ref.watch(allEventsProvider);
    final upcoming =
        occurrencesFor(events, now, now.add(const Duration(days: 7))).where((o) => o.end.isAfter(now)).length;
    final name = displayNameFor(user);

    return Scaffold(
      body: Container(
        // Delikatne tło: od miękkiego akcentu u góry do tła motywu (GUI 1.8).
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.accentSoft, t.background],
            stops: const [0, 0.35],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  AppIcon(AppIcons.today, size: 18, color: t.textMuted),
                  const SizedBox(width: 6),
                  Text('/', style: text.labelMedium),
                  const SizedBox(width: 6),
                  Text(l.homeBreadcrumb, style: text.labelMedium!.copyWith(color: t.text)),
                  const Spacer(),
                  _RoundIconButton(
                    icon: AppIcons.notifications,
                    tooltip: l.settingsTitle,
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(l.homeEyebrow, style: text.labelSmall!.copyWith(color: t.accent, letterSpacing: 1.2)),
              const SizedBox(height: 4),
              Text(name.isEmpty ? l.homeHello : l.homeHelloName(name), style: text.headlineLarge),
              const SizedBox(height: 4),
              Text(l.homeSubtitle(formatDayLong(now).toLowerCase()),
                  style: text.bodyMedium!.copyWith(color: t.textMuted)),
              const SizedBox(height: 18),
              _HeroCard(
                eyebrow: openToday == 0 ? l.heroEyebrowCalm : l.heroEyebrowBusy,
                title: l.heroTitle,
                body: l.heroBody,
                buttonLabel: l.heroAdd,
                onAdd: () => _quickAdd(context, ref, isAdmin: isAdmin),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: AppIcons.chores,
                      color: t.accent,
                      value: '${myToday.length - openToday}/${myToday.length}',
                      label: l.statTasks,
                      onTap: () => context.go('/chores'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      icon: AppIcons.shopping,
                      color: t.chart[1],
                      value: '$toBuy',
                      label: l.statShopping,
                      onTap: () => context.go('/shopping'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      icon: AppIcons.calendar,
                      color: t.chart[2],
                      value: '$upcoming',
                      label: l.statEvents,
                      onTap: () => context.go('/calendar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppCard(
                title: l.todayCardTitle,
                trailing: TertiaryButton(label: '${l.todayCardAll} →', onPressed: () => context.go('/chores')),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.todayCardWaiting(openToday), style: text.labelMedium),
                    const SizedBox(height: 6),
                    if (myToday.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            const MisMark(size: 88, resting: true),
                            const SizedBox(height: 10),
                            Text(l.choresEmptyMine, style: text.bodyMedium, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    for (final (i, o) in myToday.take(5).indexed) ...[
                      if (i > 0) const AppDivider(),
                      CheckRow(
                        title: o.title,
                        checked: o.isDone,
                        meta: [
                          l.dateToday,
                          if (rules[o.ruleId]?.reminderTime != null) rules[o.ruleId]!.reminderTime!,
                          o.assigneeId == null
                              ? l.choresSomeone
                              : (o.assigneeId == uid ? l.youLabel : (names[o.assigneeId] ?? '')),
                        ].join(' · '),
                        onChanged: o.canToggle(uid, isAdmin: isAdmin) ? (_) => _toggleChore(ref, o) : (_) {},
                        trailing: _Avatar(
                          initial: (o.assigneeId == null ? l.choresSomeone : (names[o.assigneeId] ?? '?'))
                              .characters
                              .first
                              .toUpperCase(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                icon: AppIcons.calendar,
                title: l.homeNextEvent,
                onTap: () => context.go('/calendar'),
                child: Builder(builder: (context) {
                  final next = nextOccurrence(events, now);
                  return next == null
                      ? Text(l.homeNoEvents, style: text.bodyLarge)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(next.event.title, style: text.bodyLarge),
                            const SizedBox(height: 4),
                            Text(formatWhen(l, next.start, allDay: next.event.allDay, now: now),
                                style: text.labelMedium),
                          ],
                        );
                }),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 14),
                SecondaryButton(
                  label: l.inviteAction,
                  icon: Icons.qr_code_2,
                  onPressed: () => context.push('/invite'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Karta-bohater: gradient z akcentu do jego ciemniejszej wersji, jasny przycisk, miś w tle.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onAdd,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final hsl = HSLColor.fromColor(t.accent);
    final darker = hsl.withLightness((hsl.lightness * 0.72).clamp(0.0, 1.0)).toColor();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [t.accent, darker]),
        boxShadow: [
          BoxShadow(color: t.accent.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(right: -16, top: -8, child: Opacity(opacity: 0.18, child: MisMark(size: 150))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: text.labelSmall!.copyWith(color: t.onAccent.withValues(alpha: 0.85), letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 72),
                  child: Text(title, style: text.headlineMedium!.copyWith(color: t.onAccent, height: 1.2)),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 72),
                  child: Text(body, style: text.bodyMedium!.copyWith(color: t.onAccent.withValues(alpha: 0.9))),
                ),
                const SizedBox(height: 18),
                Material(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onAdd,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 22, color: t.text),
                          const SizedBox(width: 8),
                          Text(buttonLabel, style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kafelek z liczbą: ikona w kolorowym kwadracie, duża liczba, podpis.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final AppIcons icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Material(
        color: t.surface,
        elevation: 1.5,
        shadowColor: t.text.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: t.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(icon, size: 18, color: color),
                ),
                const SizedBox(height: 12),
                Text(value, style: text.headlineMedium),
                const SizedBox(height: 2),
                Text(label, style: text.labelMedium, maxLines: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(color: t.chart[1].withValues(alpha: 0.18), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initial, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: t.chart[1])),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.tooltip, required this.onTap});

  final AppIcons icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: Material(
        color: t.surface,
        elevation: 1,
        shadowColor: t.text.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(width: 48, height: 48, child: Center(child: AppIcon(icon, size: 22, color: t.text))),
        ),
      ),
    );
  }
}

class _QuickAddRow extends StatelessWidget {
  const _QuickAddRow({required this.icon, required this.label, required this.onTap});

  final AppIcons icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: t.accentSoft, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: AppIcon(icon, size: 20, color: t.accent),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            Icon(Icons.chevron_right, color: t.textMuted),
          ],
        ),
      ),
    );
  }
}
