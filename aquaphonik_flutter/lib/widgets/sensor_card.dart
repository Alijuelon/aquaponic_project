import 'package:flutter/material.dart';

/// SensorCard — Futuristic Glassmorphism Sensor Badge
/// Matches the Desktop's floating sensor badge design with neon glow effects.
class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color neonColor;

  const SensorCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.neonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: neonColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with neon background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: neonColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: neonColor.withOpacity(0.25)),
            ),
            child: Icon(icon, color: neonColor, size: 24),
          ),
          const Spacer(),
          // Value + Unit
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: neonColor,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(color: neonColor.withOpacity(0.4), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1.5,
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
