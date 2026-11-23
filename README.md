# PorządMiś

Domowy organizer dla jednej osoby albo całej rodziny: wspólne listy zakupów,
kalendarz, notatki, obowiązki i budżet. Plan: [PLAN.md](PLAN.md), zasady pracy:
[CLAUDE.md](CLAUDE.md), wytyczne interfejsu: [docs/GUI.md](docs/GUI.md), logo: [brand/](brand/).

Stack: Flutter 3.x, Riverpod, go_router, Firebase (Auth, Firestore, Cloud Functions w TypeScript).
Wydanie do pobrania jest dostępne na Androida (minSdk 26). Stan prac nad iOS opisano poniżej.

## Pobierz PorządMisia na Androida

PorządMiś 0.1.0 wymaga Androida 8.0 lub nowszego. Na większości telefonów wybierz ARM64.

- [Pobierz APK ARM64](https://github.com/LukaszTM/PorzadMis/raw/refs/heads/main/docs/downloads/PorzadMis-0.1.0-arm64-v8a.apk)
- [Pobierz APK ARM 32-bit](https://github.com/LukaszTM/PorzadMis/raw/refs/heads/main/docs/downloads/PorzadMis-0.1.0-armeabi-v7a.apk)
- [Pobierz APK x86-64](https://github.com/LukaszTM/PorzadMis/raw/refs/heads/main/docs/downloads/PorzadMis-0.1.0-x86_64.apk)
- [Sumy kontrolne SHA-256](docs/downloads/SHA256SUMS)

[Instrukcja użytkownika w PDF](docs/instrukcja-uzytkownika.pdf) opisuje instalację, konfigurację domu i obsługę głównych funkcji. [Zrzuty ekranów](docs/screenshots/) pokazują aplikację z przykładowymi danymi.

## Co działa (stan na koniec etapu 7 – wszystkie etapy MVP)

**Etap 1 – fundament**
- Konto: e-mail i hasło oraz logowanie przez Google.
- Dom: założenie domu, tryb jednoosobowy („Zacznij tylko dla siebie” zakłada dom „Mój dom”),
  „Opuść dom” (ostatnia osoba usuwa dom).
- Zaproszenia (Administrator): kod QR i kod 6 znaków, ważne 24 h, jednorazowe lub wielokrotne,
  można unieważnić; dołączanie kodem albo skanem QR.
- Domownicy: lista, nadawanie i odbieranie roli Administratora, usuwanie z domu.
  Ostatniego Administratora nie da się zdegradować ani usunąć.
- Motywy z tokenami (kremowy i noc, pliki w `assets/themes/`), komponenty z GUI.md
  w `lib/core/ui/`, ikony i logo z paczki marki.

**Etap 2 – lista zakupów**
- Wspólna lista domu na żywo i offline: dopisywanie, odhaczanie całym wierszem,
  grupowanie po działach, edycja (ilość, jednostka, dział), „Wyczyść kupione” z „Cofnij”.
- Podpowiedzi nazw z historii domu (historia przeżywa czyszczenie listy).
- Kilka list zakupów z osobnymi pozycjami i wspólną historią podpowiedzi.
- Pasek dolny (Dziś, Zakupy) i karta-skrót z liczbą rzeczy do kupienia.

**Etap 3 – notatnik i kalendarz**
- Notatki wspólne i prywatne („wszyscy w domu / tylko ja”; prywatne widzi wyłącznie autor,
  także nie Administrator), przypinanie, szukanie, filtr, „Cofnij” po usunięciu.
- Wydarzenia wspólne i prywatne: dzień i godzina lub cały dzień, miejsce, opis, uczestnicy,
  przypomnienie (zapisane; push dojdzie w etapie 6), cykl co tydzień / miesiąc / rok.
- Widok miesiąca i tygodnia (tydzień od poniedziałku), lista dnia, legenda.

**Etap 4 – obowiązki**
- Reguły obowiązków tworzy Administrator: jednorazowo albo cyklicznie (co N dni, dni tygodnia,
  dzień miesiąca, wybrane daty z kalendarza), z końcem cyklu i przypomnieniem rano.
- Wystąpienia generuje serwer do 90 dni w przód (przy zapisie reguły i codziennie o 00:05).
- Ekran Obowiązki: pasek tygodnia, „Moje · dzień”, „Inni domownicy”, odhaczanie całym
  wierszem; obowiązki widać też w kalendarzu i na „Dziś”.

**Etap 5 – budżet (tylko Administrator)**
- Kategorie (zestaw startowy), wydatki w groszach z datą, kategorią, opisem i „kto zapłacił”.
- Wykres pierścieniowy (dotknięcie filtruje listę), sortowanie, przełączanie miesięcy.
- Plan miesięczny: limity na kategorie i suma, kopiowanie z poprzedniego miesiąca, paski
  „wydano / plan” z ostrzeżeniem przy 80 % i 100 %.
- Domownik nie dostaje danych budżetu na urządzenie (reguły Firestore).
- Piąta zakładka Administratora to „Więcej” (Notatki, Budżet, Domownicy, Zaproś, Ustawienia).

**Etap 6 – powiadomienia**
- Push (Cloud Functions + FCM): nowy obowiązek przypisany mnie, nowy domownik, nowa pozycja
  zakupów (domyślnie wyłączone), przekroczenie planu budżetu (Administratorzy).
- Lokalne przypomnienia o obowiązkach (godzina z reguły) i wydarzeniach (minuty przed).
- Dotknięcie powiadomienia otwiera właściwy ekran; preferencje w Ustawieniach.

**Etap 7 – wykończenie**
- 13 motywów (`assets/themes/*.json`), Ustawienia → Wygląd z podglądem na żywo, tryb
  jasny / ciemny / auto; wybór zapisany w profilu użytkownika.
- Onboarding (3 ekrany z misiem) raz po pierwszym logowaniu.
- Widżety ekranu głównego „Dziś” i „Zakupy” (Kotlin, RemoteViews; dotknięcie otwiera ekran).

**Poza MVP (do kolejnych wersji):** odhaczanie z poziomu widżetu,
rotacja obowiązków, eksport budżetu do CSV, załączniki w notatkach, tablet, angielski.
Przed publikacją w Google Play: klucz wydawniczy, nowy odcisk SHA-1 w Firebase, polityka
prywatności, test na dwóch telefonach (patrz definicja „zrobione” w PLAN.md).

## iOS (przygotowane bez Maca, NIESPRAWDZONE)

Kod iOS powstał na Windowsie: nie został ani zbudowany, ani uruchomiony, więc pierwszy przebieg w chmurze
prawdopodobnie będzie wymagał poprawek. Zawiera: folder `ios/` (iOS 15+, bundle `pl.porzadmis.porzadmis`),
ikonę z misiem, uprawnienia (kamera do QR, powiadomienia push, Sign in with Apple, App Group),
logowanie przez Apple (przycisk tylko na iOS), widżety WidgetKit „Dziś”, „Zakupy” i „Kalendarz”
(`ios/PorzadMisWidgets/`, ten sam JSON co widżety Androida) oraz `codemagic.yaml`.
Cel widżetów i uprawnienia dopina do projektu Xcode skrypt `ios/scripts/setup_ios_project.rb`
(uruchamia go Codemagic przed budową).

Co trzeba zrobić ręcznie, zanim zbuduje się pierwsza wersja:

1. Konto Apple Developer (99 USD rocznie).
2. W Apple Developer → Identifiers: App ID `pl.porzadmis.porzadmis` (włączone: Push Notifications, Sign in with
   Apple, App Groups) i `pl.porzadmis.porzadmis.widgets` (App Groups); App Group `group.pl.porzadmis.porzadmis`.
3. W Firebase (projekt `porzadmis`): dodać aplikację iOS o tym bundle ID, pobrać `GoogleService-Info.plist`
   do `ios/Runner/`; włączyć w Authentication dostawcę Apple; wgrać klucz APNs (.p8) w Cloud Messaging.
4. Do `ios/Runner/Info.plist` dopisać schemat URL z wartością `REVERSED_CLIENT_ID` z pliku
   `GoogleService-Info.plist` (potrzebny do logowania przez Google).
5. W Codemagic: podpiąć repozytorium i dodać integrację App Store Connect o nazwie `porzadmis_appstore`
   (klucz API z App Store Connect); w App Store Connect założyć rekord aplikacji.
6. Sprawdzić na prawdziwym iPhonie: logowanie (e-mail, Google, Apple), skan QR, push, widżety, dotknięcie widżetu.

### Wersja testowa na iPhone (dla osoby z Makiem)

Bez kwestii wydawniczych (sklep, opis, polityka prywatności): wystarczy zbudować i wysłać testerom.
Potrzebne: Mac z Xcode, Flutter, CocoaPods, konto Apple Developer (płatne) i kroki 2–4 z listy wyżej
(App ID i App Group, `GoogleService-Info.plist`, `REVERSED_CLIENT_ID`, Apple w Firebase Auth, klucz APNs).

```
flutter pub get
ruby ios/scripts/setup_ios_project.rb     # raz: cel widżetów i uprawnienia w projekcie Xcode
cd ios && pod install && cd ..
open ios/Runner.xcworkspace               # Signing & Capabilities: wybierz zespół dla obu celów
                                          # (Runner i PorzadMisWidgets), podpis automatyczny
flutter build ipa --release
```

Wysyłka testerom: TestFlight (Xcode → Product → Archive → Distribute App → App Store Connect; testerzy
wewnętrzni nie wymagają recenzji Apple) albo ad hoc (UDID iPhone'ów w Apple Developer, eksport IPA).
Każdy tester musi jednorazowo zalogować się własnym kontem; dom w aplikacji jest wspólny z wersją na Androida.

## Struktura

```
lib/core/            motyw (tokeny), komponenty UI, router, Firebase
lib/features/<moduł>/{data,domain,ui}
lib/l10n/app_pl.arb  wszystkie teksty interfejsu (po polsku)
functions/src        Cloud Functions (dom, zaproszenia, role)
functions/test       testy reguł Firestore i funkcji (emulator)
firestore.rules      reguły bezpieczeństwa
assets/ brand/ store/ logo, ikony, grafiki do sklepu
```

## Uruchamianie i testy

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
cd functions && npm install && npm test     # uruchamia emulator Firestore
```

Wymagania: Flutter, Node 22+, Java (emulator Firestore), `firebase-tools`.
Projekt Firebase: `porzadmis` (region funkcji `europe-west1`, plan Blaze).

Budowanie APK do instalacji na telefonie:

```bash
flutter build apk --release --split-per-abi
```

Wdrożenie backendu (po każdej zmianie reguł lub funkcji):

```bash
firebase deploy --only functions,firestore:rules,firestore:indexes
```

## Uwagi dla programisty

- **Polskie znaki w ścieżce.** W folderze o nazwie `PorządMiś` `flutter analyze` się wywala
  (serwer analizy Darta). Obejście: tymczasowy dysk, np. `subst P: "C:\...\PorządMiś"` i praca
  z `P:\`. Najprościej zmienić nazwę folderu na `PorzadMis`. Z tym związana jest też opcja
  `kotlin.incremental=false` w `android/gradle.properties`.
- **Port emulatora.** Emulator Firestore działa na porcie 8181 (`firebase.json`), bo 8080
  bywa zajęty. Przerwany `npm test` może zostawić proces `java` trzymający port.
- **Kolory** tylko przez tokeny motywu; jedyny wyjątek to sygnet misia
  (`lib/core/ui/mis_mark.dart`). Pilnuje tego test `no_color_literals_test.dart`.
- **Zapisy offline.** Zapisy do Firestore nie są `await`-owane w UI: przy braku sieci
  `Future` kończy się dopiero po powrocie połączenia.
- **Podpisywanie.** Udostępnione tu APK podpisano kluczem wydawniczym. Lokalny build bez
  konfiguracji podpisu używa klucza debug. Logowanie przez Google wymaga rejestracji
  odcisku certyfikatu użytego do podpisania aplikacji w Firebase.
- **Widżety.** Dane do widżetów zapisuje aplikacja (`home_widget`, klucze `widget_today`
  i `widget_shopping`); kod natywny w `android/app/src/main/kotlin/.../*WidgetProvider.kt`.
- **Funkcje w chmurze.** Po zmianie w `functions/` lub `firestore.rules`:
  `firebase deploy --only functions,firestore:rules,firestore:indexes` (z PowerShella,
  nie z Git Basha; bez `--force`).
