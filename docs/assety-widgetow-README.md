# PorządMiś — czyste assety widżetów Android

Zestaw niezależnych elementów graficznych dla dwóch planowanych widżetów: **Dziś** i **Zakupy**. Żaden plik assetu nie zawiera napisu, licznika, godziny, obudowy telefonu ani gotowej karty z treścią. Podgląd PNG zawiera podpisy pomocnicze — nie jest assetem do wdrożenia.

## Struktura

- `assets/illustrations_3d/` — transparentne ilustracje miś, dom, zakupy, obowiązki, kalendarz, notatki, budżet. Warianty 512, 256 i 128 px, pełny miś także 768 px.
- `assets/mini_icons/` — małe ilustracje produktów i czynności: 12 obiektów. Każdy jako osobny SVG oraz PNG 128 i 256 px.
- `assets/controls_svg/` — 19 ikon sterowania bez tła, SVG wykorzystujący `currentColor` do barwienia przez motyw.
- `assets/controls_png/teal|white|navy/` — rasteryzowane kontrolki 48 i 96 px, do środowisk bez SVG.
- `PODGLAD_ASSETOW.png` — arkusz podglądowy, **nie wklejać do aplikacji**.

## Jak używać w widżecie

- **Dziś, rozmiar mały:** `bear_with_house_128.png` lub `task_list_128.png`, ikonka statusu `check_done` i licznik tworzony jako żywy tekst aplikacji.
- **Dziś, rozmiar średni:** `task_list_128.png` w nagłówku, wiersze danych budowane natywnie; `check_empty`/`check_done` to osobne przyciski o obszarze dotyku co najmniej 48 dp.
- **Zakupy, rozmiar mały:** `shopping_basket_128.png` oraz natywnie wygenerowany licznik.
- **Zakupy, rozmiar średni:** `shopping_basket_128.png` i maksymalnie pięć żywych nazw produktów; `milk`, `bread` itd. są dodatkowymi ikonkami, nie sztywnym tekstem.
- **Stan pusty:** `bear_resting_256.png`. Wersja pełna `bear_logo_full_512.png` sprawdzi się przy większym polu.
- Tła, promienie rogów, obramowania, pasek postępu, cyfry i teksty tworzyć **w kodzie widżetu** z tokenów wybranego motywu, nie wypalać ich do PNG.
- Widżety Android wymagają własnej implementacji (np. Kotlin/Glance lub home_widget); te pliki są wyłącznie assetami. Nie są instalowalnym widżetem ani gotową aplikacją.
- Widżety nie powinny pokazywać budżetu ani notatek prywatnych. Ilustracja budżetu służy tylko aplikacji, nie widżetom.

## Właściwości plików

- PNG: RGBA, **rzeczywista przezroczystość**, czyste pojedyncze assety, bez napisów.
- SVG: wektory do samodzielnego skalowania; sterowanie używa `currentColor`.
- Nazwy plików ASCII, małe litery i podkreślniki, przyjazne Android `drawable`.
- Ikony 3D wyodrębnione z poprzednich projektów PorządMisia. Drobne wektorowe ikony produktów i sterowania wykonane jako uzupełnienie.

## Uwagi

W PNG są wyłącznie pojedyncze ilustracje, bez tła. Niektóre assety 3D zawierają naturalne wewnętrzne cieniowanie postaci/obiektu, ale nie dodają karty ani cienia zewnętrznego widżetu.
