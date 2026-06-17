import 'package:flutter/material.dart';

/// ControlPanel — Toggle switches for Pump and Oxygen control
/// Matches the Desktop's futuristic glassmorphism control panel with neon accents.
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header — matches Desktop ControlPanel header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, color: const Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
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
            activeColor: const Color(0xFF3ACD94), // aqua-500
            activeGlow: const Color(0xFF3ACD94),
            onToggle: () => onToggle(isPumpOn ? "POMPA:0" : "POMPA:1"),
          ),

          const SizedBox(height: 16),

          // Pompa O₂ Switch
          _buildControlRow(
            title: "Pompa O₂",
            subtitle: "Aerasi kolam",
            icon: Icons.air_rounded,
            isActive: isOxyOn,
            activeColor: const Color(0xFF3696FC), // ocean-500
            activeGlow: const Color(0xFF3696FC),
            onToggle: () => onToggle(isOxyOn ? "OKSIGEN:0" : "OKSIGEN:1"),
          ),
        ],
      ),
    );
  }

  Widget _buildControlRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color activeGlow,
    required VoidCallback onToggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.12) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.4) : Colors.white.withOpacity(0.12),
        ),
        boxShadow: isActive
            ? [BoxShadow(color: activeGlow.withOpacity(0.2), blurRadius: 16, spreadRadius: -2)]
            : [],
      ),
      child: Row(
        children: [
          // Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.25) : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? activeColor.withOpacity(0.4) : Colors.white.withOpacity(0.08),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : Colors.white54,
              size: 24,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Toggle Switch
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isActive ? activeColor : Colors.black.withOpacity(0.6),
                boxShadow: isActive
                    ? [BoxShadow(color: activeGlow.withOpacity(0.5), blurRadius: 12)]
                    : [],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
