import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pl')];

  /// No description provided for @appName.
  ///
  /// In pl, this message translates to:
  /// **'PorządMiś'**
  String get appName;

  /// No description provided for @back.
  ///
  /// In pl, this message translates to:
  /// **'Wróć'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie…'**
  String get loading;

  /// No description provided for @loginTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In pl, this message translates to:
  /// **'Załóż konto'**
  String get registerTitle;

  /// No description provided for @emailLabel.
  ///
  /// In pl, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In pl, this message translates to:
  /// **'np. ania@poczta.pl'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In pl, this message translates to:
  /// **'Hasło'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In pl, this message translates to:
  /// **'Co najmniej 6 znaków'**
  String get passwordHint;

  /// No description provided for @nameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Jak masz na imię?'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Ania'**
  String get nameHint;

  /// No description provided for @loginAction.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj'**
  String get loginAction;

  /// No description provided for @registerAction.
  ///
  /// In pl, this message translates to:
  /// **'Załóż konto'**
  String get registerAction;

  /// No description provided for @googleAction.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj przez Google'**
  String get googleAction;

  /// No description provided for @goRegister.
  ///
  /// In pl, this message translates to:
  /// **'Nie masz konta? Załóż je'**
  String get goRegister;

  /// No description provided for @goLogin.
  ///
  /// In pl, this message translates to:
  /// **'Masz już konto? Zaloguj się'**
  String get goLogin;

  /// No description provided for @errEmailEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz adres e-mail'**
  String get errEmailEmpty;

  /// No description provided for @errEmailInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poprawny adres e-mail'**
  String get errEmailInvalid;

  /// No description provided for @errPasswordEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz hasło'**
  String get errPasswordEmpty;

  /// No description provided for @errPasswordShort.
  ///
  /// In pl, this message translates to:
  /// **'Hasło musi mieć co najmniej 6 znaków'**
  String get errPasswordShort;

  /// No description provided for @errNameEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz swoje imię'**
  String get errNameEmpty;

  /// No description provided for @errWrongCredentials.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy e-mail lub hasło'**
  String get errWrongCredentials;

  /// No description provided for @errEmailInUse.
  ///
  /// In pl, this message translates to:
  /// **'Ten adres jest już zajęty. Zaloguj się'**
  String get errEmailInUse;

  /// No description provided for @errNetwork.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z internetem'**
  String get errNetwork;

  /// No description provided for @errGeneric.
  ///
  /// In pl, this message translates to:
  /// **'Coś poszło nie tak. Spróbuj ponownie'**
  String get errGeneric;

  /// No description provided for @errGoogleCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie przez Google przerwano'**
  String get errGoogleCancelled;

  /// No description provided for @startTitle.
  ///
  /// In pl, this message translates to:
  /// **'Cześć, jestem PorządMiś'**
  String get startTitle;

  /// No description provided for @startSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Korzystaj sam albo razem z domownikami.'**
  String get startSubtitle;

  /// No description provided for @soloAction.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij tylko dla siebie'**
  String get soloAction;

  /// No description provided for @soloHouseholdName.
  ///
  /// In pl, this message translates to:
  /// **'Mój dom'**
  String get soloHouseholdName;

  /// No description provided for @createHouseholdAction.
  ///
  /// In pl, this message translates to:
  /// **'Załóż dom z rodziną'**
  String get createHouseholdAction;

  /// No description provided for @joinAction.
  ///
  /// In pl, this message translates to:
  /// **'Dołącz do domu'**
  String get joinAction;

  /// No description provided for @createHouseholdTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy dom'**
  String get createHouseholdTitle;

  /// No description provided for @householdNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa domu'**
  String get householdNameLabel;

  /// No description provided for @householdNameHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Dom Kowalskich'**
  String get householdNameHint;

  /// No description provided for @errHouseholdNameEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę domu'**
  String get errHouseholdNameEmpty;

  /// No description provided for @createAction.
  ///
  /// In pl, this message translates to:
  /// **'Załóż dom'**
  String get createAction;

  /// No description provided for @joinTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dołącz do domu'**
  String get joinTitle;

  /// No description provided for @joinCodeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kod z zaproszenia'**
  String get joinCodeLabel;

  /// No description provided for @joinCodeHint.
  ///
  /// In pl, this message translates to:
  /// **'np. K7M2QX'**
  String get joinCodeHint;

  /// No description provided for @joinScanAction.
  ///
  /// In pl, this message translates to:
  /// **'Zeskanuj kod QR'**
  String get joinScanAction;

  /// No description provided for @joinSubmit.
  ///
  /// In pl, this message translates to:
  /// **'Dołącz'**
  String get joinSubmit;

  /// No description provided for @errCodeEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz kod z zaproszenia'**
  String get errCodeEmpty;

  /// No description provided for @scanTitle.
  ///
  /// In pl, this message translates to:
  /// **'Skanuj kod QR'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In pl, this message translates to:
  /// **'Skieruj aparat na kod QR z telefonu Administratora'**
  String get scanHint;

  /// No description provided for @errScanInvalid.
  ///
  /// In pl, this message translates to:
  /// **'To nie jest kod PorządMisia'**
  String get errScanInvalid;

  /// No description provided for @errCamera.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępu do aparatu. Wpisz kod ręcznie'**
  String get errCamera;

  /// No description provided for @toastJoined.
  ///
  /// In pl, this message translates to:
  /// **'Dołączono do domu'**
  String get toastJoined;

  /// No description provided for @homeGreeting.
  ///
  /// In pl, this message translates to:
  /// **'Dzień dobry, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeHouseholdCard.
  ///
  /// In pl, this message translates to:
  /// **'Twój dom'**
  String get homeHouseholdCard;

  /// No description provided for @membersCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{{count} osoba} few{{count} osoby} many{{count} osób} other{{count} osoby}}'**
  String membersCount(int count);

  /// No description provided for @inviteAction.
  ///
  /// In pl, this message translates to:
  /// **'Zaproś domownika'**
  String get inviteAction;

  /// No description provided for @signOut.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj'**
  String get signOut;

  /// No description provided for @leaveAction.
  ///
  /// In pl, this message translates to:
  /// **'Opuść dom'**
  String get leaveAction;

  /// No description provided for @confirmLeaveTitle.
  ///
  /// In pl, this message translates to:
  /// **'Opuścić dom?'**
  String get confirmLeaveTitle;

  /// No description provided for @confirmLeaveBody.
  ///
  /// In pl, this message translates to:
  /// **'Stracisz dostęp do wspólnych danych tego domu.'**
  String get confirmLeaveBody;

  /// No description provided for @confirmLeaveSoloBody.
  ///
  /// In pl, this message translates to:
  /// **'Dom „{name}” zostanie usunięty razem ze wszystkimi danymi.'**
  String confirmLeaveSoloBody(String name);

  /// No description provided for @membersTitle.
  ///
  /// In pl, this message translates to:
  /// **'Domownicy'**
  String get membersTitle;

  /// No description provided for @roleAdmin.
  ///
  /// In pl, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In pl, this message translates to:
  /// **'Domownik'**
  String get roleMember;

  /// No description provided for @youBadge.
  ///
  /// In pl, this message translates to:
  /// **'to ty'**
  String get youBadge;

  /// No description provided for @makeAdmin.
  ///
  /// In pl, this message translates to:
  /// **'Nadaj rolę Administratora'**
  String get makeAdmin;

  /// No description provided for @removeAdmin.
  ///
  /// In pl, this message translates to:
  /// **'Odbierz rolę Administratora'**
  String get removeAdmin;

  /// No description provided for @removeMember.
  ///
  /// In pl, this message translates to:
  /// **'Usuń z domu'**
  String get removeMember;

  /// No description provided for @confirmRoleTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zmienić rolę?'**
  String get confirmRoleTitle;

  /// No description provided for @confirmGiveAdminBody.
  ///
  /// In pl, this message translates to:
  /// **'{name} zostanie Administratorem.'**
  String confirmGiveAdminBody(String name);

  /// No description provided for @confirmTakeAdminBody.
  ///
  /// In pl, this message translates to:
  /// **'{name} przestanie być Administratorem.'**
  String confirmTakeAdminBody(String name);

  /// No description provided for @confirmRemoveTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć z domu?'**
  String get confirmRemoveTitle;

  /// No description provided for @confirmRemoveBody.
  ///
  /// In pl, this message translates to:
  /// **'{name} straci dostęp do wspólnych danych.'**
  String confirmRemoveBody(String name);

  /// No description provided for @confirmYes.
  ///
  /// In pl, this message translates to:
  /// **'Tak'**
  String get confirmYes;

  /// No description provided for @toastSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano'**
  String get toastSaved;

  /// No description provided for @inviteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zaproszenie'**
  String get inviteTitle;

  /// No description provided for @adminOnlyBadge.
  ///
  /// In pl, this message translates to:
  /// **'tylko Administrator'**
  String get adminOnlyBadge;

  /// No description provided for @inviteSingleUse.
  ///
  /// In pl, this message translates to:
  /// **'Jednorazowe'**
  String get inviteSingleUse;

  /// No description provided for @inviteMultiUse.
  ///
  /// In pl, this message translates to:
  /// **'Wielokrotne'**
  String get inviteMultiUse;

  /// No description provided for @inviteCreate.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz zaproszenie'**
  String get inviteCreate;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kod tekstowy'**
  String get inviteCodeLabel;

  /// No description provided for @inviteValid.
  ///
  /// In pl, this message translates to:
  /// **'Ważne 24 godziny'**
  String get inviteValid;

  /// No description provided for @inviteUsedBy.
  ///
  /// In pl, this message translates to:
  /// **'Dołączyli: {count}'**
  String inviteUsedBy(int count);

  /// No description provided for @inviteCopy.
  ///
  /// In pl, this message translates to:
  /// **'Skopiuj kod'**
  String get inviteCopy;

  /// No description provided for @toastCopied.
  ///
  /// In pl, this message translates to:
  /// **'Skopiowano kod'**
  String get toastCopied;

  /// No description provided for @inviteRevoke.
  ///
  /// In pl, this message translates to:
  /// **'Unieważnij'**
  String get inviteRevoke;

  /// No description provided for @inviteRevoked.
  ///
  /// In pl, this message translates to:
  /// **'Zaproszenie unieważniono'**
  String get inviteRevoked;

  /// No description provided for @inviteQrSemantics.
  ///
  /// In pl, this message translates to:
  /// **'Kod QR zaproszenia'**
  String get inviteQrSemantics;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
