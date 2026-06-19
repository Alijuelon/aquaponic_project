import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/socket_service.dart';

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
  void initState() { super.initState(); _urlController.text = widget.socketService.serverUrl; }

  void _saveUrl() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_url', newUrl);
      widget.onUrlChanged(newUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('✓ Server URL disimpan, koneksi dimulai ulang.'),
          backgroundColor: const Color(0xFF39FF14).withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  // === Glass container ===
  Widget _glass({required Widget child, List<Color>? gradient}) {
    final g = gradient ?? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03), Colors.white.withOpacity(0.02)];
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: g),
        boxShadow: [BoxShadow(color: g.first.withOpacity(0.15), blurRadius: 24, spreadRadius: -6, offset: const Offset(0, 6)), BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Container(margin: const EdgeInsets.all(1.5), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.07), Colors.black.withOpacity(0.48), Colors.black.withOpacity(0.58)], stops: const [0, 0.4, 1])),
        child: ClipRRect(borderRadius: BorderRadius.circular(20), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), child: child))),
    );
  }

  Widget _sectionHeader(String title, Color c, IconData icon) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [c.withOpacity(0.08), Colors.transparent]), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.12))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(gradient: LinearGradient(colors: [c.withOpacity(0.3), c.withOpacity(0.1)]), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 8)]),
          child: Icon(icon, color: c, size: 14)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
      ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        title: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.4), blurRadius: 12, spreadRadius: -2)]),
            child: const Icon(Icons.settings_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          const Text("Pengaturan", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 20)),
        ])),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), physics: const BouncingScrollPhysics(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 1. KONEKSI SERVER
        _sectionHeader("KONEKSI SERVER", const Color(0xFF33EEFF), Icons.hub_rounded),
        const SizedBox(height: 12),
        _glass(gradient: [const Color(0xFF33EEFF).withOpacity(0.2), const Color(0xFF06B6D4).withOpacity(0.06), Colors.white.withOpacity(0.03)], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("URL Server Desktop", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: _urlController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              decoration: InputDecoration(filled: true, fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF33EEFF), width: 1.5)),
                hintText: "http://192.168.0.x:8080", hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)))),
            const SizedBox(width: 10),
            GestureDetector(onTap: _saveUrl, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF39FF14), Color(0xFF10B981)]), borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: const Color(0xFF39FF14).withOpacity(0.3), blurRadius: 12)]),
              child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)))),
          ]),
        ])),

        const SizedBox(height: 20),

        // 2. STATUS KONEKSI
        _sectionHeader("STATUS KONEKSI", const Color(0xFF39FF14), Icons.wifi_rounded),
        const SizedBox(height: 12),
        _glass(gradient: [const Color(0xFF39FF14).withOpacity(0.15), const Color(0xFF10B981).withOpacity(0.06), Colors.white.withOpacity(0.03)], child: StreamBuilder<bool>(
          stream: widget.socketService.connectionStatusStream,
          initialData: widget.socketService.isConnected,
          builder: (context, snapshot) {
            final ok = snapshot.data ?? false;
            return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: [ok ? const Color(0xFF39FF14).withOpacity(0.25) : Colors.redAccent.withOpacity(0.15), Colors.transparent]),
                  borderRadius: BorderRadius.circular(10), border: Border.all(color: ok ? const Color(0xFF39FF14).withOpacity(0.3) : Colors.redAccent.withOpacity(0.3))),
                  child: Icon(ok ? Icons.wifi_rounded : Icons.wifi_off_rounded, color: ok ? const Color(0xFF39FF14) : Colors.redAccent, size: 18)),
                const SizedBox(width: 12),
                Text("Socket.IO", style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w700, fontSize: 14)),
              ]),
              AnimatedContainer(duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: ok ? [const Color(0xFF39FF14).withOpacity(0.15), const Color(0xFF10B981).withOpacity(0.08)] : [Colors.redAccent.withOpacity(0.15), Colors.red.withOpacity(0.08)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ok ? const Color(0xFF39FF14).withOpacity(0.4) : Colors.redAccent.withOpacity(0.4)),
                  boxShadow: ok ? [BoxShadow(color: const Color(0xFF39FF14).withOpacity(0.2), blurRadius: 10)] : []),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: ok ? const Color(0xFF39FF14) : Colors.redAccent,
                    boxShadow: [BoxShadow(color: ok ? const Color(0xFF39FF14) : Colors.redAccent, blurRadius: 6)])),
                  const SizedBox(width: 8),
                  Text(ok ? "Terhubung" : "Terputus", style: TextStyle(color: ok ? const Color(0xFF39FF14) : Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w800)),
                ])),
            ]);
          },
        )),

        const SizedBox(height: 20),

        // 3. INFORMASI SISTEM
        _sectionHeader("INFORMASI SISTEM", const Color(0xFFA78BFA), Icons.info_outline_rounded),
        const SizedBox(height: 12),
        _glass(gradient: [const Color(0xFFA78BFA).withOpacity(0.15), const Color(0xFF7C3AED).withOpacity(0.06), Colors.white.withOpacity(0.03)], child: Column(children: [
          _infoRow("Protokol Realtime", "Socket.IO", Icons.bolt_rounded, const Color(0xFF33EEFF)),
          _div(), _infoRow("Protokol History", "HTTP REST API", Icons.http_rounded, const Color(0xFFFBBF24)),
          _div(), _infoRow("Event Sensor", "sensor/realtime", Icons.sensors_rounded, const Color(0xFF39FF14)),
          _div(), _infoRow("API History", "GET /api/history", Icons.storage_rounded, const Color(0xFF60A5FA)),
          _div(), _infoRow("Event Aktuator", "actuator/command", Icons.tune_rounded, const Color(0xFF3ACD94)),
          _div(), _infoRow("Auto-Reconnect", "Aktif", Icons.autorenew_rounded, const Color(0xFFFF6699)),
        ])),

        const SizedBox(height: 20),

        // 4. ABOUT
        _sectionHeader("TENTANG APLIKASI", const Color(0xFF39FF14), Icons.eco_rounded),
        const SizedBox(height: 12),
        _glass(gradient: [const Color(0xFF39FF14).withOpacity(0.15), const Color(0xFF33EEFF).withOpacity(0.06), Colors.white.withOpacity(0.03)], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF39FF14), Color(0xFF10B981)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF39FF14).withOpacity(0.35), blurRadius: 14)]),
              child: const Icon(Icons.eco_rounded, color: Colors.black, size: 26)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Aquaphonic Mobile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 3),
              Text("v1.0.0 • Aquaphonic Monitoring & Control", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.5), letterSpacing: 1.0)),
            ]),
          ]),
          const SizedBox(height: 14),
          Text("Built with Flutter • Dart • Socket.IO • FL Chart", style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12, fontWeight: FontWeight.w500)),
        ])),

        const SizedBox(height: 40),
      ])),
    );
  }

  Widget _infoRow(String label, String value, IconData icon, Color c) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: LinearGradient(colors: [c.withOpacity(0.2), c.withOpacity(0.08)]),
        borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.2))),
        child: Icon(icon, color: c, size: 14)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.15))),
        child: Text(value, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700))),
    ]));
  }

  Widget _div() => Divider(color: Colors.white.withOpacity(0.04), height: 16);
}
