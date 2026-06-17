import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// Fetch data riwayat dari Desktop API (/api/history)
  static Future<Map<String, dynamic>?> getHistory(
    String baseUrl, {
    int limit = 50,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Pastikan baseUrl tidak diakhiri slash
      final formattedUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      
      // Bersihkan wss:// atau ws:// jadi http/https jika perlu, tapi idealnya inputnya udah http/https
      String httpUrl = formattedUrl;
      if (formattedUrl.startsWith('ws://')) {
        httpUrl = formattedUrl.replaceFirst('ws://', 'http://');
      } else if (formattedUrl.startsWith('wss://')) {
        httpUrl = formattedUrl.replaceFirst('wss://', 'https://');
      }

      final uri = Uri.parse('$httpUrl/api/history').replace(queryParameters: {
        'limit': limit.toString(),
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      });

      print('📥 [API] Requesting history: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ [API] Error respons server: ${response.statusCode}');
        return {
          'status': 'error',
          'message': 'Gagal memuat data riwayat. Kode Error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('❌ [API] Exception: $e');
      return {
        'status': 'error',
        'message': 'Koneksi gagal / Timeout: Tidak bisa terhubung ke server Desktop.'
      };
    }
  }
}
