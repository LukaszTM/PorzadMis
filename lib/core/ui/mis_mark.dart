import 'package:flutter/material.dart';

// Jedyny plik z literałami kolorów w widgetach: miś ma stałe kolory we wszystkich
// motywach (GUI 1.7 / 4). Odwzorowanie brand/porzadmis-sygnet.svg (viewBox 120).
const _fur = Color(0xFFC2601A);
const _cream = Color(0xFFFBF7F1);
const _ink = Color(0xFF1C2733);
const _tick = Color(0xFF2B7A57);

/// Sygnet misia. [resting] – wariant „odpoczywa”: oczy jako łuki zamiast kropek.
class MisMark extends StatelessWidget {
  const MisMark({super.key, this.size = 96, this.resting = false, this.semanticsLabel});

  final double size;
  final bool resting;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel == null,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _MisPainter(resting)),
      ),
    );
  }
}

class _MisPainter extends CustomPainter {
  const _MisPainter(this.resting);

  final bool resting;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.scale(s);
    final fill = Paint()..style = PaintingStyle.fill;
    void circle(double x, double y, double r, Color c) =>
        canvas.drawCircle(Offset(x, y), r, fill..color = c);

    circle(30, 30, 16, _fur);
    circle(90, 30, 16, _fur);
    circle(30, 30, 8, _cream);
    circle(90, 30, 8, _cream);
    circle(60, 66, 42, _fur);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 81), width: 42, height: 30),
      fill..color = _cream,
    );
    if (resting) {
      final eye = Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      for (final cx in [45.0, 75.0]) {
        canvas.drawArc(Rect.fromCenter(center: Offset(cx, 65), width: 11, height: 9), 0.2, 2.74, false, eye);
      }
    } else {
      circle(45, 66, 4.5, _ink);
      circle(75, 66, 4.5, _ink);
    }
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 73), width: 10, height: 7),
      fill..color = _ink,
    );
    final tick = Path()
      ..moveTo(50.5, 82.5)
      ..cubicTo(53, 88.5, 56.5, 91.5, 60, 91)
      ..cubicTo(65, 90.5, 68.5, 85, 70, 78);
    canvas.drawPath(
      tick,
      Paint()
        ..color = _tick
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_MisPainter old) => old.resting != resting;
}
