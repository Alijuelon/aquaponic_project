import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/socket_service.dart';
import '../widgets/gauge_widget.dart';
import '../widgets/control_panel.dart';

/// DashboardScreen — Premium Glassmorphism Monitoring Dashboard
/// Features gradient-bordered cards, neon glow icons, and ambient glass effects.
class DashboardScreen extends StatefulWidget {
  final SocketService socketService;

  const DashboardScreen({Key? key, required this.socketService})
      : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;
  late Animation<double> _ambientAnim;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _ambientAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            // Premium gradient icon badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF39FF14), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39FF14).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 12),
            // App title with subtle glow
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFF39FF14), Colors.white],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: const Text(
                "Aquaphonic",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Connection status badge
          StreamBuilder<bool>(
            stream: widget.socketService.connectionStatusStream,
            initialData: widget.socketService.isConnected,
            builder: (context, snapshot) {
              final isConnected = snapshot.data ?? false;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isConnected
                        ? [
                            const Color(0xFF39FF14).withOpacity(0.15),
                            const Color(0xFF10B981).withOpacity(0.08),
                          ]
                        : [
                            Colors.redAccent.withOpacity(0.15),
                            Colors.red.withOpacity(0.08),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isConnected
                        ? const Color(0xFF39FF14).withOpacity(0.35)
                        : Colors.redAccent.withOpacity(0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isConnected
                            ? const Color(0xFF39FF14)
                            : Colors.redAccent,
                        boxShadow: [
                          BoxShadow(
                            color: isConnected
                                ? const Color(0xFF39FF14)
                                : Colors.redAccent,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? "Online" : "Offline",
                      style: TextStyle(
                        color: isConnected
                            ? const Color(0xFF39FF14)
                            : Colors.redAccent,
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
          // Animated IoT icon with glass container
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF39FF14).withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Center(
              child: Icon(Icons.sensors_rounded,
                  color: Colors.white.withOpacity(0.6), size: 40),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF39FF14)),
                minHeight: 3,
              ),
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
          _buildSectionHeader(
              "PARAMETER UTAMA", const Color(0xFF39FF14), Icons.speed_rounded),
          const SizedBox(height: 12),

          // Gauge Grid — Premium Glass Container
          _buildGlassContainer(
            borderGradient: [
              const Color(0xFF39FF14).withOpacity(0.3),
              const Color(0xFF33EEFF).withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
              children: [
                GaugeWidget(
                  title: "Suhu Air",
                  value: data.tempWater,
                  unit: "°C",
                  min: 15,
                  max: 40,
                  neonColor: const Color(0xFF54FF33),
                  icon: Icons.thermostat_rounded,
                ),
                GaugeWidget(
                  title: "pH",
                  value: data.ph,
                  unit: "pH",
                  min: 0,
                  max: 14,
                  neonColor: const Color(0xFF33EEFF),
                  icon: Icons.science_rounded,
                ),
                GaugeWidget(
                  title: "TDS",
                  value: data.tds,
                  unit: "ppm",
                  min: 0,
                  max: 1000,
                  neonColor: const Color(0xFFFFBD33),
                  icon: Icons.water_rounded,
                ),
                GaugeWidget(
                  title: "Suhu Udara",
                  value: data.tempAir,
                  unit: "°C",
                  min: 15,
                  max: 50,
                  neonColor: const Color(0xFFFF6699),
                  icon: Icons.device_thermostat_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== SECTION: FLOATING SENSOR BADGES =====
          _buildSectionHeader("SENSOR TAMBAHAN", const Color(0xFF33EEFF),
              Icons.sensors_rounded),
          const SizedBox(height: 12),

          // Additional sensors grid — Premium Glass Container
          _buildGlassContainer(
            borderGradient: [
              const Color(0xFF33EEFF).withOpacity(0.3),
              const Color(0xFF8B5CF6).withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _buildBadge(
                  "Level Air",
                  data.waterLvl.toStringAsFixed(1),
                  "cm",
                  Icons.waves_rounded,
                  const Color(0xFF5294FF),
                  const Color(0xFF2563EB),
                ),
                _buildBadge(
                  "Kekeruhan",
                  data.turbidity.toStringAsFixed(0),
                  "NTU",
                  Icons.remove_red_eye_rounded,
                  const Color(0xFFC4A1FF),
                  const Color(0xFF8B5CF6),
                ),
                _buildBadge(
                  "DO",
                  data.doValue.toStringAsFixed(1),
                  "mg/L",
                  Icons.bubble_chart_rounded,
                  const Color(0xFF33EEFF),
                  const Color(0xFF06B6D4),
                ),
                _buildBadge(
                  "Kelembaban",
                  data.humidity.toStringAsFixed(1),
                  "%",
                  Icons.water_drop_rounded,
                  const Color(0xFF06D6A0),
                  const Color(0xFF059669),
                ),
                _buildBadge(
                  "CO₂",
                  data.co2.toStringAsFixed(0),
                  "ppm",
                  Icons.cloud_rounded,
                  const Color(0xFF10B981),
                  const Color(0xFF047857),
                ),
                _buildBadge(
                  "eCO₂",
                  data.eco2.toStringAsFixed(0),
                  "ppm",
                  Icons.cloud_queue_rounded,
                  const Color(0xFFA78BFA),
                  const Color(0xFF7C3AED),
                ),
                _buildBadge(
                  "TVOC",
                  data.tvoc.toStringAsFixed(0),
                  "ppb",
                  Icons.air_rounded,
                  const Color(0xFFFBBF24),
                  const Color(0xFFD97706),
                ),
                _buildBadge(
                  "pH Volts",
                  data.ph.toStringAsFixed(2),
                  "V",
                  Icons.bolt_rounded,
                  const Color(0xFF60A5FA),
                  const Color(0xFF3B82F6),
                ),
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

  /// Premium Glass Container with gradient border + backdrop blur
  Widget _buildGlassContainer({
    required Widget child,
    required List<Color> borderGradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: borderGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: borderGradient.first.withOpacity(0.15),
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
        margin: const EdgeInsets.all(1.5), // Gradient border effect
        padding: const EdgeInsets.all(14),
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
            child: child,
          ),
        ),
      ),
    );
  }

  /// Section header with neon icon + gradient dot
  Widget _buildSectionHeader(String title, Color neonColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            neonColor.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: neonColor.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient icon container
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  neonColor.withOpacity(0.3),
                  neonColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: neonColor.withOpacity(0.3), blurRadius: 8),
              ],
            ),
            child: Icon(icon, color: neonColor, size: 14),
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

  /// Premium sensor badge with gradient icon background + neon glow
  Widget _buildBadge(String title, String value, String unit, IconData icon,
      Color neonColor, Color darkColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        // Inner card gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            neonColor.withOpacity(0.12),
            darkColor.withOpacity(0.04),
            Colors.white.withOpacity(0.03),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: neonColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: neonColor.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Premium gradient icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  neonColor.withOpacity(0.3),
                  darkColor.withOpacity(0.15),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: neonColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: neonColor.withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ],
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
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                color: neonColor.withOpacity(0.5),
                                blurRadius: 8),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: neonColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: neonColor.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.55),
                    letterSpacing: 0.8,
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
