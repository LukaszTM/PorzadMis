# PorządMiś — kolorowe GUI 2026 i 13 motywów

Otwórz `index.html` w Chrome lub Edge po rozpakowaniu ZIP — makieta działa lokalnie i nie wymaga serwera.

## Motywy

Kliknij **Motywy** (ikona palety / gwiazdki w nagłówku) na dowolnym ekranie. Wybór pokazuje zmianę kolorów natychmiast; **Zastosuj** zapisuje wybór lokalnie. Zamknięcie panelu bez zatwierdzenia cofa podgląd. Te same palety są dostępne w Ustawieniach.

**Firmowe:** PorządMiś kremowy, PorządMiś noc.

**Inspirowane PyCharm i IDE:** Darcula, IntelliJ Light, High Contrast, Dracula, One Dark, Monokai, Solarized Light, Nord.

**Różowe:** Róż pastelowy, Róż intensywny, Róż nocny.

Nazwy inspirowanych palet nie oznaczają oficjalnego powiązania z JetBrains; są to własne zestawy dla PorządMisia.

## Interakcje

Działa nawigacja, zakupy, odhaczanie obowiązków, lista notatek, kalendarz, budżet, przełączanie podglądu roli, modale i powiększanie tekstu. Dane demonstracyjne zapisują się w localStorage. Administrator widzi budżet, Domownik nie.

## Grafiki / wykorzystanie w Androidzie

- `assets/brand/mis-logo-bez-napisu.png` — sygnet z przezroczystością, bez napisów.
- `assets/brand/google-play-512.png` — 512×512 px, PNG RGBA, sRGB, pełny kwadrat, bez tekstu i zewnętrznego cienia; do listing'u Google Play (wymaga ostatecznej weryfikacji w Play Console).
- `assets/brand/ic_launcher_foreground.png` i `ic_launcher_background.png` — punkt wyjściowy do adaptacyjnej ikony, nie w pełni zweryfikowany pod kątem maskowania na wszystkich urządzeniach.
- `assets/icons/*.png` — samodzielne, przezroczyste ikony/ilustracje bez napisów.

Makieta korzysta z prawdziwych plików PNG w katalogu assets — nie są to grafiki wklejone w zrzuty ekranu.

## Wdrożenie Flutter

Założyć `ThemeExtension` i odwzorować tokeny `background`, `surface`, `text`, `textMuted`, `border`, `accent`, `onAccent`, `accentSoft`, `warning`, `danger`, `success`, `chart1..chart5`. Wszystkie kolory ekranów powinny pochodzić z tokenów. W trybach ciemnych także notatki i wykresy muszą utrzymać kontrast. Zachować uprawnienia Administratorów/Domowników po stronie Firebase (prototyp nie posiada serwera).

## Prawa i ograniczenia

Grafiki wygenerowane dla projektu; są to obrazy rastrowe. Motywy z nazwami PyCharm i IDE są **inspirowane**, nie stanowią elementów oficjalnej marki ani produktów JetBrains. Przed produkcyjnym użyciem sprawdź wygląd najmniejszych ikon, tekst alternatywny, kontrasty wszystkich stanów, działanie przy 130% skali, adaptacyjną maskę ikony oraz dostępność TalkBack.
