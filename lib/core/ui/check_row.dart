import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Ptaszek w kształcie uśmiechu misia: ta sama krzywa co w logo v1.1
/// (`M50.5 82.5 C53 88.5 56.5 91.5 60 91 C65 90.5 68.5 85 70 78`, układ 120 × 120).
class SmileCheckPainter extends CustomPainter {
  const SmileCheckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Obszar krzywej w układzie logo: x 50,5–70 (19,5), y 78–91 (13).
    final scale = size.width / 19.5;
    final dy = (size.height - 13 * scale) / 2;
    Offset p(double x, double y) => Offset((x - 50.5) * scale, (y - 78) * scale + dy);
    final a = p(50.5, 82.5);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(p(53, 88.5).dx, p(53, 88.5).dy, p(56.5, 91.5).dx, p(56.5, 91.5).dy, p(60, 91).dx, p(60, 91).dy)
      ..cubicTo(p(65, 90.5).dx, p(65, 90.5).dy, p(68.5, 85).dx, p(68.5, 85).dy, p(70, 78).dx, p(70, 78).dy);
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
    this.trailing,
    this.onLongPress,
    this.minHeight = 60,
  });

  final String title;
  final bool checked;
  final ValueChanged<bool> onChanged;

  /// „Tomek · codziennie” – 14 sp textMuted po prawej.
  final String? meta;

  /// Dodatkowa akcja po prawej (np. edycja); poza celem odhaczania.
  final Widget? trailing;
  final VoidCallback? onLongPress;
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
        onLongPress: onLongPress,
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
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
