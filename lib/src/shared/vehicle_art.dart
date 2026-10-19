import 'dart:math';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// VECTOR VEHICLE ILLUSTRATION ENGINE
// ---------------------------------------------------------------------------

class VehicleArt extends StatelessWidget {
  final String type;
  final Color color;

  const VehicleArt({super.key, required this.type, required this.color});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Illustration of a $type',
        child: SizedBox.expand(
          child: CustomPaint(
            painter: DriveLineVehiclePainter(type: type, color: color),
          ),
        ),
      );
}

class DriveLineVehiclePainter extends CustomPainter {
  final String type;
  final Color color;

  DriveLineVehiclePainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / 500 < size.height / 260
        ? size.width / 500
        : size.height / 260);
    canvas.save();
    canvas.translate(
        (size.width - 500 * scale) / 2, (size.height - 260 * scale) / 2);
    canvas.scale(scale);

    final p = Paint()..isAntiAlias = true;

    // Road shadow
    canvas.drawOval(
      const Rect.fromLTWH(35, 210, 430, 24),
      p..color = Colors.black.withAlpha(50),
    );

    final t = type.toLowerCase();
    if (t.contains('tiggo') || t.contains('chery')) {
      _drawTiggo9SUV(canvas, p);
    } else if (t == 'hypercar') {
      _drawHypercar(canvas, p);
    } else if (t == 'suv' || t == 'pickup') {
      _drawSUV(canvas, p);
    } else if (t == 'electric') {
      _drawElectricCar(canvas, p);
    } else {
      _drawSedan(canvas, p);
    }

    canvas.restore();
  }

  void _drawWheels(Canvas canvas, Paint p, double frontX, double rearX) {
    for (final x in [frontX, rearX]) {
      p.color = const Color(0xFF111827);
      p.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, 196), 38, p);

      p.color = const Color(0xFFD1D5DB);
      canvas.drawCircle(Offset(x, 196), 25, p);

      p.color = const Color(0xFF374151);
      canvas.drawCircle(Offset(x, 196), 13, p);

      p.color = Colors.white;
      canvas.drawCircle(Offset(x, 196), 5, p);
    }
  }

  void _drawTiggo9SUV(Canvas canvas, Paint p) {
    final body = Path()
      ..moveTo(40, 182)
      ..lineTo(54, 136)
      ..lineTo(125, 114)
      ..lineTo(175, 58)
      ..lineTo(365, 58)
      ..lineTo(398, 114)
      ..lineTo(456, 132)
      ..quadraticBezierTo(478, 142, 472, 186)
      ..lineTo(458, 204)
      ..lineTo(42, 204)
      ..close();

    p.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF044E3C),
        Color(0xFF047857),
        Color(0xFF10B981),
        Color(0xFF064E3B),
      ],
    ).createShader(const Rect.fromLTWH(40, 58, 435, 146));
    p.style = PaintingStyle.fill;
    canvas.drawPath(body, p);
    p.shader = null;

    p.color = const Color(0xFFE2E8F0);
    p.strokeWidth = 3.5;
    p.style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(190, 52), const Offset(355, 52), p);

    final glass = Path()
      ..moveTo(144, 110)
      ..lineTo(182, 68)
      ..lineTo(355, 68)
      ..lineTo(382, 110)
      ..close();
    p.color = const Color(0xFF0F172A).withAlpha(235);
    p.style = PaintingStyle.fill;
    canvas.drawPath(glass, p);

    p.color = const Color(0xFFE2E8F0);
    p.strokeWidth = 2.5;
    p.style = PaintingStyle.stroke;
    canvas.drawPath(glass, p);
    canvas.drawLine(const Offset(245, 68), const Offset(245, 110), p);
    canvas.drawLine(const Offset(315, 68), const Offset(315, 110), p);

    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF0F172A);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(436, 140, 36, 42), const Radius.circular(8)),
        p);
    p.color = const Color(0xFFE2E8F0);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 2;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(436, 140, 36, 42), const Radius.circular(8)),
        p);
    for (double gx = 442; gx <= 466; gx += 5) {
      canvas.drawLine(Offset(gx, 144), Offset(gx, 178), p);
    }

    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF67E8F9);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(422, 138, 28, 10), const Radius.circular(3)),
        p);

    p.color = const Color(0xFFE50914);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(48, 142, 22, 12), const Radius.circular(3)),
        p);

    _drawTurbineAlloyWheel(canvas, p, 132, 196);
    _drawTurbineAlloyWheel(canvas, p, 388, 196);
  }

  void _drawTurbineAlloyWheel(Canvas canvas, Paint p, double x, double y) {
    p.color = const Color(0xFF111827);
    p.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 38, p);

    p.color = const Color(0xFFE2E8F0);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 2.5;
    canvas.drawCircle(Offset(x, y), 36, p);

    p.color = const Color(0xFF1E293B);
    p.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 28, p);

    p.color = const Color(0xFFE2E8F0);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.8;
    for (int i = 0; i < 14; i++) {
      final double rad = i * (pi * 2 / 14);
      canvas.drawLine(
        Offset(x + 10 * cos(rad), y + 10 * sin(rad)),
        Offset(x + 27 * cos(rad + 0.15), y + 27 * sin(rad + 0.15)),
        p,
      );
    }

    p.color = const Color(0xFF047857);
    p.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 8, p);
    p.color = Colors.white;
    canvas.drawCircle(Offset(x, y), 3.5, p);
  }

  void _drawHypercar(Canvas canvas, Paint p) {
    final body = Path()
      ..moveTo(30, 185)
      ..lineTo(48, 148)
      ..lineTo(140, 130)
      ..lineTo(210, 82)
      ..lineTo(320, 82)
      ..lineTo(405, 126)
      ..lineTo(465, 142)
      ..quadraticBezierTo(480, 150, 475, 188)
      ..lineTo(465, 202)
      ..lineTo(32, 202)
      ..close();

    p.color = const Color(0xFF0F172A);
    p.style = PaintingStyle.fill;
    canvas.drawPath(body, p);

    final glass = Path()
      ..moveTo(160, 126)
      ..lineTo(215, 88)
      ..lineTo(315, 88)
      ..lineTo(385, 126)
      ..close();
    p.color = const Color(0xFF030712).withAlpha(240);
    canvas.drawPath(glass, p);

    p.color = const Color(0xFF00F0FF);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(50, 150, 38, 8), const Radius.circular(3)),
        p);

    p.color = const Color(0xFFE50914);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(445, 146, 26, 8), const Radius.circular(3)),
        p);

    _drawWheels(canvas, p, 132, 385);
  }

  void _drawSedan(Canvas canvas, Paint p) {
    final body = Path()
      ..moveTo(40, 180)
      ..lineTo(55, 142)
      ..lineTo(125, 126)
      ..lineTo(185, 78)
      ..lineTo(315, 78)
      ..lineTo(370, 126)
      ..lineTo(440, 142)
      ..quadraticBezierTo(468, 150, 464, 188)
      ..lineTo(454, 202)
      ..lineTo(42, 202)
      ..close();

    p.color = color;
    p.style = PaintingStyle.fill;
    canvas.drawPath(body, p);

    final glass = Path()
      ..moveTo(145, 122)
      ..lineTo(190, 88)
      ..lineTo(305, 88)
      ..lineTo(355, 122)
      ..close();
    p.color = const Color(0xFF0F172A).withAlpha(220);
    canvas.drawPath(glass, p);

    p.color = color;
    p.strokeWidth = 6;
    p.style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(245, 88), const Offset(245, 122), p);

    p.style = PaintingStyle.fill;
    p.color = const Color(0xFFFEF08A);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(55, 148, 32, 12), const Radius.circular(4)),
        p);

    p.color = const Color(0xFFE50914);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(426, 148, 28, 12), const Radius.circular(4)),
        p);

    _drawWheels(canvas, p, 128, 375);
  }

  void _drawSUV(Canvas canvas, Paint p) {
    final body = Path()
      ..moveTo(38, 180)
      ..lineTo(50, 138)
      ..lineTo(120, 118)
      ..lineTo(168, 62)
      ..lineTo(355, 62)
      ..lineTo(385, 118)
      ..lineTo(445, 135)
      ..quadraticBezierTo(470, 145, 465, 188)
      ..lineTo(454, 202)
      ..lineTo(40, 202)
      ..close();

    p.color = color;
    p.style = PaintingStyle.fill;
    canvas.drawPath(body, p);

    p.color = const Color(0xFF334155);
    p.strokeWidth = 4;
    p.style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(180, 56), const Offset(345, 56), p);

    final glass = Path()
      ..moveTo(138, 114)
      ..lineTo(176, 72)
      ..lineTo(345, 72)
      ..lineTo(370, 114)
      ..close();
    p.color = const Color(0xFF0F172A).withAlpha(220);
    p.style = PaintingStyle.fill;
    canvas.drawPath(glass, p);

    p.color = const Color(0xFFFEF08A);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(50, 144, 34, 14), const Radius.circular(4)),
        p);
    p.color = const Color(0xFFE50914);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(428, 144, 28, 14), const Radius.circular(4)),
        p);

    _drawWheels(canvas, p, 126, 380);
  }

  void _drawElectricCar(Canvas canvas, Paint p) {
    final body = Path()
      ..moveTo(38, 180)
      ..lineTo(54, 140)
      ..lineTo(128, 118)
      ..lineTo(185, 72)
      ..lineTo(320, 72)
      ..lineTo(395, 130)
      ..lineTo(445, 144)
      ..quadraticBezierTo(468, 150, 464, 188)
      ..lineTo(454, 202)
      ..lineTo(40, 202)
      ..close();

    p.color = color;
    p.style = PaintingStyle.fill;
    canvas.drawPath(body, p);

    final dome = Path()
      ..moveTo(140, 114)
      ..lineTo(190, 78)
      ..lineTo(315, 78)
      ..lineTo(380, 122)
      ..close();
    p.color = const Color(0xFF0F172A).withAlpha(230);
    canvas.drawPath(dome, p);

    p.color = const Color(0xFF67E8F9);
    p.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(52, 146, 36, 8), const Radius.circular(4)),
        p);

    p.color = const Color(0xFFE50914);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(428, 146, 28, 8), const Radius.circular(4)),
        p);

    _drawWheels(canvas, p, 128, 376);
  }

  @override
  bool shouldRepaint(covariant DriveLineVehiclePainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}

