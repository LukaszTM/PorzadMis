# PorządMiś – paczka logo i ikon v1.1

Przygotowana na podstawie „PorządMiś – wytyczne logo i ikon, wersja 1.1”, 30.10.2026.

## Zawartość

- `brand/porzadmis-sygnet.svg` – sygnet 120 × 120 według tabeli geometrii na stronie 4.
- `brand/porzadmis-logo-pion.svg` – znak pionowy, nazwa pod misiem.
- `brand/porzadmis-logo-poziom.svg` – logo poziome w pełnym kolorze.
- `brand/porzadmis-logo-poziom-atrament.svg` – logo jednobarwne na jasnym tle.
- `brand/porzadmis-logo-poziom-krem.svg` – logo jednobarwne na ciemnym tle.
- `brand/porzadmis-logo-poziom.png` – eksport o szerokości **2400 px**, przezroczyste tło.
- `brand/porzadmis-logo-pion.png` – dodatkowy eksport pionowy.
- `brand/png/` – dodatkowe przezroczyste PNG sygnetu 20/48/96/192/512 px.
- `brand/porzadmis-sygnet-odpoczywa.svg` – wariant do pustych list (zmienione wyłącznie oczy).
- `assets/images/splash_logo.svg` – pionowe logo na ekran powitalny.
- `assets/images/ptaszek-zrobione.svg` – osobny nowy znak ptaszka do odhaczania (wersja opcjonalna, patrz niżej).
- `android/app/src/main/res/drawable/ic_launcher_*.xml` – vector drawable: tło, pełnokolorowy pierwszy plan, monochromatyczny Android 13+.
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` – konfiguracja ikony adaptacyjnej.
- `android/app/src/main/res/drawable/ic_notification.xml` – ikona jednobarwna do powiadomień.
- `android/app/src/main/res/mipmap-*/ic_launcher.png` – ikony dla starszych wersji Androida.
- `store/play/icon-512.png` – ikona 512 × 512.
- `store/play/feature-graphic.png` – grafika 1024 × 500.

## Geometria i kolor

- Płaski styl, bez obrysu dekoracyjnego, cienia i gradientu.
- Futro `#C2601A`, krem `#FBF7F1`, atrament `#1C2733`, ptaszek `#2B7A57`.
- Nos `(60,73)` i ścieżka uśmiechu `M50.5 82.5 C53 88.5 56.5 91.5 60 91 C65 90.5 68.5 85 70 78` o grubości 3.5, zakończenia/łączenia zaokrąglone.
- Tekst zamieniono na kontury kroju **Nunito ExtraBold 800** (bez osadzania fontu w paczce).
- Wariant monochromatyczny zawiera przezroczyste wycięcia elementów twarzy; jego kolor jest określony przez jeden wypełniony kontur.
- W ikonie adaptacyjnej znak pozostaje w centralnym bezpiecznym obszarze około 66/108 dp.

## Wdrożenie i kwestie do sprawdzenia

1. Umieść zasoby Androida w folderze `android/app/src/main/res/`. Jeśli projekt posiada już te pliki, połącz je ostrożnie, zachowując jego nazwy zasobów i manifest.
2. W Flutterze źródłem barw sygnetu powinien pozostać `lib/core/ui/mis_mark.dart`; pliki SVG/PNG są wynikowymi grafikami marki.
3. W wytycznych v1.1 decyzja o ujednoliceniu ptaszka w polu odhaczania (dotąd linia v1.0) jest otwarta. Ten ZIP zawiera gotowy ptaszek v1.1 jako **propozycję**, nie zmienia kodu aplikacji.
4. Grafiki Google Play i monochromatyczne drawable są nowymi eksportami; sprawdź wygląd i przycinanie ikony w Android Studio → Image Asset przed publikacją, jak nakazuje dokument.
5. Wersje logo na przezroczystym tle wymagają zachowania odpowiedniego tła do wybranego wariantu (kremowy mono na ciemnym tle, atramentowy mono na jasnym).
6. Zgodnie z dokumentem zapewnij wokół znaku wolne pole ~32 jednostek z 120 i nie zmniejszaj sygnetu poniżej 20 dp.

