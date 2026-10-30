# PorządMiś – wytyczne interfejsu (GUI)

Wersja 1.0 · 29 października 2026 · obowiązuje dla każdego ekranu aplikacji na Androida.

Cel: interfejs nowoczesny, ale ciepły; prosty dla dziecka i babci, a jednocześnie sprawny dla osoby, która w 10 sekund chce dopisać mleko do listy. Miś jest gospodarzem aplikacji – pojawia się tam, gdzie pomaga, i nigdy tam, gdzie przeszkadza.

---

## 1. Zasady nadrzędne

1. **Jedna rzecz naraz.** Każdy ekran ma jedną akcję główną (jeden duży przycisk w kolorze akcentu). Reszta jest drugorzędna i wygląda drugorzędnie.
2. **Czytelne bez okularów.** Tekst podstawowy 18 sp, nigdy mniej niż 14 sp. Kontrast tekstu do tła min. 4,5:1 w każdym z 13 motywów.
3. **Duże cele dotyku.** Minimum 48 × 48 dp; przyciski główne, pola tekstowe i wiersze list 56 dp.
4. **Zero żargonu.** „Dodaj”, „Gotowe”, „Wróć”. Nie „Submit”, „OK”, „Anuluj operację”.
5. **Każda ikona ma podpis** – w pasku dolnym, na przyciskach, w ustawieniach. Wyjątek: strzałka „wróć” i „X” zamykania, które mają `contentDescription`.
6. **Miś to gospodarz, nie dekoracja.** Pojawia się w 5 miejscach (sekcja 7) i nigdzie indziej.
7. **Kolory wyłącznie z tokenów motywu.** Żadnych hexów w widgetach. Ekran ma wyglądać dobrze w Kremowym, Darculi i Różu nocnym bez jednej poprawki.
8. **Zaokrąglone, miękkie, z lekką głębią.** Promienie 16–24 dp. Karty mają cienki obrys i miękki cień (elevation 1–2, kolor `text` z kryciem ok. 15 %). Gradient jest dozwolony w dwóch miejscach: karta-bohater na Pulpicie (`accent` → ciemniejszy `accent`) i tło ekranu Pulpit (`accentSoft` → `background` w górnej 1/3). Nigdzie indziej. *(Zmiana z 30.10.2026 na życzenie właściciela produktu; wcześniej: bez cieni i gradientów.)*

---

## 2. Siatka, odstępy, kształty

| Element | Wartość |
| --- | --- |
| Jednostka bazowa | 8 dp (wszystkie odstępy to wielokrotności 4 dp, preferowane 8) |
| Margines ekranu | 20 dp z lewej i prawej |
| Odstęp między kartami | 14 dp |
| Odstęp wewnątrz karty | 18 dp |
| Promień kart i paneli | 20 dp |
| Promień przycisków i pól | 16 dp |
| Promień plakietek (chip) | 999 dp (pełna pigułka) |
| Promień małych elementów (ikona w kółku, kafelek dnia) | 12–14 dp |
| Obramowanie kart | 1 dp, kolor `border` |
| Cienie | karty i kafelki: elevation 1–2, cień w kolorze `text` z kryciem ok. 15 %; karta-bohater: cień w kolorze `accent` (krycie 28 %, rozmycie 24 dp) |
| Pasek dolny | 64 dp wysokości + bezpieczny margines systemowy |
| Nagłówek ekranu | tytuł 28 sp ExtraBold, od góry 56 dp (pod paskiem statusu) |

Kształt kart jest ten sam co kształt głowy misia: miękki, pełny, bez kantów. Jeśli coś ma ostry róg, jest źle.

---

## 3. Typografia

Krój: **Nunito** (Google Fonts, licencja OFL), zapasowo systemowy Roboto.

| Rola | Rozmiar | Grubość | Użycie |
| --- | --- | --- | --- |
| Tytuł ekranu | 28 sp | 800 | „Zakupy”, „Budżet” |
| Powitanie / liczba główna | 26 sp | 800 | „Dzień dobry, Aniu”, „3 520 zł” |
| Tytuł karty | 20 sp | 800 | „Dziś do zrobienia” |
| Nagłówek sekcji | 17 sp | 800, kolor `textMuted` | „Do kupienia · 6” |
| Pozycja listy | 18 sp | 700 | nazwa produktu, obowiązku |
| Tekst zwykły | 16 sp | 500 | treść notatki |
| Meta / podpis | 14 sp | 700, kolor `textMuted` | „Tomek · codziennie” |
| Podpis ikony w pasku | 13 sp | 700 | „Dziś”, „Zakupy” |
| Plakietka | 13 sp | 800 | „wszyscy”, „tylko ja” |

