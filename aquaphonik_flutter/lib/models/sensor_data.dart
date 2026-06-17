class SensorData {
  final double tempWater;
  final double ph;
  final double tds;
  final double doValue;
  final double turbidity;
  final double waterLvl;
  final double co2;
  final double eco2;
  final double tvoc;
  final double tempAir;
  final double humidity;
  final int pumpStatus;
  final int oxyStatus;

  SensorData({
    required this.tempWater,
    required this.ph,
    required this.tds,
    required this.doValue,
    required this.turbidity,
    required this.waterLvl,
    required this.co2,
    required this.eco2,
    required this.tvoc,
    required this.tempAir,
    required this.humidity,
    required this.pumpStatus,
    required this.oxyStatus,
  });

  // Konstruktor untuk memetakan data JSON menjadi Objek Dart
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      tempWater: _parseDouble(json['temp_water']),
      ph: _parseDouble(json['ph']),
      tds: _parseDouble(json['tds']),
      doValue: _parseDouble(json['do'] ?? json['do_value']),
      turbidity: _parseDouble(json['turbidity']),
      waterLvl: _parseDouble(json['water_lvl']),
      co2: _parseDouble(json['co2']),
      eco2: _parseDouble(json['eco2']),
      tvoc: _parseDouble(json['tvoc']),
      tempAir: _parseDouble(json['temp_air']),
      humidity: _parseDouble(json['humidity']),
      pumpStatus: _parseInt(json['pump_status']),
      oxyStatus: _parseInt(json['oxy_status']),
    );
  }

  // Fungsi helper untuk parsing double dari tipe dinamis
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Fungsi helper untuk parsing int dari tipe dinamis
  static int _parseInt(dynamic value) {
    if (value is bool) return value ? 1 : 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
