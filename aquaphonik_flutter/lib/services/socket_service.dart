import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/sensor_data.dart';

class SocketService {
  late IO.Socket _socket;
  final String serverUrl;

  // Stream data sensor realtime
  final _sensorDataController = StreamController<SensorData>.broadcast();
  Stream<SensorData> get sensorStream => _sensorDataController.stream;

  // Stream status koneksi
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  SocketService({required this.serverUrl});

  void connect() {
    String finalUrl = serverUrl;

    print('🔌 [Socket.IO] Menghubungkan ke $finalUrl');
    
    _socket = IO.io(finalUrl, IO.OptionBuilder()
      .setTransports(['websocket', 'polling']) // Mendukung websocket dan fallback ke polling
      .enableReconnection() // Otomatis mencoba koneksi ulang jika terputus
      .setReconnectionAttempts(double.maxFinite.toInt()) // Coba terus menerus
      .setReconnectionDelay(2000) // Jeda awal 2 detik
      .setReconnectionDelayMax(5000) // Maksimal jeda 5 detik antar percobaan
      .disableAutoConnect()
      .build()
    );

    _socket.onConnect((_) {
      print('✅ [Socket.IO] Terhubung ke server');
      _isConnected = true;
      _connectionStatusController.add(true);
    });

    _socket.onDisconnect((_) {
      print('⚠️ [Socket.IO] Koneksi terputus');
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    _socket.onConnectError((err) {
      print('❌ [Socket.IO] Error koneksi: $err');
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    // Mendengarkan data sensor realtime dari Desktop
    _socket.on('sensor/realtime', (data) {
      try {
        final sensorData = SensorData.fromJson(Map<String, dynamic>.from(data));
        _sensorDataController.add(sensorData);
      } catch (e) {
        print('⚠️ [Socket.IO] Gagal parse data sensor: $e');
      }
    });

    _socket.connect();
  }

  /// Mengirim perintah aktuator ke Desktop
  void sendCommand(String command) {
    if (_isConnected) {
      _socket.emit('actuator/command', {'command': command});
      print('📤 [Socket.IO] Perintah terkirim: $command');
    } else {
      print('❌ [Socket.IO] Gagal kirim perintah: Tidak terhubung ke server');
    }
  }

  void dispose() {
    _socket.dispose();
    _sensorDataController.close();
    _connectionStatusController.close();
    print('🔌 [Socket.IO] Service dimatikan');
  }
}
