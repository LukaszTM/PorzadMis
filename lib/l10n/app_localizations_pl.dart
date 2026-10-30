// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'PorządMiś';

  @override
  String get back => 'Wróć';

  @override
  String get loading => 'Wczytywanie…';

  @override
  String get loginTitle => 'Zaloguj się';

  @override
  String get registerTitle => 'Załóż konto';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'np. ania@poczta.pl';

  @override
  String get passwordLabel => 'Hasło';

  @override
  String get passwordHint => 'Co najmniej 6 znaków';

  @override
  String get nameLabel => 'Jak masz na imię?';

  @override
  String get nameHint => 'np. Ania';

  @override
  String get loginAction => 'Zaloguj';

  @override
  String get registerAction => 'Załóż konto';

  @override
  String get googleAction => 'Zaloguj przez Google';

  @override
  String get goRegister => 'Nie masz konta? Załóż je';

  @override
  String get goLogin => 'Masz już konto? Zaloguj się';

  @override
  String get errEmailEmpty => 'Wpisz adres e-mail';

  @override
  String get errEmailInvalid => 'Wpisz poprawny adres e-mail';

  @override
  String get errPasswordEmpty => 'Wpisz hasło';

  @override
  String get errPasswordShort => 'Hasło musi mieć co najmniej 6 znaków';

  @override
  String get errNameEmpty => 'Wpisz swoje imię';

  @override
  String get errWrongCredentials => 'Nieprawidłowy e-mail lub hasło';

  @override
  String get errEmailInUse => 'Ten adres jest już zajęty. Zaloguj się';

  @override
  String get errNetwork => 'Brak połączenia z internetem';

  @override
  String get errGeneric => 'Coś poszło nie tak. Spróbuj ponownie';

  @override
  String get errGoogleCancelled => 'Logowanie przez Google przerwano';

  @override
  String get startTitle => 'Cześć, jestem PorządMiś';

  @override
  String get startSubtitle => 'Korzystaj sam albo razem z domownikami.';

  @override
  String get soloAction => 'Zacznij tylko dla siebie';

  @override
  String get soloHouseholdName => 'Mój dom';

  @override
  String get createHouseholdAction => 'Załóż dom z rodziną';

  @override
  String get joinAction => 'Dołącz do domu';

  @override
  String get createHouseholdTitle => 'Nowy dom';

  @override
  String get householdNameLabel => 'Nazwa domu';

  @override
  String get householdNameHint => 'np. Dom Kowalskich';

  @override
  String get errHouseholdNameEmpty => 'Wpisz nazwę domu';

  @override
  String get createAction => 'Załóż dom';

  @override
  String get joinTitle => 'Dołącz do domu';

  @override
  String get joinCodeLabel => 'Kod z zaproszenia';

  @override
  String get joinCodeHint => 'np. K7M2QX';

  @override
  String get joinScanAction => 'Zeskanuj kod QR';

  @override
  String get joinSubmit => 'Dołącz';

  @override
  String get errCodeEmpty => 'Wpisz kod z zaproszenia';

  @override
  String get scanTitle => 'Skanuj kod QR';

  @override
  String get scanHint => 'Skieruj aparat na kod QR z telefonu Administratora';

  @override
  String get errScanInvalid => 'To nie jest kod PorządMisia';

  @override
  String get errCamera => 'Brak dostępu do aparatu. Wpisz kod ręcznie';

  @override
  String get toastJoined => 'Dołączono do domu';

  @override
  String homeGreeting(String name) {
    return 'Dzień dobry, $name';
  }

  @override
  String get homeHouseholdCard => 'Twój dom';

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osoby',
      many: '$count osób',
      few: '$count osoby',
      one: '$count osoba',
    );
    return '$_temp0';
  }

  @override
  String get inviteAction => 'Zaproś domownika';

  @override
  String get signOut => 'Wyloguj';

  @override
  String get leaveAction => 'Opuść dom';

  @override
  String get confirmLeaveTitle => 'Opuścić dom?';

  @override
  String get confirmLeaveBody =>
      'Stracisz dostęp do wspólnych danych tego domu.';

  @override
  String confirmLeaveSoloBody(String name) {
    return 'Dom „$name” zostanie usunięty razem ze wszystkimi danymi.';
  }

  @override
  String get membersTitle => 'Domownicy';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleMember => 'Domownik';

  @override
  String get youBadge => 'to ty';

  @override
  String get makeAdmin => 'Nadaj rolę Administratora';

  @override
  String get removeAdmin => 'Odbierz rolę Administratora';

  @override
  String get removeMember => 'Usuń z domu';

  @override
  String get confirmRoleTitle => 'Zmienić rolę?';

  @override
  String confirmGiveAdminBody(String name) {
    return '$name zostanie Administratorem.';
  }

  @override
  String confirmTakeAdminBody(String name) {
    return '$name przestanie być Administratorem.';
  }

  @override
  String get confirmRemoveTitle => 'Usunąć z domu?';

  @override
  String confirmRemoveBody(String name) {
    return '$name straci dostęp do wspólnych danych.';
  }

  @override
  String get confirmYes => 'Tak';

  @override
  String get toastSaved => 'Zapisano';

  @override
  String get inviteTitle => 'Zaproszenie';

  @override
  String get adminOnlyBadge => 'tylko Administrator';

  @override
  String get inviteSingleUse => 'Jednorazowe';

  @override
  String get inviteMultiUse => 'Wielokrotne';

  @override
  String get inviteCreate => 'Utwórz zaproszenie';

  @override
  String get inviteCodeLabel => 'Kod tekstowy';

  @override
  String get inviteValid => 'Ważne 24 godziny';

  @override
  String inviteUsedBy(int count) {
    return 'Dołączyli: $count';
  }

  @override
  String get inviteCopy => 'Skopiuj kod';

  @override
  String get toastCopied => 'Skopiowano kod';

  @override
  String get inviteRevoke => 'Unieważnij';

  @override
  String get inviteRevoked => 'Zaproszenie unieważniono';

  @override
  String get inviteQrSemantics => 'Kod QR zaproszenia';

  @override
  String get navToday => 'Pulpit';

  @override
  String get navShopping => 'Zakupy';

  @override
  String get shoppingTitle => 'Zakupy';

  @override
  String get shoppingAddHint => 'Co dopisać? np. chleb';

  @override
  String get shoppingAddAction => 'Dodaj do listy';

  @override
  String shoppingToBuy(int count) {
    return 'Do kupienia · $count';
  }

  @override
  String shoppingBought(int count) {
    return 'Kupione · $count';
  }

  @override
  String get shoppingClear => 'Wyczyść';

  @override
  String get shoppingEmpty => 'Lista pusta – dopisz pierwszą rzecz.';

  @override
  String get shoppingAllBought => 'Wszystko kupione. Miś odpoczywa.';

  @override
  String get errShoppingName => 'Wpisz nazwę produktu';

  @override
  String get errShoppingDuplicate => 'Już jest na liście';

  @override
  String get toastAddedToList => 'Dodano do listy';

  @override
  String get toastCleared => 'Wyczyszczono kupione';

  @override
  String get toastUndo => 'Cofnij';

  @override
  String get toastOffline => 'Brak połączenia – zmiany wyślą się później';

  @override
  String get itemEditTitle => 'Pozycja na liście';

  @override
  String get itemEditAction => 'Edytuj pozycję';

  @override
  String get itemNameLabel => 'Nazwa';

  @override
  String get itemQuantityLabel => 'Ilość';

  @override
  String get itemQuantityHint => 'np. 2';

  @override
  String get itemUnitLabel => 'Jednostka';

  @override
  String get itemUnitHint => 'np. szt';

  @override
  String get itemCategoryLabel => 'Dział';

  @override
  String get itemDone => 'Gotowe';

  @override
  String get itemDelete => 'Usuń pozycję';

  @override
  String get catProduce => 'Warzywa i owoce';

  @override
  String get catBakery => 'Pieczywo';

  @override
  String get catDairy => 'Nabiał';

  @override
  String get catMeat => 'Mięso i ryby';

  @override
  String get catDrinks => 'Napoje';

  @override
  String get catHousehold => 'Chemia i dom';

  @override
  String get catOther => 'Inne';

  @override
  String get shoppingCardTitle => 'Lista zakupów';

  @override
  String get shoppingCardNone => 'Nic do kupienia';

  @override
  String shoppingCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rzeczy do kupienia',
      many: '$count rzeczy do kupienia',
      few: '$count rzeczy do kupienia',
      one: '$count rzecz do kupienia',
    );
    return '$_temp0';
  }

  @override
  String shoppingAddedBy(String name) {
    return 'dodał(a): $name';
  }

  @override
  String get toastRemoved => 'Usunięto z listy';

  @override
  String get navCalendar => 'Kalendarz';

  @override
  String get navNotes => 'Notatki';

  @override
  String get notesTitle => 'Notatki';

  @override
  String get notesSearchHint => 'Szukaj w notatkach';

  @override
  String get notesFilterAll => 'Wszystkie';

  @override
  String get notesFilterShared => 'Wspólne';

  @override
  String get notesFilterMine => 'Tylko moje';

  @override
  String get notesEmpty => 'Brak notatek – dopisz pierwszą.';

  @override
  String get notesNoResults => 'Nic nie znaleziono.';

  @override
  String get noteNew => 'Nowa';

  @override
  String get noteNewTitle => 'Nowa notatka';

  @override
  String get noteEditTitle => 'Notatka';

  @override
  String get noteTitleHint => 'Tytuł';

  @override
  String get noteBodyHint => 'Treść… Listę zacznij od „- ”';

  @override
  String get noteVisibilityLabel => 'Kto widzi';

  @override
  String get visibilityAll => 'wszyscy w domu';

  @override
  String get visibilityMe => 'tylko ja';

  @override
  String get notePin => 'Przypnij';

  @override
  String get noteUnpin => 'Odepnij';

  @override
  String get noteDelete => 'Usuń notatkę';

  @override
  String get noteSave => 'Gotowe';

  @override
  String noteMeta(String name, String date) {
    return '$name · $date';
  }

  @override
  String get errNoteEmpty => 'Wpisz tytuł albo treść';

  @override
  String get toastNoteRemoved => 'Usunięto notatkę';

  @override
  String get readOnlyNote => 'Notatka innej osoby – tylko do odczytu';

  @override
  String get calendarTitle => 'Kalendarz';

  @override
  String get calendarMonth => 'Miesiąc';

  @override
  String get calendarWeek => 'Tydzień';

  @override
  String get calendarEmptyDay => 'Nic zaplanowanego. Miś odpoczywa.';

  @override
  String get calendarLegendEvent => 'wydarzenie';

  @override
  String get calendarLegendChore => 'obowiązek';

  @override
  String get eventNew => 'Nowe';

  @override
  String get eventNewTitle => 'Nowe wydarzenie';

  @override
  String get eventEditTitle => 'Wydarzenie';

  @override
  String get eventTitleHint => 'Co się dzieje? np. Dentysta';

  @override
  String get eventTimed => 'O godzinie';

  @override
  String get eventAllDay => 'Cały dzień';

  @override
  String get eventStartLabel => 'Początek';

  @override
  String get eventEndLabel => 'Koniec';

  @override
  String get eventDateLabel => 'Dzień';

  @override
  String get eventEndDateLabel => 'Ostatni dzień';

  @override
  String get eventLocationLabel => 'Miejsce';

  @override
  String get eventLocationHint => 'np. Przychodnia';

  @override
  String get eventDescriptionLabel => 'Opis';

  @override
  String get eventRepeatLabel => 'Powtarzaj';

  @override
  String get repeatNone => 'Nie';

  @override
  String get repeatWeekly => 'Co tydzień';

  @override
  String get repeatMonthly => 'Co miesiąc';

  @override
  String get repeatYearly => 'Co rok';

  @override
  String get eventReminderLabel => 'Przypomnienie';

  @override
  String get reminderNone => 'Bez';

  @override
  String get reminderAtTime => 'W porze';

  @override
  String get reminderHour => '1 h wcześniej';

  @override
  String get reminderDay => 'Dzień wcześniej';

  @override
  String get eventParticipantsLabel => 'Kto bierze udział';

  @override
  String get eventDelete => 'Usuń wydarzenie';

  @override
  String get errEventTitle => 'Wpisz nazwę wydarzenia';

  @override
  String get errEventEnd => 'Koniec musi być po początku';

  @override
  String get toastEventRemoved => 'Usunięto wydarzenie';

  @override
  String get readOnlyEvent => 'Wydarzenie innej osoby – tylko do odczytu';

  @override
  String get allDayLabel => 'cały dzień';

  @override
  String get repeatsLabel => 'powtarza się';

  @override
  String get homeNextEvent => 'Najbliżej w kalendarzu';

  @override
  String get homeNoEvents => 'Nic zaplanowanego';

  @override
  String get homeNotesCard => 'Notatki';

  @override
  String homeNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notatki',
      many: '$count notatek',
      few: '$count notatki',
      one: '$count notatka',
      zero: 'Brak notatek',
    );
    return '$_temp0';
  }

  @override
  String get dateToday => 'Dziś';

  @override
  String get dateTomorrow => 'Jutro';

  @override
  String get navChores => 'Zadania';

  @override
  String get choresTitle => 'Zadania';

  @override
  String choresMine(String day) {
    return 'Moje · $day';
  }

  @override
  String get choresOthers => 'Inni domownicy';

  @override
  String get choresEmptyMine => 'Nic do zrobienia. Miś odpoczywa.';

  @override
  String get choresEmptyOthers => 'Nikt nic nie ma na ten dzień.';

  @override
  String get choresSomeone => 'ktoś';

  @override
  String choresDoneBy(String name) {
    return 'zrobione: $name';
  }

  @override
  String get choreNew => 'Nowy';

  @override
  String get choreNewTitle => 'Nowy obowiązek';

  @override
  String get choreEditTitle => 'Obowiązek';

  @override
  String get choreTitleHint => 'Co trzeba zrobić? np. Wynieść śmieci';

  @override
  String get choreDescriptionLabel => 'Opis (opcjonalnie)';

  @override
  String get choreWhoLabel => 'Kto';

  @override
  String get choreWhenLabel => 'Kiedy';

  @override
  String get choreOnce => 'Jednorazowo';

  @override
  String get choreRecurring => 'Cyklicznie';

  @override
  String get choreFirstDay => 'Pierwszy dzień';

  @override
  String get choreDay => 'Termin';

  @override
  String get choreCycleLabel => 'Cykl';

  @override
  String get cycleDaily => 'Co N dni';

  @override
  String get cycleWeekly => 'Dni tygodnia';

  @override
  String get cycleMonthly => 'Dzień miesiąca';

  @override
  String get cycleCustom => 'Wybrane daty';

  @override
  String get choreIntervalDays => 'Co ile dni';

  @override
  String get choreIntervalWeeks => 'Co ile tygodni';

  @override
  String get choreIntervalMonths => 'Co ile miesięcy';

  @override
  String get choreMonthDay => 'Dzień miesiąca (1–31)';

  @override
  String get choreWeekdaysLabel => 'W które dni';

  @override
  String get chorePickDates => 'Zaznacz dni w kalendarzu';

  @override
  String choreDatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'wybrano $count dni',
      many: 'wybrano $count dni',
      few: 'wybrano $count dni',
      one: 'wybrano $count dzień',
      zero: 'nie wybrano dni',
    );
    return '$_temp0';
  }

  @override
  String get choreUntilLabel => 'Koniec cyklu';

  @override
  String get choreUntilNone => 'Bez końca';

  @override
  String get choreUntilPick => 'Wybierz dzień';

  @override
  String get choreReminderLabel => 'Przypomnienie rano';

  @override
  String get choreReminderNone => 'Bez';

  @override
  String get choreDelete => 'Usuń obowiązek';

  @override
  String choreDeleteBody(String title) {
    return 'Obowiązek „$title” zniknie razem z zaplanowanymi terminami.';
  }

  @override
  String get errChoreTitle => 'Wpisz nazwę obowiązku';

  @override
  String get errChoreWeekdays => 'Zaznacz co najmniej jeden dzień tygodnia';

  @override
  String get errChoreDates => 'Zaznacz co najmniej jeden dzień';

  @override
  String get errChoreInterval => 'Wpisz liczbę większą od zera';

  @override
  String get toastChoreRemoved => 'Usunięto obowiązek';

  @override
  String get adminOnlyChores => 'Obowiązki dodaje Administrator';

  @override
  String get weekdayMon => 'Pn';

  @override
  String get weekdayTue => 'Wt';

  @override
  String get weekdayWed => 'Śr';

  @override
  String get weekdayThu => 'Cz';

  @override
  String get weekdayFri => 'Pt';

  @override
  String get weekdaySat => 'So';

  @override
  String get weekdaySun => 'Nd';

  @override
  String get homeTodayCard => 'Dziś do zrobienia';

  @override
  String get homeTodayDone => 'Wszystko zrobione';

  @override
  String get homeShowAll => 'pokaż wszystkie';

  @override
  String get chipTodo => 'do zrobienia';

  @override
  String get chipDone => 'zrobione';

  @override
  String get ruleEditHint => 'Zmiany przeliczą przyszłe terminy';

  @override
  String get navMore => 'Więcej';

  @override
  String get moreTitle => 'Więcej';

  @override
  String get moreBudget => 'Budżet';

  @override
  String get moreMembers => 'Domownicy';

  @override
  String get moreNotes => 'Notatki';

  @override
  String get moreInvite => 'Zaproś domownika';

  @override
  String get budgetTitle => 'Budżet';

  @override
  String get budgetSpent => 'wydano';

  @override
  String budgetOfPlan(String spent, String plan) {
    return '$spent z $plan';
  }

  @override
  String get budgetNoPlan => 'Bez planu na ten miesiąc';

  @override
  String get budgetSetPlan => 'Ustaw plan';

  @override
  String get budgetEditPlan => 'Edytuj plan';

  @override
  String get budgetByCategory => 'Według kategorii';

  @override
  String get budgetRecent => 'Wydatki';

  @override
  String get budgetEmpty => 'Brak wydatków w tym miesiącu.';

  @override
  String get budgetAdd => 'Dodaj wydatek';

  @override
  String get budgetSortDate => 'Data';

  @override
  String get budgetSortAmountDesc => 'Największe';

  @override
  String get budgetSortAmountAsc => 'Najmniejsze';

  @override
  String get budgetFilterAll => 'Wszystkie kategorie';

  @override
  String budgetFilterChip(String name) {
    return 'filtr: $name';
  }

  @override
  String get budgetClearFilter => 'Pokaż wszystkie';

  @override
  String get budgetPrevMonth => 'Poprzedni miesiąc';

  @override
  String get budgetNextMonth => 'Następny miesiąc';

  @override
  String get budgetWarn80 => 'Zbliżasz się do planu';

  @override
  String get budgetOver => 'Plan przekroczony';

  @override
  String get expenseNewTitle => 'Nowy wydatek';

  @override
  String get expenseEditTitle => 'Wydatek';

  @override
  String get expenseAmountLabel => 'Kwota (zł)';

  @override
  String get expenseAmountHint => 'np. 24,99';

  @override
  String get expenseDateLabel => 'Data';

  @override
  String get expenseCategoryLabel => 'Kategoria';

  @override
  String get expenseNoteLabel => 'Opis (opcjonalnie)';

  @override
  String get expenseNoteHint => 'np. zakupy w Biedronce';

  @override
  String get expensePaidByLabel => 'Kto zapłacił';

  @override
  String get expensePaidNobody => 'nie wiadomo';

  @override
  String get expenseDelete => 'Usuń wydatek';

  @override
  String get errExpenseAmount => 'Wpisz kwotę większą od zera';

  @override
  String get errExpenseCategory => 'Wybierz kategorię';

  @override
  String get toastExpenseRemoved => 'Usunięto wydatek';

  @override
  String get planTitle => 'Plan miesiąca';

  @override
  String get planTotalLabel => 'Łącznie na miesiąc (zł)';

  @override
  String get planCategoryHint => '0';

  @override
  String get planCopyPrevious => 'Skopiuj z poprzedniego miesiąca';

  @override
  String get planCopied => 'Skopiowano plan';

  @override
  String get planNoPrevious => 'Poprzedni miesiąc nie ma planu';

  @override
  String get planSave => 'Zapisz plan';

  @override
  String get budgetAdminBadge => 'tylko Administrator';

  @override
  String get budgetMemberBlocked => 'Budżet widzi tylko Administrator';

  @override
  String categoryLimit(String spent, String limit) {
    return '$spent z $limit';
  }

  @override
  String paidByMeta(String name, String date) {
    return '$name · $date';
  }

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get moreSettings => 'Ustawienia';

  @override
  String get settingsNotifications => 'Powiadomienia';

  @override
  String get settingsNotificationsHint =>
      'Każdy domownik ustawia to dla siebie.';

  @override
  String get prefChores => 'Nowy obowiązek i poranne przypomnienia';

  @override
  String get prefEvents => 'Przypomnienia o wydarzeniach';

  @override
  String get prefShopping => 'Nowa pozycja na liście zakupów';

  @override
  String get prefMembers => 'Nowy domownik dołączył';

  @override
  String get prefBudget => 'Przekroczenie planu budżetu (tylko Administrator)';

  @override
  String get prefOn => 'włączone';

  @override
  String get prefOff => 'wyłączone';

  @override
  String get notifPermissionDenied =>
      'Powiadomienia są wyłączone w systemie. Włącz je w ustawieniach telefonu.';

  @override
  String get notifChannelName => 'PorządMiś';

  @override
  String get notifChannelDescription =>
      'Przypomnienia o obowiązkach i wydarzeniach, nowości w domu';

  @override
  String reminderChoreTitle(String title) {
    return '$title – dziś';
  }

  @override
  String get reminderChoreBody => 'Obowiązek na dziś.';

  @override
  String reminderEventTitle(String title, String when) {
    return '$title – $when';
  }

  @override
  String get reminderEventBody => 'Wydarzenie z kalendarza.';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String settingsVersion(String version) {
    return 'PorządMiś, wersja $version';
  }

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get appearanceTitle => 'Wygląd';

  @override
  String get themeModeLabel => 'Tryb';

  @override
  String get themeModeLight => 'Jasny';

  @override
  String get themeModeDark => 'Ciemny';

  @override
  String get themeModeAuto => 'Auto';

  @override
  String get themeModeHint =>
      'Auto: jasny w dzień, ciemny w nocy, według ustawienia telefonu.';

  @override
  String get themeGroupDefault => 'PorządMiś';

  @override
  String get themeGroupPycharm => 'Inspirowane PyCharm';

  @override
  String get themeGroupPink => 'Różowe';

  @override
  String get themeApply => 'Zastosuj motyw';

  @override
  String get themeApplied => 'Zastosowano motyw';

  @override
  String get themePreviewHint =>
      'Dotknij kafelka, żeby zobaczyć podgląd. Zapis po „Zastosuj motyw”.';

  @override
  String get themeSample => 'Tak wygląda tekst i przycisk';

  @override
  String get onboarding1 => 'Cześć, jestem PorządMiś';

  @override
  String get onboarding2 => 'Pomagam ogarnąć dom razem z rodziną';

  @override
  String get onboarding3 => 'Dołącz do domu albo załóż nowy';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String get onboardingStart => 'Zaczynamy';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get themeAutoDarkHint =>
      'Telefon jest teraz w trybie ciemnym, więc w „Auto” zobaczysz ciemny motyw. Wybierz „Jasny”, żeby użyć jasnego.';

  @override
  String get themeAutoLightHint =>
      'Telefon jest teraz w trybie jasnym, więc w „Auto” zobaczysz jasny motyw. Wybierz „Ciemny”, żeby użyć ciemnego.';

  @override
  String get homeActivityHint => 'Dotknij karty, żeby przejść dalej';

  @override
  String get homeBreadcrumb => 'Pulpit';

  @override
  String get homeEyebrow => 'TWOJA PRZESTRZEŃ';

  @override
  String get homeHello => 'Dzień dobry!';

  @override
  String homeHelloName(String name) {
    return 'Dzień dobry, $name!';
  }

  @override
  String homeSubtitle(String date) {
    return 'Dzisiaj jest $date. Zobacz, co dzieje się w Twoim domu.';
  }

  @override
  String get heroEyebrowCalm => 'SPOKOJNIE, WSZYSTKO POD KONTROLĄ';

  @override
  String get heroEyebrowBusy => 'DZIŚ JEST CO ROBIĆ';

  @override
  String get heroTitle => 'Małe sprawy. Więcej czasu dla siebie.';

  @override
  String get heroBody =>
      'Domowe zadania, wspólne plany i zakupy – razem w jednym miejscu.';

  @override
  String get heroAdd => 'Dodaj coś nowego';

  @override
  String get statTasks => 'Moje zadania dziś';

  @override
  String get statShopping => 'Na liście zakupów';

  @override
  String get statEvents => 'Najbliższe wydarzenia';

  @override
  String get todayCardTitle => 'Do zrobienia dzisiaj';

  @override
  String get todayCardAll => 'Wszystkie';

  @override
  String todayCardWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zadania czekają na wykonanie',
      many: '$count zadań czeka na wykonanie',
      few: '$count zadania czekają na wykonanie',
      one: '$count zadanie czeka na wykonanie',
      zero: 'Nic nie czeka na wykonanie',
    );
    return '$_temp0';
  }

  @override
  String get youLabel => 'Ty';

  @override
  String get quickAddTitle => 'Co dodać?';

  @override
  String get quickAddShopping => 'Produkt na listę zakupów';

  @override
  String get quickAddChore => 'Zadanie';

  @override
  String get quickAddEvent => 'Wydarzenie w kalendarzu';

  @override
  String get quickAddNote => 'Notatkę';

  @override
  String get settingsAccount => 'Konto';
}
