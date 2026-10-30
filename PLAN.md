# PorządMiś – plan aplikacji

Wersja z 29 października 2026

## Cel i założenia

PorządMiś to mobilna aplikacja dla jednego gospodarstwa domowego: każdy domownik instaluje ją na swoim telefonie, a wpisy jednej osoby są natychmiast widoczne dla pozostałych. Jedno gospodarstwo = jedna wspólna przestrzeń danych („dom”), do której dołącza się kodem QR.

Założenia, które porządkują resztę planu:

- Jedna aplikacja, dwie role: Administrator i Domownik. Różnią się tylko uprawnieniami, nie ekranami.
- Dane wspólne synchronizują się przez backend w chmurze w czasie rzeczywistym; aplikacja działa też offline i dosyła zmiany po odzyskaniu sieci.
- Prywatność na poziomie wpisu: notatki i wydarzenia mają przełącznik „wszyscy / tylko ja”.
- Budżet jest widoczny wyłącznie dla Administratorów, również w powiadomieniach i widżetach.
- Platforma: na początek tylko Android; Flutter zostawia otwartą drogę do iOS bez przepisywania. Pierwsza wersja (MVP) po polsku, z walutą PLN i tygodniem od poniedziałku.
- Jeden dom może mieć kilku Administratorów; pierwszy, kto założy dom, jest Administratorem automatycznie.
- Tryb jednoosobowy: aplikacja działa też dla jednej osoby. To zwykły dom z jednym członkiem (Administratorem); na ekranie startowym ścieżka „Zacznij tylko dla siebie” zakłada go jednym dotknięciem pod nazwą „Mój dom”. Nie ma osobnego modelu danych ani osobnych ekranów; domowników można zaprosić później kodem QR.

## Role i uprawnienia

Administrator widzi i edytuje wszystko; Domownik nie widzi budżetu i edytuje tylko to, co jest wspólne z natury: zakupy, notatki, kalendarz.

| Obszar | Administrator | Domownik |
| --- | --- | --- |
| Budżet (wydatki, plan miesięczny, wykres) | widzi, dodaje, edytuje, usuwa | nie widzi modułu w ogóle |
| Plan obowiązków | tworzy, przypisuje, edytuje, usuwa | widzi swoje i cudze; odhacza tylko swoje |
| Lista zakupów | pełna edycja | dodaje, edytuje, odhacza, usuwa pozycje |
| Notatnik | pełna edycja notatek wspólnych i własnych | dodaje i edytuje własne (prywatne lub wspólne); cudze wspólne tylko czyta |
| Kalendarz | pełna edycja | dodaje wydarzenia (prywatne lub wspólne); edytuje tylko swoje |
| Domownicy | zaprasza kodem QR, nadaje i odbiera rolę Administratora, usuwa z domu | widzi listę domowników |
| Ustawienia domu (nazwa, waluta, początek tygodnia) | edytuje | czyta |

Zasady, które muszą być egzekwowane po stronie serwera, nie tylko ukryte w interfejsie:

- Dane budżetu nigdy nie są wysyłane na urządzenie Domownika (reguły dostępu w bazie, nie filtr w aplikacji).
- Wpis prywatny (notatka, wydarzenie) jest czytelny wyłącznie dla autora, nawet dla Administratora.
- Ostatniego Administratora nie da się zdegradować ani usunąć; dom musi mieć co najmniej jednego.
- Opuszczenie domu: każdy domownik może wyjść z domu. Jedyny Administrator wychodzi dopiero po nadaniu roli komuś innemu. Ostatnia osoba, opuszczając dom, usuwa go razem z danymi (po potwierdzeniu); to droga powrotu na ekran startowy, np. by przejść na tryb jednoosobowy.

## Funkcje

Osiem modułów; cztery z nich (zakupy, obowiązki, kalendarz, notatki) są wspólne dla domu, budżet jest tylko dla Administratorów, a widżety, powiadomienia i QR obsługują resztę.

### Budżet domowy (tylko Administrator)