Zasady:
- Wysokość linii 1,3–1,45. Nigdy tekst wielkimi literami poza plakietką statusu.
- Liczby pieniężne z odstępem tysięcy i przecinkiem: `1 420,50 zł`. Cyfry tabelaryczne (`FontFeature.tabularFigures()`).
- Daty po polsku, bez skrótów w nagłówkach: „Środa, 14 października”. W listach skrót: „13 paź”.
- Użytkownik może włączyć w ustawieniach „Duży tekst” (+2 sp w każdej roli). Layout musi to wytrzymać bez obcinania.

---

## 4. Kolory i tokeny

Pełna lista motywów jest w `PLAN.md` (sekcja „Motywy kolorystyczne”). Tu tylko znaczenie tokenów:

| Token | Do czego |
| --- | --- |
| `background` | tło ekranu |
| `surface` | karty, panele, pasek dolny, pola tekstowe |
| `text` | tekst główny, ikony aktywne w treści |
| `textMuted` | meta, podpisy, ikony nieaktywne |
| `border` | obramowania kart, separatory w listach |
| `accent` | przycisk główny, aktywna zakładka, checkbox, link |
| `onAccent` | tekst i ikona na `accent` |
| `accentSoft` | tło plakietek „wszystkie”, delikatne podświetlenie, kafelek dnia dzisiejszego |
| `success` | odhaczone, „zrobione” |
| `warning` | plan budżetu 80–100 %, obowiązek po terminie dziś |
| `danger` | przekroczony budżet, usuwanie |
| `chart1…chart5` | wycinki wykresu kołowego i paski kategorii |

Zasady:
- Miś (sygnet) ma stałe kolory we wszystkich motywach. Jedyny element z hexami w kodzie to plik SVG sygnetu.
- `danger` używamy oszczędnie: tylko przy przekroczeniu i usuwaniu. Czerwień na co dzień męczy.
- Obowiązki i wydarzenia w kalendarzu rozróżniamy kolorem **i** kształtem znacznika (kropka vs kreska), bo w motywach monochromatycznych kolory się zbliżają.
- Elementy prywatne („tylko ja”) mają kłódkę i tło `border` – nigdy samego koloru.

---

## 5. Komponenty

### 5.1 Pasek dolny (nawigacja)
- 5 pozycji: **Dziś · Zakupy · Obowiązki · Kalendarz · Notatki**. Dla Administratora piąta pozycja to **Więcej** (Notatki, Budżet, Domownicy, Ustawienia) – nigdy nie dokładamy szóstej zakładki.
- Ikona 26 dp + podpis 13 sp, zawsze razem. Aktywna: kolor `accent` + wypełnienie ikony 12 % `accent`. Nieaktywna: `textMuted`.
- Pasek jest na każdym ekranie głównym; znika na ekranach formularzy i pełnoekranowych (QR, onboarding).

### 5.2 Karta
- Tło `surface`, obramowanie 1 dp `border`, promień 20 dp, padding 18 dp.
- Tytuł karty po lewej, licznik lub akcja po prawej („1 z 3”, „Wyczyść”).
- Wiersze w karcie oddziela 1 dp `border`; ostatni wiersz bez separatora.
- Karta klikalna w całości ma strzałkę › po prawej (24 dp, `textMuted`).

### 5.3 Wiersz listy z odhaczaniem (zakupy, obowiązki)
- Wysokość min. 56 dp (60 w zakupach, 64 w obowiązkach z meta).
- Checkbox 34 × 34 dp, promień 10 dp, obrys 3 dp `accent`; po zaznaczeniu wypełnienie `accent` i biały (albo `onAccent`) ptaszek **w tym samym kształcie co uśmiech misia** (ścieżka `M50 84l6 6 14-14` z logo, przeskalowana).
- Cały wiersz jest celem dotyku, nie sam checkbox.
- Zaznaczony: tekst przekreślony, kolor `textMuted`, wiersz przesuwa się do sekcji „kupione / zrobione” z animacją 200 ms. Cofnięcie dotknięciem.
- Po prawej meta: kto dodał / kto ma zrobić (14 sp `textMuted`), bez awatarów w wierszu – awatar tylko w sekcji „Inni domownicy”.

