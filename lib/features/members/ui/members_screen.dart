import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';
import '../data/members_repository.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  Future<void> _manage(BuildContext context, WidgetRef ref, Member member) async {
    final l = AppLocalizations.of(context);
    final hid = ref.read(householdIdProvider);
    if (hid == null) return;
    final repo = ref.read(membersRepositoryProvider);

    Future<void> run(Future<void> Function() action) async {
      try {
        await action();
        if (context.mounted) showAppToast(context, l.toastSaved);
      } catch (e) {
        if (context.mounted) {
          showAppToast(context, callableMessage(e) ?? l.errGeneric, error: true);
        }
      }
    }

    final choice = await showAppSheet<_MemberAction>(
      context,
      title: member.displayName,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SecondaryButton(
            label: member.isAdmin ? l.removeAdmin : l.makeAdmin,
            onPressed: () => Navigator.of(sheetContext).pop(_MemberAction.toggleRole),
          ),
          const SizedBox(height: 8),
          TertiaryButton(
            label: l.removeMember,
            danger: true,
            onPressed: () => Navigator.of(sheetContext).pop(_MemberAction.remove),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;

    switch (choice) {
      case _MemberAction.toggleRole:
        final ok = await confirmSheet(
          context,
          title: l.confirmRoleTitle,
          body: member.isAdmin
              ? l.confirmTakeAdminBody(member.displayName)
              : l.confirmGiveAdminBody(member.displayName),
          confirmLabel: l.confirmYes,
          cancelLabel: l.back,
        );
        if (ok) {
          await run(() => repo.setRole(
                hid: hid,
                uid: member.uid,
                role: member.isAdmin ? Role.member : Role.admin,
              ));
        }
      case _MemberAction.remove:
        final ok = await confirmSheet(
          context,
          title: l.confirmRemoveTitle,
          body: l.confirmRemoveBody(member.displayName),
          confirmLabel: l.confirmYes,
          cancelLabel: l.back,
          danger: true,
        );
        if (ok) await run(() => repo.remove(hid: hid, uid: member.uid));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final myUid = ref.watch(authStateProvider).value?.uid;
    final isAdmin = ref.watch(myRoleProvider) == Role.admin;

    return ScreenScaffold(
      title: l.membersTitle,
      onBack: () => context.pop(),
      backLabel: l.back,
      children: [
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < members.length; i++) ...[
                if (i > 0) const AppDivider(),
                _MemberRow(
                  member: members[i],
                  isMe: members[i].uid == myUid,
                  onTap: isAdmin && members[i].uid != myUid
                      ? () => _manage(context, ref, members[i])
                      : null,
                  tokens: t,
                  text: text,
                  l: l,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

enum _MemberAction { toggleRole, remove }

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.isMe,
    required this.onTap,
    required this.tokens,
    required this.text,
    required this.l,
  });

  final Member member;
  final bool isMe;
  final VoidCallback? onTap;
  final AppTokens tokens;
  final TextTheme text;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final initial = member.displayName.isEmpty ? '?' : member.displayName.characters.first.toUpperCase();
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: tokens.accentSoft,
              child: Text(initial, style: text.bodyLarge!.copyWith(color: tokens.accent)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(member.displayName, style: text.bodyLarge),
                  if (isMe) Text(l.youBadge, style: text.labelMedium),
                ],
              ),
            ),
            StatusChip(
              label: member.isAdmin ? l.roleAdmin : l.roleMember,
              tone: member.isAdmin ? ChipTone.accent : ChipTone.neutral,
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 24, color: tokens.textMuted),
          ],
        ),
      ),
    );
  }
}
