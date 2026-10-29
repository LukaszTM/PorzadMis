import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class SegmentOption<T> {
  const SegmentOption(this.value, this.label);

  final T value;
  final String label;
}

/// Przełącznik segmentowy (GUI 5.8) dla 2–3 opcji. Wysokość 48 dp.
class SegmentedSwitch<T> extends StatelessWidget {
  const SegmentedSwitch({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<SegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: option.value == value,
                label: option.label,
                excludeSemantics: true,
                child: Material(
                  color: option.value == value ? t.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    onTap: () => onChanged(option.value),
                    child: Center(
                      child: Text(
                        option.label,
                        style: text.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w800,
                          color: option.value == value ? t.onAccent : t.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
