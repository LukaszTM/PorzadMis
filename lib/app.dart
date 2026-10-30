import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/household/data/household_repository.dart';
import 'features/notifications/app/notifications_bootstrap.dart';
import 'features/widgets/app/widget_sync.dart';
import 'l10n/app_localizations.dart';

class PorzadMisApp extends ConsumerWidget {
  const PorzadMisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themes = ref.watch(appThemesProvider);
    final profile = ref.watch(profileProvider).value;
    final pair = resolveThemePair(themes, profile?.themeId);
    // Uruchamia FCM i lokalne przypomnienia na czas życia aplikacji.
    ref.watch(notificationsBootstrapProvider);
    ref.watch(widgetSyncProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: buildTheme(pair.light),
      darkTheme: buildTheme(pair.dark),
      themeMode: AppThemeMode.parse(profile?.themeMode).themeMode,
      // „Duży tekst” (GUI 3): wszystkie role o ~2 sp większe.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: (profile?.largeText ?? false) ? const TextScaler.linear(1.15) : MediaQuery.of(context).textScaler,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      locale: const Locale('pl'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