- Dodawanie wydatku: kwota, data (domyślnie dziś), kategoria, opcjonalny opis i kto zapłacił.
- Kategorie: zestaw startowy (jedzenie, rachunki, dom, transport, zdrowie, dzieci, rozrywka, inne) edytowalny przez Administratora, z ikoną i kolorem.
- Widok miesiąca: lista wydatków z sortowaniem i filtrem po kategorii, dacie i kwocie; przełączanie miesięcy strzałkami.
- Wykres kołowy: udział kategorii w wydatkach bieżącego miesiąca; dotknięcie wycinka filtruje listę.
- Plan miesięczny: limit na każdą kategorię i suma; pasek „wydano / plan” z ostrzeżeniem przy 80% i 100%; plan można skopiować z poprzedniego miesiąca.
- Eksport miesiąca do CSV (poza MVP, ale model danych ma to umożliwiać).

### Plan obowiązków

- Obowiązek ma: nazwę, opis, przypisanego domownika (lub „ktoś”), termin i tryb: jednorazowy lub cykliczny.
- Cykl jest w pełni konfigurowalny: co N dni / tygodni / miesięcy, wybrane dni tygodnia (np. wt i pt), wybrany dzień miesiąca, oraz tryb „wybrane daty z kalendarza” (dowolny zestaw dni zaznaczony ręcznie). Data końca cyklu opcjonalna.
- Wystąpienia cyklu generowane są w przód (np. 90 dni) i zapisywane osobno, żeby każde dało się odhaczyć, przesunąć lub pominąć bez psucia reguły.
- Widoki: „Dziś” (moje i cudze), tydzień, kalendarz miesięczny z kropkami. Odhaczenie zapisuje kto i kiedy.
- Administrator może przypisać obowiązek rotacyjnie (kolejno kolejnym domownikom) – opcja na drugi etap.

### Lista zakupów

- Jedna wspólna lista domu, widoczna i edytowalna przez wszystkich; możliwość kilku list (np. „Spożywcze”, „Budowlane”) w drugim etapie.
- Pozycja: nazwa, ilość i jednostka (opcjonalnie), kategoria sklepowa do grupowania, kto dodał.
- Odhaczanie jednym dotknięciem; kupione przechodzą na dół do sekcji „kupione”, którą można wyczyścić jednym przyciskiem.
- Podpowiedzi nazw z historii (produkty dodawane wcześniej w tym domu).
- Zmiany pojawiają się u innych w czasie rzeczywistym, żeby dwie osoby w sklepie nie kupiły tego samego.

### Notatnik

- Notatka: tytuł, treść (prosty tekst z listami punktowanymi), autor, data zmiany, opcjonalne przypięcie.
- Przełącznik widoczności przy tworzeniu i edycji: „wszyscy w domu” albo „tylko ja”. Prywatne oznaczone kłódką i trzymane w osobnej kolekcji, do której serwer dopuszcza tylko autora.
- Wyszukiwanie po tytule i treści.

### Kalendarz domowy

- Wydarzenie: tytuł, data i godzina lub cały dzień, czas trwania, miejsce, opis, uczestnicy spośród domowników, przypomnienie (np. 1 h wcześniej).
- Ten sam przełącznik widoczności co w notatkach: wspólne albo tylko ja.
- Widoki: miesiąc, tydzień, dzień; w jednym widoku wydarzenia i obowiązki na dany dzień (obowiązki innym kolorem).
- Prosta cykliczność wydarzeń (co tydzień, co miesiąc, co rok) tą samą logiką co obowiązki.

### Widżety na ekran telefonu

- Widżet „Dziś”: moje obowiązki na dziś z możliwością odhaczenia z poziomu widżetu oraz najbliższe wydarzenia.
- Widżet „Zakupy”: liczba niekupionych pozycji i pierwsze 5 nazw, dotknięcie otwiera listę.
- Rozmiary: mały (licznik), średni (lista 3–5 pozycji). Android App Widgets (Kotlin, biblioteka Glance). Widżety nigdy nie pokazują danych budżetu.
- Dane do widżetu zapisywane lokalnie przy każdej synchronizacji, żeby widżet nie wymagał sieci.

### Powiadomienia push

