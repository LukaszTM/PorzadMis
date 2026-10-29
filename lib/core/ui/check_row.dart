import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Ptaszek w kształcie uśmiechu misia (ścieżka `M50 84l6 6 14-14` z logo).
class SmileCheckPainter extends CustomPainter {
  const SmileCheckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Ścieżka w układzie logo: (50,84) → (56,90) → (70,76); obszar 20 × 14.
    final scale = size.width / 20;
    final dy = (size.height - 14 * scale) / 2;
    Offset p(double x, double y) => Offset((x - 50) * scale, (y - 76) * scale + dy);
    final path = Path()
      ..moveTo(p(50, 84).dx, p(50, 84).dy)
      ..lineTo(p(56, 90).dx, p(56, 90).dy)
      ..lineTo(p(70, 76).dx, p(70, 76).dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.16
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(SmileCheckPainter old) => old.color != color;
}

/// Wiersz listy z odhaczaniem (GUI 5.3). Cały wiersz jest celem dotyku.
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.title,
    required this.checked,
    required this.onChanged,
    this.meta,
    this.minHeight = 60,
  });

  final String title;
  final bool checked;
  final ValueChanged<bool> onChanged;

  /// „Tomek · codziennie” – 14 sp textMuted po prawej.
  final String? meta;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Semantics(
      checked: checked,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!checked),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: checked ? t.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.accent, width: 3),
                ),
                padding: const EdgeInsets.all(5),
                child: checked
                    ? CustomPaint(painter: SmileCheckPainter(t.onAccent))
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: text.bodyLarge!.copyWith(
                    color: checked ? t.textMuted : t.text,
                    decoration: checked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (meta != null) ...[
                const SizedBox(width: 8),
                Text(meta!, style: text.labelMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
