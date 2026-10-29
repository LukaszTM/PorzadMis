import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';
import '../../household/domain/household_models.dart';
import '../../household/ui/start_screens.dart';
import '../data/invites_repository.dart';

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _redeem({String? code, String? qrToken}) async {
    final l = AppLocalizations.of(context);
    final user = ref.read(authStateProvider).value;
    setState(() => _busy = true);
    try {
      await ref.read(invitesRepositoryProvider).redeem(
            code: code,
            qrToken: qrToken,
            displayName: displayNameFor(user),
          );
      if (mounted) showAppToast(context, l.toastJoined);
    } catch (e) {
      if (mounted) showAppToast(context, callableMessage(e) ?? l.errGeneric, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    _redeem(code: _code.text.trim());
  }

  Future<void> _scan() async {
    final token = await context.push<String>('/scan');
    if (token != null && mounted) _redeem(qrToken: token);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l.joinTitle,
      onBack: () => context.go('/start'),
      backLabel: l.back,
      bottom: PrimaryButton(label: l.joinSubmit, loading: _busy, onPressed: _submit),
      children: [
        SecondaryButton(
          label: l.joinScanAction,
          icon: Icons.qr_code_scanner,
          onPressed: _busy ? null : _scan,
        ),
        Form(
          key: _form,
          child: AppTextField(
            controller: _code,
            label: l.joinCodeLabel,
            hint: l.joinCodeHint,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            inputFormatters: [LengthLimitingTextInputFormatter(12)],
            validator: (v) => (v == null || v.trim().isEmpty) ? l.errCodeEmpty : null,
          ),
        ),
      ],
    );
  }
}

/// Skaner kodu QR (pełnoekranowy – wyjątek z GUI 5.9). Zwraca token zaproszenia.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  bool _handled = false;
  bool _invalidShown = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final token = Invite.tokenFromQr(barcode.rawValue);
      if (token != null) {
        _handled = true;
        HapticFeedback.lightImpact();
        context.pop(token);
        return;
      }
    }
    if (!_invalidShown && capture.barcodes.isNotEmpty) {
      _invalidShown = true;
      showAppToast(context, AppLocalizations.of(context).errScanInvalid, error: true);
      Future<void>.delayed(const Duration(seconds: 3), () => _invalidShown = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    tooltip: l.back,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: const Icon(Icons.close, size: 26),
                  ),
                  Expanded(child: Text(l.scanTitle, style: text.headlineLarge)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(l.errCamera, style: text.bodyLarge, textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l.scanHint, style: text.bodyMedium, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