- Zdarzenia: nowy obowiązek przypisany mnie, przypomnienie o obowiązku rano w dniu wykonania (godzina ustawiana), przypomnienie o wydarzeniu, nowa pozycja na liście zakupów (opcjonalne, domyślnie wyłączone), nowy domownik dołączył, przekroczenie planu budżetu (tylko Administratorzy).
- Każdy użytkownik włącza i wyłącza typy powiadomień w ustawieniach.
- Dotknięcie powiadomienia otwiera właściwy ekran (deep link).
- Powiadomienia prywatnych wpisów idą tylko do autora.

### Dodawanie domowników kodem QR

- Administrator generuje zaproszenie: kod QR i tekstowy kod 6 znaków (na wypadek braku kamery), ważne 24 h, jednorazowe lub wielokrotne (przełącznik).
- Nowa osoba instaluje aplikację, zakłada konto, wybiera „Dołącz do domu” i skanuje kod; dołącza jako Domownik.
- Administrator może unieważnić kod i zobaczyć, kto z niego skorzystał.
- Kod zawiera tylko identyfikator zaproszenia; dane domu pobiera serwer po weryfikacji.

### Motywy kolorystyczne

- Każdy użytkownik wybiera motyw dla siebie w Ustawieniach; wybór zapisuje się w jego profilu i działa na każdym telefonie, na którym się zaloguje. Motyw nie wpływa na innych domowników.
- Opcja „Automatycznie”: jasny motyw w dzień, ciemny w nocy, zgodnie z ustawieniem systemu Android.
- Motyw to zestaw tokenów, nie kolory wpisane w ekrany: `background`, `surface`, `text`, `textMuted`, `border`, `accent`, `accentSoft`, `warning`, `danger`, `success` oraz 5 kolorów do wykresu budżetu. Każdy ekran korzysta wyłącznie z tokenów (w Flutterze: `ThemeExtension`).
- Każdy motyw musi mieć kontrast tekstu do tła min. 4,5:1 (test automatyczny w CI), żeby starsi domownicy czytali bez wysiłku.
- Podgląd na żywo: dotknięcie kafelka motywu od razu przebarwia ekran ustawień, zapis po „Zastosuj”.

Zestaw startowy motywów (palety inspirowane, nie kopiowane):

| Grupa | Motyw | Tło | Powierzchnia | Tekst | Akcent | Tryb |
| --- | --- | --- | --- | --- | --- | --- |
| Domyślne | PorządMiś (kremowy) | #FBF7F1 | #FFFFFF | #1C2733 | #2B7A57 | jasny |
| Domyślne | PorządMiś (noc) | #15202B | #1E2A36 | #F2EEE8 | #4FB388 | ciemny |
| Inspirowane PyCharm | Darcula | #2B2B2B | #3C3F41 | #A9B7C6 | #6897BB | ciemny |
| Inspirowane PyCharm | IntelliJ Light | #F7F8FA | #FFFFFF | #1F1F1F | #3574F0 | jasny |
| Inspirowane PyCharm | High Contrast | #000000 | #1B1B1B | #FFFFFF | #FFD400 | ciemny |
| Inspirowane PyCharm | Dracula | #282A36 | #343746 | #F8F8F2 | #BD93F9 | ciemny |
| Inspirowane PyCharm | One Dark | #282C34 | #2F343D | #ABB2BF | #61AFEF | ciemny |
| Inspirowane PyCharm | Monokai | #272822 | #32332B | #F8F8F2 | #A6E22E | ciemny |
| Inspirowane PyCharm | Solarized Light | #FDF6E3 | #EEE8D5 | #586E75 | #268BD2 | jasny |
| Inspirowane PyCharm | Nord | #2E3440 | #3B4252 | #ECEFF4 | #88C0D0 | ciemny |
| Różowe | Róż pastelowy | #FFF3F7 | #FFFFFF | #3B1F2B | #D6336C | jasny |
| Różowe | Róż intensywny | #FFE4EF | #FFFFFF | #2A0F1B | #C2185B | jasny |
| Różowe | Róż nocny | #1F1218 | #2C1A24 | #FBE7EF | #FF6FA3 | ciemny |

Uwagi: w motywach ciemnych akcent służy do przycisków i ikon, a tekst na przycisku jest ciemny (nie biały), bo jasne akcenty typu Monokai czy High Contrast nie dają kontrastu z białym. Czerwień ostrzeżeń budżetu w motywach różowych zastępuje bursztyn, żeby nie zlewała się z akcentem. Nowe motywy dodaje się jednym plikiem JSON bez zmian w ekranach.

