import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/calendar/ui/calendar_screen.dart';
import '../../features/chores/ui/chores_screen.dart';
import '../../features/notes/ui/notes_screen.dart';
import '../../features/auth/ui/auth_screens.dart';
import '../../features/household/data/household_repository.dart';
import '../../features/budget/ui/budget_screen.dart';
import '../../features/household/ui/home_screen.dart';
import '../../features/household/ui/more_screen.dart';
import '../../features/household/ui/start_screens.dart';
import '../../features/invites/ui/invite_screen.dart';
import '../../features/invites/ui/join_screens.dart';
import '../../features/members/ui/members_screen.dart';
import '../../features/notifications/ui/settings_screen.dart';
import '../../features/onboarding/ui/onboarding_screen.dart';
import '../../features/settings/ui/appearance_screen.dart';
import '../../features/shopping/ui/shopping_screen.dart';
import '../ui/app_shell.dart';
import '../ui/illustration.dart';

const _authRoutes = {'/login', '/register'};
const _startRoutes = {'/start', '/create', '/join', '/scan'};

/// Decyzja o przekierowaniu na podstawie sesji i domu. Wydzielona, żeby dało się ją przetestować.
String? resolveRedirect({
  required String location,
  required bool loading,
  required bool signedIn,
  required String? householdId,
  bool onboardingDone = true,
}) {
  if (loading) return location == '/splash' ? null : '/splash';
  if (!signedIn) return _authRoutes.contains(location) ? null : '/login';
  // Onboarding raz, po pierwszym zalogowaniu, przed domem.
  if (!onboardingDone) return location == '/onboarding' ? null : '/onboarding';
  if (location == '/onboarding') return householdId == null ? '/start' : '/home';
  if (householdId == null) return _startRoutes.contains(location) ? null : '/start';
  if (_authRoutes.contains(location) || _startRoutes.contains(location) || location == '/splash') {
    return '/home';
  }
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.listen(profileProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final profile = ref.read(profileProvider);
      final signedIn = auth.value != null;
      return resolveRedirect(
        location: state.matchedLocation,
        // Błąd odczytu nie może zatrzymywać aplikacji na ekranie startowym:
        // traktujemy go jak brak profilu (użytkownik trafi na ekran startowy domu).
        loading: (auth.isLoading && !auth.hasError) ||
            (signedIn && profile.isLoading && !profile.hasError),
        signedIn: signedIn,
        householdId: profile.value?.householdId,
        onboardingDone: profile.value?.onboardingDone ?? true,
      );
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/start', builder: (_, _) => const StartScreen()),
      GoRoute(path: '/create', builder: (_, _) => const CreateHouseholdScreen()),
      GoRoute(path: '/join', builder: (_, _) => const JoinScreen()),
      GoRoute(path: '/scan', builder: (_, _) => const ScanScreen()),
      ShellRoute(
        builder: (_, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/shopping', builder: (_, state) => ShoppingScreen(autofocusAdd: state.uri.queryParameters['add'] == '1')),
          GoRoute(path: '/chores', builder: (_, state) => ChoresScreen(openAdd: state.uri.queryParameters['add'] == '1')),
          GoRoute(path: '/calendar', builder: (_, _) => const CalendarScreen()),
          GoRoute(path: '/notes', builder: (_, _) => const NotesScreen()),
          GoRoute(path: '/more', builder: (_, _) => const MoreScreen()),
        ],
      ),
      GoRoute(path: '/members', builder: (_, _) => const MembersScreen()),
      GoRoute(path: '/budget', builder: (_, _) => const BudgetScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/settings/appearance', builder: (_, _) => const AppearanceScreen()),
      GoRoute(path: '/invite', builder: (_, _) => const InviteScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: IllustrationImage(Illustration.bearLogo, height: 180)));
}
