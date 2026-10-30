import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminders.dart';

const notificationChannelId = 'porzadmis_default';

/// Lokalne powiadomienia: kanał, uprawnienie, planowanie przypomnień, obsługa dotknięcia.
class LocalNotifications {
  LocalNotifications._();

  static final instance = LocalNotifications._();
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Trasa z dotkniętego powiadomienia, gdy aplikacja była zamknięta.
  String? launchRoute;

  Future<void> init({
    required String channelName,
    required String channelDescription,
    required void Function(String route) onTap,
    String timeZone = 'Europe/Warsaw',
  }) async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(timeZone));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('ic_notification')),
      onDidReceiveNotificationResponse: (resp) {
        final route = resp.payload;
        if (route != null && route.isNotEmpty) onTap(route);
      },
    );
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(AndroidNotificationChannel(
      notificationChannelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
    ));
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      launchRoute = launch?.notificationResponse?.payload;
    }
    _ready = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  NotificationDetails _details(String channelName) => NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
      );

  /// Pokazuje powiadomienie od razu (np. push odebrany, gdy aplikacja jest na wierzchu).
  Future<void> show({required String title, required String body, required String route, required String channelName}) =>
      _plugin.show(
        id: route.hashCode & 0x7fffffff,
        title: title,
        body: body,
        notificationDetails: _details(channelName),
        payload: route,
      );

  /// Zastępuje wszystkie zaplanowane przypomnienia nowym zestawem.
  Future<void> reschedule(List<Reminder> reminders, {required String channelName}) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        title: r.title,
        body: r.body,
        scheduledDate: tz.TZDateTime.from(r.when, tz.local),
        notificationDetails: _details(channelName),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: r.route,
      );
    }
  }
}
