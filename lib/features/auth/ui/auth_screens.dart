import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_repository.dart';

String _failureMessage(AppLocalizations l, AuthFailure failure) => switch (failure.kind) {
      AuthFailureKind.wrongCredentials => l.errWrongCredentials,
      AuthFailureKind.emailInUse => l.errEmailInUse,
      AuthFailureKind.network => l.errNetwork,
      AuthFailureKind.cancelled => l.errGoogleCancelled,
      AuthFailureKind.generic => l.errGeneric,
    };

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted && e.kind != AuthFailureKind.cancelled) {
        showAppToast(context, _failureMessage(l, e), error: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    _run(() => ref.read(authRepositoryProvider).signIn(
          email: _email.text,
          password: _password.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l.loginTitle,
      kicker: l.appName,
      subtitle: l.loginSubtitle,
      headerTrailing: const IllustrationImage(Illustration.bearLogo, height: 88),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(label: l.loginAction, loading: _busy, onPressed: _submit),
          const SizedBox(height: 12),
          SecondaryButton(
            label: l.googleAction,
            icon: Icons.account_circle_outlined,
            onPressed: _busy
                ? null
                : () => _run(() => ref.read(authRepositoryProvider).signInWithGoogle()),
          ),
          TertiaryButton(label: l.goRegister, onPressed: () => context.go('/register')),
        ],
      ),
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              AppTextField(
                controller: _email,
                label: l.emailLabel,
                hint: l.emailHint,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.errEmailEmpty
                    : (_emailPattern.hasMatch(v.trim()) ? null : l.errEmailInvalid),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: l.passwordLabel,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                validator: (v) => (v == null || v.isEmpty) ? l.errPasswordEmpty : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).register(
            email: _email.text,
            password: _password.text,
            displayName: _name.text,
          );
    } on AuthFailure catch (e) {
      if (mounted) showAppToast(context, _failureMessage(l, e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l.registerTitle,
      kicker: l.appName,
      subtitle: l.registerSubtitle,
      headerTrailing: const IllustrationImage(Illustration.bearLogo, height: 88),
      onBack: () => context.go('/login'),
      backLabel: l.back,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(label: l.registerAction, loading: _busy, onPressed: _submit),
          TertiaryButton(label: l.goLogin, onPressed: () => context.go('/login')),
        ],
      ),
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              AppTextField(
                controller: _name,
                label: l.nameLabel,
                hint: l.nameHint,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                validator: (v) => (v == null || v.trim().isEmpty) ? l.errNameEmpty : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _email,
                label: l.emailLabel,
                hint: l.emailHint,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.errEmailEmpty
                    : (_emailPattern.hasMatch(v.trim()) ? null : l.errEmailInvalid),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: l.passwordLabel,
                hint: l.passwordHint,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
                validator: (v) => (v == null || v.length < 6) ? l.errPasswordShort : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
