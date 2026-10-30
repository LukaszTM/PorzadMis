import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/app/notifications_bootstrap.dart';
import 'features/notifications/data/local_notifications.dart';
import 'l10n/app_localizations_pl.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pl');
  // Kanał i obsługa dotknięcia muszą istnieć przed pierwszym powiadomieniem; trasę z dotknięcia
  // odczyta bootstrap po zalogowaniu.
  await LocalNotifications.instance.init(
    channelName: 'PorządMiś',
    channelDescription: 'Przypomnienia o obowiązkach i wydarzeniach, nowości w domu',
    onTap: (route) => LocalNotifications.instance.launchRoute = route,
  );
  final themes = await AppThemes.load();
  runApp(
    ProviderScope(
      // Bez automatycznych ponowień: błąd odczytu ma od razu trafić do UI, a nie wisieć w pętli.
      retry: (_, _) => null,
      overrides: [
        appThemesProvider.overrideWithValue(themes),
        // Teksty powiadomień poza drzewem widgetów (aplikacja jest tylko po polsku).
        appLocalizationsProvider.overrideWithValue(AppLocalizationsPl()),
      ],
      child: const PorzadMisApp(),
    ),
  );
}
