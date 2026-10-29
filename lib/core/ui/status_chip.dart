import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

enum ChipTone { accent, neutral, warning, success }

/// Plakietka (GUI 5.7): pigułka 13 sp ExtraBold. Status zawsze tekstem, nie samym kolorem.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.tone = ChipTone.accent, this.icon});

  final String label;
  final ChipTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (Color bg, Color fg) = switch (tone) {
      ChipTone.accent => (t.accentSoft, t.accent),
      ChipTone.neutral => (t.border, t.textMuted),
      ChipTone.warning => (t.warning.withValues(alpha: 0.15), t.warning),
      ChipTone.success => (t.success.withValues(alpha: 0.15), t.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(label, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: fg)),
        ],
      ),
    );
  }
}
