import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/domain/household_models.dart';
import '../../members/data/members_repository.dart';
import '../data/notifications_repository.dart';
import '../domain/reminders.dart';

/// Ustawienia: typy powiadomień (każdy użytkownik dla siebie). Motywy dojdą w etapie 7.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final uid = ref.watch(authStateProvider).value?.uid;
    final prefs = ref.watch(notificationPrefsProvider).value ?? const NotificationPrefs();
    final isAdmin = ref.watch(myRoleProvider) == Role.admin;

    void save(NotificationPrefs p) {
      if (uid == null) return;
      ref.read(notificationsRepositoryProvider).savePrefs(uid, p).catchError((Object _) {});
    }

    Widget row(String label, bool value, ValueChanged<bool> onChanged) => Semantics(
          toggled: value,
          label: label,
          child: InkWell(
            onTap: () => onChanged(!value),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: text.bodyMedium)),
                  const SizedBox(width: 12),
                  Switch(
                    value: value,
                    onChanged: onChanged,
                    activeTrackColor: t.accent,
                    activeThumbColor: t.onAccent,
                    inactiveTrackColor: t.border,
                    inactiveThumbColor: t.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );

    return ScreenScaffold(
      title: l.settingsTitle,
      onBack: () => Navigator.of(context).maybePop(),
      backLabel: l.back,
      children: [
        AppCard(
          title: l.settingsAppearance,
          onTap: () => context.push('/settings/appearance'),
          child: Text(l.themePreviewHint, style: text.bodyMedium),
        ),
        AppCard(
          title: l.settingsNotifications,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.settingsNotificationsHint, style: text.labelMedium),
              const SizedBox(height: 6),
              row(l.prefChores, prefs.chores, (v) => save(prefs.copyWith(chores: v))),
              const AppDivider(),
              row(l.prefEvents, prefs.events, (v) => save(prefs.copyWith(events: v))),
              const AppDivider(),
              row(l.prefShopping, prefs.shopping, (v) => save(prefs.copyWith(shopping: v))),
              const AppDivider(),
              row(l.prefMembers, prefs.members, (v) => save(prefs.copyWith(members: v))),
              if (isAdmin) ...[
                const AppDivider(),
                row(l.prefBudget, prefs.budget, (v) => save(prefs.copyWith(budget: v))),
              ],
            ],
          ),
        ),
        AppCard(
          title: l.settingsAbout,
          child: Text(l.settingsVersion('0.1.0'), style: text.bodyMedium),
        ),
      ],
    );
  }
}
