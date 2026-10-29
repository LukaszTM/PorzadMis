import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_buttons.dart';

/// Arkusz dolny (GUI 5.9): uchwyt 40 × 4, tytuł 20 sp, przycisk główny na dole.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required Widget Function(BuildContext context) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final t = sheetContext.tokens;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 16),
              builder(sheetContext),
            ],
          ),
        ),
      );
    },
  );
}

/// Potwierdzenie (usuwanie, zmiana roli) w arkuszu dolnym. Zwraca true po „Tak”.
Future<bool> confirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  bool danger = false,
}) async {
  final result = await showAppSheet<bool>(
    context,
    title: title,
    builder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(body, style: Theme.of(sheetContext).textTheme.bodyMedium),
        const SizedBox(height: 20),
        PrimaryButton(
          label: confirmLabel,
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        const SizedBox(height: 8),
        TertiaryButton(
          label: cancelLabel,
          danger: danger,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    ),
  );
  return result ?? false;
}
