import '../l10n/strings.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/models.dart';
import 'guides.dart';

/// Original schematic drawings. These are visual cues, not scale assembly diagrams.
class CareIllustration extends StatelessWidget {
  const CareIllustration({super.key, required this.model, required this.art});
  final DeviceModel model;
  final CareArt art;
  @override
  Widget build(BuildContext context) => Semantics(
    label: (L.italian
        ? "Illustrazione schematica: ${model.label}, fase di pulizia"
        : "Schematische Illustration: ${model.label}, Pflegeschritt"),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 1.65,
        child: CustomPaint(painter: _CarePainter(model, art)),
      ),
    ),
  );
}

class _CarePainter extends CustomPainter {
  _CarePainter(this.model, this.art);
  final DeviceModel model;
  final CareArt art;
  static const orange = Color(0xFFFF8C42), blue = Color(0xFF7DD9EC);
  late Canvas c;
  Paint ink(Color color, {double stroke = 0}) => Paint()
    ..color = color
    ..style = stroke == 0 ? PaintingStyle.fill : PaintingStyle.stroke
    ..strokeWidth = stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  void line(
    double x1,
    double y1,
    double x2,
    double y2,
    Color color, [
    double width = 2,
  ]) => c.drawLine(Offset(x1, y1), Offset(x2, y2), ink(color, stroke: width));
  void box(
    double x,
    double y,
    double w,
    double h,
    Color color, [
    double radius = 10,
  ]) => c.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(radius)),
    ink(color),
  );
  void text(
    String text,
    double x,
    double y, {
    Color color = const Color(0xFFBAC1CA),
    double size = 11,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: size,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 290);
    p.paint(c, Offset(x, y));
  }

  void ring(double x, double y, double r, [Color color = orange]) =>
      c.drawCircle(Offset(x, y), r, ink(color, stroke: 3));
  void screen(double x, double y, double r) {
    c.drawCircle(Offset(x, y), r, ink(const Color(0xFF737B85), stroke: 2));
    for (var a = -r + 5; a < r; a += 5) {
      final half = math.sqrt(r * r - a * a);
      line(x - half, y + a, x + half, y + a, const Color(0xFF65717D), 1);
    }
  }

  void arrow(double x, double y, double length, {bool up = true}) {
    final end = y + (up ? -length : length);
    line(x, y, x, end, orange, 3);
    line(x, end, x - 6, end + (up ? 7 : -7), orange, 3);
    line(x, end, x + 6, end + (up ? 7 : -7), orange, 3);
  }

  void device(double x, double y, {bool separated = false}) {
    if (model == DeviceModel.volcanoHybrid) {
      final path = Path()
        ..moveTo(x + 18, y + 108)
        ..lineTo(x + 47, y + 21)
        ..quadraticBezierTo(x + 65, y + 7, x + 83, y + 21)
        ..lineTo(x + 112, y + 108)
        ..close();
      c.drawPath(path, ink(const Color(0xFFB9C1C8)));
      box(x + 12, y + 100, 106, 28, const Color(0xFF252B32), 8);
      box(x + 41, y + 104, 48, 15, const Color(0xFF10141A), 3);
      line(x + 50, y + 111, x + 80, y + 111, orange, 3);
      box(x + 48, y + (separated ? -7 : 8), 35, 14, orange, 4);
      return;
    }
    final w = model == DeviceModel.venty ? 72.0 : 64.0;
    box(x + 29, y + 25, w, 110, const Color(0xFF363E47), 13);
    for (var n = 0; n < 11; n++) {
      line(
        x + 34,
        y + 41 + n * 7,
        x + 24 + w,
        y + 41 + n * 7,
        const Color(0xFF1B2027),
        3,
      );
    }
    final top = y + (separated ? -12 : 16);
    box(x + 29, top, w, 23, const Color(0xFF606A74), 8);
    box(x + 40, top - 13, 38, 9, orange, 4);
    if (model == DeviceModel.venty) {
      box(x + 42, y + 72, 43, 26, const Color(0xFF0E1217), 4);
      text('OFF', x + 50, y + 79, color: const Color(0xFFB9C1C8), size: 12);
    } else {
      c.drawCircle(Offset(x + 60, y + 109), 6, ink(orange));
    }
    line(x + 42, y + 129, x + 78, y + 129, orange, 3);
  }

  void brush(double x, double y) {
    c.save();
    c.translate(x, y);
    c.rotate(-.4);
    box(0, 0, 13, 72, orange, 6);
    box(-5, 64, 23, 28, const Color(0xFFD6C3AB), 4);
    for (var n = 0; n < 5; n++) {
      line(-3 + n * 4, 69, -3 + n * 4, 94, const Color(0xFF967C5B), 1);
    }
    c.restore();
  }

  void drop(double x, double y) {
    final path = Path()
      ..moveTo(x, y - 9)
      ..quadraticBezierTo(x - 12, y + 5, x, y + 8)
      ..quadraticBezierTo(x + 12, y + 5, x, y - 9);
    c.drawPath(path, ink(blue));
  }

  @override
  void paint(Canvas canvas, Size size) {
    c = canvas;
    c.save();
    c.scale(size.width / 360, size.height / 218);
    box(0, 0, 360, 218, const Color(0xFF1A2027), 0);
    c.drawCircle(
      const Offset(180, 104),
      96,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x244F82A7), Color(0x001A2027)],
        ).createShader(const Rect.fromLTWH(84, 8, 192, 192)),
    );
    for (var x = 16.0; x < 360; x += 22) {
      for (var y = 17.0; y < 195; y += 22) {
        c.drawCircle(Offset(x, y), .7, ink(const Color(0xFF303842)));
      }
    }
    switch (art) {
      case CareArt.tools:
        box(66, 62, 49, 85, const Color(0xFFADC3C8), 12);
        box(77, 44, 27, 23, const Color(0xFF535E68), 5);
        box(72, 89, 37, 34, const Color(0xFF20303B), 5);
        text('CLEAN', 77, 100, color: blue, size: 8);
        brush(160, 58);
        box(212, 120, 74, 33, const Color(0xFF687B8B));
        ring(239, 93, 15);
        screen(283, 76, 18);
        text(L.s284, 89, 174, color: orange);
      case CareArt.power:
        device(62, 28);
        ring(252, 100, 28);
        c.drawArc(
          const Rect.fromLTWH(236, 84, 32, 32),
          -.9,
          4.9,
          false,
          ink(orange, stroke: 4),
        );
        line(252, 78, 252, 98, orange, 4);
        text(L.s285, 209, 148, color: orange);
      case CareArt.mouthpiece:
        device(104, 49);
        box(215, 45, 51, 10, orange, 5);
        arrow(235, 101, 30);
        ring(250, 125, 13);
      case CareArt.cap:
        device(86, 55, separated: true);
        arrow(243, 105, 51);
        text(L.s286, 222, 131, color: orange);
      case CareArt.parts:
        box(68, 56, 78, 22, const Color(0xFF6C7C87), 9);
        box(73, 111, 73, 24, const Color(0xFF47535F), 9);
        ring(213, 69, 22);
        screen(281, 76, 21);
        ring(203, 130, 13);
        screen(263, 138, 17);
        text(model.isCrafty ? L.s287 : L.s288, 85, 177, color: orange);
      case CareArt.brush:
        screen(135, 115, 37);
        brush(203, 44);
        c.drawCircle(const Offset(107, 167), 3, ink(orange));
        c.drawCircle(const Offset(124, 175), 2, ink(orange));
        text(
          model == DeviceModel.volcanoHybrid ? L.s289 : L.s290,
          79,
          187,
          color: orange,
        );
      case CareArt.bath:
        final path = Path()
          ..moveTo(67, 83)
          ..lineTo(86, 164)
          ..quadraticBezierTo(180, 184, 274, 164)
          ..lineTo(293, 83)
          ..close();
        c.drawPath(path, ink(const Color(0xFF283F4B)));
        c.drawPath(path, ink(blue, stroke: 2));
        c.drawOval(
          const Rect.fromLTWH(67, 70, 226, 28),
          ink(const Color(0xFF355C6A)),
        );
        ring(132, 119, 20);
        screen(207, 132, 25);
        box(219, 94, 30, 11, const Color(0xFF9DAEB8), 3);
        text(L.s291, 103, 188, color: blue);
      case CareArt.rinse:
        box(90, 44, 126, 20, const Color(0xFF8598A7), 6);
        box(195, 51, 24, 28, const Color(0xFF8598A7), 4);
        drop(200, 101);
        drop(220, 117);
        drop(200, 140);
        ring(219, 167, 21);
        screen(270, 155, 19);
      case CareArt.dry:
        box(67, 125, 225, 37, const Color(0xFF8CA2B0), 10);
        ring(112, 112, 18);
        screen(178, 113, 22);
        box(224, 102, 43, 16, const Color(0xFF4E616E), 4);
        for (final x in [110.0, 174.0, 239.0]) {
          line(x, 59, x, 78, blue, 2);
          line(x - 6, 68, x + 6, 68, blue, 2);
        }
        text(L.s292, 102, 182, color: blue);
      case CareArt.assemble:
        device(82, 30);
        ring(257, 105, 28, const Color(0xFF8CD7BA));
        line(242, 105, 252, 115, const Color(0xFF8CD7BA), 4);
        line(252, 115, 273, 92, const Color(0xFF8CD7BA), 4);
      case CareArt.replace:
        c.drawOval(
          const Rect.fromLTWH(76, 35, 100, 115),
          ink(const Color(0xFF9CABBA), stroke: 3),
        );
        box(115, 148, 23, 20, orange, 4);
        final tube = Path()
          ..moveTo(230, 64)
          ..cubicTo(331, 45, 176, 159, 278, 154);
        c.drawPath(tube, ink(orange, stroke: 10));
        text(L.s352, 210, 177, color: orange);
    }
    text('SCHEMA', 16, 199, size: 8, color: const Color(0xFF7F8C98));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _CarePainter oldDelegate) =>
      oldDelegate.model != model || oldDelegate.art != art;
}
