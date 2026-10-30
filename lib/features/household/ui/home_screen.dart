import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/ui.dart';
import '../../../core/util/dates.dart';
import '../../calendar/data/events_repository.dart';
import '../../calendar/domain/event_models.dart';
import '../../notes/data/notes_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../members/data/members_repository.dart';
import '../../shopping/data/shopping_repository.dart';
import '../data/household_repository.dart';
import '../domain/household_models.dart';
import 'start_screens.dart';

/// Ekran domu po zalogowaniu. Pasek dolny i „Dziś” dojdą w kolejnych etapach.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    final household = ref.watch(householdProvider).value;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final isAdmin = ref.watch(myRoleProvider) == Role.admin;
    final toBuy = (ref.watch(shoppingItemsProvider).value ?? const []).where((i) => !i.checked).length;
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();
    final next = nextOccurrence(ref.watch(allEventsProvider), now);
    final notesCount = ref.watch(allNotesProvider).length;

    return ScreenScaffold(
      title: l.homeGreeting(displayNameFor(user)),
      bottom: isAdmin
          ? PrimaryButton(label: l.inviteAction, onPressed: () => context.push('/invite'))
          : null,
      children: [
        Text(formatDayLong(now), style: text.titleMedium),
        AppCard(
          title: l.homeNextEvent,
          onTap: () => context.go('/calendar'),
          child: next == null
              ? Text(l.homeNoEvents, style: text.bodyLarge)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(next.event.title, style: text.bodyLarge),
                    const SizedBox(height: 4),
                    Text(
                      formatWhen(l, next.start, allDay: next.event.allDay, now: now),
                      style: text.labelMedium,
                    ),
                  ],
                ),
        ),
        AppCard(
          title: l.homeHouseholdCard,
          onTap: () => context.push('/members'),
          semanticsLabel: l.membersTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(household?.name ?? '', style: text.bodyLarge),
              const SizedBox(height: 4),
              Text(l.membersCount(members.length), style: text.labelMedium),
            ],
          ),
        ),
        AppCard(
          title: l.shoppingCardTitle,
          onTap: () => context.go('/shopping'),
          child: Text(
            toBuy == 0 ? l.shoppingCardNone : l.shoppingCardCount(toBuy),
            style: text.bodyLarge,
          ),
        ),
        AppCard(
          title: l.homeNotesCard,
          onTap: () => context.go('/notes'),
          child: Text(l.homeNotesCount(notesCount), style: text.bodyLarge),
        ),
        TertiaryButton(
          label: l.signOut,
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
        ),
        TertiaryButton(
          label: l.leaveAction,
          danger: true,
          onPressed: () => _leave(context, ref, household?.name ?? '', members.length),
        ),
      ],
    );
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, String name, int memberCount) async {
    final l = AppLocalizations.of(context);
    final hid = ref.read(householdIdProvider);
    if (hid == null) return;
    final ok = await confirmSheet(
      context,
      title: l.confirmLeaveTitle,
      body: memberCount <= 1 ? l.confirmLeaveSoloBody(name) : l.confirmLeaveBody,
      confirmLabel: l.confirmYes,
      cancelLabel: l.back,
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(membersRepositoryProvider).leave(hid: hid);
      // Profil bez householdId przyjdzie strumieniem i router przeniesie na ekran startowy.
    } catch (e) {
      if (context.mounted) showAppToast(context, callableMessage(e) ?? l.errGeneric, error: true);
    }
  }
}
