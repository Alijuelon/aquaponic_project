import 'dart:ui';
import 'package:flutter/material.dart';

/// ControlPanel — Premium Toggle switches for Pump and Oxygen control
/// Features glassmorphism containers, gradient icon boxes, and neon toggle switches.
class ControlPanel extends StatelessWidget {
  final int pumpStatus;
  final int oxyStatus;
  final Function(String) onToggle;

  const ControlPanel({
    Key? key,
    required this.pumpStatus,
    required this.oxyStatus,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPumpOn = pumpStatus == 1;
    final bool isOxyOn = oxyStatus == 1;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Gradient border
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withOpacity(0.3),
            const Color(0xFF3696FC).withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.07),
              Colors.black.withOpacity(0.45),
              Colors.black.withOpacity(0.55),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header — Premium Design
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withOpacity(0.3),
                              const Color(0xFF10B981).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.3),
                                blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: Color(0xFF10B981), size: 14),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "CONTROL PANEL",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Pompa Air Switch
                _buildControlRow(
                  title: "Pompa Air",
                  subtitle: "Sirkulasi air",
                  icon: Icons.water_drop_rounded,
                  isActive: isPumpOn,
                  activeColor: const Color(0xFF3ACD94),
                  darkColor: const Color(0xFF059669),
                  onToggle: () =>
                      onToggle(isPumpOn ? "POMPA:0" : "POMPA:1"),
                ),

                const SizedBox(height: 14),

                // Pompa O₂ Switch
                _buildControlRow(
                  title: "Pompa O₂",
                  subtitle: "Aerasi kolam",
                  icon: Icons.air_rounded,
                  isActive: isOxyOn,
                  activeColor: const Color(0xFF3696FC),
                  darkColor: const Color(0xFF2563EB),
                  onToggle: () =>
                      onToggle(isOxyOn ? "OKSIGEN:0" : "OKSIGEN:1"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color darkColor,
    required VoidCallback onToggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Card gradient bg based on active state
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
                  activeColor.withOpacity(0.15),
                  darkColor.withOpacity(0.05),
                ]
              : [
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? activeColor.withOpacity(0.35)
              : Colors.white.withOpacity(0.08),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: activeColor.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: -4),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Icon with gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? [
                        activeColor.withOpacity(0.35),
                        darkColor.withOpacity(0.15),
                      ]
                    : [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? activeColor.withOpacity(0.4)
                    : Colors.white.withOpacity(0.08),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                          color: activeColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: -2),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : Colors.white54,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    // Status dot
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? activeColor : Colors.white38,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                    color: activeColor.withOpacity(0.6),
                                    blurRadius: 4),
                              ]
                            : [],
                      ),
                    ),
                    Text(
                      isActive
                          ? "AKTIF • ${subtitle.toUpperCase()}"
                          : subtitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? activeColor.withOpacity(0.8)
                            : Colors.white.withOpacity(0.35),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Premium Toggle Switch
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isActive
                    ? LinearGradient(
                        colors: [activeColor, darkColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                border: Border.all(
                  color: isActive
                      ? activeColor.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: activeColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: -2),
                      ]
                    : [],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                alignment:
                    isActive ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isActive
                            ? activeColor.withOpacity(0.4)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isActive
                      ? Icon(Icons.power_settings_new_rounded,
                          color: activeColor, size: 14)
                      : Icon(Icons.power_settings_new_rounded,
                          color: Colors.grey.shade400, size: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
