import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/router/app_router.dart';
import '../../../core/util/dates.dart';
import '../../auth/data/auth_repository.dart';
import '../../calendar/data/events_repository.dart';
import '../../chores/data/chores_repository.dart';
import '../../notifications/app/notifications_bootstrap.dart';
import '../../shopping/data/shopping_repository.dart';
import '../domain/widget_payload.dart';

const _todayProvider = 'TodayWidgetProvider';
const _shoppingProvider = 'ShoppingWidgetProvider';

/// Zapisuje dane do widżetów przy każdej zmianie (z odstępem) i obsługuje dotknięcie widżetu.
final widgetSyncProvider = Provider<void>((ref) {
  final l = ref.watch(appLocalizationsProvider);
  Timer? debounce;
  StreamSubscription<Uri?>? clicks;

  Future<void> push() async {
    final uid = ref.read(authStateProvider).value?.uid;
    final now = DateTime.now();
    final payloads = buildWidgetPayloads(
      now: now,
      uid: uid ?? '',
      occurrences: uid == null ? const [] : (ref.read(choreOccurrencesProvider).value ?? const []),
      events: uid == null ? const [] : ref.read(allEventsProvider),
      items: uid == null ? const [] : (ref.read(shoppingItemsProvider).value ?? const []),
      nextEventLabel: (title, start, allDay) => '$title · ${formatWhen(l, start, allDay: allDay, now: now)}',
      todayEmptyText: l.choresEmptyMine,
      shoppingEmptyText: l.shoppingCardNone,
    );
    try {
      await HomeWidget.saveWidgetData<String>('widget_today', payloads.today);
      await HomeWidget.saveWidgetData<String>('widget_shopping', payloads.shopping);
      await HomeWidget.updateWidget(androidName: _todayProvider);
      await HomeWidget.updateWidget(androidName: _shoppingProvider);
    } catch (_) {
      // Brak widżetów na ekranie albo platforma bez obsługi: nic do zrobienia.
    }
  }

  void schedule() {
    debounce?.cancel();
    debounce = Timer(const Duration(seconds: 2), push);
  }

  ref.listen(authStateProvider, (_, _) => schedule(), fireImmediately: true);
  ref.listen(choreOccurrencesProvider, (_, _) => schedule());
  ref.listen(allEventsProvider, (_, _) => schedule());
  ref.listen(shoppingItemsProvider, (_, _) => schedule());

  void open(Uri? uri) {
    final route = routeFromWidgetUri(uri);
    if (route != null) ref.read(routerProvider).go(route);
  }

  HomeWidget.initiallyLaunchedFromHomeWidget().then(open).catchError((Object _) {});
  clicks = HomeWidget.widgetClicked.listen(open, onError: (Object _) {});

  ref.onDispose(() {
    debounce?.cancel();
    clicks?.cancel();
  });
});
