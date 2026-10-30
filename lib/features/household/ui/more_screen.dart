import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import 'home_top_bar.dart';

/// Piąta zakładka Administratora (GUI 5.1): Notatki, Budżet, Domownicy, Zaproś.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    Widget row(AppIcons icon, String label, VoidCallback onTap, {String? badge}) => InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Row(
              children: [
                AppIcon(icon, size: 26, color: t.text),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: text.bodyLarge)),
                if (badge != null) StatusChip(label: badge, tone: ChipTone.neutral, icon: Icons.lock_outline),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 24, color: t.textMuted),
              ],
            ),
          ),
        );

    return ScreenScaffold(
      title: l.moreTitle,
      kicker: l.kickerMine,
      topBar: const HomeTopBar(),
      children: [
        AppCard(
          child: Column(
            children: [
              row(AppIcons.notes, l.moreNotes, () => context.push('/notes')),
              const AppDivider(),
              row(AppIcons.budget, l.moreBudget, () => context.push('/budget'), badge: l.budgetAdminBadge),
              const AppDivider(),
              row(AppIcons.settings, l.moreMembers, () => context.push('/members')),
              const AppDivider(),
              row(AppIcons.qr, l.moreInvite, () => context.push('/invite')),
              const AppDivider(),
              row(AppIcons.notifications, l.moreSettings, () => context.push('/settings')),
            ],
          ),
        ),
        TertiaryButton(label: l.signOut, onPressed: () => ref.read(authRepositoryProvider).signOut()),
      ],
    );
  }
}
