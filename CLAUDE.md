# PorządMiś – zasady pracy

- Czytaj PLAN.md przed każdym zadaniem; realizuj dokładnie jeden etap naraz.
- Wytyczne interfejsu: docs/GUI.md (obowiązkowe przy każdym ekranie). Logo i ikony: docs/wytyczne-logo-i-ikon.pdf.
- Stack: Flutter 3.x, Riverpod, Firebase (Auth, Firestore, Functions w TypeScript, FCM).
- Cel: tylko Android (minSdk 26). Nie dodawaj konfiguracji ani kodu iOS.
- Struktura: lib/features/<moduł>/{data,domain,ui}, lib/core, functions/src.
- Kwoty w groszach (int). Czas w UTC. Identyfikatory UUID z klienta.
- Każda zmiana reguł Firestore wymaga testu w emulatorze (allow + deny).
- Przed zakończeniem zadania: flutter analyze, flutter test, npm test w functions/.
- Nie dodawaj zależności spoza listy w PLAN.md bez pytania.
- Teksty interfejsu po polsku, w pliku lib/l10n/app_pl.arb.
- Kolory tylko przez tokeny motywu (ThemeExtension); żadnych hexów w widgetach. Motywy w assets/themes/*.json.
