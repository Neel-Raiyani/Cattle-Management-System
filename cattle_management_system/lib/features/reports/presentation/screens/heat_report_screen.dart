import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';
import '../../../heat_record/domain/entities/heat_record.dart';

// ============================================================
// CONSTANTS
// ============================================================
const _kOlive = Color(0xFF99AA5A);
const _kRed   = Color(0xFFE53935);
const _kGreen  = Color(0xFF4CAF50);

// ============================================================
// MOCK DATA MODELS
// ============================================================

class _HeatCow {
  final String name;
  final String tagNo;
  final String no;
  final String imagePath; // asset path
  final List<_HeatRecord> records;
  const _HeatCow({
    required this.name,
    required this.tagNo,
    required this.no,
    required this.imagePath,
    required this.records,
  });
}

class _HeatRecord {
  final DateTime date;
  final int parity;
  final bool isBreed; // true = Breed, false = Not Breed
  final int days;
  final String note;
  const _HeatRecord({
    required this.date,
    required this.parity,
    required this.isBreed,
    required this.days,
    required this.note,
  });
}

// ── Static mock cows with heat records ────────────────────────
final _heatCows = <_HeatCow>[
  _HeatCow(
    name: 'મેઘા',
    tagNo: '101',
    no: '0001',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _HeatRecord(
        date: DateTime(2025, 9, 9),
        parity: 0,
        isBreed: true,
        days: 0,
        note: 'raz ni milto nathi noto',
      ),
      _HeatRecord(
        date: DateTime(2025, 9, 9),
        parity: 1,
        isBreed: true,
        days: 0,
        note: 'raz ni milto nathi noto',
      ),
    ],
  ),
  _HeatCow(
    name: 'ઢિભા',
    tagNo: '106',
    no: '0005',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _HeatRecord(
        date: DateTime(2025, 9, 28),
        parity: 1,
        isBreed: false,
        days: 0,
        note: 'ઓવ્યુ લઈ ૧-૨ ડોઝ (૪૦-૦૦) થઈ ગઈ/ અઘ઼ ઓળ઼ ભ઼ ભindle',
      ),
      _HeatRecord(
        date: DateTime(2025, 9, 28),
        parity: 1,
        isBreed: true,
        days: 0,
        note: 'ni talpadi',
      ),
      _HeatRecord(
        date: DateTime(2025, 11, 22),
        parity: 1,
        isBreed: false,
        days: 35,
        note: 'bandi taripathi',
      ),
    ],
  ),
  _HeatCow(
    name: 'રાધા',
    tagNo: '104',
    no: '0004',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _HeatRecord(
        date: DateTime(2025, 11, 15),
        parity: 0,
        isBreed: false,
        days: 0,
        note: 'તારે ૪ જ-ઊ-સ-ભ-ઊ-ઈ સ-ભ-ઈ-ઊ-ભ-ઈ-ઈ-ભ-ઈ-ઊ-ો-ઈ-ઈ-ો-ો-ઈ-ઈ-ો-ઈ-ો-ઈ-ો-ો-ઈ-ો-ો-ો-ો-ો-ઈ-ઈ-ો-ો-ઈ-ઈ-ો-ો-ો-ો-ો-ો',
      ),
    ],
  ),
  _HeatCow(
    name: 'કલ્યાણી',
    tagNo: '102',
    no: '0002',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [],
  ),
  _HeatCow(
    name: 'કાવેરી',
    tagNo: '103',
    no: '0003',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [],
  ),
  _HeatCow(
    name: 'પારેવ',
    tagNo: '105',
    no: '0006',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [],
  ),
  _HeatCow(
    name: 'અશ્વિની',
    tagNo: '107',
    no: '0007',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [],
  ),
  _HeatCow(
    name: 'તુલસી',
    tagNo: '108',
    no: '0008',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [],
  ),
];

// ============================================================
// HELPERS
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
// 1. HUB  –  Heat Record Report
// ============================================================
class HeatReportHubScreen extends StatelessWidget {
  const HeatReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Heat Record Report',
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
            label: 'Cow Wise Heat Report',
            leadingIcon: Image.asset(
              'assets/icons/mother_cow.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.pets, color: _kOlive),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CowWiseHeatReportScreen()),
            ),
          ),
          _HubTile(
            label: 'Date Wise Heat Record Report',
            leadingIcon: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF5B8FD4),
              size: 28,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DateWiseHeatRecordScreen()),
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
// 2. COW WISE HEAT REPORT
// ============================================================
class CowWiseHeatReportScreen extends StatefulWidget {
  const CowWiseHeatReportScreen({super.key});

