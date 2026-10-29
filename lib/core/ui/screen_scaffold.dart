import 'package:flutter/material.dart';

/// Szkielet ekranu (GUI 2): margines 20 dp, tytuł 28 sp, akcja główna przyklejona u dołu.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.title,
    required this.children,
    this.bottom,
    this.onBack,
    this.backLabel,
    this.headerTrailing,
  });

  final String title;
  final List<Widget> children;

  /// Akcja główna ekranu (przycisk), przyklejona nad dolną krawędzią.
  final Widget? bottom;
  final VoidCallback? onBack;

  /// Etykieta dostępności strzałki „wróć”.
  final String? backLabel;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 20, 8),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      tooltip: backLabel,
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: const Icon(Icons.arrow_back, size: 26),
                    )
                  else
                    const SizedBox(width: 8),
                  Expanded(child: Text(title, style: text.headlineLarge)),
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
    );
  }
}
