import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';

/// Onboarding (GUI 7): trzy ekrany, duży sygnet i jedno zdanie; „Dalej”, na końcu „Zaczynamy”.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    // Profil z flagą przyjdzie strumieniem i router przeniesie dalej.
    ref.read(householdRepositoryProvider).markOnboardingDone(uid).catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final sentences = [l.onboarding1, l.onboarding2, l.onboarding3];
    final last = _page == sentences.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TertiaryButton(label: l.onboardingSkip, onPressed: _finish),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: sentences.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IllustrationImage(i == 1 ? Illustration.bearResting : Illustration.bearHouse, height: 220),
                      const SizedBox(height: 28),
                      Text(sentences[i], style: text.headlineMedium, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < sentences.length; i++)
                    Container(
                      width: i == _page ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == _page ? t.accent : t.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: last ? l.onboardingStart : l.onboardingNext,
                onPressed: last
                    ? _finish
                    : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
