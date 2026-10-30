import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final themes = await AppThemes.load();
  runApp(
    ProviderScope(
      // Bez automatycznych ponowień: błąd odczytu ma od razu trafić do UI, a nie wisieć w pętli.
      retry: (_, _) => null,
      overrides: [appThemesProvider.overrideWithValue(themes)],
      child: const PorzadMisApp(),
    ),
  );
}
