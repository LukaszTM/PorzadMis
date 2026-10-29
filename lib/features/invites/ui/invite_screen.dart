import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';
import '../data/invites_repository.dart';

/// Zaproszenie domownika (tylko Administrator): QR + kod 6 znaków, ważne 24 h.
class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  bool _multiUse = false;
  bool _busy = false;
  Invite? _invite;

  Future<void> _create() async {
    final hid = ref.read(householdIdProvider);
    if (hid == null) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final invite = await ref.read(invitesRepositoryProvider).create(hid: hid, multiUse: _multiUse);
      if (mounted) setState(() => _invite = invite);
    } catch (e) {
      if (mounted) showAppToast(context, callableMessage(e) ?? l.errGeneric, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _revoke(Invite invite) async {
    final hid = ref.read(householdIdProvider);
    if (hid == null) return;
    final l = AppLocalizations.of(context);
    try {
      await ref.read(invitesRepositoryProvider).revoke(hid: hid, code: invite.code);
      if (mounted) showAppToast(context, l.inviteRevoked);
    } catch (e) {
      if (mounted) showAppToast(context, callableMessage(e) ?? l.errGeneric, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final hid = ref.watch(householdIdProvider);
    final created = _invite;
    // Stan na żywo (kto dołączył, czy unieważnione); do czasu pierwszego odczytu – dane z utworzenia.
    final live = (created != null && hid != null)
        ? ref.watch(_inviteStreamProvider((hid: hid, code: created.code))).value ?? created
        : null;

    return ScreenScaffold(
      title: l.inviteTitle,
      onBack: () => context.pop(),
      backLabel: l.back,
      headerTrailing: StatusChip(
        label: l.adminOnlyBadge,
        tone: ChipTone.neutral,
        icon: Icons.lock_outline,
      ),
      bottom: PrimaryButton(label: l.inviteCreate, loading: _busy, onPressed: _create),
      children: [
        SegmentedSwitch<bool>(
          options: [
            SegmentOption(false, l.inviteSingleUse),
            SegmentOption(true, l.inviteMultiUse),
          ],
          value: _multiUse,
          onChanged: (v) => setState(() => _multiUse = v),
        ),
        if (live != null)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Semantics(
                    label: l.inviteQrSemantics,
                    image: true,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: t.qrLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: live.qrPayload,
                        size: 200,
                        padding: EdgeInsets.zero,
                        backgroundColor: t.qrLight,
                        eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: t.qrDark),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: t.qrDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l.inviteCodeLabel, style: text.labelMedium, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(
                  live.revoked ? l.inviteRevoked : live.code,
                  textAlign: TextAlign.center,
                  style: text.headlineMedium!.copyWith(
                    letterSpacing: live.revoked ? 0 : 6,
                    color: live.revoked ? t.danger : t.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l.inviteValid} · ${l.inviteUsedBy(live.usedBy.length)}',
                  textAlign: TextAlign.center,
                  style: text.labelMedium,
                ),
                const SizedBox(height: 12),
                if (!live.revoked) ...[
                  SecondaryButton(
                    label: l.inviteCopy,
                    icon: Icons.copy,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: live.code));
                      if (context.mounted) showAppToast(context, l.toastCopied);
                    },
                  ),
                  TertiaryButton(
                    label: l.inviteRevoke,
                    danger: true,
                    onPressed: () => _revoke(live),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

final _inviteStreamProvider =
    StreamProvider.autoDispose.family<Invite?, ({String hid, String code})>(
  (ref, key) => ref.watch(invitesRepositoryProvider).watch(hid: key.hid, code: key.code),
);
