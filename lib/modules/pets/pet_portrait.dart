import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'pets_model.dart';

/// Original locally drawn illustrations: no network images or third-party art.
class PetPortrait extends StatelessWidget {
  final Pet pet;
  const PetPortrait({super.key, required this.pet});
  @override
  Widget build(BuildContext context) => Semantics(
    label: '${pet.name}, ${pet.species == 'cat' ? '🐈' : '🐕'}',
    image: true,
    child: CustomPaint(painter: PetIllustration(pet), size: Size.infinite),
  );
}

class PetIllustration extends CustomPainter {
  final Pet pet;
  PetIllustration(this.pet);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Color(pet.color));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final scale = math.min(size.width / 260, size.height / 230);
    canvas.scale(scale);
    void oval(double x, double y, double w, double h, Color c) =>
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: w, height: h),
          Paint()..color = c,
        );
    const dark = Color(0xFF343D36);
    final fur = pet.id == 'amora'
        ? const Color(0xFF4C514C)
        : pet.id == 'oliver'
        ? const Color(0xFFE2A662)
        : const Color(0xFFF6E8D5);
    oval(0, 116, 165, 165, fur);
    if (pet.species == 'cat') {
      for (final side in [-1.0, 1.0]) {
        final ear = Path()
          ..moveTo(side * 68, -15)
          ..lineTo(side * 74, -99)
          ..lineTo(side * 15, -60)
          ..close();
        canvas.drawPath(ear, Paint()..color = fur);
        final inner = Path()
          ..moveTo(side * 57, -40)
          ..lineTo(side * 61, -78)
          ..lineTo(side * 32, -58)
          ..close();
        canvas.drawPath(inner, Paint()..color = const Color(0xFFCF9B91));
      }
    } else {
      oval(-68, -5, 61, 126, const Color(0xFFA97D58));
      oval(68, -5, 61, 126, const Color(0xFFA97D58));
    }
    oval(0, -10, 150, 151, fur);
    oval(-28, -17, 12, 17, dark);
    oval(28, -17, 12, 17, dark);
    oval(-30, -20, 3, 4, Colors.white);
    oval(26, -20, 3, 4, Colors.white);
    oval(-14, 21, 40, 32, const Color(0xFFFFF5E8));
    oval(14, 21, 40, 32, const Color(0xFFFFF5E8));
    oval(0, 13, 16, 11, dark);
    final line = Paint()
      ..color = dark
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(0, 18)
        ..lineTo(0, 29)
        ..quadraticBezierTo(9, 37, 17, 28),
      line,
    );
    if (pet.species == 'cat') {
      for (final side in [-1.0, 1.0]) {
        canvas.drawLine(Offset(side * 32, 21), Offset(side * 83, 12), line);
        canvas.drawLine(Offset(side * 34, 31), Offset(side * 85, 36), line);
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-51, 59, 102, 14),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF1D594E),
    );
    oval(0, 79, 23, 23, const Color(0xFFDDA44F));
    canvas.restore();
  }

  @override
  bool shouldRepaint(PetIllustration oldDelegate) => oldDelegate.pet != pet;
}

class LanguageFlag extends StatelessWidget {
  final bool brazil;
  const LanguageFlag({super.key, required this.brazil});
  @override
  Widget build(BuildContext context) => ClipOval(
    child: SizedBox(
      width: 25,
      height: 25,
      child: CustomPaint(painter: _FlagPainter(brazil)),
    ),
  );
}

class _FlagPainter extends CustomPainter {
  final bool brazil;
  _FlagPainter(this.brazil);
  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawRect(
      r,
      Paint()
        ..color = brazil ? const Color(0xFF16834B) : const Color(0xFF243D7C),
    );
    if (brazil) {
      c.drawPath(
        Path()
          ..moveTo(12.5, 3)
          ..lineTo(23, 12.5)
          ..lineTo(12.5, 22)
          ..lineTo(2, 12.5)
          ..close(),
        Paint()..color = const Color(0xFFFFD94A),
      );
      c.drawCircle(
        const Offset(12.5, 12.5),
        5,
        Paint()..color = const Color(0xFF243D7C),
      );
      c.drawLine(
        const Offset(8, 11),
        const Offset(17, 14),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5,
      );
    } else {
      for (final color in [Colors.white, const Color(0xFFD83346)]) {
        final p = Paint()
          ..color = color
          ..strokeWidth = color == Colors.white ? 6 : 2;
        c.drawLine(Offset.zero, const Offset(25, 25), p);
        c.drawLine(const Offset(0, 25), const Offset(25, 0), p);
      }
      for (final color in [Colors.white, const Color(0xFFD83346)]) {
        final p = Paint()
          ..color = color
          ..strokeWidth = color == Colors.white ? 9 : 5;
        c.drawLine(const Offset(12.5, 0), const Offset(12.5, 25), p);
        c.drawLine(const Offset(0, 12.5), const Offset(25, 12.5), p);
      }
    }
  }

  @override
  bool shouldRepaint(_FlagPainter oldDelegate) => oldDelegate.brazil != brazil;
}
