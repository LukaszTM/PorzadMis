import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/household/domain/household_models.dart';
import '../../features/members/data/members_repository.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';

/// Pasek dolny (GUI 5.1): Dziś · Zakupy · Kalendarz · Notatki. Obowiązki dojdą w etapie 4
/// (wtedy Notatki trafią pod „Więcej” dla Administratora).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    // Administrator ma piątą zakładkę „Więcej” (Notatki, Budżet, Domownicy); Domownik – Notatki.
    final isAdmin = ref.watch(myRoleProvider) == Role.admin;
    final fifth = isAdmin ? '/more' : '/notes';
    final paths = ['/home', '/shopping', '/chores', '/calendar', fifth];
    final index = switch (location) {
      _ when location.startsWith('/shopping') => 1,
      _ when location.startsWith('/chores') => 2,
      _ when location.startsWith('/calendar') => 3,
      _ when location.startsWith('/notes') || location.startsWith('/more') => 4,
      _ => 0,
    };
    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: t.border))),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => context.go(paths[i]),
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
              icon: const AppIcon(AppIcons.chores, size: 26),
              selectedIcon: const AppIcon(AppIcons.chores, size: 26),
              label: l.navChores,
            ),
            NavigationDestination(
              icon: const AppIcon(AppIcons.calendar, size: 26),
              selectedIcon: const AppIcon(AppIcons.calendar, size: 26),
              label: l.navCalendar,
            ),
            NavigationDestination(
              icon: AppIcon(isAdmin ? AppIcons.settings : AppIcons.notes, size: 26),
              selectedIcon: AppIcon(isAdmin ? AppIcons.settings : AppIcons.notes, size: 26),
              label: isAdmin ? l.navMore : l.navNotes,
            ),
          ],
        ),
      ),
    );
  }
}