## Architektura techniczna

Rekomendacja: Flutter po stronie telefonu i Firebase jako backend. To najkrótsza droga do synchronizacji w czasie rzeczywistym, trybu offline, push i logowania bez pisania własnego serwera.

| Warstwa | Wybór | Dlaczego |
| --- | --- | --- |
| Aplikacja mobilna | Flutter 3.x (Dart), teraz tylko Android; iOS później z tego samego kodu | jeden zespół, jeden kod, dobre wsparcie Claude Code |
| Stan i architektura | Riverpod + warstwy: ui / domain / data (repozytoria) | testowalne, czytelne dla agenta |
| Baza i synchronizacja | Cloud Firestore z włączoną persystencją offline | zmiany jednej osoby od razu u innych; działa bez sieci |
| Logowanie | Firebase Auth: e-mail + hasło, Google | Sign in with Apple dojdzie dopiero przy wersji iOS |
| Uprawnienia | Firestore Security Rules oparte na roli w dokumencie członkostwa | budżet i wpisy prywatne chronione na serwerze |
| Logika serwerowa | Cloud Functions (TypeScript): generowanie wystąpień cykli, wysyłka push, obsługa zaproszeń QR, alert budżetu | logika, której nie wolno zostawić w telefonie |
| Push | Firebase Cloud Messaging + flutter_local_notifications | darmowe; na Androidzie bez dodatkowej konfiguracji |
| Widżety | pakiet home_widget + Android App Widget (Kotlin) | jedyna część wymagająca kodu natywnego |
| QR | mobile_scanner (skan), qr_flutter (generowanie) | dojrzałe pakiety |
| Wykresy | fl_chart (wykres kołowy, paski planu) | lekki, bez opłat |
| Kalendarz | table_calendar + własny widok dnia/tygodnia | konfigurowalne zaznaczanie wielu dat |

Skoro tylko Android, realna jest też wersja natywna: Kotlin + Jetpack Compose z tym samym backendem Firebase; wybierz ją, jeśli na pewno nie planujesz iOS. Alternatywa, jeśli wolisz unikać Google: React Native (Expo) + Supabase (Postgres, Realtime, Auth, Edge Functions) + Expo Notifications. Plan działa tak samo, zmienia się tylko warstwa danych.

Zasady techniczne dla Claude Code:

- Każdy dokument wspólny ma pole `householdId`; wszystkie zapytania filtrują po nim. Reguły bezpieczeństwa sprawdzają członkostwo w `households/{id}/members/{uid}`.
- Wpisy prywatne (notatki, wydarzenia) leżą w osobnej kolekcji `users/{uid}/private/...`, nie w kolekcji domu, żeby reguły były proste i nie dało się ich obejść.
- Identyfikatory generowane po stronie klienta (UUID), żeby zapis offline nie czekał na serwer.
- Czas przechowywany w UTC, strefa domu w ustawieniach domu.
- Testy: jednostkowe dla logiki cykli i budżetu, testy reguł Firestore w emulatorze, kilka testów widgetów Flutter na kluczowe ekrany.

Schemat: telefon (Flutter) ↔ Cloud Firestore (cache offline, Security Rules) ← Cloud Functions → FCM → telefon. Firebase Auth obsługuje logowanie.

Telefon rozmawia z Firestore przez lokalny cache, więc działa bez sieci; funkcje serwerowe reagują na zapisy w bazie, generują wystąpienia cykli, realizują zaproszenia QR i wysyłają push przez FCM.

## Model danych

Dane wspólne żyją pod jednym dokumentem domu; dane prywatne pod użytkownikiem. Reguła dostępu wynika wprost ze ścieżki.

