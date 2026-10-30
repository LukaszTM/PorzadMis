import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../data/household_repository.dart';

/// Imię do wpisania w domu: z profilu Firebase, a gdy go nie ma – z początku adresu e-mail.
String displayNameFor(User? user) {
  final name = user?.displayName?.trim();
  if (name != null && name.isNotEmpty) return name;
  return user?.email?.split('@').first ?? '';
}

/// Ekran po zalogowaniu bez domu: miś wita i prowadzi do trybu solo, założenia domu albo dołączenia.
class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  bool _busy = false;

  /// Tryb jednoosobowy: zwykły dom z jednym członkiem, założony od razu.
  Future<void> _startSolo() async {
    final l = AppLocalizations.of(context);
    final user = ref.read(authStateProvider).value;
    setState(() => _busy = true);
    try {
      await ref.read(householdRepositoryProvider).createHousehold(
            name: l.soloHouseholdName,
            displayName: displayNameFor(user),
          );
      // Profil z householdId przyjdzie strumieniem i router przeniesie na ekran domu.
    } catch (e) {
      if (mounted) showAppToast(context, callableMessage(e) ?? l.errGeneric, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const MisMark(size: 160),
                    const SizedBox(height: 24),
                    Text(l.startTitle, style: text.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(l.startSubtitle, style: text.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
              PrimaryButton(label: l.soloAction, loading: _busy, onPressed: _startSolo),
              const SizedBox(height: 12),
              SecondaryButton(
                label: l.createHouseholdAction,
                onPressed: _busy ? null : () => context.go('/create'),
              ),
              TertiaryButton(
                label: l.joinAction,
                onPressed: _busy ? null : () => context.go('/join'),
              ),
              TertiaryButton(
                label: l.signOut,
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateHouseholdScreen extends ConsumerStatefulWidget {
  const CreateHouseholdScreen({super.key});

  @override
  ConsumerState<CreateHouseholdScreen> createState() => _CreateHouseholdScreenState();
}

class _CreateHouseholdScreenState extends ConsumerState<CreateHouseholdScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    final user = ref.read(authStateProvider).value;
    setState(() => _busy = true);
    try {
      await ref.read(householdRepositoryProvider).createHousehold(
            name: _name.text.trim(),
            displayName: displayNameFor(user),
          );
      // Profil z householdId przyjdzie strumieniem i router przeniesie na ekran domu.
    } catch (e) {
      if (mounted) showAppToast(context, callableMessage(e) ?? l.errGeneric, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l.createHouseholdTitle,
      onBack: () => context.go('/start'),
      backLabel: l.back,
      bottom: PrimaryButton(label: l.createAction, loading: _busy, onPressed: _submit),
      children: [
        Form(
          key: _form,
          child: AppTextField(
            controller: _name,
            label: l.householdNameLabel,
            hint: l.householdNameHint,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            autofocus: true,
            onSubmitted: (_) => _submit(),
            validator: (v) => (v == null || v.trim().isEmpty) ? l.errHouseholdNameEmpty : null,
          ),
        ),
      ],
    );
  }
}