  @override
  State<CowWiseHeatReportScreen> createState() =>
      _CowWiseHeatReportScreenState();
}

class _CowWiseHeatReportScreenState
    extends State<CowWiseHeatReportScreen> {
  List<_HeatCow> _cows = [];
  _HeatCow? _selectedCow;
  bool _showDropdown = false;
  bool _isLoading = true;
  String? _error;
  String _searchQ = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCows();
  }

  Future<void> _fetchCows() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cows = await sl<ApiService>().getCows();
      final mapped = cows.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return _HeatCow(
          name: map['name']?.toString() ?? 'Unknown',
          tagNo: map['tagNumber']?.toString() ?? '-',
          no: map['animalNumber']?.toString().isNotEmpty == true
              ? map['animalNumber'].toString()
              : '-',
          imagePath: 'assets/icons/cow_and_calf.png',
          records: const [],
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _cows = mapped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load cows';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectCow(_HeatCow cow) async {
    setState(() {
      _selectedCow = cow;
      _showDropdown = false;
      _searchCtrl.clear();
      _searchQ = '';
      _isLoading = true;
      _error = null;
    });

    try {
      final report = await sl<ApiService>().getHeatReport();
      final records = report
          .map((item) => HeatRecord.fromJson(Map<String, dynamic>.from(item as Map)))
          .where((record) {
            final matchesTag =
                record.cowTagNumber.trim().toLowerCase() == cow.tagNo.trim().toLowerCase();
            final matchesName =
                record.cowName.trim().toLowerCase() == cow.name.trim().toLowerCase();
            return matchesTag || matchesName;
          })
          .map(
            (record) => _HeatRecord(
              date: record.heatDate,
              parity: record.parity,
              isBreed: record.isConceived,
              days: 0,
              note: record.note ?? '',
            ),
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _selectedCow = _HeatCow(
          name: cow.name,
          tagNo: cow.tagNo,
          no: cow.no,
          imagePath: cow.imagePath,
          records: records,
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedCow = cow;
        _error = 'Failed to load heat records';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_HeatCow> get _filtered {
    if (_searchQ.isEmpty) return _cows;
    return _cows
        .where((c) =>
            c.name.toLowerCase().contains(_searchQ.toLowerCase()) ||
            c.tagNo.toLowerCase().contains(_searchQ.toLowerCase()) ||
            c.no.toLowerCase().contains(_searchQ.toLowerCase()))
        .toList();
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
          'Cow Wise Heat Report',
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
                if (!_showDropdown) {
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

          // ── Search Dropdown (overlaps with Expanded area) ──
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
                      // Search box
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12),
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
                                  style: GoogleFonts.inter(
                                      fontSize: 13),
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
                      // Cow list
                      if (_isLoading)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(color: _kOlive),
                          ),
                        )
                      else if (_error != null && _filtered.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              _error!,
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView(
                          shrinkWrap: true,
                          children: _filtered
                              .map((c) => Column(
                                    children: [
                                      InkWell(
                                        onTap: () => _selectCow(c),
                                        child: Padding(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              vertical: 12,
                                              horizontal: 16),
                                          child: Center(
                                            child: Text(
                                              c.name,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
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
              ),
            ),

          // ── Content (cow card + timeline) ────────────────────
          if (_selectedCow != null && !_showDropdown)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CowCard(cow: _selectedCow!),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: _kOlive),
                        ),
                      )
                    else if (_error != null && _selectedCow!.records.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            _error!,
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                    else if (_selectedCow!.records.isEmpty)
                      Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No heat records found',
                            style: GoogleFonts.poppins(
                                color: Colors.grey, fontSize: 15),
                          ),
                        ),
                      )
                    else
                      _HeatTimeline(records: _selectedCow!.records),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Cow card ────────────────────────────────────────────────
class _CowCard extends StatelessWidget {
  final _HeatCow cow;
  const _CowCard({required this.cow});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDeco(),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              cow.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: const Color(0xFFF5F6F7),
                child: const Icon(Icons.no_photography_outlined,
                    size: 36, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cow.name,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                // Tag row
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
                const SizedBox(height: 4),
                Text(
                  'No. ${cow.no}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Heat timeline ─────────────────────────────────────────
// Uses a Stack-based approach so the grey vertical line runs the full
// height of every card, exactly matching the mockup design.
class _HeatTimeline extends StatelessWidget {
  final List<_HeatRecord> records;
  const _HeatTimeline({required this.records});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');

    return Column(
      children: List.generate(records.length, (i) {
        final r       = records[i];
        final isLast  = i == records.length - 1;
        final dotColor = r.isBreed ? _kGreen : _kRed;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
          // IntrinsicHeight gives the Row a finite height (= card's natural
          // height) so CrossAxisAlignment.stretch works on the left Stack
          // column without receiving an infinite h constraint.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left: dot + full-height line ──────────────
              SizedBox(
                width: 32,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Full-height grey vertical line (behind dot)
                    if (!isLast)
                      Positioned(
                        top: 0,
                        bottom: -14, // extend into bottom padding
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 2,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                    // Bullseye dot: white ring + coloured fill
                    Positioned(
                      top: 14,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                              color: dotColor, width: 2),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Right: record card ─────────────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date + Parity pill
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fmt.format(r.date),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                color: Colors.black87),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Parity: ${r.parity}',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Breed status + Days badge
                      Row(
                        children: [
                          // Breed / Not Breed — colored bold text
                          Text(
                            r.isBreed ? 'Breed' : 'Not Breed',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: dotColor),
                          ),
                          const SizedBox(width: 10),
                          // Days badge — colored border + text
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: dotColor.withOpacity(0.5),
                                  width: 1.2),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${r.days} Days',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: dotColor),
                            ),
                          ),
                        ],
                      ),

                      // Note
                      if (r.note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          r.note,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            ),   // end Row
          ),     // end IntrinsicHeight
        );
      }),
    );
  }
}


// ============================================================
// 3. DATE WISE HEAT RECORD
// ============================================================
class DateWiseHeatRecordScreen extends StatefulWidget {
  const DateWiseHeatRecordScreen({super.key});

  @override
  State<DateWiseHeatRecordScreen> createState() =>
      _DateWiseHeatRecordScreenState();
}

class _DateWiseHeatRecordScreenState
    extends State<DateWiseHeatRecordScreen> {
  DateTime _fromDate = DateTime(2025, 11, 30);
  DateTime _toDate   = DateTime(2025, 12, 30);

  // Cows that have at least one heat record within [_fromDate, _toDate]
  List<_HeatCow> get _filtered {
    return _heatCows.where((cow) {
      return cow.records.any((r) =>
          !r.date.isBefore(_fromDate) && !r.date.isAfter(_toDate));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');
    final results = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Date Wise Heat Record',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
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
                      if (d != null) setState(() => _fromDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F6F7), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateFmt.format(_fromDate), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
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
                      if (d != null) setState(() => _toDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F6F7), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateFmt.format(_toDate), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Total count ─────────────────────────────────
            Text(
              'Total: ${results.length}',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // ── Cow cards ────────────────────────────────────
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        'No records in selected range',
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 15),
                      ),
                    )
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final cow = results[i];
                        // Use first record in range for the detail view
                        final rec = cow.records.firstWhere(
                          (r) =>
                              !r.date.isBefore(_fromDate) &&
                              !r.date.isAfter(_toDate),
                        );
                        return _DateWiseCowCard(
                            cow: cow, record: rec);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateWiseCowCard extends StatelessWidget {
  final _HeatCow cow;
  final _HeatRecord record;
  const _DateWiseCowCard(
      {required this.cow, required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');
    return Container(
      decoration: _cardDeco(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cow header row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  cow.imagePath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFFF5F6F7),
                    child: const Icon(
                        Icons.no_photography_outlined,
                        size: 28,
                        color: Colors.grey),
                  ),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1DC),
                            borderRadius:
                                BorderRadius.circular(5),
                            border: Border.all(
                                color:
                                    const Color(0xFFD4B96A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sell_outlined,
                                  size: 10,
                                  color: Color(0xFFB8942C)),
                              const SizedBox(width: 3),
                              Text(
                                'Tag No.: ${cow.tagNo}',
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: const Color(
                                        0xFFB8942C)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No. ${cow.no}',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey),
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

          // Detail rows
          _DetailRow(
            icon: Icons.circle_outlined,
            iconColor: Colors.grey,
            label: 'Parity',
            value: record.parity.toString(),
            valueColor: Colors.black87,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.favorite_border_rounded,
            iconColor: _kGreen,
            label: 'Breeding Status',
            value: record.isBreed ? 'Conceived' : 'Not Conceived',
            valueColor: record.isBreed ? _kGreen : _kRed,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            iconColor: Colors.blue,
            label: 'Heat Date',
            value: dateFmt.format(record.date),
            valueColor: Colors.black87,
          ),
          if (record.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.notes_rounded,
              iconColor: Colors.orange,
              label: 'Note',
              value: record.note,
              valueColor: Colors.black54,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 13,
                color: valueColor,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