| Kolekcja (Firestore) | Najważniejsze pola | Kto czyta / pisze |
| --- | --- | --- |
| `users/{uid}` | displayName, avatar, fcmTokens[], notificationPrefs, householdId, themeId, themeMode: light | dark | auto | właściciel |
| `users/{uid}/privateNotes/{id}` | title, body, pinned, updatedAt | tylko właściciel |
| `users/{uid}/privateEvents/{id}` | title, start, end, allDay, location, reminderMinutes, recurrence | tylko właściciel |
| `households/{hid}` | name, currency (PLN), timezone, weekStartsOn, createdBy | członkowie czytają; admin pisze |
| `households/{hid}/members/{uid}` | role: admin | member, displayName, joinedAt | członkowie czytają; admin pisze |
| `households/{hid}/invites/{code}` | qrToken, expiresAt, multiUse, createdBy, usedBy[] | admin; Cloud Function realizuje dołączenie |
| `households/{hid}/categories/{id}` | name, icon, color, order | członkowie czytają; admin pisze |
| `households/{hid}/expenses/{id}` | amount (grosze, int), date, categoryId, note, paidBy, createdBy | tylko admin (czyta i pisze) |
| `households/{hid}/budgetPlans/{yyyy-MM}` | limits: {categoryId: amount}, total | tylko admin |
| `households/{hid}/choreRules/{id}` | title, description, assigneeId, mode: once | recurring, recurrence (type, interval, weekdays[], monthDay, dates[], until), reminderTime | członkowie czytają; admin pisze |
| `households/{hid}/choreOccurrences/{id}` | ruleId, date, assigneeId, status: todo | done | skipped, doneBy, doneAt | członkowie czytają; assignee lub admin pisze |
| `households/{hid}/shoppingLists/{id}` | name, order | członkowie |
| `households/{hid}/shoppingLists/{id}/items/{id}` | name, quantity, unit, storeCategory, checked, checkedBy, addedBy | członkowie |
| `households/{hid}/notes/{id}` | title, body, pinned, createdBy, updatedAt | członkowie czytają; autor lub admin pisze |
| `households/{hid}/events/{id}` | title, start, end, allDay, location, participants[], reminderMinutes, recurrence, createdBy | członkowie czytają; autor lub admin pisze |

Uwagi do modelu:

- Kwoty jako liczby całkowite w groszach; nigdy float.
- `recurrence.type` przyjmuje: `daily`, `weekly`, `monthly`, `customDates`. Dla `customDates` lista `dates[]` jest źródłem prawdy i wystąpienia powstają tylko dla nich.
- Wystąpienia obowiązków generuje Cloud Function przy zapisie reguły i codziennie o 00:05 czasu domu, zawsze do 90 dni w przód; edycja reguły regeneruje tylko przyszłe, nieodhaczone wystąpienia.
- Przełączenie notatki lub wydarzenia z prywatnego na wspólne to przeniesienie dokumentu między kolekcjami (transakcja), nie zmiana flagi.
- Indeksy złożone: expenses (householdId, date), choreOccurrences (date, assigneeId), items (checked, order).

## Plan prac w etapach

Siedem etapów, każdy kończy się działającą aplikacją na telefonie. Kolejność jest celowa: najpierw wspólna lista zakupów (najprostszy moduł, a sprawdza całą synchronizację), budżet i widżety na końcu.

1. Fundament: projekt Flutter, Firebase (Auth, Firestore, emulatory), logowanie, zakładanie domu, dołączanie kodem QR i kodem tekstowym, lista domowników, role, reguły bezpieczeństwa z testami.
2. Lista zakupów: wspólna lista, dodawanie, odhaczanie, czyszczenie kupionych, podpowiedzi z historii, synchronizacja na żywo i offline.
3. Notatnik i kalendarz: notatki wspólne i prywatne, wydarzenia wspólne i prywatne, widoki miesiąc / tydzień / dzień, prosta cykliczność wydarzeń.
4. Plan obowiązków: reguły jednorazowe i cykliczne z pełną konfiguracją (w tym daty wybierane z kalendarza), Cloud Function generująca wystąpienia, widok „Dziś”, odhaczanie, obowiązki w kalendarzu.
5. Budżet (admin): kategorie, wydatki, filtrowanie i sortowanie, wykres kołowy, plan miesięczny z paskami i ostrzeżeniami, ukrycie modułu dla Domowników.
6. Powiadomienia push: FCM, tokeny, preferencje, Cloud Functions dla każdego zdarzenia, deep linki, lokalne przypomnienia o obowiązkach i wydarzeniach.
7. Widżety i wykończenie: widżety „Dziś” i „Zakupy” na Androida, ikona i ekran startowy z misiem PorządMisiem, ustawienia z wyborem motywu (13 motywów z tabeli, podgląd na żywo, test kontrastu), onboarding, przygotowanie do sklepów.

