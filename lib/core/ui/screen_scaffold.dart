import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Szkielet ekranu (makieta 2026): opcjonalny pasek górny, kicker (mały akcent), tytuł 28 sp,
/// podtytuł, lista kart; akcja główna przyklejona u dołu.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.title,
    required this.children,
    this.kicker,
    this.subtitle,
    this.topBar,
    this.bottom,
    this.onBack,
    this.backLabel,
    this.headerTrailing,
  });

  final String title;
  final List<Widget> children;

  /// Krótki napis nad tytułem, np. „Wspólnie”, „Po Twojemu”.
  final String? kicker;
  final String? subtitle;

  /// Pasek nad nagłówkiem (np. nazwa domu i przycisk motywów).
  final Widget? topBar;

  /// Akcja główna ekranu (przycisk), przyklejona nad dolną krawędzią.
  final Widget? bottom;
  final VoidCallback? onBack;

  /// Etykieta dostępności strzałki „wróć”.
  final String? backLabel;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        // Delikatne przejście u góry ekranu, jak w makiecie (radial-gradient akcentu 7 %).
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.alphaBlend(t.accent.withValues(alpha: 0.07), t.background), t.background],
            stops: const [0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (topBar != null) Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 0), child: topBar),
              Padding(
                padding: EdgeInsets.fromLTRB(onBack != null ? 12 : 20, topBar != null ? 18 : 16, 20, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onBack != null)
                      IconButton(
                        onPressed: onBack,
                        tooltip: backLabel,
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        icon: const Icon(Icons.arrow_back, size: 26),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (kicker != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                kicker!,
                                style: text.labelSmall!.copyWith(color: t.accent, letterSpacing: 0.8),
                              ),
                            ),
                          Text(title, style: text.headlineLarge),
                          if (subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(subtitle!, style: text.bodyMedium!.copyWith(color: t.textMuted)),
                            ),
                        ],
                      ),
                    ),
                    ?headerTrailing,
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: children.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => children[i],
                ),
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
