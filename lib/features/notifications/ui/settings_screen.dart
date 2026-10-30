import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../../members/data/members_repository.dart' show membersProvider, membersRepositoryProvider, myRoleProvider;
import '../../household/domain/household_models.dart';
import '../../budget/domain/budget_models.dart' show currencySymbols;
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
    final household = ref.watch(householdProvider).value;
    final profile = ref.watch(profileProvider).value;

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
      kicker: l.kickerMine,
      subtitle: l.settingsSubtitle,
      onBack: () => Navigator.of(context).maybePop(),
      backLabel: l.back,
      children: [
        AppCard(
          title: l.themeCardTitle,
          onTap: () => context.push('/settings/appearance'),
          child: Text(l.themeCardSubtitle, style: text.bodyMedium),
        ),
        AppCard(
          title: l.settingsComfort,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.largeTextHint, style: text.labelMedium),
              row(l.largeTextLabel, profile?.largeText ?? false, (v) {
                if (uid != null) ref.read(householdRepositoryProvider).setLargeText(uid, v).catchError((Object _) {});
              }),
            ],
          ),
        ),
        if (isAdmin && household != null) _HouseholdSettingsCard(household: household),
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
          title: l.settingsAccount,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SecondaryButton(label: l.signOut, onPressed: () => ref.read(authRepositoryProvider).signOut()),
              TertiaryButton(
                label: l.leaveAction,
                danger: true,
                onPressed: () async {
                  final hid = ref.read(householdIdProvider);
                  if (hid == null) return;
                  final members = ref.read(membersProvider).value ?? const [];
                  final household = ref.read(householdProvider).value;
                  final ok = await confirmSheet(
                    context,
                    title: l.confirmLeaveTitle,
                    body: members.length <= 1 ? l.confirmLeaveSoloBody(household?.name ?? '') : l.confirmLeaveBody,
                    confirmLabel: l.confirmYes,
                    cancelLabel: l.back,
                    danger: true,
                  );
                  if (!ok) return;
                  try {
                    await ref.read(membersRepositoryProvider).leave(hid: hid);
                  } catch (e) {
                    if (context.mounted) showAppToast(context, callableMessage(e) ?? l.errGeneric, error: true);
                  }
                },
              ),
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

/// Ustawienia domu (Administrator): nazwa, waluta, początek tygodnia.
class _HouseholdSettingsCard extends ConsumerStatefulWidget {
  const _HouseholdSettingsCard({required this.household});

  final Household household;

  @override
  ConsumerState<_HouseholdSettingsCard> createState() => _HouseholdSettingsCardState();
}

class _HouseholdSettingsCardState extends ConsumerState<_HouseholdSettingsCard> {
  late final _name = TextEditingController(text: widget.household.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _saveName() {
    final l = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      showAppToast(context, l.errHouseholdNameEmpty, error: true);
      return;
    }
    ref.read(householdRepositoryProvider).updateHousehold(widget.household.id, name: _name.text).catchError((Object _) {});
    FocusScope.of(context).unfocus();
    showAppToast(context, l.toastSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final repo = ref.read(householdRepositoryProvider);
    final h = widget.household;
    return AppCard(
      title: l.settingsHousehold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _name,
            label: l.householdNameLabel,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _saveName(),
          ),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: TertiaryButton(label: l.saveNameAction, onPressed: _saveName)),
          const SizedBox(height: 8),
          Text(l.currencyLabel, style: text.labelMedium),
          const SizedBox(height: 8),
          ChoiceChips<String>(
            options: [for (final c in currencySymbols.keys) ChoiceOption(c, c)],
            selected: {h.currency},
            onToggle: (c) => repo.updateHousehold(h.id, currency: c).catchError((Object _) {}),
          ),
          const SizedBox(height: 14),
          Text(l.weekStartLabel, style: text.labelMedium),
          const SizedBox(height: 8),
          SegmentedSwitch<int>(
            options: [SegmentOption(1, l.weekStartMonday), SegmentOption(7, l.weekStartSunday)],
            value: h.weekStartsOn,
            onChanged: (v) => repo.updateHousehold(h.id, weekStartsOn: v).catchError((Object _) {}),
          ),
        ],
      ),
    );
  }
}
