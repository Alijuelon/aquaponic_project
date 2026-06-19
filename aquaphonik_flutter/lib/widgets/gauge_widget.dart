import 'dart:ui';
import 'package:flutter/material.dart';

/// GaugeWidget — Premium Icon-Centric Sensor Card
/// Replaces arc gauge with a large glowing icon that represents each sensor,
/// wrapped in a glassmorphism card with neon effects and animated pulse.
class GaugeWidget extends StatefulWidget {
  final String title;
  final double value;
  final String unit;
  final double min;
  final double max;
  final Color neonColor;
  final IconData icon;

  const GaugeWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.neonColor,
    required this.icon,
  }) : super(key: key);

  @override
  State<GaugeWidget> createState() => _GaugeWidgetState();
}

class _GaugeWidgetState extends State<GaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage =
        ((widget.value - widget.min) / (widget.max - widget.min))
            .clamp(0.0, 1.0);

    // Status color + label
    Color statusColor;
    String statusLabel;
    if (percentage < 0.3) {
      statusColor = const Color(0xFFFF6B6B);
      statusLabel = "LOW";
    } else if (percentage > 0.8) {
      statusColor = const Color(0xFFFFBD33);
      statusLabel = "HIGH";
    } else {
      statusColor = const Color(0xFF39FF14);
      statusLabel = "NORMAL";
    }

    // Darker variant of neon color
    final darkNeon = HSLColor.fromColor(widget.neonColor)
        .withLightness(
            (HSLColor.fromColor(widget.neonColor).lightness * 0.4).clamp(0, 1))
        .toColor();

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final pulseVal = _pulseAnim.value;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            // Gradient border
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.neonColor.withOpacity(0.35 + pulseVal * 0.1),
                widget.neonColor.withOpacity(0.05),
                Colors.white.withOpacity(0.04),
                widget.neonColor.withOpacity(0.15 + pulseVal * 0.05),
              ],
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
            boxShadow: [
              // Animated neon glow
              BoxShadow(
                color:
                    widget.neonColor.withOpacity(0.12 + pulseVal * 0.12),
                blurRadius: 24,
                spreadRadius: -4,
              ),
              // Deep shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.black.withOpacity(0.50),
                  Colors.black.withOpacity(0.62),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ===== LARGE ICON with neon glow =====
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ambient glow circle (pulsing)
                              Container(
                                width: 72 + pulseVal * 8,
                                height: 72 + pulseVal * 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      widget.neonColor
                                          .withOpacity(0.18 + pulseVal * 0.08),
                                      widget.neonColor.withOpacity(0.0),
                                    ],
                                    stops: const [0.3, 1.0],
                                  ),
                                ),
                              ),
                              // Icon container with gradient bg
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      widget.neonColor.withOpacity(0.25),
                                      darkNeon.withOpacity(0.12),
                                    ],
                                  ),
                                  border: Border.all(
                                    color:
                                        widget.neonColor.withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.neonColor
                                          .withOpacity(0.3),
                                      blurRadius: 16,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: widget.neonColor,
                                  size: 28,
                                  shadows: [
                                    Shadow(
                                      color: widget.neonColor
                                          .withOpacity(0.6),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ===== VALUE + UNIT =====
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Value row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  widget.value.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    height: 1.0,
                                    shadows: [
                                      Shadow(
                                        color: widget.neonColor
                                            .withOpacity(0.6),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Unit mini badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: widget.neonColor
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                    border: Border.all(
                                      color: widget.neonColor
                                          .withOpacity(0.25),
                                    ),
                                  ),
                                  child: Text(
                                    widget.unit,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: widget.neonColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Title
                            Text(
                              widget.title.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),

                            // Status indicator bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            statusColor.withOpacity(0.7),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: statusColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
