import 'dart:ui';

import 'package:flutter/material.dart';

class DrawingArea {
  Offset point;
  Paint arreaPaint;

  DrawingArea({required this.point, required this.arreaPaint});
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> points;

  MyCustomPainter({required List<DrawingArea> points})
      : points = points.toList();

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.black;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != points.last && points[i + 1] != points.last) {
        canvas.drawLine(
            points[i].point, points[i + 1].point, points[i].arreaPaint);
      } else if (points[i] != points.last && points[i + 1] == points.last) {
        canvas.drawPoints(
            PointMode.points, [points[i].point], points[i].arreaPaint);
      }
    }
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
