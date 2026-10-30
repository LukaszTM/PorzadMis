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

  /// No description provided for @navToday.
  ///
  /// In pl, this message translates to:
  /// **'Pulpit'**
  String get navToday;

  /// No description provided for @navShopping.
  ///
  /// In pl, this message translates to:
  /// **'Zakupy'**
  String get navShopping;

  /// No description provided for @shoppingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zakupy'**
  String get shoppingTitle;

  /// No description provided for @shoppingAddHint.
  ///
  /// In pl, this message translates to:
  /// **'Co dopisać? np. chleb'**
  String get shoppingAddHint;

  /// No description provided for @shoppingAddAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do listy'**
  String get shoppingAddAction;

  /// No description provided for @shoppingToBuy.
  ///
  /// In pl, this message translates to:
  /// **'Do kupienia · {count}'**
  String shoppingToBuy(int count);

  /// No description provided for @shoppingBought.
  ///
  /// In pl, this message translates to:
  /// **'Kupione · {count}'**
  String shoppingBought(int count);

  /// No description provided for @shoppingClear.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść'**
  String get shoppingClear;

  /// No description provided for @shoppingEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Lista pusta – dopisz pierwszą rzecz.'**
  String get shoppingEmpty;

  /// No description provided for @shoppingAllBought.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko kupione. Miś odpoczywa.'**
  String get shoppingAllBought;

  /// No description provided for @errShoppingName.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę produktu'**
  String get errShoppingName;

  /// No description provided for @errShoppingDuplicate.
  ///
  /// In pl, this message translates to:
  /// **'Już jest na liście'**
  String get errShoppingDuplicate;

  /// No description provided for @toastAddedToList.
  ///
  /// In pl, this message translates to:
  /// **'Dodano do listy'**
  String get toastAddedToList;

  /// No description provided for @toastCleared.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyszczono kupione'**
  String get toastCleared;

  /// No description provided for @toastUndo.
  ///
  /// In pl, this message translates to:
  /// **'Cofnij'**
  String get toastUndo;

  /// No description provided for @toastOffline.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia – zmiany wyślą się później'**
  String get toastOffline;

  /// No description provided for @itemEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja na liście'**
  String get itemEditTitle;

  /// No description provided for @itemEditAction.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj pozycję'**
  String get itemEditAction;

  /// No description provided for @itemNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get itemNameLabel;

  /// No description provided for @itemQuantityLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ilość'**
  String get itemQuantityLabel;

  /// No description provided for @itemQuantityHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 2'**
  String get itemQuantityHint;

  /// No description provided for @itemUnitLabel.
  ///
  /// In pl, this message translates to:
  /// **'Jednostka'**
  String get itemUnitLabel;

  /// No description provided for @itemUnitHint.
  ///
  /// In pl, this message translates to:
  /// **'np. szt'**
  String get itemUnitHint;

  /// No description provided for @itemCategoryLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dział'**
  String get itemCategoryLabel;

  /// No description provided for @itemDone.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get itemDone;

  /// No description provided for @itemDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń pozycję'**
  String get itemDelete;

  /// No description provided for @catProduce.
  ///
  /// In pl, this message translates to:
  /// **'Warzywa i owoce'**
  String get catProduce;

  /// No description provided for @catBakery.
  ///
  /// In pl, this message translates to:
  /// **'Pieczywo'**
  String get catBakery;

  /// No description provided for @catDairy.
  ///
  /// In pl, this message translates to:
  /// **'Nabiał'**
  String get catDairy;

  /// No description provided for @catMeat.
  ///
  /// In pl, this message translates to:
  /// **'Mięso i ryby'**
  String get catMeat;

  /// No description provided for @catDrinks.
  ///
  /// In pl, this message translates to:
  /// **'Napoje'**
  String get catDrinks;

  /// No description provided for @catHousehold.
  ///
  /// In pl, this message translates to:
  /// **'Chemia i dom'**
  String get catHousehold;

  /// No description provided for @catOther.
  ///
  /// In pl, this message translates to:
  /// **'Inne'**
  String get catOther;

  /// No description provided for @shoppingCardTitle.
  ///
  /// In pl, this message translates to:
  /// **'Lista zakupów'**
  String get shoppingCardTitle;

  /// No description provided for @shoppingCardNone.
  ///
  /// In pl, this message translates to:
  /// **'Nic do kupienia'**
  String get shoppingCardNone;

  /// No description provided for @shoppingCardCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{{count} rzecz do kupienia} few{{count} rzeczy do kupienia} many{{count} rzeczy do kupienia} other{{count} rzeczy do kupienia}}'**
  String shoppingCardCount(int count);

  /// No description provided for @shoppingAddedBy.
  ///
  /// In pl, this message translates to:
  /// **'dodał(a): {name}'**
  String shoppingAddedBy(String name);

  /// No description provided for @toastRemoved.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto z listy'**
  String get toastRemoved;

  /// No description provided for @navCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get navCalendar;

  /// No description provided for @navNotes.
  ///
  /// In pl, this message translates to:
  /// **'Notatki'**
  String get navNotes;

  /// No description provided for @notesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Notatki'**
  String get notesTitle;

  /// No description provided for @notesSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj w notatkach'**
  String get notesSearchHint;

  /// No description provided for @notesFilterAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get notesFilterAll;

  /// No description provided for @notesFilterShared.
  ///
  /// In pl, this message translates to:
  /// **'Wspólne'**
  String get notesFilterShared;

  /// No description provided for @notesFilterMine.
  ///
  /// In pl, this message translates to:
  /// **'Tylko moje'**
  String get notesFilterMine;

  /// No description provided for @notesEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak notatek – dopisz pierwszą.'**
  String get notesEmpty;

  /// No description provided for @notesNoResults.
  ///
  /// In pl, this message translates to:
  /// **'Nic nie znaleziono.'**
  String get notesNoResults;

  /// No description provided for @noteNew.
  ///
  /// In pl, this message translates to:
  /// **'Nowa'**
  String get noteNew;

  /// No description provided for @noteNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowa notatka'**
  String get noteNewTitle;

  /// No description provided for @noteEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get noteEditTitle;

  /// No description provided for @noteTitleHint.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get noteTitleHint;

  /// No description provided for @noteBodyHint.
  ///
  /// In pl, this message translates to:
  /// **'Treść… Listę zacznij od „- ”'**
  String get noteBodyHint;

  /// No description provided for @noteVisibilityLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kto widzi'**
  String get noteVisibilityLabel;

  /// No description provided for @visibilityAll.
  ///
  /// In pl, this message translates to:
  /// **'wszyscy w domu'**
  String get visibilityAll;

  /// No description provided for @visibilityMe.
  ///
  /// In pl, this message translates to:
  /// **'tylko ja'**
  String get visibilityMe;

  /// No description provided for @notePin.
  ///
  /// In pl, this message translates to:
  /// **'Przypnij'**
  String get notePin;

  /// No description provided for @noteUnpin.
  ///
  /// In pl, this message translates to:
  /// **'Odepnij'**
  String get noteUnpin;

  /// No description provided for @noteDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń notatkę'**
  String get noteDelete;

  /// No description provided for @noteSave.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get noteSave;

  /// No description provided for @noteMeta.
  ///
  /// In pl, this message translates to:
  /// **'{name} · {date}'**
  String noteMeta(String name, String date);

  /// No description provided for @errNoteEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz tytuł albo treść'**
  String get errNoteEmpty;

  /// No description provided for @toastNoteRemoved.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto notatkę'**
  String get toastNoteRemoved;

  /// No description provided for @readOnlyNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatka innej osoby – tylko do odczytu'**
  String get readOnlyNote;

  /// No description provided for @calendarTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get calendarTitle;

  /// No description provided for @calendarMonth.
  ///
  /// In pl, this message translates to:
  /// **'Miesiąc'**
  String get calendarMonth;

  /// No description provided for @calendarWeek.
  ///
  /// In pl, this message translates to:
  /// **'Tydzień'**
  String get calendarWeek;

  /// No description provided for @calendarEmptyDay.
  ///
  /// In pl, this message translates to:
  /// **'Nic zaplanowanego. Miś odpoczywa.'**
  String get calendarEmptyDay;

  /// No description provided for @calendarLegendEvent.
  ///
  /// In pl, this message translates to:
  /// **'wydarzenie'**
  String get calendarLegendEvent;

  /// No description provided for @calendarLegendChore.
  ///
  /// In pl, this message translates to:
  /// **'obowiązek'**
  String get calendarLegendChore;

  /// No description provided for @eventNew.
  ///
  /// In pl, this message translates to:
  /// **'Nowe'**
  String get eventNew;

  /// No description provided for @eventNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowe wydarzenie'**
  String get eventNewTitle;

  /// No description provided for @eventEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenie'**
  String get eventEditTitle;

  /// No description provided for @eventTitleHint.
  ///
  /// In pl, this message translates to:
  /// **'Co się dzieje? np. Dentysta'**
  String get eventTitleHint;

  /// No description provided for @eventTimed.
  ///
  /// In pl, this message translates to:
  /// **'O godzinie'**
  String get eventTimed;

  /// No description provided for @eventAllDay.
  ///
  /// In pl, this message translates to:
  /// **'Cały dzień'**
  String get eventAllDay;

  /// No description provided for @eventStartLabel.
  ///
  /// In pl, this message translates to:
  /// **'Początek'**
  String get eventStartLabel;

  /// No description provided for @eventEndLabel.
  ///
  /// In pl, this message translates to:
  /// **'Koniec'**
  String get eventEndLabel;

  /// No description provided for @eventDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dzień'**
  String get eventDateLabel;

  /// No description provided for @eventEndDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni dzień'**
  String get eventEndDateLabel;

  /// No description provided for @eventLocationLabel.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce'**
  String get eventLocationLabel;

  /// No description provided for @eventLocationHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Przychodnia'**
  String get eventLocationHint;

  /// No description provided for @eventDescriptionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Opis'**
  String get eventDescriptionLabel;

  /// No description provided for @eventRepeatLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powtarzaj'**
  String get eventRepeatLabel;

  /// No description provided for @repeatNone.
  ///
  /// In pl, this message translates to:
  /// **'Nie'**
  String get repeatNone;

  /// No description provided for @repeatWeekly.
  ///
  /// In pl, this message translates to:
  /// **'Co tydzień'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In pl, this message translates to:
  /// **'Co miesiąc'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In pl, this message translates to:
  /// **'Co rok'**
  String get repeatYearly;

  /// No description provided for @eventReminderLabel.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie'**
  String get eventReminderLabel;

  /// No description provided for @reminderNone.
  ///
  /// In pl, this message translates to:
  /// **'Bez'**
  String get reminderNone;

  /// No description provided for @reminderAtTime.
  ///
  /// In pl, this message translates to:
  /// **'W porze'**
  String get reminderAtTime;

  /// No description provided for @reminderHour.
  ///
  /// In pl, this message translates to:
  /// **'1 h wcześniej'**
  String get reminderHour;

  /// No description provided for @reminderDay.
  ///
  /// In pl, this message translates to:
  /// **'Dzień wcześniej'**
  String get reminderDay;

  /// No description provided for @eventParticipantsLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kto bierze udział'**
  String get eventParticipantsLabel;

  /// No description provided for @eventDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wydarzenie'**
  String get eventDelete;

  /// No description provided for @errEventTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę wydarzenia'**
  String get errEventTitle;

  /// No description provided for @errEventEnd.
  ///
  /// In pl, this message translates to:
  /// **'Koniec musi być po początku'**
  String get errEventEnd;

  /// No description provided for @toastEventRemoved.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto wydarzenie'**
  String get toastEventRemoved;

  /// No description provided for @readOnlyEvent.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenie innej osoby – tylko do odczytu'**
  String get readOnlyEvent;

  /// No description provided for @allDayLabel.
  ///
  /// In pl, this message translates to:
  /// **'cały dzień'**
  String get allDayLabel;

  /// No description provided for @repeatsLabel.
  ///
  /// In pl, this message translates to:
  /// **'powtarza się'**
  String get repeatsLabel;

  /// No description provided for @homeNextEvent.
  ///
  /// In pl, this message translates to:
  /// **'Najbliżej w kalendarzu'**
  String get homeNextEvent;

  /// No description provided for @homeNoEvents.
  ///
  /// In pl, this message translates to:
  /// **'Nic zaplanowanego'**
  String get homeNoEvents;

  /// No description provided for @homeNotesCard.
  ///
  /// In pl, this message translates to:
  /// **'Notatki'**
  String get homeNotesCard;

  /// No description provided for @homeNotesCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =0{Brak notatek} one{{count} notatka} few{{count} notatki} many{{count} notatek} other{{count} notatki}}'**
  String homeNotesCount(int count);

  /// No description provided for @dateToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In pl, this message translates to:
  /// **'Jutro'**
  String get dateTomorrow;

  /// No description provided for @navChores.
  ///
  /// In pl, this message translates to:
  /// **'Zadania'**
  String get navChores;

  /// No description provided for @choresTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zadania'**
  String get choresTitle;

  /// No description provided for @choresMine.
  ///
  /// In pl, this message translates to:
  /// **'Moje · {day}'**
  String choresMine(String day);

  /// No description provided for @choresOthers.
  ///
  /// In pl, this message translates to:
  /// **'Inni domownicy'**
  String get choresOthers;

  /// No description provided for @choresEmptyMine.
  ///
  /// In pl, this message translates to:
  /// **'Nic do zrobienia. Miś odpoczywa.'**
  String get choresEmptyMine;

  /// No description provided for @choresEmptyOthers.
  ///
  /// In pl, this message translates to:
  /// **'Nikt nic nie ma na ten dzień.'**
  String get choresEmptyOthers;

  /// No description provided for @choresSomeone.
  ///
  /// In pl, this message translates to:
  /// **'ktoś'**
  String get choresSomeone;

  /// No description provided for @choresDoneBy.
  ///
  /// In pl, this message translates to:
  /// **'zrobione: {name}'**
  String choresDoneBy(String name);

  /// No description provided for @choreNew.
  ///
  /// In pl, this message translates to:
  /// **'Nowy'**
  String get choreNew;

  /// No description provided for @choreNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy obowiązek'**
  String get choreNewTitle;

  /// No description provided for @choreEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Obowiązek'**
  String get choreEditTitle;

  /// No description provided for @choreTitleHint.
  ///
  /// In pl, this message translates to:
  /// **'Co trzeba zrobić? np. Wynieść śmieci'**
  String get choreTitleHint;

  /// No description provided for @choreDescriptionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Opis (opcjonalnie)'**
  String get choreDescriptionLabel;

  /// No description provided for @choreWhoLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kto'**
  String get choreWhoLabel;

  /// No description provided for @choreWhenLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kiedy'**
  String get choreWhenLabel;

  /// No description provided for @choreOnce.
  ///
  /// In pl, this message translates to:
  /// **'Jednorazowo'**
  String get choreOnce;

  /// No description provided for @choreRecurring.
  ///
  /// In pl, this message translates to:
  /// **'Cyklicznie'**
  String get choreRecurring;

  /// No description provided for @choreFirstDay.
  ///
  /// In pl, this message translates to:
  /// **'Pierwszy dzień'**
  String get choreFirstDay;

  /// No description provided for @choreDay.
  ///
  /// In pl, this message translates to:
  /// **'Termin'**
  String get choreDay;

  /// No description provided for @choreCycleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Cykl'**
  String get choreCycleLabel;

  /// No description provided for @cycleDaily.
  ///
  /// In pl, this message translates to:
  /// **'Co N dni'**
  String get cycleDaily;

  /// No description provided for @cycleWeekly.
  ///
  /// In pl, this message translates to:
  /// **'Dni tygodnia'**
  String get cycleWeekly;

  /// No description provided for @cycleMonthly.
  ///
  /// In pl, this message translates to:
  /// **'Dzień miesiąca'**
  String get cycleMonthly;

  /// No description provided for @cycleCustom.
  ///
  /// In pl, this message translates to:
  /// **'Wybrane daty'**
  String get cycleCustom;

  /// No description provided for @choreIntervalDays.
  ///
  /// In pl, this message translates to:
  /// **'Co ile dni'**
  String get choreIntervalDays;

  /// No description provided for @choreIntervalWeeks.
  ///
  /// In pl, this message translates to:
  /// **'Co ile tygodni'**
  String get choreIntervalWeeks;

  /// No description provided for @choreIntervalMonths.
  ///
  /// In pl, this message translates to:
  /// **'Co ile miesięcy'**
  String get choreIntervalMonths;

  /// No description provided for @choreMonthDay.
  ///
  /// In pl, this message translates to:
  /// **'Dzień miesiąca (1–31)'**
  String get choreMonthDay;

  /// No description provided for @choreWeekdaysLabel.
  ///
  /// In pl, this message translates to:
  /// **'W które dni'**
  String get choreWeekdaysLabel;

  /// No description provided for @chorePickDates.
  ///
  /// In pl, this message translates to:
  /// **'Zaznacz dni w kalendarzu'**
  String get chorePickDates;

  /// No description provided for @choreDatesCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =0{nie wybrano dni} one{wybrano {count} dzień} few{wybrano {count} dni} many{wybrano {count} dni} other{wybrano {count} dni}}'**
  String choreDatesCount(int count);

  /// No description provided for @choreUntilLabel.
  ///
  /// In pl, this message translates to:
  /// **'Koniec cyklu'**
  String get choreUntilLabel;

  /// No description provided for @choreUntilNone.
  ///
  /// In pl, this message translates to:
  /// **'Bez końca'**
  String get choreUntilNone;

  /// No description provided for @choreUntilPick.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz dzień'**
  String get choreUntilPick;

  /// No description provided for @choreReminderLabel.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie rano'**
  String get choreReminderLabel;

  /// No description provided for @choreReminderNone.
  ///
  /// In pl, this message translates to:
  /// **'Bez'**
  String get choreReminderNone;

  /// No description provided for @choreDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń obowiązek'**
  String get choreDelete;

  /// No description provided for @choreDeleteBody.
  ///
  /// In pl, this message translates to:
  /// **'Obowiązek „{title}” zniknie razem z zaplanowanymi terminami.'**
  String choreDeleteBody(String title);

  /// No description provided for @errChoreTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę obowiązku'**
  String get errChoreTitle;

  /// No description provided for @errChoreWeekdays.
  ///
  /// In pl, this message translates to:
  /// **'Zaznacz co najmniej jeden dzień tygodnia'**
  String get errChoreWeekdays;

  /// No description provided for @errChoreDates.
  ///
  /// In pl, this message translates to:
  /// **'Zaznacz co najmniej jeden dzień'**
  String get errChoreDates;

  /// No description provided for @errChoreInterval.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz liczbę większą od zera'**
  String get errChoreInterval;

  /// No description provided for @toastChoreRemoved.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto obowiązek'**
  String get toastChoreRemoved;

  /// No description provided for @adminOnlyChores.
  ///
  /// In pl, this message translates to:
  /// **'Obowiązki dodaje Administrator'**
  String get adminOnlyChores;

  /// No description provided for @weekdayMon.
  ///
  /// In pl, this message translates to:
  /// **'Pn'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In pl, this message translates to:
  /// **'Wt'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In pl, this message translates to:
  /// **'Śr'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In pl, this message translates to:
  /// **'Cz'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In pl, this message translates to:
  /// **'Pt'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In pl, this message translates to:
  /// **'So'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In pl, this message translates to:
  /// **'Nd'**
  String get weekdaySun;

  /// No description provided for @homeTodayCard.
  ///
  /// In pl, this message translates to:
  /// **'Dziś do zrobienia'**
  String get homeTodayCard;

  /// No description provided for @homeTodayDone.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko zrobione'**
  String get homeTodayDone;

  /// No description provided for @homeShowAll.
  ///
  /// In pl, this message translates to:
  /// **'pokaż wszystkie'**
  String get homeShowAll;

  /// No description provided for @chipTodo.
  ///
  /// In pl, this message translates to:
  /// **'do zrobienia'**
  String get chipTodo;

  /// No description provided for @chipDone.
  ///
  /// In pl, this message translates to:
  /// **'zrobione'**
  String get chipDone;

  /// No description provided for @ruleEditHint.
  ///
  /// In pl, this message translates to:
  /// **'Zmiany przeliczą przyszłe terminy'**
  String get ruleEditHint;

  /// No description provided for @navMore.
  ///
  /// In pl, this message translates to:
  /// **'Więcej'**
  String get navMore;

  /// No description provided for @moreTitle.
  ///
  /// In pl, this message translates to:
  /// **'Więcej'**
  String get moreTitle;

  /// No description provided for @moreBudget.
  ///
  /// In pl, this message translates to:
  /// **'Budżet'**
  String get moreBudget;

  /// No description provided for @moreMembers.
  ///
  /// In pl, this message translates to:
  /// **'Domownicy'**
  String get moreMembers;

  /// No description provided for @moreNotes.
  ///
  /// In pl, this message translates to:
  /// **'Notatki'**
  String get moreNotes;

  /// No description provided for @moreInvite.
  ///
  /// In pl, this message translates to:
  /// **'Zaproś domownika'**
  String get moreInvite;

  /// No description provided for @budgetTitle.
  ///
  /// In pl, this message translates to:
  /// **'Budżet'**
  String get budgetTitle;

  /// No description provided for @budgetSpent.
  ///
  /// In pl, this message translates to:
  /// **'wydano'**
  String get budgetSpent;

  /// No description provided for @budgetOfPlan.
  ///
  /// In pl, this message translates to:
  /// **'{spent} z {plan}'**
  String budgetOfPlan(String spent, String plan);

  /// No description provided for @budgetNoPlan.
  ///
  /// In pl, this message translates to:
  /// **'Bez planu na ten miesiąc'**
  String get budgetNoPlan;

  /// No description provided for @budgetSetPlan.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw plan'**
  String get budgetSetPlan;

  /// No description provided for @budgetEditPlan.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj plan'**
  String get budgetEditPlan;

  /// No description provided for @budgetByCategory.
  ///
  /// In pl, this message translates to:
  /// **'Według kategorii'**
  String get budgetByCategory;

  /// No description provided for @budgetRecent.
  ///
  /// In pl, this message translates to:
  /// **'Wydatki'**
  String get budgetRecent;

  /// No description provided for @budgetEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak wydatków w tym miesiącu.'**
  String get budgetEmpty;

  /// No description provided for @budgetAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wydatek'**
  String get budgetAdd;

  /// No description provided for @budgetSortDate.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get budgetSortDate;

  /// No description provided for @budgetSortAmountDesc.
  ///
  /// In pl, this message translates to:
  /// **'Największe'**
  String get budgetSortAmountDesc;

  /// No description provided for @budgetSortAmountAsc.
  ///
  /// In pl, this message translates to:
  /// **'Najmniejsze'**
  String get budgetSortAmountAsc;

  /// No description provided for @budgetFilterAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie kategorie'**
  String get budgetFilterAll;

  /// No description provided for @budgetFilterChip.
  ///
  /// In pl, this message translates to:
  /// **'filtr: {name}'**
  String budgetFilterChip(String name);

  /// No description provided for @budgetClearFilter.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż wszystkie'**
  String get budgetClearFilter;

  /// No description provided for @budgetPrevMonth.
  ///
  /// In pl, this message translates to:
  /// **'Poprzedni miesiąc'**
  String get budgetPrevMonth;

  /// No description provided for @budgetNextMonth.
  ///
  /// In pl, this message translates to:
  /// **'Następny miesiąc'**
  String get budgetNextMonth;

  /// No description provided for @budgetWarn80.
  ///
  /// In pl, this message translates to:
  /// **'Zbliżasz się do planu'**
  String get budgetWarn80;

  /// No description provided for @budgetOver.
  ///
  /// In pl, this message translates to:
  /// **'Plan przekroczony'**
  String get budgetOver;

  /// No description provided for @expenseNewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowy wydatek'**
  String get expenseNewTitle;

  /// No description provided for @expenseEditTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wydatek'**
  String get expenseEditTitle;

  /// No description provided for @expenseAmountLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kwota (zł)'**
  String get expenseAmountLabel;

  /// No description provided for @expenseAmountHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 24,99'**
  String get expenseAmountHint;

  /// No description provided for @expenseDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get expenseDateLabel;

  /// No description provided for @expenseCategoryLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get expenseCategoryLabel;

  /// No description provided for @expenseNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Opis (opcjonalnie)'**
  String get expenseNoteLabel;

  /// No description provided for @expenseNoteHint.
  ///
  /// In pl, this message translates to:
  /// **'np. zakupy w Biedronce'**
  String get expenseNoteHint;

  /// No description provided for @expensePaidByLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kto zapłacił'**
  String get expensePaidByLabel;

  /// No description provided for @expensePaidNobody.
  ///
  /// In pl, this message translates to:
  /// **'nie wiadomo'**
  String get expensePaidNobody;

  /// No description provided for @expenseDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wydatek'**
  String get expenseDelete;

  /// No description provided for @errExpenseAmount.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz kwotę większą od zera'**
  String get errExpenseAmount;

  /// No description provided for @errExpenseCategory.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz kategorię'**
  String get errExpenseCategory;

  /// No description provided for @toastExpenseRemoved.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto wydatek'**
  String get toastExpenseRemoved;

  /// No description provided for @planTitle.
  ///
  /// In pl, this message translates to:
  /// **'Plan miesiąca'**
  String get planTitle;

  /// No description provided for @planTotalLabel.
  ///
  /// In pl, this message translates to:
  /// **'Łącznie na miesiąc (zł)'**
  String get planTotalLabel;

  /// No description provided for @planCategoryHint.
  ///
  /// In pl, this message translates to:
  /// **'0'**
  String get planCategoryHint;

  /// No description provided for @planCopyPrevious.
  ///
  /// In pl, this message translates to:
  /// **'Skopiuj z poprzedniego miesiąca'**
  String get planCopyPrevious;

  /// No description provided for @planCopied.
  ///
  /// In pl, this message translates to:
  /// **'Skopiowano plan'**
  String get planCopied;

  /// No description provided for @planNoPrevious.
  ///
  /// In pl, this message translates to:
  /// **'Poprzedni miesiąc nie ma planu'**
  String get planNoPrevious;

  /// No description provided for @planSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz plan'**
  String get planSave;

  /// No description provided for @budgetAdminBadge.
  ///
  /// In pl, this message translates to:
  /// **'tylko Administrator'**
  String get budgetAdminBadge;

  /// No description provided for @budgetMemberBlocked.
  ///
  /// In pl, this message translates to:
  /// **'Budżet widzi tylko Administrator'**
  String get budgetMemberBlocked;

  /// No description provided for @categoryLimit.
  ///
  /// In pl, this message translates to:
  /// **'{spent} z {limit}'**
  String categoryLimit(String spent, String limit);

  /// No description provided for @paidByMeta.
  ///
  /// In pl, this message translates to:
  /// **'{name} · {date}'**
  String paidByMeta(String name, String date);

  /// No description provided for @settingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settingsTitle;

  /// No description provided for @moreSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get moreSettings;

  /// No description provided for @settingsNotifications.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsHint.
  ///
  /// In pl, this message translates to:
  /// **'Każdy domownik ustawia to dla siebie.'**
  String get settingsNotificationsHint;

  /// No description provided for @prefChores.
  ///
  /// In pl, this message translates to:
  /// **'Nowy obowiązek i poranne przypomnienia'**
  String get prefChores;

  /// No description provided for @prefEvents.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o wydarzeniach'**
  String get prefEvents;

  /// No description provided for @prefShopping.
  ///
  /// In pl, this message translates to:
  /// **'Nowa pozycja na liście zakupów'**
  String get prefShopping;

  /// No description provided for @prefMembers.
  ///
  /// In pl, this message translates to:
  /// **'Nowy domownik dołączył'**
  String get prefMembers;

  /// No description provided for @prefBudget.
  ///
  /// In pl, this message translates to:
  /// **'Przekroczenie planu budżetu (tylko Administrator)'**
  String get prefBudget;

  /// No description provided for @prefOn.
  ///
  /// In pl, this message translates to:
  /// **'włączone'**
  String get prefOn;

  /// No description provided for @prefOff.
  ///
  /// In pl, this message translates to:
  /// **'wyłączone'**
  String get prefOff;

  /// No description provided for @notifPermissionDenied.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia są wyłączone w systemie. Włącz je w ustawieniach telefonu.'**
  String get notifPermissionDenied;

  /// No description provided for @notifChannelName.
  ///
  /// In pl, this message translates to:
  /// **'PorządMiś'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o obowiązkach i wydarzeniach, nowości w domu'**
  String get notifChannelDescription;

  /// No description provided for @reminderChoreTitle.
  ///
  /// In pl, this message translates to:
  /// **'{title} – dziś'**
  String reminderChoreTitle(String title);

  /// No description provided for @reminderChoreBody.
  ///
  /// In pl, this message translates to:
  /// **'Obowiązek na dziś.'**
  String get reminderChoreBody;

  /// No description provided for @reminderEventTitle.
  ///
  /// In pl, this message translates to:
  /// **'{title} – {when}'**
  String reminderEventTitle(String title, String when);

  /// No description provided for @reminderEventBody.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenie z kalendarza.'**
  String get reminderEventBody;

  /// No description provided for @settingsAbout.
  ///
  /// In pl, this message translates to:
  /// **'O aplikacji'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In pl, this message translates to:
  /// **'PorządMiś, wersja {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsAppearance.
  ///
  /// In pl, this message translates to:
  /// **'Wygląd'**
  String get settingsAppearance;

  /// No description provided for @appearanceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wygląd'**
  String get appearanceTitle;

  /// No description provided for @themeModeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tryb'**
  String get themeModeLabel;

  /// No description provided for @themeModeLight.
  ///
  /// In pl, this message translates to:
  /// **'Jasny'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In pl, this message translates to:
  /// **'Ciemny'**
  String get themeModeDark;

  /// No description provided for @themeModeAuto.
  ///
  /// In pl, this message translates to:
  /// **'Auto'**
  String get themeModeAuto;

  /// No description provided for @themeModeHint.
  ///
  /// In pl, this message translates to:
  /// **'Auto: jasny w dzień, ciemny w nocy, według ustawienia telefonu.'**
  String get themeModeHint;

  /// No description provided for @themeGroupDefault.
  ///
  /// In pl, this message translates to:
  /// **'PorządMiś'**
  String get themeGroupDefault;

  /// No description provided for @themeGroupPycharm.
  ///
  /// In pl, this message translates to:
  /// **'Inspirowane PyCharm'**
  String get themeGroupPycharm;

  /// No description provided for @themeGroupPink.
  ///
  /// In pl, this message translates to:
  /// **'Różowe'**
  String get themeGroupPink;

  /// No description provided for @themeApply.
  ///
  /// In pl, this message translates to:
  /// **'Zastosuj motyw'**
  String get themeApply;

  /// No description provided for @themeApplied.
  ///
  /// In pl, this message translates to:
  /// **'Zastosowano motyw'**
  String get themeApplied;

  /// No description provided for @themePreviewHint.
  ///
  /// In pl, this message translates to:
  /// **'Dotknij kafelka, żeby zobaczyć podgląd. Zapis po „Zastosuj motyw”.'**
  String get themePreviewHint;

  /// No description provided for @themeSample.
  ///
  /// In pl, this message translates to:
  /// **'Tak wygląda tekst i przycisk'**
  String get themeSample;

  /// No description provided for @onboarding1.
  ///
  /// In pl, this message translates to:
  /// **'Cześć, jestem PorządMiś'**
  String get onboarding1;

  /// No description provided for @onboarding2.
  ///
  /// In pl, this message translates to:
  /// **'Pomagam ogarnąć dom razem z rodziną'**
  String get onboarding2;

  /// No description provided for @onboarding3.
  ///
  /// In pl, this message translates to:
  /// **'Dołącz do domu albo załóż nowy'**
  String get onboarding3;

  /// No description provided for @onboardingNext.
  ///
  /// In pl, this message translates to:
  /// **'Dalej'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In pl, this message translates to:
  /// **'Zaczynamy'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In pl, this message translates to:
  /// **'Pomiń'**
  String get onboardingSkip;

  /// No description provided for @themeAutoDarkHint.
  ///
  /// In pl, this message translates to:
  /// **'Telefon jest teraz w trybie ciemnym, więc w „Auto” zobaczysz ciemny motyw. Wybierz „Jasny”, żeby użyć jasnego.'**
  String get themeAutoDarkHint;

  /// No description provided for @themeAutoLightHint.
  ///
  /// In pl, this message translates to:
  /// **'Telefon jest teraz w trybie jasnym, więc w „Auto” zobaczysz jasny motyw. Wybierz „Ciemny”, żeby użyć ciemnego.'**
  String get themeAutoLightHint;

  /// No description provided for @homeActivityHint.
  ///
  /// In pl, this message translates to:
  /// **'Dotknij karty, żeby przejść dalej'**
  String get homeActivityHint;

  /// No description provided for @homeBreadcrumb.
  ///
  /// In pl, this message translates to:
  /// **'Pulpit'**
  String get homeBreadcrumb;

  /// No description provided for @homeEyebrow.
  ///
  /// In pl, this message translates to:
  /// **'TWOJA PRZESTRZEŃ'**
  String get homeEyebrow;

  /// No description provided for @homeHello.
  ///
  /// In pl, this message translates to:
  /// **'Dzień dobry!'**
  String get homeHello;

  /// No description provided for @homeHelloName.
  ///
  /// In pl, this message translates to:
  /// **'Dzień dobry, {name}!'**
  String homeHelloName(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiaj jest {date}. Zobacz, co dzieje się w Twoim domu.'**
  String homeSubtitle(String date);

  /// No description provided for @heroEyebrowCalm.
  ///
  /// In pl, this message translates to:
  /// **'SPOKOJNIE, WSZYSTKO POD KONTROLĄ'**
  String get heroEyebrowCalm;

  /// No description provided for @heroEyebrowBusy.
  ///
  /// In pl, this message translates to:
  /// **'DZIŚ JEST CO ROBIĆ'**
  String get heroEyebrowBusy;

  /// No description provided for @heroTitle.
  ///
  /// In pl, this message translates to:
  /// **'Małe sprawy. Więcej czasu dla siebie.'**
  String get heroTitle;

  /// No description provided for @heroBody.
  ///
  /// In pl, this message translates to:
  /// **'Domowe zadania, wspólne plany i zakupy – razem w jednym miejscu.'**
  String get heroBody;

  /// No description provided for @heroAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj coś nowego'**
  String get heroAdd;

  /// No description provided for @statTasks.
  ///
  /// In pl, this message translates to:
  /// **'Moje zadania dziś'**
  String get statTasks;

  /// No description provided for @statShopping.
  ///
  /// In pl, this message translates to:
  /// **'Na liście zakupów'**
  String get statShopping;

  /// No description provided for @statEvents.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższe wydarzenia'**
  String get statEvents;

  /// No description provided for @todayCardTitle.
  ///
  /// In pl, this message translates to:
  /// **'Do zrobienia dzisiaj'**
  String get todayCardTitle;

  /// No description provided for @todayCardAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get todayCardAll;

  /// No description provided for @todayCardWaiting.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =0{Nic nie czeka na wykonanie} one{{count} zadanie czeka na wykonanie} few{{count} zadania czekają na wykonanie} many{{count} zadań czeka na wykonanie} other{{count} zadania czekają na wykonanie}}'**
  String todayCardWaiting(int count);

  /// No description provided for @youLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ty'**
  String get youLabel;

  /// No description provided for @quickAddTitle.
  ///
  /// In pl, this message translates to:
  /// **'Co dodać?'**
  String get quickAddTitle;

  /// No description provided for @quickAddShopping.
  ///
  /// In pl, this message translates to:
  /// **'Produkt na listę zakupów'**
  String get quickAddShopping;

  /// No description provided for @quickAddChore.
  ///
  /// In pl, this message translates to:
  /// **'Zadanie'**
  String get quickAddChore;

  /// No description provided for @quickAddEvent.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenie w kalendarzu'**
  String get quickAddEvent;

  /// No description provided for @quickAddNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatkę'**
  String get quickAddNote;

  /// No description provided for @settingsAccount.
  ///
  /// In pl, this message translates to:
  /// **'Konto'**
  String get settingsAccount;

  /// No description provided for @homeHouseholdFallback.
  ///
  /// In pl, this message translates to:
  /// **'Nasz dom'**
  String get homeHouseholdFallback;

  /// No description provided for @themesButton.
  ///
  /// In pl, this message translates to:
  /// **'Motywy'**
  String get themesButton;

  /// No description provided for @homeHeroSubtitleCalm.
  ///
  /// In pl, this message translates to:
  /// **'Twój dom ma dziś mały plan. Sprawdź, co przed Wami.'**
  String get homeHeroSubtitleCalm;

  /// No description provided for @homeHeroSubtitleBusy.
  ///
  /// In pl, this message translates to:
  /// **'Dziś jest trochę do zrobienia. Zacznij od pierwszej rzeczy.'**
  String get homeHeroSubtitleBusy;

  /// No description provided for @todayCardSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'{done} z {total} Twoich obowiązków wykonanych'**
  String todayCardSubtitle(int done, int total);

  /// No description provided for @todayShowAll.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż wszystkie obowiązki'**
  String get todayShowAll;

  /// No description provided for @shoppingTileCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{produkt do kupienia} few{produkty do kupienia} many{produktów do kupienia} other{produktu do kupienia}}'**
  String shoppingTileCount(int count);

  /// No description provided for @quickActionsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie akcje'**
  String get quickActionsTitle;

  /// No description provided for @quickShopping.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj produkt'**
  String get quickShopping;

  /// No description provided for @quickChore.
  ///
  /// In pl, this message translates to:
  /// **'Nowe zadanie'**
  String get quickChore;

  /// No description provided for @quickEvent.
  ///
  /// In pl, this message translates to:
  /// **'Nowe wydarzenie'**
  String get quickEvent;

  /// No description provided for @quickNote.
  ///
  /// In pl, this message translates to:
  /// **'Nowa notatka'**
  String get quickNote;

  /// No description provided for @kickerShared.
  ///
  /// In pl, this message translates to:
  /// **'Wspólnie'**
  String get kickerShared;

  /// No description provided for @kickerMine.
  ///
  /// In pl, this message translates to:
  /// **'Po Twojemu'**
  String get kickerMine;

  /// No description provided for @kickerHome.
  ///
  /// In pl, this message translates to:
  /// **'Dla domu'**
  String get kickerHome;

  /// No description provided for @kickerAdmin.
  ///
  /// In pl, this message translates to:
  /// **'Dla Administratora'**
  String get kickerAdmin;

  /// No description provided for @shoppingSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Jedna lista, którą widzi każdy domownik.'**
  String get shoppingSubtitle;

  /// No description provided for @shoppingAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj'**
  String get shoppingAdd;

  /// No description provided for @shoppingListMeta.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, one{Lista wspólna · {count} domownik} few{Lista wspólna · {count} domowników} many{Lista wspólna · {count} domowników} other{Lista wspólna · {count} domownika}}'**
  String shoppingListMeta(int count);

  /// No description provided for @shoppingAddedByMeta.
  ///
  /// In pl, this message translates to:
  /// **'dodał/a: {name}'**
  String shoppingAddedByMeta(String name);

  /// No description provided for @choresSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Kto, co i kiedy – bez przypominania.'**
  String get choresSubtitle;

  /// No description provided for @calendarSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenia i zadania całego domu w jednym miejscu.'**
  String get calendarSubtitle;

  /// No description provided for @notesSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wspólne ustalenia i Twoje prywatne notatki.'**
  String get notesSubtitle;

  /// No description provided for @budgetSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wydatki i plan miesiąca.'**
  String get budgetSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Dopasuj wygląd i działanie PorządMisia do swoich potrzeb.'**
  String get settingsSubtitle;

  /// No description provided for @themeCardTitle.
  ///
  /// In pl, this message translates to:
  /// **'Motyw aplikacji'**
  String get themeCardTitle;

  /// No description provided for @themeCardSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'13 palet do wyboru · podgląd na żywo'**
  String get themeCardSubtitle;

  /// No description provided for @shoppingToBuyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Do kupienia'**
  String get shoppingToBuyTitle;

  /// No description provided for @eventColorLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kolor wydarzenia'**
  String get eventColorLabel;

  /// No description provided for @eventTypeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Typ wydarzenia'**
  String get eventTypeLabel;

  /// No description provided for @eventTypeNone.
  ///
  /// In pl, this message translates to:
  /// **'Bez typu'**
  String get eventTypeNone;

  /// No description provided for @eventTypesButton.
  ///
  /// In pl, this message translates to:
  /// **'Typy'**
  String get eventTypesButton;

  /// No description provided for @eventTypesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Typy wydarzeń'**
  String get eventTypesTitle;

  /// No description provided for @eventTypesHint.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa i kolor typu obowiązują w całym domu. Zmiana koloru przebarwia wszystkie wydarzenia tego typu.'**
  String get eventTypesHint;

  /// No description provided for @eventTypeNameHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Lekarz'**
  String get eventTypeNameHint;

  /// No description provided for @eventTypeAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj typ'**
  String get eventTypeAdd;

  /// No description provided for @eventTypeDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń typ'**
  String get eventTypeDelete;

  /// No description provided for @eventTypeDeleteBody.
  ///
  /// In pl, this message translates to:
  /// **'Typ „{name}” zniknie, a jego wydarzenia zostaną bez typu.'**
  String eventTypeDeleteBody(String name);

  /// No description provided for @errEventTypeName.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę typu'**
  String get errEventTypeName;

  /// No description provided for @toastEventTypeRemoved.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto typ'**
  String get toastEventTypeRemoved;

  /// No description provided for @loginSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Witaj z powrotem. Twój dom czeka.'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Jedno konto, cały dom w jednym miejscu.'**
  String get registerSubtitle;

  /// No description provided for @renameTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zmień imię'**
  String get renameTitle;

  /// No description provided for @renameAction.
  ///
  /// In pl, this message translates to:
  /// **'Zmień imię'**
  String get renameAction;
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