### 5.4 Przycisk główny
- Pełna szerokość lub w nagłówku; 56 dp wysokości (48 w nagłówku), promień 16 dp, tło `accent`, tekst `onAccent` 18 sp ExtraBold.
- Jeden na ekran. Etykieta czasownikiem: „Dodaj”, „Zastosuj motyw”, „Gotowe”.
- Stan wciśnięcia: przyciemnienie 8 %, bez zmiany rozmiaru. Stan ładowania: tekst zamienia się w trzy kropki, przycisk nie znika.

### 5.5 Przycisk drugorzędny
- Obrys 2 dp `accent`, tekst `accent`, tło `surface`. Ta sama wysokość co główny.
- Przycisk tekstowy (trzeciorzędny): sam tekst `accent` 16 sp ExtraBold, min. 44 dp wysokości celu.

### 5.6 Pole tekstowe
- 56 dp, promień 16 dp, obrys 2 dp `border` (w fokusie `accent`), tekst 18 sp, placeholder `textMuted` z przykładem: „Co dopisać? np. chleb”.
- Etykieta nad polem tylko w formularzach wielopolowych; w pojedynczym polu wystarcza placeholder + `semanticsLabel`.
- Błąd: obrys `danger` + jedno zdanie pod polem, po polsku, mówiące co zrobić: „Wpisz kwotę większą od zera”.

### 5.7 Plakietka (chip)
- Pigułka, 13 sp ExtraBold, padding 4 × 10 dp.
- Statusy: `wszyscy` (tło `accentSoft`, tekst `accent` ciemny), `tylko ja` (tło `border`, tekst `textMuted`, kłódka 14 dp), `do zrobienia` (tło brzoskwiniowe / `warning` 15 %), `zrobione` (`success` 15 %).

### 5.8 Przełącznik segmentowy
- Dla wyborów 2–3 opcji (Jasny / Ciemny / Auto; Wszystkie / Wspólne / Tylko moje). Tło `surface`, obrys `border`, promień 16, aktywny segment `accent` + `onAccent`. Wysokość 44–52 dp.
- Zamiast rozwijanej listy, gdy opcji jest ≤ 3.

### 5.9 Arkusz dolny (bottom sheet)
- Do dodawania i edycji (nowy wydatek, nowy obowiązek, nowe wydarzenie). Promień górnych rogów 24 dp, uchwyt 40 × 4 dp, tytuł 20 sp, przycisk główny przyklejony na dole arkusza.
- Nie używamy pełnoekranowych dialogów modalnych z wyjątkiem onboardingu i skanera QR.

### 5.10 Kalendarz
- Siatka 7 kolumn, komórka 44 dp, nagłówki dni 13 sp `textMuted`. Dziś: tło `accent`, cyfra `onAccent`. Dni spoza miesiąca: `textMuted` 50 %.
- Znaczniki pod cyfrą: kropka `accent` = wydarzenie, kropka `chart2` (pomarańcz) = obowiązek, maks. 2 kropki. Legenda pod siatką, zawsze widoczna.
- Zaznaczanie wielu dat (tryb „wybrane daty” obowiązku): zaznaczone dni mają obrys 2 dp `accent` i wypełnienie `accentSoft`; licznik „wybrano 4 dni” nad przyciskiem.

### 5.11 Wykres kołowy (budżet)
- Pierścień (donut) o grubości 26 dp, bez etykiet na wycinkach; wartości w legendzie obok, w tej samej kolejności co wycinki. W środku: „wydano” + kwota.
- Dotknięcie wycinka podświetla go (reszta 40 % krycia) i filtruje listę poniżej. Nic nie animuje się dłużej niż 300 ms.
- Pasek „wydano / plan”: 10 dp, zaokrąglony; kolor `accent` do 80 %, `warning` 80–100 %, `danger` powyżej.

