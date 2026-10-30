import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'mis_mark.dart';

/// Komunikat (GUI 7, 8). Miś po lewej tylko przy komunikatach pozytywnych – błąd go nie ma.
void showAppToast(
  BuildContext context,
  String message, {
  bool error = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final t = context.tokens;
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(label: actionLabel, textColor: t.accent, onPressed: onAction)
            : null,
        content: Row(
          children: [
            if (!error) ...[const MisMark(size: 20), const SizedBox(width: 12)],
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: error ? t.danger : t.text,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
}
