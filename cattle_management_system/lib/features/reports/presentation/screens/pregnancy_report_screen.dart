import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';

// ============================================================
// CONSTANTS
// ============================================================
const _kOlive = Color(0xFF99AA5A);
const _kGreen = Color(0xFF4CAF50);

// ============================================================
// MOCK DATA MODELS
// ============================================================

class _PregnancyCow {
  final String name;
  final String tagNo;
  final String no;
  final String imagePath;
  final DateTime? pregnantDate;
  final DateTime? deliveryDate;
  final int parity;
  final String calfStatus;   // e.g. 'Alive'
  final String calfGender;   // e.g. 'Bull Calf'
  final int totalDays;
  final int totalMilk;
  final String bullName;
  final String bullTagNo;
  final String note;
  final String cowType;      // e.g. 'Heifer'
  final String breedType;    // e.g. 'AI'

  const _PregnancyCow({
    required this.name,
    required this.tagNo,
    required this.no,
    required this.imagePath,
    this.pregnantDate,
    this.deliveryDate,
    required this.parity,
    this.calfStatus = '',
    this.calfGender = '',
    this.totalDays = 0,
    this.totalMilk = 0,
    this.bullName = '-',
    this.bullTagNo = '',
    this.note = '',
    this.cowType = '',
    this.breedType = '',
  });

  factory _PregnancyCow.fromJourney(Map<String, dynamic> raw) {
    final animal = _asMap(raw['animal']) ?? _asMap(raw['animalId']) ?? const {};
    final bull = _asMap(raw['bull']) ?? _asMap(raw['bullId']) ?? const {};
    final conceiveDate = _parseDate(
      raw['conceiveDate'] ?? raw['pregnancyDate'] ?? raw['inseminationDate'],
    );
    final deliveryDate = _parseDate(raw['deliveryDate'] ?? raw['expectedDeliveryDate']);
    final deliveredMilk = _toInt(raw['totalMilk'] ?? raw['milkProduced']);

    return _PregnancyCow(
      name: _text(animal['name'], fallback: 'Unknown'),
      tagNo: _text(animal['tagNumber'] ?? raw['tagNumber'], fallback: '-'),
      no: _text(
        animal['animalNumber'] ?? animal['serialNumber'] ?? raw['animalNumber'],
        fallback: '-',
      ),
      imagePath: _text(
        animal['viewUrl'] ?? animal['photoUrl'] ?? animal['imageUrl'],
        fallback: 'assets/icons/cow_and_calf.png',
      ),
      pregnantDate: conceiveDate,
      deliveryDate: deliveryDate,
      parity: _toInt(raw['parity'] ?? animal['parity']),
      calfStatus: _text(raw['calfStatus']),
      calfGender: _text(raw['calfGender']),
      totalDays: conceiveDate == null ? 0 : DateTime.now().difference(conceiveDate).inDays,
      totalMilk: deliveredMilk,
      bullName: _text(bull['name'], fallback: '-'),
      bullTagNo: _text(bull['tagNumber'], fallback: ''),
      note: _text(raw['remark'] ?? raw['remarks'] ?? raw['note']),
      cowType: _text(animal['category'] ?? animal['type'] ?? animal['gender']),
      breedType: _text(raw['pregnancyType'] ?? raw['breedingType']),
    );
  }

  factory _PregnancyCow.fromDelivery(Map<String, dynamic> raw) {
    final animal = _asMap(raw['animal']) ?? _asMap(raw['animalId']) ?? const {};
    final pregnancyDate = _parseDate(raw['pregnancyDate'] ?? raw['conceiveDate']);
    final deliveryDate = _parseDate(raw['deliveryDate']);
    return _PregnancyCow(
      name: _text(animal['name'], fallback: 'Unknown'),
      tagNo: _text(animal['tagNumber'], fallback: '-'),
      no: _text(animal['animalNumber'] ?? animal['serialNumber'], fallback: '-'),
      imagePath: _text(
        animal['viewUrl'] ?? animal['photoUrl'] ?? animal['imageUrl'],
        fallback: 'assets/icons/cow_and_calf.png',
      ),
      pregnantDate: pregnancyDate,
      deliveryDate: deliveryDate,
      parity: _toInt(raw['parity'] ?? animal['parity']),
      calfStatus: _text(raw['calfStatus']),
      calfGender: _text(raw['calfGender']),
      totalDays: pregnancyDate != null && deliveryDate != null
          ? deliveryDate.difference(pregnancyDate).inDays
          : 0,
      totalMilk: _toInt(raw['totalMilk'] ?? raw['milkProduced']),
      bullName: _text(raw['bullName'], fallback: '-'),
      bullTagNo: _text(raw['bullTagNo']),
      note: _text(raw['remark'] ?? raw['remarks'] ?? raw['note']),
      cowType: _text(animal['category'] ?? animal['type'] ?? animal['gender']),
      breedType: _text(raw['pregnancyType'] ?? raw['breedingType']),
    );
  }

