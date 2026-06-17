import 'dart:math';
import 'package:flutter/material.dart';

/// Custom Gauge Widget — Replaces ECharts Gauge from Desktop
/// Renders a futuristic half-circle gauge with neon glow effects.
class GaugeWidget extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final double min;
  final double max;
  final Color neonColor;
  final double size;

  const GaugeWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.neonColor,
    this.size = 140,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return Container(
      width: size,
      height: size + 10,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size - 30,
            height: (size - 30) * 0.65,
            child: CustomPaint(
              painter: _GaugePainter(
                percentage: percentage,
                neonColor: neonColor,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: size * 0.16,
                            fontWeight: FontWeight.w800,
                            color: neonColor,
                            shadows: [
                              Shadow(color: neonColor.withOpacity(0.5), blurRadius: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$title ($unit)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color neonColor;

  _GaugePainter({required this.percentage, required this.neonColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = min(size.width, size.height) * 0.75;
    const startAngle = pi + 0.35;
    const sweepAngle = pi - 0.7;

    // Background arc
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.08);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Progress arc with glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = neonColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * percentage,
      false,
      glowPaint,
    );

    // Main progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [neonColor.withOpacity(0.6), neonColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.neonColor != neonColor;
  }
}
