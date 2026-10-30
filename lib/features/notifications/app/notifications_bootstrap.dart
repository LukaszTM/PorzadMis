import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_router.dart';
import '../../../core/util/dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../calendar/data/events_repository.dart';
import '../../chores/data/chores_repository.dart';
import '../data/local_notifications.dart';
import '../data/notifications_repository.dart';
import '../domain/reminders.dart';

/// Spina FCM i lokalne przypomnienia z sesją: token do profilu, push na wierzchu jako
/// lokalne powiadomienie, dotknięcie = deep link, przeliczanie przypomnień przy zmianie danych.
final notificationsBootstrapProvider = Provider<void>((ref) {
  final l = ref.watch(appLocalizationsProvider);
  final local = LocalNotifications.instance;
  StreamSubscription<RemoteMessage>? onMessage;
  StreamSubscription<RemoteMessage>? onOpened;
  StreamSubscription<String>? onToken;
  Timer? debounce;

  void go(String route) => ref.read(routerProvider).go(route);

  Future<void> start(String uid) async {
    final messaging = FirebaseMessaging.instance;
    final repo = ref.read(notificationsRepositoryProvider);
    await local.requestPermission();
    await messaging.requestPermission();
    // Serwer wysyła po tokenie urządzenia (sendEachForMulticast); nowe register()/onRegistered
    // daje identyfikator instalacji, którego funkcje jeszcze nie używają.
    try {
      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (token != null) await repo.addToken(uid, token);
    } catch (_) {
      // Brak usług Google na urządzeniu: lokalne przypomnienia nadal działają.
    }
    // ignore: deprecated_member_use
    onToken = messaging.onTokenRefresh.listen((t) => repo.addToken(uid, t));
    onMessage = FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n == null) return;
      local.show(
        title: n.title ?? l.appName,
        body: n.body ?? '',
        route: m.data['route'] as String? ?? '/home',
        channelName: l.notifChannelName,
      );
    });
    onOpened = FirebaseMessaging.onMessageOpenedApp.listen((m) {
      final route = m.data['route'] as String?;
      if (route != null) go(route);
    });
    final initial = await messaging.getInitialMessage();
    final initialRoute = initial?.data['route'] as String? ?? local.launchRoute;
    if (initialRoute != null) {
      local.launchRoute = null;
      go(initialRoute);
    }
  }

  void stop() {
    onMessage?.cancel();
    onOpened?.cancel();
    onToken?.cancel();
    onMessage = onOpened = null;
    onToken = null;
  }

  ref.listen(authStateProvider, (prev, next) {
    final uid = next.value?.uid;
    stop();
    if (uid != null) start(uid);
  }, fireImmediately: true);

  // Przeliczanie przypomnień (z odstępem, żeby strumienie nie wywoływały tego kilka razy z rzędu).
  void schedule() {
    debounce?.cancel();
    debounce = Timer(const Duration(seconds: 2), () {
      final uid = ref.read(authStateProvider).value?.uid;
      if (uid == null) return;
      final now = DateTime.now();
      final reminders = buildReminders(
        now: now,
        uid: uid,
        prefs: ref.read(notificationPrefsProvider).value ?? const NotificationPrefs(),
        occurrences: ref.read(choreOccurrencesProvider).value ?? const [],
        rules: ref.read(choreRulesProvider).value ?? const [],
        events: ref.read(allEventsProvider),
        choreTitle: l.reminderChoreTitle,
        choreBody: l.reminderChoreBody,
        eventTitle: (title, start, allDay) =>
            l.reminderEventTitle(title, formatWhen(l, start, allDay: allDay, now: now)),
        eventBody: l.reminderEventBody,
      );
      local.reschedule(reminders, channelName: l.notifChannelName);
    });
  }

  ref.listen(choreOccurrencesProvider, (_, _) => schedule());
  ref.listen(choreRulesProvider, (_, _) => schedule());
  ref.listen(allEventsProvider, (_, _) => schedule());
  ref.listen(notificationPrefsProvider, (_, _) => schedule());

  ref.onDispose(() {
    stop();
    debounce?.cancel();
  });
});

/// Teksty poza drzewem widgetów (do powiadomień). Nadpisywane w [PorzadMisApp].
final appLocalizationsProvider = Provider<AppLocalizations>(
  (ref) => throw UnimplementedError('appLocalizationsProvider musi być nadpisany'),
);