  factory _PregnancyCow.fromParity(Map<String, dynamic> raw) {
    final animal = _asMap(raw['animal']) ?? const {};
    final item = _asMap(raw['item']) ?? const {};
    final source = item.isNotEmpty ? item : raw;
    return _PregnancyCow(
      name: _text(animal['name'] ?? raw['animalName'], fallback: 'Unknown'),
      tagNo: _text(animal['tagNumber'] ?? raw['tagNumber'], fallback: '-'),
      no: _text(
        animal['animalNumber'] ?? animal['serialNumber'] ?? raw['animalNumber'],
        fallback: '-',
      ),
      imagePath: _text(
        animal['viewUrl'] ?? animal['photoUrl'] ?? animal['imageUrl'],
        fallback: 'assets/icons/cow_and_calf.png',
      ),
      pregnantDate: _parseDate(
        source['pregnancyDate'] ?? source['conceiveDate'] ?? source['inseminationDate'],
      ),
      deliveryDate: _parseDate(source['deliveryDate']),
      parity: _toInt(source['parity'] ?? raw['parity']),
      calfStatus: _text(source['calfStatus']),
      calfGender: _text(source['calfGender']),
      totalDays: _toInt(source['totalDays']),
      totalMilk: _toInt(source['totalMilk']),
      bullName: _text(source['bullName'], fallback: '-'),
      bullTagNo: _text(source['bullTagNo']),
      note: _text(source['remark'] ?? source['remarks'] ?? source['note']),
      cowType: _text(animal['category'] ?? animal['type'] ?? animal['gender']),
      breedType: _text(source['pregnancyType'] ?? source['breedingType']),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String _text(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Widget _buildAnimalImage(String imagePath, {double width = 80, double height = 80}) {
  final fallback = Container(
    width: width,
    height: height,
    color: const Color(0xFFF5F6F7),
    child: Icon(Icons.no_photography_outlined, size: width * 0.45, color: Colors.grey),
  );
  if (imagePath.startsWith('http')) {
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
  return Image.asset(
    imagePath,
    width: width,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => fallback,
  );
}

// ── Static mock data ──────────────────────────────────────────
final _pregnancyCows = <_PregnancyCow>[
  _PregnancyCow(
    name: 'કાવેરી',
    tagNo: '107',
    no: '0007',
    imagePath: 'assets/icons/cow_and_calf.png',
    pregnantDate: DateTime(2025, 3, 15),
    deliveryDate: DateTime(2025, 12, 26),
    parity: 2,
    calfStatus: 'Alive',
    calfGender: 'Bull Calf',
    totalDays: 0,
    totalMilk: 0,
    bullName: '-',
    bullTagNo: '106',
    note: 'વિકાસ પાણી ચેકીંન 100ml\nહકીમજી 250ml\nટ્રેવરજીન 500ml ની ઈજેક્શન આપેલ',
    cowType: 'Heifer',
    breedType: 'AI',
  ),
  _PregnancyCow(
    name: 'ક્રિષ્ના',
    tagNo: '106',
    no: '0005',
    imagePath: 'assets/icons/cow_and_calf.png',
    pregnantDate: DateTime(2025, 1, 26),
    deliveryDate: DateTime(2025, 5, 7),
    parity: 2,
    calfStatus: 'Alive',
    calfGender: 'Bull Calf',
    totalDays: 0,
    totalMilk: 0,
    bullName: '-',
    bullTagNo: '106',
    note: 'આપણે ત્યાં નથી વિહાણી સાથે આવેલ છે\nમાહિતી હતી માટે આમ ઉમેરેલ છે',
    cowType: 'Heifer',
    breedType: 'AI',
  ),
];

// ============================================================
// SHARED HELPERS (same pattern as heat_report_screen.dart)
// ============================================================

BoxDecoration _cardDeco() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.10),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      border: Border.all(color: Colors.grey.withOpacity(0.12)),
    );

Widget _circleBack(BuildContext context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
      ),
    );

// ============================================================
// 1. PREGNANCY REPORT HUB
// ============================================================
class PregnancyReportHubScreen extends StatelessWidget {
  const PregnancyReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Pragnancy Report',
          style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HubTile(
            label: 'Date Wise Pregnancy Report',
            leadingIcon: Image.asset(
              'assets/icons/mother_cow.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.pets, color: _kOlive),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DateWisePregnancyReportScreen()),
            ),
          ),
          _HubTile(
            label: 'Date Wise Delivery Report',
            leadingIcon: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF5B8FD4),
              size: 28,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DateWiseDeliveryReportScreen()),
            ),
          ),
          _HubTile(
            label: 'Parity Report',
            leadingIcon: Image.asset(
              'assets/icons/mother_cow.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.pets, color: _kOlive),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ParityReportScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  final String label;
  final Widget? leadingIcon;
  final VoidCallback onTap;
  const _HubTile({
    required this.label,
    required this.onTap,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDeco(),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: leadingIcon != null
            ? SizedBox(width: 36, height: 36, child: leadingIcon)
            : null,
        title: Text(
          label,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6F7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

// ============================================================
// 2. DATE WISE PREGNANCY REPORT (shows "No data found" when empty)
// ============================================================
class DateWisePregnancyReportScreen extends StatefulWidget {
  const DateWisePregnancyReportScreen({super.key});

  @override
  State<DateWisePregnancyReportScreen> createState() =>
      _DateWisePregnancyReportScreenState();
}

class _DateWisePregnancyReportScreenState
    extends State<DateWisePregnancyReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  bool _isLoading = false;
  List<_PregnancyCow> _cows = [];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await sl<ApiService>().getPregnancyReport(
        from: _fromDate,
        to: _toDate,
      );
      if (!mounted) return;
      setState(() {
        _cows = data
            .whereType<Map>()
            .map((item) => _PregnancyCow.fromJourney(Map<String, dynamic>.from(item)))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cows = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    final cows = _cows;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Date Wise Pregnancy Report',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _fromDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _kOlive)),
                          child: child!,
                        ),
                      );
                      if (d != null) {
                        setState(() => _fromDate = d);
                        _loadReport();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F6F7), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fmt.format(_fromDate), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _toDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _kOlive)),
                          child: child!,
                        ),
                      );
                      if (d != null) {
                        setState(() => _toDate = d);
                        _loadReport();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F6F7), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fmt.format(_toDate), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total ${cows.length}',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // ── Content ──────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _kOlive))
                  : cows.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/no_data_found.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _kOlive,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: cows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cow = cows[index];
                        return _PregnancyCowCard(cow: cow);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 3. DATE WISE DELIVERY REPORT
// ============================================================
class DateWiseDeliveryReportScreen extends StatefulWidget {
  const DateWiseDeliveryReportScreen({super.key});

  @override
  State<DateWiseDeliveryReportScreen> createState() =>
      _DateWiseDeliveryReportScreenState();
}

class _DateWiseDeliveryReportScreenState
    extends State<DateWiseDeliveryReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  bool _isLoading = false;
  List<_PregnancyCow> _cows = [];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await sl<ApiService>().getDeliveryReport(
        from: _fromDate,
        to: _toDate,
      );
      if (!mounted) return;
      setState(() {
        _cows = data
            .whereType<Map>()
            .map((item) => _PregnancyCow.fromDelivery(Map<String, dynamic>.from(item)))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cows = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    final cows = _cows;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Date Wise Delivery Report',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _fromDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _kOlive)),
                          child: child!,
                        ),
                      );
                      if (d != null) {
                        setState(() => _fromDate = d);
                        _loadReport();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F6F7), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fmt.format(_fromDate), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _toDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _kOlive)),
                          child: child!,
                        ),
                      );
                      if (d != null) {
                        setState(() => _toDate = d);
                        _loadReport();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F6F7), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fmt.format(_toDate), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total ${cows.length}',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // ── Content ──────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _kOlive))
                  : cows.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/no_data_found.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _kOlive,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: cows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cow = cows[index];
                        return GestureDetector(
                          onTap: () => _showDeliveryDetails(context, cow),
                          child: _DeliveryCowCard(cow: cow),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryDetails(BuildContext context, _PregnancyCow cow) {
    final dateFmt = DateFormat('dd MMM, yyyy');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                'Delivery Details',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // Cow info row
              Row(
                children: [
                  // Avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildAnimalImage(
                      cow.imagePath,
                      width: 56,
                      height: 56,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cow.name,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F1DC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: const Color(0xFFD4B96A)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.sell_outlined,
                                      size: 11,
                                      color: Color(0xFFB8942C)),
                                  const SizedBox(width: 3),
                                  Text('Tag No.: ${cow.tagNo}',
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFB8942C))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Parity: ${cow.parity}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'No.: ${cow.no}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calf Status & Calf Gender
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.pets, size: 16, color: _kGreen),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Calf Status:',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.grey)),
                            Text(cow.calfStatus,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _kGreen)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.pets, size: 16, color: _kOlive),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Calf Gender:',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.grey)),
                            Text(cow.calfGender,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Total Days & Total Milk
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Days:',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.grey)),
                            Text('${cow.totalDays}',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.water_drop_outlined,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Milk:',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.grey)),
                            Text('${cow.totalMilk}',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Note
              if (cow.note.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cow.note,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              // Pregnant & Delivery date pills
              Row(
                children: [
                  _DatePill(
                    label: 'Pregnant',
                    date: cow.pregnantDate != null
                        ? dateFmt.format(cow.pregnantDate!)
                        : '-',
                    color: _kGreen,
                  ),
                  const SizedBox(width: 12),
                  _DatePill(
                    label: 'Delivery',
                    date: cow.deliveryDate != null
                        ? dateFmt.format(cow.deliveryDate!)
                        : '-',
                    color: _kOlive,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// 4. PARITY REPORT
// ============================================================
class ParityReportScreen extends StatefulWidget {
  const ParityReportScreen({super.key});

  @override
  State<ParityReportScreen> createState() => _ParityReportScreenState();
}

class _ParityReportScreenState extends State<ParityReportScreen> {
  _PregnancyCow? _selectedCow;
  String? _selectedCowId;
  bool _showDropdown = false;
  List<Map<String, dynamic>> _dropdownCows = [];
  List<_PregnancyCow> _parityItems = [];
  bool _isLoading = false;
  bool _isLoadingDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadDropdown();
  }

  Future<void> _loadDropdown() async {
    setState(() => _isLoadingDropdown = true);
    try {
      final cows = await sl<ApiService>().getParityAnimalsDropdown();
      if (!mounted) return;
      setState(() {
        _dropdownCows = cows.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoadingDropdown = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dropdownCows = [];
        _isLoadingDropdown = false;
      });
    }
  }

  Future<void> _loadParityReport() async {
    if (_selectedCowId == null) return;
    setState(() => _isLoading = true);
    try {
      final data = await sl<ApiService>().getBreedingParityReport(
        animalId: _selectedCowId!,
      );
      if (!mounted) return;
      final parsed = data
          .whereType<Map>()
          .map((item) => _PregnancyCow.fromParity(Map<String, dynamic>.from(item)))
          .toList();
      setState(() {
        _parityItems = parsed.isEmpty ? [_selectedCow!] : parsed;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _parityItems = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Parity Report',
          style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Animal Dropdown ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: () => setState(() {
                _showDropdown = !_showDropdown;
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
                        _selectedCow?.name ?? 'Select animal',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _selectedCow == null
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          // ── Search Dropdown ──────────────────────────────────
          if (_showDropdown)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: _isLoadingDropdown
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(color: _kOlive),
                                ),
                              )
                            : ListView(
                                shrinkWrap: true,
                                children: _dropdownCows
                              .map((raw) {
                                final cow = _PregnancyCow(
                                  name: _text(raw['name'], fallback: 'Unknown'),
                                  tagNo: _text(raw['tagNumber'], fallback: '-'),
                                  no: _text(raw['id'] ?? raw['_id']),
                                  imagePath: _text(
                                    raw['viewUrl'] ?? raw['photoUrl'] ?? raw['imageUrl'],
                                    fallback: 'assets/icons/cow_and_calf.png',
                                  ),
                                  parity: _toInt(raw['parity']),
                                  cowType: _text(raw['category'] ?? raw['type']),
                                );
                                return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedCow = cow;
                                            _selectedCowId = _text(raw['id'] ?? raw['_id']);
                                            _showDropdown = false;
                                          });
                                          _loadParityReport();
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 16),
                                          child: Center(
                                            child: Text(
                                              cow.name,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                              })
                          .toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Content (parity card) ──────────────────────────
          if (_selectedCow != null && !_showDropdown)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _kOlive))
                  : _parityItems.isEmpty
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
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total ${_parityItems.length} Parity',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 14),
                              ..._parityItems.map((cow) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _ParityCard(cow: cow),
                                  )),
                            ],
                          ),
                        ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED CARD WIDGETS
// ============================================================

// ── Pregnancy cow card (simple, with pregnant + delivery dates) ──
class _PregnancyCowCard extends StatelessWidget {
  final _PregnancyCow cow;
  const _PregnancyCowCard({required this.cow});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');
    return Container(
      decoration: _cardDeco(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildAnimalImage(cow.imagePath),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cow.name,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Parity: ${cow.parity}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1DC),
                            borderRadius: BorderRadius.circular(6),
                            border:
                                Border.all(color: const Color(0xFFD4B96A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sell_outlined,
                                  size: 11, color: Color(0xFFB8942C)),
                              const SizedBox(width: 3),
                              Text('Tag No.: ${cow.tagNo}',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFB8942C))),
                            ],
                          ),
                        ),
                        Text(
                          'No.: ${cow.no}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Pregnant & Delivery dates
          Row(
            children: [
              // Pregnant
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: _kGreen),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pregnant',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey)),
                      Text(
                        cow.pregnantDate != null
                            ? dateFmt.format(cow.pregnantDate!)
                            : '-',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 30),
              // Delivery
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: _kOlive),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey)),
                      Text(
                        cow.deliveryDate != null
                            ? dateFmt.format(cow.deliveryDate!)
                            : '-',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Delivery cow card (used in Date Wise Delivery Report) ──
class _DeliveryCowCard extends StatelessWidget {
  final _PregnancyCow cow;
  const _DeliveryCowCard({required this.cow});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');
    return Container(
      decoration: _cardDeco(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildAnimalImage(cow.imagePath),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cow.name,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Parity: ${cow.parity}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1DC),
                            borderRadius: BorderRadius.circular(6),
                            border:
                                Border.all(color: const Color(0xFFD4B96A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sell_outlined,
                                  size: 11, color: Color(0xFFB8942C)),
                              const SizedBox(width: 3),
                              Text('Tag No.: ${cow.tagNo}',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFB8942C))),
                            ],
                          ),
                        ),
                        Text(
                          'No.: ${cow.no}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Pregnant & Delivery dates
          Row(
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: _kGreen),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pregnant',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey)),
                      Text(
                        cow.pregnantDate != null
                            ? dateFmt.format(cow.pregnantDate!)
                            : '-',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: _kOlive),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey)),
                      Text(
                        cow.deliveryDate != null
                            ? dateFmt.format(cow.deliveryDate!)
                            : '-',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Parity card (detailed, matches iPhone 16 - 73.png) ──
class _ParityCard extends StatelessWidget {
  final _PregnancyCow cow;
  const _ParityCard({required this.cow});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');
    return Container(
      decoration: _cardDeco(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top: Image + Name/Tag/Parity ───────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with type badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildAnimalImage(
                      cow.imagePath,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  if (cow.cowType.isNotEmpty)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kOlive,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cow.cowType,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cow.name,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Parity: ${cow.parity}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Alive badge + AI label
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _kGreen.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Alive',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _kGreen),
                          ),
                        ),
                        const Spacer(),
                        if (cow.breedType.isNotEmpty)
                          Text(
                            cow.breedType,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _kOlive),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Total Days / Total Milk ────────────────────
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Total Days:',
                  value: '${cow.totalDays}',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.water_drop_outlined,
                  label: 'Total Milk:',
                  value: '${cow.totalMilk}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Pregnant / Delivery ────────────────────────
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.favorite_outline,
                  label: 'Pregnant:',
                  value: cow.pregnantDate != null
                      ? dateFmt.format(cow.pregnantDate!)
                      : '-',
                  valueColor: Colors.black87,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Delivery:',
                  value: cow.deliveryDate != null
                      ? dateFmt.format(cow.deliveryDate!)
                      : '-',
                  valueColor: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Bull Name / Tag No ────────────────────────
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.pets,
                  label: 'Bull Name:',
                  value: cow.bullName,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.sell_outlined,
                  label: 'Tag No.:',
                  value: cow.bullTagNo.isNotEmpty ? cow.bullTagNo : '-',
                ),
              ),
            ],
          ),

          // ── Note ──────────────────────────────────────
          if (cow.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.description_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text('Note:',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              cow.note,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Small info item (icon + label + value) ──
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.grey.shade500)),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Date pill widget (green/olive pill with label + date) ──
class _DatePill extends StatelessWidget {
  final String label;
  final String date;
  final Color color;

  const _DatePill({
    required this.label,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );
  }
}
