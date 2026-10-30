import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/household/domain/household_models.dart';
import '../../features/members/data/members_repository.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_tokens.dart';
import 'illustration.dart';

/// Pasek dolny (makieta 2026): ilustracje 3D z podpisami. Dziś · Zakupy · Obowiązki · Kalendarz ·
/// Więcej (Administrator) / Notatki (Domownik). Nigdy szóstej zakładki.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
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

    Widget icon(Illustration i, bool selected) => Opacity(
          opacity: selected ? 1 : 0.72,
          child: IllustrationImage(i, height: 28),
        );

    Widget fifthIcon(bool selected) => isAdmin
        ? Icon(Icons.menu_rounded, size: 28, color: selected ? t.accent : t.textMuted)
        : icon(Illustration.notes, selected);

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: t.border))),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => context.go(paths[i]),
          destinations: [
            NavigationDestination(
              icon: icon(Illustration.home, false),
              selectedIcon: icon(Illustration.home, true),
              label: l.navToday,
            ),
            NavigationDestination(
              icon: icon(Illustration.shopping, false),
              selectedIcon: icon(Illustration.shopping, true),
              label: l.navShopping,
            ),
            NavigationDestination(
              icon: icon(Illustration.chores, false),
              selectedIcon: icon(Illustration.chores, true),
              label: l.navChores,
            ),
            NavigationDestination(
              icon: icon(Illustration.calendar, false),
              selectedIcon: icon(Illustration.calendar, true),
              label: l.navCalendar,
            ),
            NavigationDestination(
              icon: fifthIcon(false),
              selectedIcon: fifthIcon(true),
              label: isAdmin ? l.navMore : l.navNotes,
            ),
          ],
        ),
      ),
    );
  }
}
