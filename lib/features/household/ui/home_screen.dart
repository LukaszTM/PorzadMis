import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../members/data/members_repository.dart';
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
    final text = Theme.of(context).textTheme;

    return ScreenScaffold(
      title: l.homeGreeting(displayNameFor(user)),
      bottom: isAdmin
          ? PrimaryButton(label: l.inviteAction, onPressed: () => context.push('/invite'))
          : null,
      children: [
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
