

import 'dart:math';

import 'package:flutter/material.dart';

class TreeCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
      Paint paint = Paint()
            ..color = Colors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10;
      Path generatePath(double x, double y) {
        Path path = new Path();
        path.moveTo(x, y);
        path.lineTo(x + 100, y + 100);
        path.lineTo(x + 150, y + 80);
        path.lineTo(x + 100, y + 200);
        path.lineTo(x, y + 100);
        return path;
      }

      canvas.drawPath(generatePath(100, 100), paint);
      canvas.rotate(10 * pi / 180);
      canvas.drawPath(generatePath(100, 150), paint);
      canvas.drawPath(generatePath(100, 500), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

}