Definicja „zrobione” dla każdego etapu:

- [ ] Funkcja działa na dwóch telefonach z Androidem zalogowanych do tego samego domu.
- [ ] Zmiana wykonana offline pojawia się u drugiej osoby po odzyskaniu sieci.
- [ ] Reguły bezpieczeństwa mają test na dostęp dozwolony i zabroniony.
- [ ] Brak ostrzeżeń `flutter analyze`, testy jednostkowe przechodzą.

Poza MVP (do kolejnych wersji): kilka list zakupów, rotacja obowiązków, eksport budżetu do CSV, załączniki w notatkach, wersja na tablet, język angielski, wersja iOS.

## Dokumenty towarzyszące

- `docs/GUI.md` – wytyczne interfejsu (layout, komponenty, miś w UI).
- `docs/wytyczne-logo-i-ikon.pdf` – logo, ikona aplikacji, ikony.

## Jak uruchomić Claude Code z tym planem

Wyeksportuj ten dokument do Markdown, zapisz go w repozytorium jako `PLAN.md` i obok połóż krótki `CLAUDE.md` z zasadami pracy. Potem prowadź Claude Code etap po etapie, nie całością naraz.

Przygotowanie na komputerze:

1. Zainstaluj Flutter SDK, Android Studio (SDK + emulator); sprawdź `flutter doctor`.
2. Załóż projekt w konsoli Firebase, włącz Auth, Firestore, Cloud Messaging i Functions; zainstaluj `firebase-tools` i `flutterfire`.
3. Utwórz puste repozytorium git, wejdź do niego i uruchom `claude`.

Proponowana treść `CLAUDE.md`:

```markdown
# PorządMiś – zasady pracy

- Czytaj PLAN.md przed każdym zadaniem; realizuj dokładnie jeden etap naraz.
- Stack: Flutter 3.x, Riverpod, Firebase (Auth, Firestore, Functions w TypeScript, FCM).
- Cel: tylko Android (minSdk 26). Nie dodawaj konfiguracji ani kodu iOS.
- Struktura: lib/features/<moduł>/{data,domain,ui}, lib/core, functions/src.
- Kwoty w groszach (int). Czas w UTC. Identyfikatory UUID z klienta.
- Każda zmiana reguł Firestore wymaga testu w emulatorze (allow + deny).
- Przed zakończeniem zadania: flutter analyze, flutter test, npm test w functions/.
- Nie dodawaj zależności spoza listy w PLAN.md bez pytania.
- Teksty interfejsu po polsku, w pliku lib/l10n/app_pl.arb.
- Kolory tylko przez tokeny motywu (ThemeExtension); żadnych hexów w widgetach. Motywy w assets/themes/*.json.
```

Pierwsze polecenia dla Claude Code, po kolei:

1. „Przeczytaj PLAN.md i CLAUDE.md. Zaproponuj strukturę katalogów i listę zależności w pubspec.yaml dla etapu 1. Nie pisz jeszcze kodu.”
2. „Zrealizuj etap 1 z PLAN.md: projekt, Firebase, logowanie, dom, QR, role, reguły bezpieczeństwa z testami. Pracuj w małych commitach.”
3. Po każdym etapie: „Uruchom testy, popraw ostrzeżenia, zaktualizuj README o to, co działa. Potem zaczynamy etap N+1.”

Wskazówki, które oszczędzają czas:

- Trzymaj emulatory Firebase uruchomione podczas pracy (`firebase emulators:start`), żeby agent mógł sam testować reguły i funkcje.
- Widżety (etap 7) wymagają kodu natywnego w Kotlinie; bez iOS nie potrzebujesz Maca ani Xcode, wystarczy Windows lub Linux.
- Przy każdym etapie wklejaj agentowi tylko tę część planu, której dotyczy, plus model danych; długi kontekst obniża jakość.
- Gdy agent proponuje zmianę modelu danych, najpierw zaktualizuj PLAN.md, potem kod.
