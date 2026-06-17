import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/socket_service.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _serverUrl = 'http://192.168.0.115:8080'; // Otomatis disinkronkan
  bool _isInit = false;

  // Socket Service tunggal untuk seluruh aplikasi
  SocketService? _socketService;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  @override
  void dispose() {
    _socketService?.dispose();
    super.dispose();
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _serverUrl = savedUrl;
    }
    // Inisialisasi dan hubungkan Socket Service
    _socketService = SocketService(serverUrl: _serverUrl);
    _socketService!.connect();
    setState(() {
      _isInit = true;
    });
  }

  /// Dipanggil saat user mengganti Server URL di Settings
  void _onUrlChanged(String newUrl) {
    setState(() {
      _serverUrl = newUrl;
      // Dispose koneksi lama dan buat koneksi baru
      _socketService?.dispose();
      _socketService = SocketService(serverUrl: newUrl);
      _socketService!.connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _socketService == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0C10),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF39FF14))),
      );
    }

    final List<Widget> pages = [
      DashboardScreen(key: ValueKey(_serverUrl), socketService: _socketService!),
      HistoryScreen(serverUrl: _serverUrl),
      SettingsScreen(socketService: _socketService!, onUrlChanged: _onUrlChanged),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // ===== Immersive Fullscreen Background — Same as Desktop App.vue =====
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg-aquaponics.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay (dikurangi menjadi 0.35 agar gambar utama lebih terlihat cerah)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0A0C10).withOpacity(0.35),
            ),
          ),
          // Ambient glow particles (decorative, same as Desktop)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3ACD94).withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3696FC).withOpacity(0.06),
              ),
            ),
          ),

          // ===== Main Content =====
          Positioned.fill(
            child: pages[_currentIndex],
          ),

          // ===== Bottom Navigation Bar (Modern Floating Style) =====
          Positioned(
            left: 20, right: 20, bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavItem(1, Icons.analytics_rounded, Icons.analytics_outlined, "Riwayat"),
                        _buildCenterButton(),
                        _buildNavItem(2, Icons.settings_rounded, Icons.settings_outlined, "Pengaturan"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Center Dashboard Button (Large)
  Widget _buildCenterButton() {
    final isActive = _currentIndex == 0;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isActive 
            ? const LinearGradient(
                colors: [Color(0xFF39FF14), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
              ),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isActive
            ? [BoxShadow(color: const Color(0xFF39FF14).withOpacity(0.4), blurRadius: 15, spreadRadius: 2)]
            : [],
        ),
        child: Center(
          child: Icon(
            isActive ? Icons.dashboard_rounded : Icons.dashboard_outlined,
            color: isActive ? Colors.black : Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// Custom nav item matching Desktop's bottom navigation with neon active indicator
  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    final Color activeColor = index == 1 ? const Color(0xFF33EEFF) : Colors.white;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: Colors.white.withOpacity(0.12)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Neon top indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 24 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: isActive
                    ? const LinearGradient(colors: [Color(0xFF39FF14), Color(0xFF33EEFF)])
                    : null,
                boxShadow: isActive
                    ? [BoxShadow(color: const Color(0xFF39FF14).withOpacity(0.6), blurRadius: 8)]
                    : [],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isActive
                    ? LinearGradient(colors: [activeColor.withOpacity(0.15), activeColor.withOpacity(0.05)])
                    : null,
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive ? activeColor : Colors.white.withOpacity(0.5),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