### 5.12 Powiadomienia (wygląd w systemie)
- Tytuł = co i kiedy: „Podlać kwiaty – dziś”. Treść = jedno zdanie, bez wykrzykników. Mała ikona = sylwetka misia (biała). Duża ikona = brak (nie powtarzamy misia dwa razy).
- Przyciski akcji w powiadomieniu: „Zrobione” i „Przypomnij za godzinę”.

### 5.13 Widżety ekranu głównego
- Tło `surface` motywu systemowego (jasny/ciemny), promień 20 dp, nagłówek z małą sylwetką misia 16 dp + „Dziś” / „Zakupy”.
- Odhaczanie z widżetu tym samym checkboxem 34 dp. Mały widżet: licznik + jedna pozycja; średni: do 5 pozycji.
- Widżet nigdy nie pokazuje budżetu ani wpisów prywatnych.

---

## 6. Układ kluczowych ekranów

### Dziś (ekran startowy)
1. Data + powitanie imieniem.
2. Karta „Dziś do zrobienia” z moimi obowiązkami (max 5, potem „pokaż wszystkie”).
3. Karta-skrót „Najbliżej w kalendarzu” (jedno wydarzenie).
4. Karta-skrót „Lista zakupów” (liczba niekupionych).
5. Pasek aktywności domu: „Tomek dodał „mleko” 5 min temu” (ostatnie 1 zdarzenie, tło `accentSoft`).
Kiedy nic nie ma do zrobienia: miś odpoczywa (sekcja 7).

### Zakupy
Pole „Co dopisać?” + przycisk ＋ na samej górze (najczęstsza akcja, bez klawiatury nie da się przeoczyć). Pod spodem karta „Do kupienia”, niżej „Kupione” z przyciskiem „Wyczyść”.

### Obowiązki
Pasek tygodnia z kropkami, dziś zaznaczone. Karta „Moje · dzień”, karta „Inni domownicy” z awatarem (inicjał w kółku) i plakietką statusu. Przycisk „Nowy” w nagłówku otwiera arkusz dolny: nazwa → kto → kiedy (jednorazowo / cyklicznie) → cykl (co N dni, dni tygodnia, dzień miesiąca, wybrane daty z kalendarza) → przypomnienie.

### Kalendarz
Siatka miesiąca na górze, lista dnia pod spodem z paskiem koloru po lewej (zielony = wydarzenie, pomarańcz = obowiązek). Plakietka widoczności przy każdym wydarzeniu.

### Notatki
Przełącznik Wszystkie / Wspólne / Tylko moje, pole szukania, lista kart. Przypięta notatka ma obrys 2 dp `accent` i pinezkę. Prywatna ma lekko inne tło (`background` zamiast `surface`) i kłódkę.

### Budżet (tylko Administrator)
Plakietka „tylko Administrator” pod tytułem (zawsze – żeby nikt nie pokazał tego ekranu domownikowi przez przypadek). Przełącznik miesiąca, karta z pierścieniem i paskiem planu, karta „Według kategorii” z sortowaniem, karta „Ostatnie wydatki”.

### Ustawienia → Wygląd
Przełącznik trybu, kafelki motywów w trzech grupach (PorządMiś · Inspirowane PyCharm · Różowe), podgląd na żywo, przycisk „Zastosuj motyw”.

---

## 7. Miś w interfejsie – gdzie i jak

Miś ma dokładnie pięć ról. Każda inna propozycja wymaga zmiany tego dokumentu.

| Miejsce | Forma | Zasada |
| --- | --- | --- |
| **Ekran startowy aplikacji (splash)** | logo pionowe na tle `background` motywu | 1 s, bez animacji poza łagodnym pojawieniem |
| **Onboarding (3 ekrany)** | duży sygnet + jedno zdanie na ekran: „Cześć, jestem PorządMiś”, „Pomagam ogarnąć dom razem z rodziną”, „Dołącz do domu albo załóż nowy” | zero funkcji do nauki; same przyciski „Dalej” i na końcu „Zaczynamy” |
| **Pusty stan listy** | sygnet 96 dp w kolorze z lekko przymkniętymi oczami (wariant „odpoczywa”: oczy jako łuki zamiast kropek) + zdanie: „Nic do zrobienia. Miś odpoczywa.” / „Lista pusta – dopisz pierwszą rzecz.” | jeden wariant graficzny więcej niż w logo (oczy); nic poza tym nie zmieniamy |
| **Checkbox i stan „zrobione”** | ptaszek w kształcie uśmiechu misia | ten sam kształt w checkboxie, plakietce „zrobione” i powiadomieniu „Zrobione” |
| **Komunikaty pomocnicze (toast / snackbar)** | sylwetka misia 20 dp po lewej od tekstu | tylko w komunikatach pozytywnych i neutralnych („Dodano do listy”, „Zapisano”). Nigdy przy błędach – błąd nie ma misia |

