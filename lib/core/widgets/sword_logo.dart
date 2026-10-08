import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SwordLogo extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const SwordLogo({
    Key? key,
    this.size = 64.0,
    this.primaryColor = AppTheme.primaryCyan,
    this.secondaryColor = AppTheme.accentBlue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ZulfiqarSwordPainter(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
      ),
    );
  }
}

class _ZulfiqarSwordPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _ZulfiqarSwordPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Glowing effect paint
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.6),
          secondaryColor.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.45, glowPaint);

    // Sword Gradient Paint
    final Paint bladePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor, secondaryColor],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw Zulfiqar Dual-Tip Blade
    final Path bladePath = Path();
    final double centerX = w / 2;

    // Left Tip
    bladePath.moveTo(centerX - w * 0.12, h * 0.12);
    // Center notch between tips
    bladePath.lineTo(centerX, h * 0.22);
    // Right Tip
    bladePath.lineTo(centerX + w * 0.12, h * 0.12);

    // Right Edge curving down to Guard
    bladePath.quadraticBezierTo(
      centerX + w * 0.18,
      h * 0.5,
      centerX + w * 0.08,
      h * 0.68,
    );

    // Right Crossguard
    bladePath.lineTo(centerX + w * 0.32, h * 0.68);
    bladePath.lineTo(centerX + w * 0.32, h * 0.74);
    bladePath.lineTo(centerX + w * 0.06, h * 0.74);

    // Hilt / Handle
    bladePath.lineTo(centerX + w * 0.05, h * 0.88);
    // Pommel (Bottom Orb)
    bladePath.arcToPoint(
      Offset(centerX - w * 0.05, h * 0.88),
      radius: Radius.circular(w * 0.05),
      clockwise: true,
    );
    bladePath.lineTo(centerX - w * 0.06, h * 0.74);

    // Left Crossguard
    bladePath.lineTo(centerX - w * 0.32, h * 0.74);
    bladePath.lineTo(centerX - w * 0.32, h * 0.68);
    bladePath.lineTo(centerX - w * 0.08, h * 0.68);

    // Left Edge curving up to Left Tip
    bladePath.quadraticBezierTo(
      centerX - w * 0.18,
      h * 0.5,
      centerX - w * 0.12,
      h * 0.12,
    );

    bladePath.close();

    canvas.drawPath(bladePath, bladePaint);
    canvas.drawPath(bladePath, borderPaint);

    // Center Blade Fulling Line / Energy Channel
    final Paint energyLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path energyLine = Path();
    energyLine.moveTo(centerX, h * 0.22);
    energyLine.lineTo(centerX, h * 0.66);

    canvas.drawPath(energyLine, energyLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
