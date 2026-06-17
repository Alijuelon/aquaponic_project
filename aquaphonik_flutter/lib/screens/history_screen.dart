import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

/// HistoryScreen — Matches Desktop's History view with glassmorphism design.
/// Features: Date filters, chart, and data table with neon accents.
class HistoryScreen extends StatefulWidget {
  final String serverUrl;

  const HistoryScreen({Key? key, required this.serverUrl}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _selectedParameter = 'temp_water';
  int _limit = 50;

  // Date filter
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime _endDate = DateTime.now();

  final Map<String, String> _paramNames = {
    'temp_water': 'Suhu Air (°C)',
    'ph': 'pH Air',
    'tds': 'TDS (ppm)',
    'do_value': 'DO (mg/L)',
    'turbidity': 'Kekeruhan (NTU)',
    'water_lvl': 'Level Air (cm)',
    'temp_air': 'Suhu Udara (°C)',
    'humidity': 'Kelembaban (%)',
  };

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { _isLoading = true; _hasError = false; _errorMessage = ''; });
    final response = await ApiService.getHistory(widget.serverUrl, limit: _limit);
    if (response == null || response['status'] == 'error') {
      setState(() {
        _isLoading = false; _hasError = true;
        _errorMessage = response?['message'] ?? 'Timeout: Server Desktop tidak merespons.';
      });
      return;
    }
    if (response['status'] == 'success') {
      final List<dynamic> dataList = response['data'] ?? [];
      setState(() {
        _logs = List<Map<String, dynamic>>.from(dataList).reversed.toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadByDateRange() async {
    setState(() { _isLoading = true; _hasError = false; _errorMessage = ''; });
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate);
    final response = await ApiService.getHistory(
      widget.serverUrl,
      startDate: '$startStr 00:00:00',
      endDate: '$endStr 23:59:59',
    );
    if (response == null || response['status'] == 'error') {
      setState(() {
        _isLoading = false; _hasError = true;
        _errorMessage = response?['message'] ?? 'Gagal memuat data.';
      });
      return;
    }
    if (response['status'] == 'success') {
      final List<dynamic> dataList = response['data'] ?? [];
      setState(() {
        _logs = List<Map<String, dynamic>>.from(dataList).reversed.toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF33EEFF),
              surface: Color(0xFF1E212A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
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
          "Riwayat Sensor",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF33EEFF)),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 36, height: 36,
                    child: CircularProgressIndicator(
                      color: Color(0xFF33EEFF), strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Memuat data...",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w700)),
                ],
              ),
            )
          : _hasError
              ? _buildErrorState()
              : _logs.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _buildNeonButton("Coba Lagi", const Color(0xFF33EEFF), _loadHistory),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_chart_outlined, color: Colors.white.withOpacity(0.3), size: 56),
          const SizedBox(height: 16),
          Text("Belum ada data log tersimpan",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== FILTERS — Matches Desktop's glassmorphism filter bar =====
          _buildFilterBar(),
          const SizedBox(height: 20),

          // ===== CHART =====
          _buildChartHeader(),
          const SizedBox(height: 12),
          _buildChart(),

          const SizedBox(height: 28),

          // ===== DATA TABLE =====
          _buildSectionHeader("DATA TERAKHIR"),
          const SizedBox(height: 12),
          _buildDataTable(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Filter bar — matches Desktop's glassmorphism filter card
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(22),
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
        children: [
          // Date pickers row
          Row(
            children: [
              Expanded(child: _buildDateField("Dari", _startDate, () => _pickDate(context, true))),
              const SizedBox(width: 12),
              Expanded(child: _buildDateField("Sampai", _endDate, () => _pickDate(context, false))),
            ],
          ),
          const SizedBox(height: 12),
          // Buttons row
          Row(
            children: [
              Expanded(
                child: _buildNeonButton("Filter", const Color(0xFF33EEFF), _loadByDateRange),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildOutlineButton("Latest $_limit", _loadHistory),
              ),
              const SizedBox(width: 10),
              // Limit selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.6)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _limit,
                    dropdownColor: const Color(0xFF1E212A),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF33EEFF), size: 20),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _limit = val);
                        _loadHistory();
                      }
                    },
                    items: [25, 50, 100, 200].map((v) =>
                      DropdownMenuItem(value: v, child: Text('$v'))
                    ).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.5), letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: Colors.white.withOpacity(0.5), size: 16),
                const SizedBox(width: 8),
                Text(DateFormat('dd MMM yyyy').format(date),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_paramNames[_selectedParameter]!,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedParameter,
              dropdownColor: const Color(0xFF1E212A),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF33EEFF)),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              onChanged: (v) { if (v != null) setState(() => _selectedParameter = v); },
              items: _paramNames.keys.map((k) =>
                DropdownMenuItem(value: k, child: Text(_paramNames[k]!))
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (_logs.isEmpty) return const SizedBox();

    List<FlSpot> spots = [];
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (int i = 0; i < _logs.length; i++) {
      double val = (_logs[i][_selectedParameter] ?? 0.0).toDouble();
      spots.add(FlSpot(i.toDouble(), val));
      if (val < minY) minY = val;
      if (val > maxY) maxY = val;
    }
    if (minY == maxY) { minY -= 1; maxY += 1; }
    else { double d = maxY - minY; minY -= d * 0.15; maxY += d * 0.15; }

    return Container(
      height: 240,
      padding: const EdgeInsets.only(right: 16, left: 0, top: 24, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minX: 0, maxX: _logs.length.toDouble() - 1,
          minY: minY, maxY: maxY,
          gridData: FlGridData(
            show: true, drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4 == 0 ? 1 : (maxY - minY) / 4,
            getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.06), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40,
                getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)))),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                interval: _logs.length > 5 ? (_logs.length / 5).floorToDouble() : 1,
                getTitlesWidget: (v, _) {
                  int i = v.toInt();
                  if (i >= 0 && i < _logs.length) {
                    final ds = _logs[i]['timestamp'];
                    if (ds != null) {
                      final dt = DateTime.parse(ds).toLocal();
                      return Text(DateFormat('HH:mm').format(dt),
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10));
                    }
                  }
                  return const Text('');
                })),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots, isCurved: true,
              color: const Color(0xFF33EEFF), barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF33EEFF).withOpacity(0.12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    final tableLogs = _logs.reversed.toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
            dataRowColor: WidgetStateProperty.all(Colors.transparent),
            dividerThickness: 0.3,
            headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.0),
            columns: const [
              DataColumn(label: Text('WAKTU')),
              DataColumn(label: Text('SUHU AIR')),
              DataColumn(label: Text('pH')),
              DataColumn(label: Text('TDS')),
              DataColumn(label: Text('DO')),
              DataColumn(label: Text('TURB.')),
              DataColumn(label: Text('LEVEL')),
              DataColumn(label: Text('SUHU UDARA')),
              DataColumn(label: Text('HUM.')),
              DataColumn(label: Text('POMPA')),
              DataColumn(label: Text('O₂')),
            ],
            rows: tableLogs.take(50).map((log) {
              final dtStr = log['timestamp'] as String?;
              String timeStr = "-";
              if (dtStr != null) {
                final dt = DateTime.parse(dtStr).toLocal();
                timeStr = DateFormat('dd MMM HH:mm').format(dt);
              }
              return DataRow(cells: [
                DataCell(Text(timeStr, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w700))),
                DataCell(Text('${log['temp_water']?.toStringAsFixed(1) ?? "-"}°C', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                DataCell(Text('${log['ph']?.toStringAsFixed(1) ?? "-"}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                DataCell(Text('${log['tds']?.toStringAsFixed(0) ?? "-"}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                DataCell(Text('${log['do_value']?.toStringAsFixed(1) ?? "-"}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                DataCell(Text('${log['turbidity']?.toStringAsFixed(0) ?? "-"}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                DataCell(Text('${log['water_lvl']?.toStringAsFixed(1) ?? "-"}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                DataCell(Text('${log['temp_air']?.toStringAsFixed(1) ?? "-"}°C', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                DataCell(Text('${log['humidity']?.toStringAsFixed(1) ?? "-"}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                DataCell(_buildStatusBadge(log['pump_status'] == 1, const Color(0xFF3ACD94))),
                DataCell(_buildStatusBadge(log['oxy_status'] == 1, const Color(0xFF3696FC))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOn, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOn ? color.withOpacity(0.2) : Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOn ? color.withOpacity(0.5) : Colors.black.withOpacity(0.6)),
        boxShadow: isOn ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)] : [],
      ),
      child: Text(
        isOn ? 'ON' : 'OFF',
        style: TextStyle(
          color: isOn ? color : Colors.white.withOpacity(0.4),
          fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
              shape: BoxShape.circle, color: const Color(0xFF33EEFF),
              boxShadow: [BoxShadow(color: const Color(0xFF33EEFF).withOpacity(0.6), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
        ],
      ),
    );
  }

  Widget _buildNeonButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.6)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
