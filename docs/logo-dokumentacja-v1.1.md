# Polecenie dla ChatGPT (wklej całość i wyślij)

Na podstawie poniższej dokumentacji przygotuj profesjonalny, dwukolumnowo czytelny dokument PDF
„PorządMiś – wytyczne logo i ikon, wersja 1.1” (A4, pionowo, 8–10 stron). Zachowaj wszystkie
liczby, kolory i nazwy plików dokładnie jak w tekście. Dodaj okładkę, spis treści, rysunki
poglądowe (sygnet w wersji pełnokolorowej, jednokolorowej na jasnym i ciemnym tle, pole
ochronne, błędne użycia) oraz tabele z kolorami i rozmiarami. Język: polski. Styl: ciepły,
prosty, bez żargonu. Nie dodawaj żadnych informacji spoza tekstu.

---

# PorządMiś – wytyczne logo i ikon, wersja 1.1

Data: 30 października 2026. Wersja 1.1 zastępuje 1.0. Zmiana: nowy ptaszek-uśmiech w pysku misia.

## 1. Idea znaku

Znakiem PorządMisia jest głowa misia – **sygnet**. Miś jest gospodarzem aplikacji: pomaga
ogarnąć dom razem z rodziną. Ptaszek („zrobione”) jest częścią pyska i czyta się jednocześnie
jako uśmiech i jako odhaczenie. Znak jest płaski: bez cieni, obrysów i gradientów.

## 2. Co zmieniło się w wersji 1.1

W wersji 1.0 ptaszek był prostą, ostro zagiętą linią, która wystawała poza pysk i nachodziła
na nos. W wersji 1.1:

- ptaszek jest **zaokrąglony**, jak uśmiech z lekko uniesionym prawym końcem,
- cały ptaszek mieści się **wewnątrz pyska**, pod nosem,
- **nos przesunięto w górę** (z y = 79 na y = 73), żeby zrobić miejsce na uśmiech,
- grubość linii ptaszka zmniejszono z 4,5 do 3,5 (w układzie 120 × 120).

## 3. Budowa sygnetu (układ 120 × 120)

| Element | Kształt | Położenie (x, y) | Rozmiar | Kolor |
| --- | --- | --- | --- | --- |
| Ucho lewe, zewnętrzne | koło | 30, 30 | r = 16 | futro |
| Ucho prawe, zewnętrzne | koło | 90, 30 | r = 16 | futro |
| Ucho lewe, wewnętrzne | koło | 30, 30 | r = 8 | krem |
| Ucho prawe, wewnętrzne | koło | 90, 30 | r = 8 | krem |
| Głowa | koło | 60, 66 | r = 42 | futro |
| Pysk | elipsa | 60, 81 | rx = 21, ry = 15 | krem |
| Oko lewe | koło | 45, 66 | r = 4,5 | atrament |
| Oko prawe | koło | 75, 66 | r = 4,5 | atrament |
| Nos | elipsa | 60, 73 | rx = 5, ry = 3,5 | atrament |
| Ptaszek-uśmiech | linia | patrz niżej | grubość 3,5 | ptaszek |

Ścieżka ptaszka (SVG, układ 120 × 120):

```
M50.5 82.5 C53 88.5 56.5 91.5 60 91 C65 90.5 68.5 85 70 78
```

Zakończenia linii i łączenia: okrągłe (`stroke-linecap="round"`, `stroke-linejoin="round"`).
Kolejność rysowania: uszy, głowa, pysk, oczy, nos, ptaszek.

## 4. Kolory

| Nazwa | Kod | Użycie |
| --- | --- | --- |
| Futro | #C2601A | uszy i głowa misia |
| Krem | #FBF7F1 | wnętrza uszu, pysk, tło jasne |
| Atrament | #1C2733 | oczy, nos, napis na jasnym tle |
| Ptaszek | #2B7A57 | uśmiech-ptaszek |

Miś ma **stałe kolory we wszystkich motywach aplikacji**. Jedynym miejscem w kodzie, gdzie
wolno wpisać te kolory na stałe, jest plik sygnetu (w aplikacji: `lib/core/ui/mis_mark.dart`).

## 5. Wariant „odpoczywa”

Do pustych stanów list. Różni się od podstawowego **wyłącznie oczami**: zamiast kropek są
łuki (zamknięte oczy). Nic poza oczami się nie zmienia: ani poza, ani kolory, ani ptaszek.