Czego miś nie robi:
- nie mówi w pierwszej osobie poza onboardingiem i pustym stanem („Dodano do listy”, a nie „Dodałem do listy”),
- nie pojawia się w nagłówkach ekranów, na przyciskach ani jako awatar użytkownika,
- nie ma animacji poza pojawieniem na splashu i 200 ms „mrugnięciem” po odhaczeniu ostatniego zadania dnia (opcjonalne, wyłączane w ustawieniach „Ogranicz animacje”),
- nie zmienia stroju, pozy ani koloru futra; wariant „odpoczywa” różni się tylko oczami.

---

## 8. Ton komunikatów

- Krótko, po polsku, bez wykrzykników: „Zapisano”, „Dodano do listy”, „Brak połączenia – zmiany wyślą się później”.
- Błędy mówią, co zrobić, nie co się stało: „Wpisz nazwę produktu” zamiast „Pole nie może być puste”.
- Potwierdzenia tylko przy usuwaniu i przy zmianie roli domownika. Reszta działa od razu z możliwością cofnięcia („Cofnij” w snackbarze przez 5 s).
- Zwracamy się per „ty”, imieniem w powitaniu. Bez „Drogi użytkowniku”.

---

## 9. Ruch i reakcje

- Standardowe przejścia 200–250 ms, krzywa `easeOutCubic`. Lista odhaczonych: przesunięcie 200 ms.
- Brak animacji dekoracyjnych. Jedyne „ozdobne” to mrugnięcie misia (sekcja 7), domyślnie włączone, respektuje systemowe „Ogranicz animacje”.
- Wibracja haptyczna lekka przy odhaczeniu i zaskanowaniu QR; nic więcej.
- Pociągnięcie w dół odświeża listy (choć synchronizacja działa sama) – ludzie tego oczekują.

---

## 10. Dostępność – lista kontrolna każdego ekranu

- [ ] Kontrast tekstu ≥ 4,5:1 i ikon ≥ 3:1 w motywach: Kremowy, Noc, High Contrast, Róż pastelowy (cztery skrajne; test automatyczny sprawdza wszystkie 13).
- [ ] Każdy element interaktywny ma ≥ 48 dp i `semanticsLabel` / `tooltip`.
- [ ] Ekran działa z „Dużym tekstem” (+2 sp) i systemowym powiększeniem 130 % bez obcinania.
- [ ] Informacja nie jest przekazywana samym kolorem (status = kolor + tekst lub ikona).
- [ ] Kolejność fokusu TalkBack: nagłówek → akcja główna → lista → pasek dolny.
- [ ] Działa jedną ręką: akcja główna i pasek dolny w dolnej połowie ekranu; w nagłówku tylko przycisk „Nowy / Dodaj” jako skrót.

---

## 11. Co jest poza tymi wytycznymi

- Tablety i orientacja pozioma (poza MVP).
- Tryb „dla dzieci” z uproszczonym interfejsem – pomysł na później; na razie prostota dla wszystkich.
- Własne ilustracje poza misiem – nie dodajemy; jeśli ekran potrzebuje obrazka, to jest nim miś albo nic.

---

## 12. Polecenie dla Claude Code

> Przeczytaj docs/GUI.md. Zbuduj w `lib/core/ui/` zestaw komponentów z sekcji 5 (karta, wiersz z odhaczaniem, przycisk główny i drugorzędny, pole tekstowe, plakietka, przełącznik segmentowy, arkusz dolny), każdy jako osobny widget korzystający wyłącznie z tokenów `ThemeExtension`. Dodaj test widgetowy sprawdzający, że żaden komponent nie zawiera literału `Color(0x…)`. Potem zbuduj ekran „Dziś” według sekcji 6, używając tylko tych komponentów.
