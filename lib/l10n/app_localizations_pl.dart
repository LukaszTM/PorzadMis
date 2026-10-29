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
  String get startSubtitle => 'Dołącz do domu albo załóż nowy.';

  @override
  String get createHouseholdAction => 'Załóż nowy dom';

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
}
