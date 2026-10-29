import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Przycisk główny (GUI 5.4): 56 dp, accent, jeden na ekran.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Stan ładowania: etykieta zamienia się w trzy kropki, przycisk nie znika.
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = Theme.of(context).textTheme.labelLarge!.copyWith(color: t.onAccent);
    return Semantics(
      button: true,
      label: loading ? label : null,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: t.onAccent,
            disabledBackgroundColor: loading ? t.accent : t.border,
            disabledForegroundColor: loading ? t.onAccent : t.textMuted,
            overlayColor: t.text,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: style,
          ),
          child: Text(loading ? '•••' : label, style: style),
        ),
      ),
    );
  }
}

/// Przycisk drugorzędny (GUI 5.5): obrys 2 dp accent, tło surface.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = Theme.of(context).textTheme.labelLarge!.copyWith(color: t.accent);
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: t.surface,
          foregroundColor: t.accent,
          side: BorderSide(color: t.accent, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: style,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 24), const SizedBox(width: 8)],
            Flexible(child: Text(label, style: style, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}

/// Przycisk tekstowy (GUI 5.5): sam tekst accent, cel min. 44 dp.
class TertiaryButton extends StatelessWidget {
  const TertiaryButton({super.key, required this.label, required this.onPressed, this.danger = false});

  final String label;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = danger ? t.danger : t.accent;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
      ),
    );
  }
}
