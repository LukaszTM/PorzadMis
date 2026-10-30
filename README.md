# PorządMiś

Domowy organizer na Androida dla jednej osoby albo całej rodziny: wspólna lista zakupów,
(wkrótce) kalendarz, notatki, obowiązki i budżet. Plan: [PLAN.md](PLAN.md), zasady pracy:
[CLAUDE.md](CLAUDE.md), wytyczne interfejsu: [docs/GUI.md](docs/GUI.md), logo: [brand/](brand/).

Stack: Flutter 3.x, Riverpod, go_router, Firebase (Auth, Firestore, Cloud Functions w TypeScript).
Tylko Android (minSdk 26).

## Co działa (stan na koniec etapu 2)

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
- Pasek dolny (Dziś, Zakupy) i karta-skrót z liczbą rzeczy do kupienia.

**Jeszcze nie ma:** kalendarz, notatki, obowiązki, budżet, powiadomienia, widżety,
wybór motywu (etapy 3–7 z PLAN.md).

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
- **Podpisywanie.** APK jest podpisany kluczem debug (do testów). Do Google Play potrzebny
  jest osobny klucz wydawniczy i odcisk SHA-1 w konsoli Firebase.
