import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';

// ============================================================
// CONSTANTS
// ============================================================
const _kOlive = Color(0xFF99AA5A);
// ============================================================
// HUB
// ============================================================
class MilkReportHubScreen extends StatelessWidget {
  const MilkReportHubScreen({super.key});

  static const _items = [
    _HubItem('Daily Milk Report', Icons.calendar_today_rounded,
        Color(0xFF7BAC68)),
    _HubItem('Monthly Milk Report', Icons.calendar_month_rounded,
        Color(0xFF5B8FD4)),
    _HubItem('Milk Report as per Parity', Icons.pets_rounded,
        Color(0xFF8DA94D)),
    _HubItem('Cow-wise Monthly Milk Report',
        Icons.grid_view_rounded, Color(0xFF4CAF50)),
    _HubItem('Milk Distribution Report', Icons.water_drop_rounded,
        Color(0xFF7B5EA7)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _CircleBack(onTap: () => Navigator.pop(context)),
        title: Text('Milk Report',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) => _buildTile(ctx, _items[i]),
      ),
    );
  }

  Widget _buildTile(BuildContext ctx, _HubItem item) {
    return GestureDetector(
      onTap: () => _navigate(ctx, item.label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  shape: BoxShape.circle),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.label,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  shape: BoxShape.circle),
              child: const Icon(Icons.chevron_right,
                  size: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext ctx, String label) {
    Widget dest;
    switch (label) {
      case 'Daily Milk Report':
        dest = const DailyMilkReportScreen();
        break;
      case 'Monthly Milk Report':
        dest = const MonthlyMilkReportScreen();
        break;
      case 'Milk Report as per Parity':
        dest = const MilkReportAsPerParityScreen();
        break;
      case 'Cow-wise Monthly Milk Report':
        dest = const CowWiseMonthlyMilkReportScreen();
        break;
      case 'Milk Distribution Report':
        dest = const MilkDistributionReportScreen();
        break;
      default:
        return;
    }
    Navigator.push(
        ctx, MaterialPageRoute(builder: (_) => dest));
  }
}

class _HubItem {
  final String label;
  final IconData icon;
  final Color color;
  const _HubItem(this.label, this.icon, this.color);
}

// ============================================================
// 1. DAILY MILK REPORT  (iPhone 16 - 52)
// ============================================================
class DailyMilkReportScreen extends StatefulWidget {
  const DailyMilkReportScreen({super.key});

  @override
  State<DailyMilkReportScreen> createState() =>
      _DailyMilkReportScreenState();
}

