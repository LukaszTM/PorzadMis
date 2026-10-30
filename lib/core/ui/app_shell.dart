import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';

/// Pasek dolny (GUI 5.1). Na razie dwie zakładki; kolejne moduły dojdą w następnych etapach
/// (docelowo: Dziś · Zakupy · Obowiązki · Kalendarz · Notatki/Więcej).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _paths = ['/home', '/shopping'];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final index = location.startsWith('/shopping') ? 1 : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: t.border))),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => context.go(_paths[i]),
          destinations: [
            NavigationDestination(
              icon: const AppIcon(AppIcons.today, size: 26),
              selectedIcon: const AppIcon(AppIcons.today, size: 26),
              label: l.navToday,
            ),
            NavigationDestination(
              icon: const AppIcon(AppIcons.shopping, size: 26),
              selectedIcon: const AppIcon(AppIcons.shopping, size: 26),
              label: l.navShopping,
            ),
          ],
        ),
      ),
    );
  }
}
