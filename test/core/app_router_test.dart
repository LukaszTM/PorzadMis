import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/core/router/app_router.dart';
import 'package:porzadmis/features/household/domain/household_models.dart';

String? r(String loc, {bool loading = false, bool signedIn = true, String? hid}) =>
    resolveRedirect(location: loc, loading: loading, signedIn: signedIn, householdId: hid);

void main() {
  group('resolveRedirect', () {
    test('podczas ładowania wszystko prowadzi na splash', () {
      expect(r('/home', loading: true), '/splash');
      expect(r('/splash', loading: true), isNull);
    });
    test('bez sesji: tylko logowanie i rejestracja', () {
      expect(r('/home', signedIn: false), '/login');
      expect(r('/start', signedIn: false), '/login');
      expect(r('/login', signedIn: false), isNull);
      expect(r('/register', signedIn: false), isNull);
    });
    test('zalogowany bez domu: ekrany startowe, reszta wraca na /start', () {
      expect(r('/home'), '/start');
      expect(r('/members'), '/start');
      expect(r('/login'), '/start');
      for (final p in ['/start', '/create', '/join', '/scan']) {
        expect(r(p), isNull);
      }
    });
    test('zalogowany z domem: ekrany logowania i startu prowadzą do domu', () {
      for (final p in ['/login', '/register', '/start', '/create', '/join', '/splash']) {
        expect(r(p, hid: 'h1'), '/home');
      }
      expect(r('/home', hid: 'h1'), isNull);
      expect(r('/members', hid: 'h1'), isNull);
      expect(r('/invite', hid: 'h1'), isNull);
    });
  });

  group('Invite.tokenFromQr', () {
    test('wyciąga token z treści QR PorządMisia', () {
      expect(Invite.tokenFromQr('porzadmis:join:abc123'), 'abc123');
    });
    test('odrzuca obce i puste kody', () {
      expect(Invite.tokenFromQr('https://example.com'), isNull);
      expect(Invite.tokenFromQr('porzadmis:join:'), isNull);
      expect(Invite.tokenFromQr(null), isNull);
    });
  });
}
