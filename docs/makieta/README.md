# PorządMiś — interaktywna makieta GUI

Wersja przygotowana na podstawie `GUI.md` z 29 października 2026 r. oraz planu aplikacji Porządniś.

## Uruchomienie

1. Rozpakuj ZIP do folderu.
2. Otwórz `index.html` w aktualnej przeglądarce Chrome, Edge lub Firefox.
3. Możesz korzystać z makiety na komputerze albo w przeglądarce telefonu.
4. Domyślnie wyświetlany jest tryb Administratora. W `Ustawienia → Wygoda korzystania → Podgląd roli` przełącz na Domownika.
5. W `Ustawienia → Motyw aplikacji` wybierz jeden z 13 motywów i użyj `Zastosuj motyw`.

## Widoki i demonstracyjne interakcje

- **Dziś**: moje zadania, najbliższe wydarzenie, skrót do zakupów, dodawanie nowego wpisu.
- **Zakupy**: dodawanie produktu bez otwierania formularza, odhaczanie, przywracanie i czyszczenie kupionych.
- **Obowiązki**: wybór dnia, filtrowanie, przypisywanie i oznaczanie realizacji; domownik nie może odhaczać cudzych zadań.
- **Kalendarz**: widok miesiąca, tygodnia i dnia, wydarzenia prywatne i wspólne.
- **Notatki**: filtrowanie, wyszukiwanie, otwieranie, edycja, przypinanie i prywatność.
- **Budżet**: demonstracyjny wykres kołowy, podsumowanie wydatków, filtry i plan; ukryty dla Domownika.
- **Domownicy**: demonstracyjny widok ról i kodu zaproszenia.
- **Ustawienia**: 13 motywów, powiadomienia, powiększanie tekstu, przełączanie roli, onboarding.

## Zgodność z GUI.md

- Mobile-first, pięć pozycji paska dolnego (dla Administratora piąta = Więcej, dla Domownika = Notatki).
- Nunito z fallbackiem do czcionki systemowej (Google Fonts wymaga Internetu).
- Jasny i ciemny wariant, kolory pochodzące z 13 zestawów motywów.
- Karty z obramowaniami, bez gradientów i dekoracyjnych cieni.
- Miś w ekranie uruchomienia, onboardingu, pustych stanach i pozytywnych komunikatach; własny wektor SVG ma charakter tymczasowy do czasu podmiany na docelowy sygnet.
- Duże obszary dotyku, responsywność 320–1440 px, obsługa ograniczenia animacji.

## Ograniczenia makiety

To **samodzielny prototyp HTML + CSS + JavaScript**, a nie produkcyjna aplikacja Flutter. Przechowuje dane przykładowe w `localStorage` bieżącej przeglądarki. Nie korzysta z Firebase, nie umożliwia rzeczywistego logowania, zaproszeń QR, synchronizacji czy prawdziwej kontroli dostępu po stronie serwera. Formularz cykliczności obowiązków demonstruje jedynie podstawowe opcje; pełne reguły należy wdrożyć w Flutterze według planu.

W folderze `docs/` znajduje się dostarczony plik źródłowych wytycznych. W pliku `assets/` znajdują się tymczasowe sygnety misia, które można zastąpić oficjalnym logo bez zmiany układu ekranów.

Wszystkie dane w makiecie są fikcyjne.
