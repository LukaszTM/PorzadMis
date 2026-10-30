import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/util/dates.dart';
import '../../../core/util/emoji.dart';
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
import 'home_top_bar.dart';
import 'start_screens.dart';

/// Pulpit (makieta 2026): jasna karta-bohater z misiem, „Dziś do zrobienia” z paskiem postępu,
/// kafelki kalendarza i zakupów, szybkie akcje.
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
    final done = myToday.where((o) => o.isDone).length;
    final toBuy = (ref.watch(shoppingItemsProvider).value ?? const []).where((i) => !i.checked).length;
    final events = ref.watch(allEventsProvider);
    final next = nextOccurrence(events, now);
    final memberName = members.where((m) => m.uid == uid).map((m) => m.displayName).firstOrNull;
    final name = (memberName != null && memberName.isNotEmpty) ? memberName : displayNameFor(user);
    final progress = myToday.isEmpty ? 0.0 : done / myToday.length;

    return ScreenScaffold(
      title: '',
      topBar: const HomeTopBar(),
      children: [
        // Karta-bohater: jasny gradient z akcentu do powierzchni, miś z domkiem po prawej.
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: t.border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.alphaBlend(t.accent.withValues(alpha: 0.11), t.surface), t.surface],
              stops: const [0, 0.81],
            ),
            boxShadow: [BoxShadow(color: t.text.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatDayLong(now).toLowerCase(), style: text.labelMedium!.copyWith(color: t.accent)),
                    const SizedBox(height: 6),
                    Text(name.isEmpty ? l.homeHello : l.homeHelloName(name), style: text.headlineMedium),
                    const SizedBox(height: 6),
                    Text(
                      myToday.length - done == 0 ? l.homeHeroSubtitleCalm : l.homeHeroSubtitleBusy,
                      style: text.bodyMedium!.copyWith(color: t.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IllustrationImage(myToday.length - done == 0 ? Illustration.bearResting : Illustration.bearHouse, height: 112),
            ],
          ),
        ),
        AppCard(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.homeTodayCard, style: text.titleLarge),
                                const SizedBox(height: 2),
                                Text(l.todayCardSubtitle(done, myToday.length), style: text.labelMedium),
                              ],
                            ),
                          ),
                          StatusChip(label: '$done/${myToday.length}', tone: ChipTone.accent),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: SizedBox(
                          height: 8,
                          child: Stack(
                            children: [
                              Container(color: t.accentSoft),
                              FractionallySizedBox(widthFactor: progress, child: Container(color: t.accent)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (myToday.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              const IllustrationImage(Illustration.bearResting, height: 64),
                              const SizedBox(width: 12),
                              Expanded(child: Text(l.choresEmptyMine, style: text.bodyMedium)),
                            ],
                          ),
                        ),
                      for (final (i, o) in myToday.take(5).indexed) ...[
                        if (i > 0) const AppDivider(),
                        CheckRow(
                          title: o.title,
                          checked: o.isDone,
                          leading: Text(emojiFor(o.title, fallback: emojiChore), style: const TextStyle(fontSize: 22)),
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
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TertiaryButton(label: '${l.todayShowAll}  →', onPressed: () => context.go('/chores')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Tile(
                tint: t.chart[2],
                illustration: Illustration.dates,
                onTap: () => context.go('/calendar'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.homeNextEvent, style: text.bodyLarge),
                    const SizedBox(height: 8),
                    if (next == null)
                      Text(l.homeNoEvents, style: text.bodyMedium)
                    else ...[
                      Text(next.event.title, style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (next.event.isPrivate) ...[Icon(Icons.lock_outline, size: 14, color: t.textMuted), const SizedBox(width: 4)],
                          Expanded(child: Text(formatWhen(l, next.start, allDay: next.event.allDay, now: now), style: text.labelMedium, maxLines: 2)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Tile(
                tint: t.chart[1],
                illustration: Illustration.shopping,
                onTap: () => context.go('/shopping'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.shoppingCardTitle, style: text.bodyLarge),
                    const SizedBox(height: 4),
                    Text('$toBuy', style: text.headlineLarge!.copyWith(fontSize: 34, color: t.accent)),
                    Text(toBuy == 0 ? l.shoppingCardNone : l.shoppingTileCount(toBuy), style: text.labelMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
        Text(l.quickActionsTitle.toUpperCase(), style: text.labelSmall!.copyWith(color: t.textMuted, letterSpacing: 0.8)),
        Row(
          children: [
            Expanded(child: _QuickCard(illustration: Illustration.list, label: l.quickShopping, onTap: () => context.go('/shopping'))),
            const SizedBox(width: 9),
            Expanded(
              child: isAdmin
                  ? _QuickCard(illustration: Illustration.chores, label: l.quickChore, onTap: () => showChoreSheet(context, ref, null, initialDay: now))
                  : _QuickCard(illustration: Illustration.notebook, label: l.quickNote, onTap: () => showNoteSheet(context, ref, null)),
            ),
            const SizedBox(width: 9),
            Expanded(child: _QuickCard(illustration: Illustration.dates, label: l.quickEvent, onTap: () => showEventSheet(context, ref, null, initialDay: now))),
          ],
        ),
        if (isAdmin) SecondaryButton(label: l.inviteAction, icon: Icons.qr_code_2, onPressed: () => context.push('/invite')),
      ],
    );
  }
}

/// Kafelek z delikatnie zabarwionym tłem (makieta: pastel dopasowany do modułu).
class _Tile extends StatelessWidget {
  const _Tile({required this.tint, required this.illustration, required this.onTap, required this.child});

  final Color tint;
  final Illustration illustration;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Color.alphaBlend(tint.withValues(alpha: 0.12), t.surface),
      elevation: 1.5,
      shadowColor: t.text.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: t.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IllustrationImage(illustration, height: 44),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.illustration, required this.label, required this.onTap});

  final Illustration illustration;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: t.surface,
        elevation: 1,
        shadowColor: t.text.withValues(alpha: 0.14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: t.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
            child: Column(
              children: [
                IllustrationImage(illustration, height: 40),
                const SizedBox(height: 8),
                Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: t.text), textAlign: TextAlign.center, maxLines: 2),
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
      decoration: BoxDecoration(color: t.accentSoft, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initial, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: t.accent)),
    );
  }
}
