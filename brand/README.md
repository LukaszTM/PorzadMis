# PorządMiś — pakiet logo i ikon (wersja 1.0)

Opracowano na podstawie dokumentu „PorządMiś — wytyczne logo i ikon” (październik 2026).

Zawartość:
- `brand/`: sygnet, wersje pozioma i pionowa, warianty monochromatyczne oraz PNG 2400 px;
- `android/app/src/main/res/`: wektorowe warstwy ikony adaptacyjnej Android 8+, monochromatyczna ikona dla Android 13+, ikona powiadomienia i definicja launcher;
- `play/`: grafika sklepu Google Play 512 × 512 oraz feature graphic 1024 × 500;
- `assets/images/splash_logo.svg`: znak pionowy na ekran powitalny;
- `assets/icons/`: 12 ikon interfejsu SVG 24 × 24 z `currentColor`.

Kolory: futro #C2601A, krem #FBF7F1, atrament #1C2733, ptaszek #2B7A57. Kształty płaskie, bez cieni, obrysów czy gradientów.

**Ważna uwaga typograficzna:** Dokument wymaga Nunito ExtraBold 800 w krzywych. Pełny plik tej czcionki nie jest dostępny w środowisku. Aby dostarczyć gotowe SVG z konturami, literowanie używa kroju zastępczego **Lato Black**. Przed zatwierdzeniem finalnego znaku należy zamienić same ścieżki nazwy na Nunito ExtraBold 800. Sygnet, paleta kolorów, rozmiary i zasoby Androida nie wymagają tej korekty.

Zgodnie z wytycznymi w plikach SVG nie ma edytowalnego `<text>` w logo. Dla idealnej zgodności przed publikacją wymagany jest jeszcze przegląd czcionki i podgląd przycięcia ikony w Android Studio: Image Asset.
