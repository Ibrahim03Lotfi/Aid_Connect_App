import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The official custom brand emblem for "أثر" (Athar / AidConnect).
/// Represents humanitarian shelter, supportive hands, and a radiant beacon of hope.
class AtharLogoWidget extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool showText;
  final String? subtitle;
  final bool? isDark;

  const AtharLogoWidget({
    super.key,
    this.size = 80,
    this.showGlow = true,
    this.showText = false,
    this.subtitle,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    Widget emblem = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGlow)
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E7ABF).withAlpha(dark ? 60 : 35),
                    blurRadius: size * 0.4,
                    spreadRadius: size * 0.05,
                  ),
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withAlpha(dark ? 40 : 20),
                    blurRadius: size * 0.6,
                  ),
                ],
              ),
            ),
          CustomPaint(
            size: Size(size, size),
            painter: _AtharLogoPainter(isDark: dark),
          ),
        ],
      ),
    );

    if (!showText) return emblem;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        emblem,
        const SizedBox(height: 14),
        Text(
          'أثر',
          style: GoogleFonts.cairo(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w900,
            color: dark ? const Color(0xFF60A5FA) : const Color(0xFF0F2C59),
            letterSpacing: 1.0,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: GoogleFonts.cairo(
              fontSize: size * 0.16,
              fontWeight: FontWeight.w600,
              color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }
}

class _AtharLogoPainter extends CustomPainter {
  final bool isDark;

  const _AtharLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Background Rounded Contour Pill / Shield
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w * 0.96, height: h * 0.96),
      Radius.circular(w * 0.28),
    );

    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF0F2C59), const Color(0xFF1E293B)]
          : [Colors.white, const Color(0xFFF0F7FF)],
    );

    final bgPaint = Paint()
      ..shader = bgGradient.createShader(bgRect.outerRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bgRect, bgPaint);

    // Subtle Border
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF38BDF8).withAlpha(isDark ? 100 : 80),
          const Color(0xFF1E7ABF).withAlpha(isDark ? 40 : 30),
        ],
      ).createShader(bgRect.outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;
    canvas.drawRRect(bgRect, borderPaint);

    // 2. The Protective Humanitarian Embracing Curves ("أثر" Dual Wings / Hands)
    // Left Wing (Rising compassion wing)
    final leftPath = Path();
    leftPath.moveTo(w * 0.26, h * 0.68);
    leftPath.cubicTo(
      w * 0.18, h * 0.46,
      w * 0.32, h * 0.26,
      w * 0.50, h * 0.20,
    );
    leftPath.cubicTo(
      w * 0.44, h * 0.36,
      w * 0.36, h * 0.52,
      w * 0.38, h * 0.66,
    );
    leftPath.close();

    final leftGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF38BDF8), Color(0xFF1E7ABF)],
    );
    final leftPaint = Paint()
      ..shader = leftGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftPath, leftPaint);

    // Right Wing (Interlocking caring hand)
    final rightPath = Path();
    rightPath.moveTo(w * 0.74, h * 0.68);
    rightPath.cubicTo(
      w * 0.82, h * 0.46,
      w * 0.68, h * 0.26,
      w * 0.50, h * 0.20,
    );
    rightPath.cubicTo(
      w * 0.56, h * 0.36,
      w * 0.64, h * 0.52,
      w * 0.62, h * 0.66,
    );
    rightPath.close();

    final rightGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF10B981), Color(0xFF0D9488)],
    );
    final rightPaint = Paint()
      ..shader = rightGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightPath, rightPaint);

    // 3. Foundation Base Cradle (Supporting Arc)
    final baseArc = Path();
    baseArc.moveTo(w * 0.30, h * 0.66);
    baseArc.cubicTo(
      w * 0.40, h * 0.82,
      w * 0.60, h * 0.82,
      w * 0.70, h * 0.66,
    );
    baseArc.cubicTo(
      w * 0.60, h * 0.75,
      w * 0.40, h * 0.75,
      w * 0.30, h * 0.66,
    );
    baseArc.close();

    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E7ABF), Color(0xFF0F2C59)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(baseArc, basePaint);

    // 4. Central Radiant Beacon of Hope (Radiant 4-Point Star of Impact "أثر")
    final starPath = Path();
    final starCenterX = w * 0.50;
    final starCenterY = h * 0.46;
    final outerR = w * 0.16;
    final innerR = w * 0.05;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180 - (math.pi / 2);
      final r = (i % 2 == 0) ? outerR : innerR;
      final x = starCenterX + r * math.cos(angle);
      final y = starCenterY + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    final starGradient = const LinearGradient(
      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    );
    final starPaint = Paint()
      ..shader = starGradient.createShader(Rect.fromCircle(center: Offset(starCenterX, starCenterY), radius: outerR))
      ..style = PaintingStyle.fill;

    canvas.drawPath(starPath, starPaint);

    // Center Core Light Gem
    final coreGlow = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(starCenterX, starCenterY), w * 0.035, coreGlow);
  }

  @override
  bool shouldRepaint(covariant _AtharLogoPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