## 6. Wersje i pliki

| Plik | Zastosowanie |
| --- | --- |
| `brand/porzadmis-sygnet.svg` | sygnet samodzielny, pełnokolorowy |
| `brand/porzadmis-logo-pion.svg` | sygnet nad napisem |
| `brand/porzadmis-logo-poziom.svg` | sygnet obok napisu, wersja pełnokolorowa |
| `brand/porzadmis-logo-poziom-atrament.svg` | wersja jednokolorowa, atrament na jasnym tle |
| `brand/porzadmis-logo-poziom-krem.svg` | wersja jednokolorowa, krem na ciemnym tle |
| `assets/images/splash_logo.svg` | ekran powitalny |
| `android/.../drawable/ic_launcher_*.xml` | ikona aplikacji Android 8+ (tło, pierwszy plan, monochromatyczna Android 13+) |
| `android/.../drawable/ic_notification.xml` | mała ikona powiadomień |
| `store/play/icon-512.png`, `feature-graphic.png` | grafiki Google Play 512 × 512 i 1024 × 500 |

## 7. Pole ochronne i minimalne rozmiary (propozycja)

- Pole ochronne: wolna przestrzeń równa **szerokości jednego ucha** (ok. 32 jednostek z 120)
  wokół całego znaku. Nic nie wchodzi w to pole.
- Minimalny rozmiar sygnetu na ekranie: **20 dp** (toast, komunikat). Poniżej tego rozmiaru
  ptaszek przestaje być czytelny.
- Minimalna szerokość logo poziomego: **120 dp**.
- Ikona aplikacji: znak mieści się w bezpiecznej strefie ikony adaptacyjnej (66 z 108 dp).

## 8. Miś w aplikacji – pięć miejsc

1. ekran startowy (splash): logo pionowe na tle motywu,
2. onboarding: duży sygnet i jedno zdanie na ekran,
3. pusty stan listy: sygnet 96 dp w wariancie „odpoczywa”,
4. ptaszek w polu odhaczania i w plakietce „zrobione”,
5. komunikaty pozytywne i neutralne: sygnet 20 dp po lewej od tekstu.

Miś **nie** pojawia się w nagłówkach ekranów, na przyciskach, jako awatar użytkownika ani
przy komunikatach o błędach. Nie zmienia stroju, pozy ani koloru futra.

## 9. Czego nie robić

- nie zmieniać kolorów futra ani ptaszka (także w motywach ciemnych i różowych),
- nie dodawać cieni, obrysów, gradientów ani efektów 3D,
- nie obracać, nie rozciągać i nie przechylać znaku,
- nie przenosić ptaszka poza pysk ani nie wracać do wersji 1.0 (prosty, wystający ptaszek),
- nie umieszczać znaku na tle o niskim kontraście względem futra (#C2601A),
- nie zmieniać napisu na inny krój niż wybrany w pkt. 10.

## 10. Napis i typografia – sprawy otwarte

- Wymagany krój napisu: **Nunito ExtraBold 800**, w krzywych. W pakiecie 1.0 napis używa kroju
  zastępczego **Lato Black**. Przed zatwierdzeniem znaku trzeba zamienić ścieżki napisu na Nunito.
- Napis nie jest edytowalnym tekstem w SVG, tylko konturem.

## 11. Co trzeba jeszcze wyeksportować po zmianie ptaszka (stan na 30.10.2026)

Zaktualizowane w kodzie i plikach wektorowych: sygnet, logo pionowe, logo poziome
pełnokolorowe, splash, ikona launchera (pierwszy plan), miś w aplikacji.

Wymagają ponownego wyeksportowania z nowego SVG:
- `brand/porzadmis-logo-poziom.png` (2400 px),
- `store/play/icon-512.png` i `store/play/feature-graphic.png`,
- `brand/porzadmis-logo-poziom-atrament.svg` i `-krem.svg` (miś zamieniony na kontury),
- `ic_launcher_monochrome.xml` i `ic_notification.xml` (sylwetki jednokolorowe; ptaszek
  musi być w nich wycięty lub zaznaczony w nowym kształcie),
- ptaszek w polu odhaczania w aplikacji nadal ma kształt prostej linii z wersji 1.0
  (`M50 84 l6 6 14-14`); do decyzji, czy ujednolicić go z nowym uśmiechem.

Przed publikacją w sklepie: podgląd przycięcia ikony w Android Studio (Image Asset).
