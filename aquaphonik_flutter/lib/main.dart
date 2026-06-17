import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mengatur warna status bar transparan dan mengunci orientasi ke Portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const AquaPhonikApp());
}

class AquaPhonikApp extends StatelessWidget {
  const AquaPhonikApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaPhonik Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1E212A),
        scaffoldBackgroundColor: const Color(0xFF0A0C10),
        useMaterial3: true,
        // Konfigurasi text theme dasar agar bersih
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      // MainScreen akan memuat Navbar (Dashboard, History, Settings)
      // dan juga menyimpan konfigurasi IP Address dari SharedPreferences.
      home: const MainScreen(),
    );
  }
}
