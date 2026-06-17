import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/socket_service.dart';
import '../widgets/gauge_widget.dart';
import '../widgets/control_panel.dart';

/// DashboardScreen — Futuristic Glassmorphism Monitoring Dashboard
/// Matches the Desktop layout: Gauge Panel + Floating Sensor Badges + Control Panel
class DashboardScreen extends StatefulWidget {
  final SocketService socketService;

  const DashboardScreen({Key? key, required this.socketService}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF39FF14), Color(0xFF33EEFF)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39FF14).withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.sensors, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              "AquaPhonik",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Connection status badge — same as before but improved
          StreamBuilder<bool>(
            stream: widget.socketService.connectionStatusStream,
            initialData: widget.socketService.isConnected,
            builder: (context, snapshot) {
              final isConnected = snapshot.data ?? false;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isConnected
                      ? const Color(0xFF39FF14).withOpacity(0.1)
                      : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isConnected
                        ? const Color(0xFF39FF14).withOpacity(0.3)
                        : Colors.redAccent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isConnected ? const Color(0xFF39FF14) : Colors.redAccent,
                        boxShadow: [
                          BoxShadow(
                            color: isConnected ? const Color(0xFF39FF14) : Colors.redAccent,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? "Online" : "Offline",
                      style: TextStyle(
                        color: isConnected ? const Color(0xFF39FF14) : Colors.redAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<SensorData>(
        stream: widget.socketService.sensorStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi Kesalahan:\n${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return _buildWaitingState();
          }

          final data = snapshot.data!;
          return _buildDashboardContent(data);
        },
      ),
    );
  }

  /// Waiting state — matches Desktop's "Menunggu Koneksi Data" design
  Widget _buildWaitingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated IoT icon
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.black.withOpacity(0.6)),
            ),
            child: Center(
              child: Icon(Icons.sensors, color: Colors.white.withOpacity(0.6), size: 36),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Menunggu Koneksi Data",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Menghubungkan ke server Desktop\nuntuk menerima data sensor real-time...",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  /// Main dashboard content — matching Desktop layout
  Widget _buildDashboardContent(SensorData data) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== SECTION: PARAMETER UTAMA (Gauge Charts) =====
          _buildSectionHeader("PARAMETER UTAMA", const Color(0xFF39FF14)),
          const SizedBox(height: 12),

          // Gauge Grid — 2x2 layout matching Desktop
          Container(
            padding: const EdgeInsets.all(16),
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
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
              children: [
                GaugeWidget(
                  title: "Suhu Air", value: data.tempWater, unit: "°C",
                  min: 15, max: 40, neonColor: const Color(0xFF54FF33),
                ),
                GaugeWidget(
                  title: "pH", value: data.ph, unit: "pH",
                  min: 0, max: 14, neonColor: const Color(0xFF33EEFF),
                ),
                GaugeWidget(
                  title: "TDS", value: data.tds, unit: "ppm",
                  min: 0, max: 1000, neonColor: const Color(0xFFFFBD33),
                ),
                GaugeWidget(
                  title: "Suhu Udara", value: data.tempAir, unit: "°C",
                  min: 15, max: 50, neonColor: const Color(0xFFFF6699),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== SECTION: FLOATING SENSOR BADGES =====
          _buildSectionHeader("SENSOR TAMBAHAN", const Color(0xFF33EEFF)),
          const SizedBox(height: 12),

          // Additional sensors grid — no horizontal scroll
          Container(
            padding: const EdgeInsets.all(16),
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
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2, // Wider for smaller cards
              children: [
                _buildBadge("Level Air", data.waterLvl.toStringAsFixed(1), "cm",
                    Icons.waves_rounded, const Color(0xFF5294FF)),
                _buildBadge("Kekeruhan", data.turbidity.toStringAsFixed(0), "NTU",
                    Icons.remove_red_eye_rounded, const Color(0xFFC4A1FF)),
                _buildBadge("DO", data.doValue.toStringAsFixed(1), "mg/L",
                    Icons.bubble_chart_rounded, const Color(0xFF33EEFF)),
                _buildBadge("Kelembaban", data.humidity.toStringAsFixed(1), "%",
                    Icons.water_drop_rounded, const Color(0xFF06B6D4)),
                _buildBadge("CO₂", data.co2.toStringAsFixed(0), "ppm",
                    Icons.cloud_rounded, const Color(0xFF10B981)),
                _buildBadge("eCO₂", data.eco2.toStringAsFixed(0), "ppm",
                    Icons.cloud_queue_rounded, const Color(0xFF8B5CF6)),
                _buildBadge("TVOC", data.tvoc.toStringAsFixed(0), "ppb",
                    Icons.air_rounded, const Color(0xFFF59E0B)),
                _buildBadge("pH Volts", data.ph.toStringAsFixed(2), "V",
                    Icons.bolt_rounded, const Color(0xFF3B82F6)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== SECTION: CONTROL PANEL =====
          ControlPanel(
            pumpStatus: data.pumpStatus,
            oxyStatus: data.oxyStatus,
            onToggle: (command) {
              widget.socketService.sendCommand(command);
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Section header with neon dot — matching Desktop's section headers
  Widget _buildSectionHeader(String title, Color neonColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: neonColor,
              boxShadow: [BoxShadow(color: neonColor.withOpacity(0.6), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Small sensor badge used in the grid
  Widget _buildBadge(String title, String value, String unit, IconData icon, Color neonColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08), // Light translucent inner card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: neonColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: neonColor.withOpacity(0.3)),
            ),
            child: Icon(icon, color: neonColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: neonColor,
                          shadows: [Shadow(color: neonColor.withOpacity(0.3), blurRadius: 4)],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
