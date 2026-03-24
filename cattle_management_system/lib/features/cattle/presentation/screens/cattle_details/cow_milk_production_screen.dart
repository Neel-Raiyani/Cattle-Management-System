import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:cattle_management_system/core/services/api_service.dart';
import 'package:cattle_management_system/core/di/injection_container.dart';
import 'package:cattle_management_system/features/cattle/domain/entities/cattle.dart';

class CowMilkProductionScreen extends StatefulWidget {
  final Cattle cattle;

  const CowMilkProductionScreen({super.key, required this.cattle});

  @override
  _CowMilkProductionScreenState createState() => _CowMilkProductionScreenState();
}

class _CowMilkProductionScreenState extends State<CowMilkProductionScreen> {
  String selectedMonthStr = '';
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final ApiService _apiService = sl<ApiService>();
  List<dynamic> _milkRecords = [];
  Map<String, dynamic>? _reportSummary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    selectedMonthStr = '${months[selectedMonth - 1]}, $selectedYear';
    _fetchMilkHistory();
  }

  Future<void> _fetchMilkHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final report = await _apiService.getCowMonthlyReport(
        animalId: widget.cattle.id,
        month: selectedMonth,
        year: selectedYear,
      );

      final data = Map<String, dynamic>.from(report['data'] ?? report);
      final normalizedData = (data['dailyRecords'] as List?)?.isNotEmpty == true
          ? {
              'dailyRecords': (data['dailyRecords'] as List)
                  .whereType<Map>()
                  .map((item) {
                    final map = Map<String, dynamic>.from(item);
                    return {
                      'date': map['date'],
                      'morningMilk': _asDouble(map['morningMilk'] ?? map['morning']),
                      'eveningMilk': _asDouble(map['eveningMilk'] ?? map['evening']),
                      'morningFeed': _asDouble(map['morningFeed']),
                      'eveningFeed': _asDouble(map['eveningFeed']),
                    };
                  })
                  .toList(),
              'totalMorningMilk': _asDouble(
                data['totalMorningMilk'] ?? data['morningTotal'],
              ),
              'totalEveningMilk': _asDouble(
                data['totalEveningMilk'] ?? data['eveningTotal'],
              ),
              'totalMorningFeed': _asDouble(data['totalMorningFeed']),
              'totalEveningFeed': _asDouble(data['totalEveningFeed']),
            }
          : _buildMonthlyFallback(records: const []);
      final List<dynamic> records =
          normalizedData['dailyRecords'] as List<dynamic>;

      if (records.isNotEmpty) {
        setState(() {
          _milkRecords = records;
          _reportSummary = normalizedData;
          _isLoading = false;
        });
        return;
      }

      final history = await _apiService.getMilkHistoryForAnimal(
        animalId: widget.cattle.id,
        month: selectedMonth,
        year: selectedYear,
      );

      setState(() {
        final normalized = _buildMonthlyFallback(records: history);
        _milkRecords = normalized['dailyRecords'] as List<dynamic>;
        _reportSummary = normalized;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[MilkProduction] Fetch Error: $e');
      setState(() {
        _error = 'Failed to load records';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _buildMonthlyFallback({required List<dynamic> records}) {
    final normalized = records
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    double morningTotal = 0;
    double eveningTotal = 0;
    double morningFeedTotal = 0;
    double eveningFeedTotal = 0;

    final dailyRecords = normalized.map((item) {
      final morning = _asDouble(item['morning'] ?? item['morningMilk']);
      final evening = _asDouble(item['evening'] ?? item['eveningMilk']);
      final morningFeed = _asDouble(item['morningFeed']);
      final eveningFeed = _asDouble(item['eveningFeed']);
      morningTotal += morning;
      eveningTotal += evening;
      morningFeedTotal += morningFeed;
      eveningFeedTotal += eveningFeed;
      return {
        'date': item['date'],
        'morningMilk': morning,
        'eveningMilk': evening,
        'morningFeed': morningFeed,
        'eveningFeed': eveningFeed,
      };
    }).toList();

    return {
      'dailyRecords': dailyRecords,
      'totalMorningMilk': morningTotal,
      'totalEveningMilk': eveningTotal,
      'totalMorningFeed': morningFeedTotal,
      'totalEveningFeed': eveningFeedTotal,
    };
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Milk Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildChartSection(),
                      const SizedBox(height: 24),
                      _buildDailyListSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Report',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildMonthDropdown(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _milkRecords.isEmpty
                ? const Center(child: Text('No chart data'))
                : _buildBarChart(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegendItem('Morning', const Color(0xFF6A9DFC)),
              const SizedBox(width: 16),
              _buildLegendItem('Evening', const Color(0xFFE38EAC)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    List<String> monthYearOptions = [];
    final now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      monthYearOptions.add('${months[d.month - 1]}, ${d.year}');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMonthStr,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          items: monthYearOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              final parts = newValue.split(', ');
              setState(() {
                selectedMonthStr = newValue;
                selectedMonth = months.indexOf(parts[0]) + 1;
                selectedYear = int.parse(parts[1]);
              });
              _fetchMilkHistory();
            }
          },
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final displayRecords = _milkRecords.length > 7 
        ? _milkRecords.sublist(_milkRecords.length - 7)
        : _milkRecords;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        maxY: 15, 
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < displayRecords.length) {
                  final record = displayRecords[index];
                  final String rawDate = record['date']?.toString() ?? '';
                  final date = DateTime.tryParse(rawDate) ?? DateTime.now();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd').format(date),
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < displayRecords.length) {
                  final record = displayRecords[index];
                  final m = (record['morningMilk'] ?? record['morning'] ?? 0).toDouble();
                  final e = (record['eveningMilk'] ?? record['evening'] ?? 0).toDouble();
                  if (m == 0 && e == 0) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Center(
                      child: Text(
                        (m + e).toStringAsFixed(1),
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(displayRecords.length, (index) {
          final record = displayRecords[index];
          return _makeGroupData(
            index,
            (record['morningMilk'] ?? record['morning'] ?? 0).toDouble(),
            (record['eveningMilk'] ?? record['evening'] ?? 0).toDouble(),
          );
        }),
      ),
    );
  }

  Widget _buildDailyListSection() {
    double totalMorning = 0;
    double totalEvening = 0;
    
    if (_reportSummary != null) {
      totalMorning = (_reportSummary!['totalMorningMilk'] ?? 0).toDouble();
      totalEvening = (_reportSummary!['totalEveningMilk'] ?? 0).toDouble();
    } else {
      for (var r in _milkRecords) {
        totalMorning += (r['morningMilk'] ?? r['morning'] ?? 0).toDouble();
        totalEvening += (r['eveningMilk'] ?? r['evening'] ?? 0).toDouble();
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableSubtitle(),
          const Divider(height: 1),
          if (_milkRecords.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No records for this month'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _milkRecords.length,
              itemBuilder: (context, index) {
                final record = _milkRecords[index];
                final date = DateTime.tryParse(record['date']?.toString() ?? '') ?? DateTime.now();
                return _buildListRow(
                  DateFormat('dd').format(date),
                  (record['morningMilk'] ?? record['morning'] ?? 0).toStringAsFixed(1),
                  (record['eveningMilk'] ?? record['evening'] ?? 0).toStringAsFixed(1),
                  morningFeed: (record['morningFeed'] ?? 0).toStringAsFixed(1),
                  eveningFeed: (record['eveningFeed'] ?? 0).toStringAsFixed(1),
                );
              },
            ),
          _buildTableTotal(totalMorning, totalEvening),
        ],
      ),
    );
  }

  Widget _buildTableSubtitle() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildHeaderCol('Date', width: 40),
          _buildVerticalDivider(),
          Expanded(child: _buildSessionHeader('Morning', const Color(0xFF6A9DFC), Icons.wb_sunny_outlined)),
          _buildVerticalDivider(),
          Expanded(child: _buildSessionHeader('Evening', const Color(0xFFE38EAC), Icons.nightlight_round)),
        ],
      ),
    );
  }

  Widget _buildHeaderCol(String label, {double? width}) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildSessionHeader(String title, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Milk', style: GoogleFonts.inter(fontSize: 11)),
            Text('Feed', style: GoogleFonts.inter(fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildListRow(String day, String milkMor, String milkEve, {String morningFeed = '-', String eveningFeed = '-'}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          _buildVerticalDividerSmall(),
          Expanded(child: _buildDataCols(milkMor, morningFeed)),
          _buildVerticalDividerSmall(),
          Expanded(child: _buildDataCols(milkEve, eveningFeed)),
        ],
      ),
    );
  }

  Widget _buildVerticalDividerSmall() {
    return Container(height: 24, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildDataCols(String milk, String feed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(milk, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(feed, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildTableTotal(double morning, double evening) {
    final totalMorningFeed = _reportSummary != null 
        ? (_reportSummary!['totalMorningFeed'] ?? 0).toDouble() 
        : 0.0;
    final totalEveningFeed = _reportSummary != null 
        ? (_reportSummary!['totalEveningFeed'] ?? 0).toDouble() 
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF9BAB64),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'Total',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(child: _buildTotalCol(morning, totalMorningFeed)),
          Expanded(child: _buildTotalCol(evening, totalEveningFeed)),
        ],
      ),
    );
  }

  Widget _buildTotalCol(double milk, double feed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          '${milk.toStringAsFixed(1)} L',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          feed > 0 ? '${feed.toStringAsFixed(1)} Kg' : '-',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withAlpha(230)),
        ),
      ],
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: const Color(0xFF6A9DFC),
          width: 8,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2)),
        ),
        BarChartRodData(
          toY: y2,
          color: const Color(0xFFE38EAC),
          width: 8,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2)),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ],
    );
  }
}
