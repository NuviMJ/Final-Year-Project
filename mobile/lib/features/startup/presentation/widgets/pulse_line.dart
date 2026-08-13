import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PulseLinePainter extends CustomPainter {
  const PulseLinePainter({
    required this.progress,
    required this.color,
    this.endpointColor = const Color(0xFFF2694A),
  });

  final double progress;

  final Color color;

  final Color endpointColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double drawn = progress.clamp(0.0, 1.0);
    if (drawn <= 0 || size.width <= 0 || size.height <= 0) return;

    final List<ui.PathMetric> metrics = _tracePath(size).computeMetrics().toList();
    if (metrics.isEmpty) return;

    final ui.PathMetric metric = metrics.first;
    final double length = metric.length * drawn;

    canvas.drawPath(
      metric.extractPath(0, length),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final ui.Tangent? head = metric.getTangentForOffset(length);
    if (head != null) {
      canvas.drawCircle(head.position, 4, Paint()..color = endpointColor);
    }
  }

  Path _tracePath(Size size) {
    final double w = size.width;
    final double midY = size.height / 2;
    final double peak = size.height * 0.44;

    return Path()
      ..moveTo(0, midY)
      ..lineTo(w * 0.30, midY)
      ..lineTo(w * 0.35, midY - peak * 0.30)
      ..lineTo(w * 0.40, midY)
      ..lineTo(w * 0.46, midY - peak)
      ..lineTo(w * 0.52, midY + peak * 0.75)
      ..lineTo(w * 0.58, midY)
      ..lineTo(w * 0.66, midY - peak * 0.18)
      ..lineTo(w * 0.72, midY)
      ..lineTo(w, midY);
  }

  @override
  bool shouldRepaint(PulseLinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.endpointColor != endpointColor;
}
