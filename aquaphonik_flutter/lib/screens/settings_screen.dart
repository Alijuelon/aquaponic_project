import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/socket_service.dart';

/// SettingsScreen — Matches Desktop's futuristic glassmorphism Settings view.
/// Shows: Server URL config, Connection Status, and About section.
/// Excludes: Serial Port / USB connection (Desktop-only feature).
class SettingsScreen extends StatefulWidget {
  final SocketService socketService;
  final Function(String) onUrlChanged;

  const SettingsScreen({Key? key, required this.socketService, required this.onUrlChanged}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.socketService.serverUrl;
  }

  void _saveUrl() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_url', newUrl);
      widget.onUrlChanged(newUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Server URL disimpan, koneksi dimulai ulang.'),
            backgroundColor: const Color(0xFF39FF14).withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Pengaturan",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 1. KONEKSI SERVER =====
            _buildGlassCard(
              headerIcon: Icons.hub_rounded,
              headerColor: const Color(0xFF33EEFF),
              headerTitle: "KONEKSI SERVER",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("URL Server Desktop (Format: http://IP:PORT)",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF33EEFF), width: 1.5),
                            ),
                            hintText: "http://192.168.0.x:8080",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _saveUrl,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF39FF14), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black.withOpacity(0.6)),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF39FF14).withOpacity(0.3), blurRadius: 12),
                            ],
                          ),
                          child: const Text("Simpan",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== 2. STATUS KONEKSI =====
            _buildGlassCard(
              headerIcon: Icons.wifi_rounded,
              headerColor: const Color(0xFF39FF14),
              headerTitle: "STATUS KONEKSI",
              child: StreamBuilder<bool>(
                stream: widget.socketService.connectionStatusStream,
                initialData: widget.socketService.isConnected,
                builder: (context, snapshot) {
                  final isConnected = snapshot.data ?? false;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Socket.IO:",
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isConnected
                              ? const Color(0xFF39FF14).withOpacity(0.15)
                              : Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isConnected
                                ? const Color(0xFF39FF14).withOpacity(0.5)
                                : Colors.redAccent.withOpacity(0.5),
                          ),
                          boxShadow: isConnected
                              ? [BoxShadow(color: const Color(0xFF39FF14).withOpacity(0.3), blurRadius: 10)]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isConnected ? const Color(0xFF39FF14) : Colors.redAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isConnected ? "Terhubung" : "Terputus",
                              style: TextStyle(
                                color: isConnected ? const Color(0xFF39FF14) : Colors.redAccent,
                                fontSize: 13, fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ===== 3. INFORMASI SISTEM =====
            _buildGlassCard(
              headerIcon: Icons.info_outline_rounded,
              headerColor: const Color(0xFF8B5CF6),
              headerTitle: "INFORMASI SISTEM",
              child: Column(
                children: [
                  _buildInfoRow("Protokol Realtime", "Socket.IO (WebSockets)"),
                  _buildDivider(),
                  _buildInfoRow("Protokol History", "HTTP REST API"),
                  _buildDivider(),
                  _buildInfoRow("Event Sensor", "sensor/realtime"),
                  _buildDivider(),
                  _buildInfoRow("API History", "GET /api/history"),
                  _buildDivider(),
                  _buildInfoRow("Event Aktuator", "actuator/command"),
                  _buildDivider(),
                  _buildInfoRow("Auto-Reconnect", "Aktif (Socket.IO)"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== 4. ABOUT — Matches Desktop's About card =====
            _buildAboutCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Glassmorphism card with neon header — matches Desktop's card style
  Widget _buildGlassCard({
    required IconData headerIcon,
    required Color headerColor,
    required String headerTitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badge
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
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: headerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: headerColor.withOpacity(0.3)),
                  ),
                  child: Icon(headerIcon, color: headerColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(headerTitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2.0)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Color(0xFF33EEFF), fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.06), height: 18);
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF39FF14), Color(0xFF33EEFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF39FF14).withOpacity(0.3), blurRadius: 14),
                  ],
                ),
                child: const Icon(Icons.sensors, color: Colors.black, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("AquaPhonik Mobile",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text("v1.0.0 • Aquaponics Monitoring & Control",
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.5), letterSpacing: 1.0)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Built with Flutter • Dart • Socket.IO • FL Chart",
            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
