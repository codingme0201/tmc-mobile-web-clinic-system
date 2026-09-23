import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Premium emerald clinic emblem representing TMC CareLink.
/// Features a squircle emerald base, protective care shield, medical cross,
/// vitality lifeline ECG pulse, and gold luxury sparkle.
class ClinicEmblem extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool showSparkle;

  const ClinicEmblem({
    super.key,
    this.size = 80,
    this.showShadow = true,
    this.showSparkle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.32),
                  blurRadius: size * 0.26,
                  offset: Offset(0, size * 0.09),
                ),
              ],
            )
          : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _ClinicEmblemPainter(showSparkle: showSparkle),
      ),
    );
  }
}

class _ClinicEmblemPainter extends CustomPainter {
  final bool showSparkle;

  _ClinicEmblemPainter({this.showSparkle = true});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 512.0;
    final margin = 20.0 * scale;
    final inner = size.width - (margin * 2.0);
    final r = inner * 0.24;

    // 1. Base Squircle with Deep Emerald Gradient
    final rect = Rect.fromLTWH(margin, margin, inner, inner);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0B4F49),
          Color(0xFF073B37),
          Color(0xFF042623),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    // 2. Glowing Mint Rim Stroke
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, 4.0 * scale)
      ..color = const Color(0xFF34D399).withValues(alpha: 0.65);
    canvas.drawRRect(rrect, rimPaint);

    // Inner subtle hairline
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin + 3.0 * scale, margin + 3.0 * scale, inner - 6.0 * scale, inner - 6.0 * scale),
      Radius.circular(math.max(2.0, r - 3.0 * scale)),
    );
    final innerHairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, 1.2 * scale)
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawRRect(innerRRect, innerHairline);

    final cx = size.width / 2.0;
    final cy = size.height / 2.0;

    // 3. Protective Care Arc / Shield
    final shieldPath = Path();
    final pTop = Offset(cx, cy - 120.0 * scale);
    final pLeft = Offset(cx - 130.0 * scale, cy - 50.0 * scale);
    final pRight = Offset(cx + 130.0 * scale, cy - 50.0 * scale);
    final pBottom = Offset(cx, cy + 135.0 * scale);

    shieldPath.moveTo(pTop.dx, pTop.dy);
    shieldPath.cubicTo(
      cx - 70.0 * scale, cy - 170.0 * scale,
      pLeft.dx, cy + 40.0 * scale,
      pBottom.dx, pBottom.dy,
    );
    shieldPath.cubicTo(
      pRight.dx, cy + 40.0 * scale,
      cx + 70.0 * scale, cy - 170.0 * scale,
      pTop.dx, pTop.dy,
    );

    final shieldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, 8.0 * scale)
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF34D399).withValues(alpha: 0.28);
    canvas.drawPath(shieldPath, shieldPaint);

    // 4. Pure White Medical Cross
    final crossW = 68.0 * scale;
    final crossL = 210.0 * scale;
    final crossR = Radius.circular(18.0 * scale);

    final crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Vertical Bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: crossW, height: crossL),
        crossR,
      ),
      crossPaint,
    );

    // Horizontal Bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: crossL, height: crossW),
        crossR,
      ),
      crossPaint,
    );

    // 5. Vitality Lifeline Pulse (ECG heartbeat)
    final pulsePoints = [
      Offset(cx - 88.0 * scale, cy),
      Offset(cx - 48.0 * scale, cy),
      Offset(cx - 26.0 * scale, cy - 44.0 * scale),
      Offset(cx - 4.0 * scale, cy + 44.0 * scale),
      Offset(cx + 20.0 * scale, cy - 20.0 * scale),
      Offset(cx + 38.0 * scale, cy + 14.0 * scale),
      Offset(cx + 54.0 * scale, cy),
      Offset(cx + 88.0 * scale, cy),
    ];

    final pulsePath = Path()..moveTo(pulsePoints[0].dx, pulsePoints[0].dy);
    for (int i = 1; i < pulsePoints.length; i++) {
      pulsePath.lineTo(pulsePoints[i].dx, pulsePoints[i].dy);
    }

    // Outer dark contrast backing
    final pulseBgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.5, 11.0 * scale)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF073B37);
    canvas.drawPath(pulsePath, pulseBgPaint);

    // Inner glowing emerald pulse
    final pulseFgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, 5.5 * scale)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF10B981);
    canvas.drawPath(pulsePath, pulseFgPaint);

    // 6. Gold Sparkle Star (Top-right accent)
    if (showSparkle) {
      final sx = cx + 105.0 * scale;
      final sy = cy - 105.0 * scale;
      final sr = 22.0 * scale;
      final innerSr = sr * 0.26;

      final starPath = Path()
        ..moveTo(sx, sy - sr)
        ..lineTo(sx + innerSr, sy - innerSr)
        ..lineTo(sx + sr, sy)
        ..lineTo(sx + innerSr, sy + innerSr)
        ..lineTo(sx, sy + sr)
        ..lineTo(sx - innerSr, sy + innerSr)
        ..lineTo(sx - sr, sy)
        ..lineTo(sx - innerSr, sy - innerSr)
        ..close();

      final starPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill;
      canvas.drawPath(starPath, starPaint);

      // Star gleam
      final gleamPaint = Paint()
        ..color = const Color(0xFFFFFBEB)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sx, sy), math.max(1.0, 3.2 * scale), gleamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClinicEmblemPainter oldDelegate) {
    return oldDelegate.showSparkle != showSparkle;
  }
}
