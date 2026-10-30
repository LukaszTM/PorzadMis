import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class ChoiceOption<T> {
  const ChoiceOption(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Wybór jednej lub wielu opcji z pigułek (GUI 5.7/5.8 dla >3 opcji). Każda pigułka ma min. 48 dp.
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<ChoiceOption<T>> options;
  final Set<T> selected;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          Semantics(
            button: true,
            selected: selected.contains(o.value),
            label: o.label,
            excludeSemantics: true,
            child: Material(
              color: selected.contains(o.value) ? t.accent : t.surface,
              shape: StadiumBorder(
                side: BorderSide(color: selected.contains(o.value) ? t.accent : t.border, width: 2),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onToggle(o.value),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (o.icon != null) ...[
                          Icon(o.icon, size: 18, color: selected.contains(o.value) ? t.onAccent : t.textMuted),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          o.label,
                          style: text.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: selected.contains(o.value) ? t.onAccent : t.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
