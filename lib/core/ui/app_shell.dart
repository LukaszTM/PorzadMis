import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';

/// Pasek dolny (GUI 5.1): Dziś · Zakupy · Kalendarz · Notatki. Obowiązki dojdą w etapie 4
/// (wtedy Notatki trafią pod „Więcej” dla Administratora).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _paths = ['/home', '/shopping', '/calendar', '/notes'];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final index = location.startsWith('/shopping')
        ? 1
        : location.startsWith('/calendar')
            ? 2
            : location.startsWith('/notes')
                ? 3
                : 0;
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
            NavigationDestination(
              icon: const AppIcon(AppIcons.calendar, size: 26),
              selectedIcon: const AppIcon(AppIcons.calendar, size: 26),
              label: l.navCalendar,
            ),
            NavigationDestination(
              icon: const AppIcon(AppIcons.notes, size: 26),
              selectedIcon: const AppIcon(AppIcons.notes, size: 26),
              label: l.navNotes,
            ),
          ],
        ),
      ),
    );
  }
}
