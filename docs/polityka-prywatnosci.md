# Polityka prywatności aplikacji PorządMiś

Ostatnia aktualizacja: 30 października 2026

## 1. Kto odpowiada za dane

Administratorem danych przetwarzanych w aplikacji PorządMiś („Aplikacja”) jest Łukasz Kap
(„Administrator”). Kontakt w sprawach prywatności: kapslogranie@gmail.com.

## 2. Czym jest Aplikacja

PorządMiś to organizer domowy na Androida: wspólna lista zakupów, notatki, kalendarz,
obowiązki i budżet domu dla osób, które tworzą jeden „dom” w Aplikacji. Z Aplikacji można
korzystać również w pojedynkę.

## 3. Jakie dane przetwarzamy

| Dane | Skąd pochodzą | Po co |
| --- | --- | --- |
| Adres e‑mail, identyfikator konta, imię wyświetlane | Logowanie przez Google lub e‑mail (Firebase Authentication) | Założenie i rozpoznanie konta, pokazanie imienia domownikom |
| Treści wpisane w Aplikacji: pozycje listy zakupów, notatki, wydarzenia, obowiązki, wydatki, kategorie, nazwa domu, ustawienia | Wpisujesz je Ty lub inni domownicy | Działanie Aplikacji i synchronizacja między domownikami |
| Token powiadomień push (FCM) | Generowany przez urządzenie | Wysyłanie powiadomień o obowiązkach, wydarzeniach, zakupach i wydatkach, jeśli je włączysz |
| Preferencje: motyw, tryb, „Duży tekst”, ustawienia powiadomień | Wybierasz je w Ustawieniach | Zapamiętanie wyglądu i powiadomień na każdym Twoim urządzeniu |
| Zaproszenia (kod i token QR) | Tworzone przez Administratora domu | Dołączanie domowników do domu |

Aplikacja **nie** zbiera lokalizacji, kontaktów, zdjęć ani danych z innych aplikacji.
Nie korzysta z reklam, z zewnętrznych narzędzi analitycznych ani z profilowania.

Notatki oznaczone jako **prywatne** widzi tylko ich autor. Budżet domu widzi tylko
Administrator domu. Dane prywatne i budżet nigdy nie trafiają do widżetów ekranu głównego.

## 4. Gdzie dane są przechowywane

Dane przechowujemy w usługach Google Firebase (Firebase Authentication, Cloud Firestore,
Cloud Functions, Firebase Cloud Messaging) w regionie **europe‑west1** (Belgia, Unia
Europejska). Google LLC przetwarza je jako podmiot przetwarzający na podstawie umowy
powierzenia i standardowych klauzul umownych. Polityka prywatności Google:
<https://policies.google.com/privacy>.

Na urządzeniu Aplikacja trzyma kopię danych domu, żeby działać bez internetu, oraz dane
dla widżetów (lista do kupienia, dzisiejsze obowiązki, najbliższe wydarzenie, kolory motywu).

## 5. Podstawa prawna i cel

- wykonanie umowy o korzystanie z Aplikacji (art. 6 ust. 1 lit. b RODO) – konto, synchronizacja,
  powiadomienia, które sam(a) włączysz;
- prawnie uzasadniony interes Administratora (art. 6 ust. 1 lit. f RODO) – bezpieczeństwo,
  zapobieganie nadużyciom, diagnostyka błędów.

## 6. Kto widzi Twoje dane

- domownicy Twojego domu – wspólne listy, notatki współdzielone, wydarzenia, obowiązki i imiona;
- Administrator domu dodatkowo – wydatki, plan budżetu, zarządzanie domownikami i zaproszeniami;
- Google Firebase – jako dostawca infrastruktury.

Nie sprzedajemy danych i nie przekazujemy ich innym podmiotom.

## 7. Jak długo przechowujemy dane

- dane domu – do czasu usunięcia przez domownika lub Administratora domu (np. skreślenie pozycji,
  usunięcie notatki, opuszczenie domu);
- historia zakupów (nazwy kupowanych produktów, do podpowiedzi) – do czasu usunięcia domu;
- konto – do momentu usunięcia konta;
- tokeny powiadomień – usuwane po wylogowaniu lub gdy przestają działać.

## 8. Twoje prawa

Masz prawo do dostępu do danych, ich sprostowania, usunięcia, ograniczenia przetwarzania,
przenoszenia oraz sprzeciwu, a także do skargi do Prezesa Urzędu Ochrony Danych Osobowych.
Większość danych możesz zmienić lub usunąć bezpośrednio w Aplikacji. Aby usunąć konto wraz
ze wszystkimi danymi, napisz na adres podany w pkt 1 – usuniemy je w ciągu 30 dni.

## 9. Bezpieczeństwo

Dostęp do danych chronią reguły Firestore: każdy dokument domu jest dostępny tylko dla
zalogowanych domowników tego domu, a operacje wrażliwe (role, zaproszenia, usuwanie
domowników) wykonują funkcje serwerowe po sprawdzeniu uprawnień. Transmisja jest szyfrowana (TLS).

## 10. Dzieci

Aplikacja nie jest przeznaczona dla dzieci poniżej 13 lat i nie zbiera świadomie ich danych.
Konto dziecka w domu może założyć rodzic lub opiekun.

## 11. Zmiany polityki

O istotnych zmianach poinformujemy w Aplikacji. Aktualna wersja jest zawsze dostępna pod
adresem wskazanym w sklepie Google Play.