class _DailyMilkReportScreenState
    extends State<DailyMilkReportScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic> _apiDailyData = {};

  double get _totalMorning => (_apiDailyData['morning'] ?? 0.0).toDouble();
  double get _totalEvening => (_apiDailyData['evening'] ?? 0.0).toDouble();
  double get _totalMilk => (_apiDailyData['total'] ?? 0.0).toDouble();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final report = await sl<ApiService>().getDailyProductionReport(date: dateStr);
      
      if (mounted) {
        setState(() {
          _apiDailyData = report['data'] ?? report;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching daily report: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _CircleBack(onTap: () => Navigator.pop(context)),
        title: Text('Daily Milk Report',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kOlive))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Date + Summary Card ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        // Date row
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                  builder: (c, child) =>
                                      _oliveDateTheme(c, child!),
                                );
                                if (d != null) {
                                  setState(() => _selectedDate = d);
                                  _fetchData();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F6F7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Text(fmt.format(_selectedDate),
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 16, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Total Milk: ${_totalMilk.toStringAsFixed(2)} Ltr.',
                              style: GoogleFonts.poppins(
                                  color: _kOlive,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Morning / Evening boxes
                        Row(
                          children: [
                            Expanded(
                                child: _SessionBox(
                                    label: 'Morning',
                                    milk: _totalMorning,
                                    feed: 0)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _SessionBox(
                                    label: 'Evening',
                                    milk: _totalEvening,
                                    feed: 0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Table ─────────────────────────────────────────────
                  Container(
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text('Cow Name',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))),
                              _SessionHeader(isMorning: true),
                              _SessionHeader(isMorning: false),
                            ],
                          ),
                        ),
                        // Sub-header icons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Expanded(flex: 3, child: SizedBox()),
                              Expanded(
                                  flex: 2,
                                  child: Row(children: [
                                    const Icon(Icons.water_drop_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Image.asset(
                                      'assets/icons/cow_and_calf.png',
                                      width: 16,
                                      height: 16,
                                    ),
                                  ])),
                              Expanded(
                                  flex: 2,
                                  child: Row(children: [
                                    const Icon(Icons.water_drop_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Image.asset(
                                      'assets/icons/cow_and_calf.png',
                                      width: 16,
                                      height: 16,
                                    ),
                                  ])),
                            ],
                          ),
                        ),
                        const Divider(height: 12),
                        // Data rows
                        if ((_apiDailyData['items'] as List?)?.isEmpty ?? true)
                           Padding(
                             padding: const EdgeInsets.all(20.0),
                             child: Text('No records for this date', style: GoogleFonts.poppins(color: Colors.grey)),
                           )
                        else
                          ...(_apiDailyData['items'] as List).map((item) {
                            return _DailyTableRow(
                              name: item['animalName'] ?? 'Unknown',
                              morningMilk: (item['morning'] ?? 0.0).toDouble(),
                              eveningMilk: (item['evening'] ?? 0.0).toDouble(),
                            );
                          }),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// 2. MONTHLY MILK REPORT  (iPhone 16 - 53)
// ============================================================
class MonthlyMilkReportScreen extends StatefulWidget {
  const MonthlyMilkReportScreen({super.key});

  @override
  State<MonthlyMilkReportScreen> createState() =>
      _MonthlyMilkReportScreenState();
}

class _MonthlyMilkReportScreenState
    extends State<MonthlyMilkReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;
  bool _isDownloading = false;
  Map<String, dynamic> _apiMonthlyData = {};

  List<dynamic> get _monthlyItems => (_apiMonthlyData['items'] as List?) ?? const [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final report = await sl<ApiService>()
          .getMonthlyProductionReport(
            month: _selectedMonth.month,
            year: _selectedMonth.year,
          )
          .timeout(const Duration(seconds: 8));
      if (mounted) {
        setState(() {
          _apiMonthlyData = _normalizeMonthlyReport(report);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching monthly report: $e');
      if (mounted) {
        setState(() {
          _apiMonthlyData = {'items': <Map<String, dynamic>>[]};
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadMonthlyReport() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final response = await sl<ApiService>()
          .getMonthlyProductionExport(
            month: _selectedMonth.month,
            year: _selectedMonth.year,
          )
          .timeout(const Duration(seconds: 20));
      if (!mounted) return;
      final payload = _firstMap(response, const ['data', 'report', 'result']) ?? response;
      final fileUrl = _asText(
        payload['url'] ??
            payload['fileUrl'] ??
            payload['downloadUrl'] ??
            payload['link'],
        fallback: '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fileUrl.isNotEmpty
                ? 'Monthly export is ready.'
                : 'Monthly export request completed.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to export monthly report right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _pickMonth(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => _MonthPickerDialog(
        initialMonth: _selectedMonth,
        onSelected: (d) {
           setState(() => _selectedMonth = d);
           _fetchData();
        },
      ),
    );
  }

  Map<String, dynamic> _normalizeMonthlyReport(
    Map<String, dynamic> report,
  ) {
    final payload = _firstMap(report, const [
          'data',
          'report',
          'monthlyReport',
          'result',
        ]) ??
        report;

    return {
      ...payload,
      'items': _extractMonthlyItems(payload, report),
    };
  }

  List<Map<String, dynamic>> _extractMonthlyItems(
    Map<String, dynamic> payload,
    Map<String, dynamic> root,
  ) {
    final dynamic nestedData = payload['data'];
    final List<dynamic> rawItems =
        (payload['items'] as List?) ??
            (payload['records'] as List?) ??
            (payload['rows'] as List?) ??
            (payload['list'] as List?) ??
            (payload['animals'] as List?) ??
            (nestedData is List ? nestedData : null) ??
            (root['items'] as List?) ??
            (root['records'] as List?) ??
            (root['rows'] as List?) ??
            (root['list'] as List?) ??
            const [];

    return rawItems
        .whereType<Map>()
        .map((item) => _normalizeMonthlyItem(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Map<String, dynamic> _normalizeMonthlyItem(Map<String, dynamic> item) {
    final animal = _firstMap(item, const ['animal', 'cow', 'cattle']) ?? const {};
    final total = _asDouble(
      item['total'] ??
          item['totalMilk'] ??
          item['totalMilkProduction'] ??
          item['monthlyTotal'] ??
          item['quantity'],
    );
    final average = _asDouble(
      item['average'] ??
          item['avg'] ??
          item['averageMilk'] ??
          item['averageProduction'],
    );

    return {
      ...item,
      'animalName': _asText(
        item['animalName'] ?? item['cowName'] ?? item['name'] ?? animal['name'],
        fallback: 'Unknown',
      ),
      'tagNumber': _asText(
        item['tagNumber'] ??
            item['animalTagNumber'] ??
            item['tagNo'] ??
            item['tagno'] ??
            animal['tagNumber'] ??
            animal['tagNo'] ??
            animal['tagno'],
        fallback: '-',
      ),
      'total': total,
      'average': average > 0 ? average : _deriveAverage(item, total),
    };
  }

  double _deriveAverage(Map<String, dynamic> item, double total) {
    final days = _asDouble(
      item['days'] ??
          item['daysCount'] ??
          item['milkingDays'] ??
          item['recordCount'],
    );
    if (days > 0) {
      return total / days;
    }
    return total;
  }

  Map<String, dynamic>? _firstMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return null;
  }

  String _asText(dynamic value, {required String fallback}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final monthFmt = DateFormat('MMM, yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _CircleBack(onTap: () => Navigator.pop(context)),
        title: Text('Monthly Milk Report',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: [
          _AppBarIconBtn(
            icon: Icons.file_download_outlined,
            onTap: _downloadMonthlyReport,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Month',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickMonth(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(monthFmt.format(_selectedMonth),
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const Icon(Icons.calendar_today_outlined,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                if (_isDownloading) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _kOlive,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Preparing export...',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _kOlive),
                  )
                : _monthlyItems.isEmpty
                    ? _buildNoDataView()
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Container(
                            decoration: _cardDeco(),
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.all(Colors.white),
                              columnSpacing: 18,
                              horizontalMargin: 14,
                              dividerThickness: 0.8,
                              headingTextStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87),
                              dataTextStyle: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.black87),
                              columns: [
                                const DataColumn(label: Text('Cow Name')),
                                const DataColumn(label: Text('Tag No.')),
                                const DataColumn(label: Text('Total (Ltr)')),
                                const DataColumn(label: Text('Avg (Ltr)')),
                              ],
                              rows: _monthlyItems.map((item) {
                                final total = _asDouble(item['total']);
                                final average = _asDouble(item['average']);
                                return DataRow(cells: [
                                  DataCell(Text(item['animalName'] ?? 'Unknown',
                                      style: GoogleFonts.inter(
                                          color: _kOlive,
                                          fontWeight: FontWeight.w600))),
                                  DataCell(Text(item['tagNumber'] ?? '-')),
                                  DataCell(Text(total.toStringAsFixed(1),
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold))),
                                  DataCell(Text(average.toStringAsFixed(1),
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold))),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 3. MILK REPORT AS PER PARITY  (iPhone 16 - 54/55/56/57)
// ============================================================
class MilkReportAsPerParityScreen extends StatefulWidget {
  const MilkReportAsPerParityScreen({super.key});

  @override
  State<MilkReportAsPerParityScreen> createState() =>
      _MilkReportAsPerParityScreenState();
}

class _MilkReportAsPerParityScreenState
    extends State<MilkReportAsPerParityScreen> {
  dynamic _selectedCow;
  bool _showSearch = false;
  String _searchQ = '';
  final _searchCtrl = TextEditingController();
  
  List<dynamic> _apiCows = [];
  Map<String, dynamic>? _apiParityData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCows();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCows() async {
    setState(() => _isLoading = true);
    try {
      final cows = await sl<ApiService>().getCows();
      if (mounted) {
        setState(() {
          _apiCows = cows;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cows: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchParityReport(String animalId) async {
    setState(() => _isLoading = true);
    try {
      final report = await sl<ApiService>().getParityReport(animalId: animalId);
      if (mounted) {
        setState(() {
          _apiParityData = report['data'] ?? report;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching parity report: $e');
      if (mounted) {
        setState(() {
          _apiParityData = null;
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filteredCows {
    if (_searchQ.isEmpty) return _apiCows;
    return _apiCows
        .where((c) =>
            (c['name'] ?? '').toString().toLowerCase().contains(_searchQ.toLowerCase()) ||
            (c['tagNumber'] ?? '').toString().toLowerCase().contains(_searchQ.toLowerCase()))
        .toList();
  }

  List<dynamic>? get _parityItems => _apiParityData?['items'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _CircleBack(onTap: () => Navigator.pop(context)),
        title: Text('Milk Report as per Parity',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cow label
            Text('Cow',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            // Dropdown trigger
            GestureDetector(
              onTap: () => setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  _searchQ = '';
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedCow != null ? _selectedCow['name'] ?? 'Unknown' : 'Select cow',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _selectedCow == null
                                ? Colors.grey
                                : Colors.black87),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey),
                  ],
                ),
              ),
            ),

            // Search + list dropdown
            if (_showSearch) ...[
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        height: 40,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                autofocus: true,
                                onChanged: (v) =>
                                    setState(() => _searchQ = v),
                                style:
                                    GoogleFonts.inter(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search here...',
                                  hintStyle: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: 260),
                      child: ListView(
                        shrinkWrap: true,
                        children: _filteredCows
                            .map((c) => Column(
                                  children: [
                                    ListTile(
                                      dense: true,
                                      title: Center(
                                        child: Text(c['name'] ?? 'Unknown',
                                            style:
                                                GoogleFonts.poppins(
                                                    fontSize: 14)),
                                      ),
                                      onTap: () => setState(() {
                                        _selectedCow = c;
                                        _showSearch = false;
                                        _searchCtrl.clear();
                                        _searchQ = '';
                                        _fetchParityReport(c['id'].toString());
                                      }),
                                    ),
                                    const Divider(height: 1),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Body: no cow selected → empty; cow selected with data → table; no data → no_data_found
            if (_selectedCow == null) const SizedBox(),

            if (_selectedCow != null && _parityItems == null)
              Expanded(
                child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: _kOlive))
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/no_data_found.png',
                        width: 180,
                        height: 180,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.search_off_rounded,
                            size: 100,
                            color: _kOlive),
                      ),
                      const SizedBox(height: 14),
                      Text('No data found',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _kOlive)),
                    ],
                  ),
                ),
              ),

            if (_selectedCow != null && _parityItems != null)
              Expanded(
                child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: _kOlive))
                : Container(
                  decoration: _cardDeco(),
                  child: DataTable(
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    headingRowColor: MaterialStateProperty.all(
                        Colors.white),
                    headingTextStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87),
                    dataTextStyle:
                        GoogleFonts.inter(fontSize: 13),
                    columns: const [
                      DataColumn(label: Text('Parity')),
                      DataColumn(label: Text('Total (Ltr)')),
                      DataColumn(label: Text('Days')),
                      DataColumn(label: Text('Avg')),
                    ],
                    rows: _parityItems!.map((p) {
                      final parity = p['parity']?.toString() ?? '-';
                      final total = (p['totalMilk'] ?? 0.0).toStringAsFixed(1);
                      final days = p['days']?.toString() ?? '-';
                      final avg = (p['avgMilk'] ?? 0.0).toStringAsFixed(1);
                      return DataRow(cells: [
                        DataCell(Text(parity)),
                        DataCell(Text(total,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold))),
                        DataCell(Text(days)),
                        DataCell(Text(avg,
                            style: GoogleFonts.inter(
                                color: _kOlive,
                                fontWeight: FontWeight.bold))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 4. COW-WISE MONTHLY MILK REPORT  (iPhone 16 - 58 / 61)
// ============================================================
class CowWiseMonthlyMilkReportScreen extends StatefulWidget {
  const CowWiseMonthlyMilkReportScreen({super.key});

  @override
  State<CowWiseMonthlyMilkReportScreen> createState() =>
      _CowWiseMonthlyMilkReportScreenState();
}

class _CowWiseMonthlyMilkReportScreenState
    extends State<CowWiseMonthlyMilkReportScreen> {
  DateTime? _selectedMonth;
  dynamic _selectedCow;
  bool _showCowSearch = false;

  List<dynamic> _apiCows = [];
  Map<String, dynamic>? _apiReportData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCows();
  }

  Future<void> _fetchCows() async {
    setState(() => _isLoading = true);
    try {
      final cows = await sl<ApiService>().getCows();
      if (mounted) {
        setState(() {
          _apiCows = cows;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cows: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReport() async {
    if (_selectedMonth == null || _selectedCow == null) return;

    setState(() => _isLoading = true);
    try {
      final report = await sl<ApiService>().getCowMonthlyReport(
        animalId: _selectedCow['id'].toString(),
        month: _selectedMonth!.month,
        year: _selectedMonth!.year,
      );
      if (mounted) {
        setState(() {
          final data = report['data'] ?? report;
          final dailyRecords = (data['dailyRecords'] as List?) ?? const [];
          _apiReportData = dailyRecords.isNotEmpty
              ? data
              : _buildCowMonthlyFallback(
                  records: data is Map<String, dynamic> ? const [] : const [],
                );
          _isLoading = false;
        });
      }
    } catch (e) {
      try {
        final history = await sl<ApiService>().getMilkHistoryForAnimal(
          animalId: _selectedCow['id'].toString(),
          month: _selectedMonth!.month,
          year: _selectedMonth!.year,
        );
        if (mounted) {
          setState(() {
            _apiReportData = _buildCowMonthlyFallback(records: history);
            _isLoading = false;
          });
        }
      } catch (_) {
        debugPrint('Error fetching cow monthly report: $e');
        if (mounted) {
          setState(() {
            _apiReportData = null;
            _isLoading = false;
          });
        }
      }
    }
  }

  Map<String, dynamic> _buildCowMonthlyFallback({required List<dynamic> records}) {
    final normalized = records
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    double morningTotal = 0;
    double eveningTotal = 0;
    final dailyRecords = normalized.map((item) {
      final morning = double.tryParse((item['morning'] ?? item['morningMilk'] ?? 0).toString()) ?? 0;
      final evening = double.tryParse((item['evening'] ?? item['eveningMilk'] ?? 0).toString()) ?? 0;
      morningTotal += morning;
      eveningTotal += evening;
      return {
        'date': item['date'],
        'morningMilk': morning,
        'eveningMilk': evening,
        'morningFeed': item['morningFeed'],
        'eveningFeed': item['eveningFeed'],
      };
    }).toList();

    return {
      'dailyRecords': dailyRecords,
      'totalMorningMilk': morningTotal,
      'totalEveningMilk': eveningTotal,
    };
  }

  @override
  Widget build(BuildContext context) {
    final monthFmt = DateFormat('MMM, yyyy');
    final bool showTable =
        _selectedMonth != null && _selectedCow != null;
    final int daysInSelectedMonth = _selectedMonth == null
        ? 31
        : DateUtils.getDaysInMonth(
            _selectedMonth!.year, _selectedMonth!.month);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _CircleBack(onTap: () => Navigator.pop(context)),
        title: Text('Cow-wise Monthly Milk Report',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: _isLoading && _apiCows.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _kOlive))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filters ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                // Month
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Month',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _pickMonth(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F7),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedMonth == null
                                      ? 'Select month'
                                      : monthFmt
                                          .format(_selectedMonth!),
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: _selectedMonth ==
                                              null
                                          ? Colors.grey
                                          : Colors.black87),
                                ),
                              ),
                              const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Cow dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cow',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => setState(() => _showCowSearch = !_showCowSearch),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F7),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                   _selectedCow != null ? _selectedCow['name'] ?? 'Unknown' : 'Select cow',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: _selectedCow ==
                                              null
                                          ? Colors.grey
                                          : Colors.black87),
                                ),
                              ),
                              const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Cow dropdown
          if (_showCowSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8)
                  ],
                ),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: 180),
                      child: ListView(
                        shrinkWrap: true,
                        children: _apiCows
                            .map((c) => ListTile(
                                  dense: true,
                                  title: Text(c['name'] ?? 'Unknown',
                                      style:
                                          GoogleFonts.poppins(
                                              fontSize: 13)),
                                  onTap: () {
                                    setState(() {
                                      _selectedCow = c;
                                      _showCowSearch = false;
                                    });
                                    _fetchReport();
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),


          // ── Data table (when month + cow selected) ───────────
          if (showTable)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _kOlive))
                  : ((_apiReportData?['dailyRecords'] as List?)?.isEmpty ?? true)
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/icons/no_data_found.png', width: 180, height: 180),
                              const SizedBox(height: 16),
                              Text(
                                'No data found',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: _kOlive,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _CowWiseTable(
                          daysInMonth: daysInSelectedMonth,
                          cowName: _selectedCow!['name'] ?? 'Unknown',
                          apiDailyData: _apiReportData?['dailyRecords'],
                          totalMorningMilk: ((_apiReportData?['totalMorningMilk'] ?? 0.0) as num).toDouble(),
                          totalEveningMilk: ((_apiReportData?['totalEveningMilk'] ?? 0.0) as num).toDouble(),
                        ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => _MonthPickerDialog(
        initialMonth: _selectedMonth ?? DateTime.now(),
        onSelected: (d) {
          setState(() => _selectedMonth = d);
          _fetchReport();
        },
      ),
    );
  }
}

// ============================================================
// 5. MILK DISTRIBUTION REPORT  (iPhone 16 - 62)
// ============================================================
class MilkDistributionReportScreen extends StatefulWidget {
  const MilkDistributionReportScreen({super.key});

  @override
  State<MilkDistributionReportScreen> createState() =>
      _MilkDistributionReportScreenState();
}

class _MilkDistributionReportScreenState
    extends State<MilkDistributionReportScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<dynamic> _distributions = [];
  Map<String, dynamic> _apiProductionData = {};

  double get _totalMorning => (_apiProductionData['morning'] ?? 0.0).toDouble();
  double get _totalEvening => (_apiProductionData['evening'] ?? 0.0).toDouble();
  double get _totalMilk => (_apiProductionData['total'] ?? 0.0).toDouble();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final dists = await sl<ApiService>().getMilkDistributions(date: dateStr);
      final report = await sl<ApiService>().getDailyProductionReport(date: dateStr);

      if (mounted) {
        setState(() {
          _distributions = dists;
          _apiProductionData = report['data'] ?? report;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching distributions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _CircleBack(onTap: () => Navigator.pop(context)),
        title: Text('Milk Distribution Report',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kOlive))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Date navigator ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() => _selectedDate = _selectedDate
                                .subtract(const Duration(days: 1)));
                            _fetchData();
                          },
                          icon:
                              const Icon(Icons.chevron_left, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (c, child) =>
                                    _oliveDateTheme(c, child!),
                              );
                              if (d != null) {
                                setState(() => _selectedDate = d);
                                _fetchData();
                              }
                            },
                            child: Center(
                              child: Text(fmt.format(_selectedDate),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _selectedDate =
                                _selectedDate.add(const Duration(days: 1)));
                            _fetchData();
                          },
                          icon: const Icon(Icons.chevron_right,
                              color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Summary card ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDeco(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Milk: ${_totalMilk.toStringAsFixed(2)} Ltr.',
                          style: GoogleFonts.poppins(
                              color: _kOlive,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: _SessionBox(
                                    label: 'Morning',
                                    milk: _totalMorning,
                                    feed: 0)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _SessionBox(
                                    label: 'Evening',
                                    milk: _totalEvening,
                                    feed: 0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Distributions List ────────────────────────────
                  Expanded(
                    child: Container(
                      decoration: _cardDeco(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Distributions',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: _distributions.isEmpty
                                ? Center(
                                    child: Text('No distributions for today',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey)))
                                : ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _distributions.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(),
                                    itemBuilder: (ctx, i) {
                                      final d = _distributions[i];
                                      return ListTile(
                                        title: Text(d['categoryName'] ?? 'Unknown',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600)),
                                        trailing: Text('${d['amount']} Ltr.',
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                color: _kOlive)),
                                        subtitle: d['remarks'] != null
                                            ? Text(d['remarks'])
                                            : null,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// SHARED WIDGETS
// ============================================================

class _SessionBox extends StatelessWidget {
  final String label;
  final double milk;
  final double feed;
  const _SessionBox(
      {required this.label, required this.milk, required this.feed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style:
                  GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text('Milk: ${milk.toStringAsFixed(2)} Ltr.',
              style: GoogleFonts.poppins(
                  color: _kOlive,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text('(+${feed.toStringAsFixed(2)} Ltr. Feed)',
              style: GoogleFonts.inter(
                  fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _DailyTableRow extends StatelessWidget {
  final String name;
  final double morningMilk;
  final double eveningMilk;
  const _DailyTableRow(
      {required this.name,
      required this.morningMilk,
      required this.eveningMilk});

  @override
  Widget build(BuildContext context) {
    String fmt(double v) => v > 0 ? v.toInt().toString() : '0';

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(name,
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text(fmt(morningMilk),
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Text('-', style: GoogleFonts.inter(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text(fmt(eveningMilk),
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Text('-', style: GoogleFonts.inter(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 12, endIndent: 12),
      ],
    );
  }
}

class _SessionHeader extends StatelessWidget {
  final bool isMorning;
  const _SessionHeader({required this.isMorning});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _kOlive,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMorning ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(isMorning ? 'Morning' : 'Evening',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}

// Month-year grid picker widget
class _MonthYearPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onSelected;
  const _MonthYearPicker(
      {required this.initialDate, required this.onSelected});

  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  late int _year;
  int? _selectedMonth;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Year row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _year--),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text('$_year',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _year++),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Month grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final isSelected = i + 1 == _selectedMonth;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedMonth = i + 1);
                  widget.onSelected(DateTime(_year, i + 1));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? _kOlive : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(_months[i],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : Colors.black87)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Dialog wrapper for month picker
class _MonthPickerDialog extends StatefulWidget {
  final DateTime initialMonth;
  final ValueChanged<DateTime> onSelected;
  const _MonthPickerDialog(
      {required this.initialMonth, required this.onSelected});

  @override
  State<_MonthPickerDialog> createState() =>
      _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;
  int? _selectedMonth;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialMonth.year;
    _selectedMonth = widget.initialMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _year--),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text('$_year',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _year++),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
              ),
              itemCount: 12,
              itemBuilder: (_, i) {
                final isSelected = i + 1 == _selectedMonth;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedMonth = i + 1);
                    widget.onSelected(DateTime(_year, i + 1));
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? _kOlive : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(_months[i],
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Cow-wise data table  (iPhone 16 - 61)
class _CowWiseTable extends StatelessWidget {
  final int daysInMonth;
  final String cowName;
  final List<dynamic>? apiDailyData;
  final double totalMorningMilk;
  final double totalEveningMilk;

  const _CowWiseTable({
    required this.daysInMonth,
    required this.cowName,
    this.apiDailyData,
    this.totalMorningMilk = 0.0,
    this.totalEveningMilk = 0.0,
  });

  Map<int, Map<String, dynamic>> get _dailyMap {
    if (apiDailyData == null) return {};
    final map = <int, Map<String, dynamic>>{};
    for (final entry in apiDailyData!) {
      if (entry is Map<String, dynamic>) {
        final dayStr = entry['date']?.toString() ?? '';
        try {
          final day = DateTime.parse(dayStr).day;
          map[day] = entry;
        } catch (_) {}
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final daily = _dailyMap;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text('Date',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      _TableHeaderSession(label: 'Morning', isMorning: true),
                      const SizedBox(width: 8),
                      _TableHeaderSession(label: 'Evening', isMorning: false),
                    ],
                  ),
                ),
                // Sub header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const SizedBox(width: 48),
                      Expanded(
                          child: Text('Milk',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey))),
                      Expanded(
                          child: Text('Feed',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text('Milk',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey))),
                      Expanded(
                          child: Text('Feed',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey))),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...List.generate(daysInMonth, (i) {
                  final day = i + 1;
                  final entry = daily[day];
                  String fmt(dynamic v) =>
                      v != null && double.tryParse(v.toString()) != null
                          ? double.parse(v.toString()).toStringAsFixed(1)
                          : '-';
                  final mMilk = fmt(entry?['morningMilk']);
                  final mFeed = fmt(entry?['morningFeed']);
                  final eMilk = fmt(entry?['eveningMilk']);
                  final eFeed = fmt(entry?['eveningFeed']);
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text('$day',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 1, height: 16, color: Colors.grey.shade300),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Center(
                                    child: Text(mMilk,
                                        style: GoogleFonts.inter(
                                            color: mMilk == '-' ? Colors.grey : Colors.black87,
                                            fontWeight: mMilk == '-' ? FontWeight.normal : FontWeight.w600)))),
                            Expanded(
                                child: Center(
                                    child: Text(mFeed,
                                        style: GoogleFonts.inter(color: Colors.grey)))),
                            const SizedBox(width: 8),
                            Container(width: 1, height: 16, color: Colors.grey.shade300),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Center(
                                    child: Text(eMilk,
                                        style: GoogleFonts.inter(
                                            color: eMilk == '-' ? Colors.grey : Colors.black87,
                                            fontWeight: eMilk == '-' ? FontWeight.normal : FontWeight.w600)))),
                            Expanded(
                                child: Center(
                                    child: Text(eFeed,
                                        style: GoogleFonts.inter(color: Colors.grey)))),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        // Total bar (olive green)
        Container(
          color: _kOlive,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text('Total',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Center(
                      child: Text('${totalMorningMilk.toStringAsFixed(1)} L',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 12)))),
              // Feed total not in API response, show n/a
              Expanded(
                  child: Center(
                      child: Text('-',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 12)))),
              const SizedBox(width: 8),
              Expanded(
                  child: Center(
                      child: Text('${totalEveningMilk.toStringAsFixed(1)} L',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 12)))),
              Expanded(
                  child: Center(
                      child: Text('-',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 12)))),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableHeaderSession extends StatelessWidget {
  final String label;
  final bool isMorning;
  const _TableHeaderSession(
      {required this.label, required this.isMorning});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration:
                const BoxDecoration(color: _kOlive, shape: BoxShape.circle),
            child: Icon(
                isMorning
                    ? Icons.wb_sunny_outlined
                    : Icons.nightlight_round,
                color: Colors.white,
                size: 14),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED UTILITY WIDGETS
// ============================================================
class _CircleBack extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleBack({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black, size: 20),
          onPressed: onTap,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        width: 38,
        decoration: const BoxDecoration(
            color: _kOlive, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.withOpacity(0.15)),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3))
      ],
    );

Widget _oliveDateTheme(BuildContext ctx, Widget child) => Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(
            primary: _kOlive,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87),
      ),
      child: child,
    );
