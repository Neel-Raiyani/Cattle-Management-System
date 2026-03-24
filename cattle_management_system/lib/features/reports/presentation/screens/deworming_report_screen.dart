import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ============================================================
// CONSTANTS & COLORS
// ============================================================
const _kOlive = Color(0xFF99AA5A);
const _kLightGrey = Color(0xFFF5F6F7);

class _NoDataFound extends StatelessWidget {
  const _NoDataFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/no_data_found.png', width: 200),
          const SizedBox(height: 16),
          Text(
            'No Data Found',
            style: GoogleFonts.poppins(
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
// MODELS
// ============================================================

class _DewormingRecord {
  final DateTime date;
  final String medicine; // e.g. "Panacure 3gm (MSD)"
  final String doctor; // e.g. "Dr. uday"
  final String age; // e.g. "-"
  final String lastDose; // e.g. "-"
  final DateTime nextDose;
  final String dosage; // e.g. "Tablet (1 Qty.)"

  const _DewormingRecord({
    required this.date,
    required this.medicine,
    required this.doctor,
    this.age = '-',
    this.lastDose = '-',
    required this.nextDose,
    this.dosage = 'Tablet (1 Qty.)',
  });
}

class _DewormingAnimal {
  final String name;
  final String tagNo;
  final String no;
  final String type; // 'Cow' or 'Bull'
  final String imagePath;
  final List<_DewormingRecord> records;

  const _DewormingAnimal({
    required this.name,
    required this.tagNo,
    required this.no,
    required this.type,
    required this.imagePath,
    required this.records,
  });
}

// ============================================================
// MOCK DATA
// ============================================================

final _dewormingAnimals = <_DewormingAnimal>[
  _DewormingAnimal(
    name: 'ક્રિષ્ના',
    tagNo: '106',
    no: '0005',
    type: 'Cow',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _DewormingRecord(
        date: DateTime(2025, 9, 4),
        medicine: 'Panacure 3gm (MSD)',
        doctor: 'Dr. uday',
        nextDose: DateTime(2026, 1, 4),
      ),
      _DewormingRecord(
        date: DateTime(2025, 12, 30),
        medicine: 'MSD Panacur Boli',
        doctor: 'Self',
        nextDose: DateTime(2026, 3, 30),
      ),
      _DewormingRecord(
        date: DateTime(2025, 9, 4),
        medicine: 'Panacure 3gm (MSD)',
        doctor: 'Dr. uday',
        nextDose: DateTime(2026, 1, 4),
      ),
    ],
  ),
  _DewormingAnimal(
    name: 'મેઘા',
    tagNo: '101',
    no: '0001',
    type: 'Cow',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _DewormingRecord(
        date: DateTime(2025, 9, 4),
        medicine: 'Panacure 3gm (MSD)',
        doctor: 'Dr. uday',
        nextDose: DateTime(2026, 1, 4),
      ),
    ],
  ),
  _DewormingAnimal(
    name: 'અશ્વિની',
    tagNo: '103',
    no: '0002',
    type: 'Cow',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _DewormingRecord(
        date: DateTime(2025, 9, 4),
        dosage: 'Tablet (1.5 Qty.)',
        medicine: 'Panacure 3gm (MSD)',
        doctor: 'Dr. uday',
        nextDose: DateTime(2026, 1, 4),
      ),
    ],
  ),
  _DewormingAnimal(
    name: 'રાજા',
    tagNo: '201',
    no: '0010',
    type: 'Bull',
    imagePath: 'assets/icons/father_cow.png',
    records: [
      _DewormingRecord(
        date: DateTime(2025, 9, 10),
        medicine: 'Dewormer Max',
        doctor: 'Dr. uday',
        nextDose: DateTime(2026, 1, 10),
      ),
    ],
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
      color: Colors.grey.withOpacity(0.08),
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
// 1. DEWORMING REPORT HUB
// ============================================================

class DewormingReportHubScreen extends StatelessWidget {
  const DewormingReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Deworming Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HubTile(
            label: 'Animal Wise Deworming Report',
            leadingIcon: Image.asset(
              'assets/icons/mother_cow.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.pets, color: _kOlive),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnimalWiseDewormingReportScreen(),
              ),
            ),
          ),
          _HubTile(
            label: 'Date Wise Deworming Dose Report',
            leadingIcon: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF5B8FD4),
              size: 28,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DateWiseDewormingDoseReportScreen(),
              ),
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
  const _HubTile({required this.label, required this.onTap, this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDeco(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: leadingIcon != null
            ? SizedBox(width: 36, height: 36, child: leadingIcon)
            : null,
        title: Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: _kLightGrey,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

// ============================================================
// 2. ANIMAL WISE DEWORMING REPORT
// ============================================================

class AnimalWiseDewormingReportScreen extends StatefulWidget {
  const AnimalWiseDewormingReportScreen({super.key});

  @override
  State<AnimalWiseDewormingReportScreen> createState() =>
      _AnimalWiseDewormingReportScreenState();
}

class _AnimalWiseDewormingReportScreenState
    extends State<AnimalWiseDewormingReportScreen> {
  String? _selectedType; // 'Cow' or 'Bull'
  _DewormingAnimal? _selectedAnimal;
  bool _showTypeDropdown = false;
  bool _showAnimalDropdown = false;

  final _searchCtrl = TextEditingController();
  String _searchQ = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_DewormingAnimal> get _filteredAnimals {
    var list = _dewormingAnimals;
    if (_selectedType != null) {
      list = list.where((a) => a.type == _selectedType).toList();
    }
    if (_searchQ.isNotEmpty) {
      list = list
          .where((a) => a.name.toLowerCase().contains(_searchQ.toLowerCase()))
          .toList();
    }
    return list;
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
          'Animal Wise Deworming Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Dropdown Selectors ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                // Animal Type Dropdown
                Expanded(
                  child: _CustomDropdown(
                    label: _selectedType ?? 'Animal Type',
                    isOpen: _showTypeDropdown,
                    onTap: () => setState(() {
                      _showTypeDropdown = !_showTypeDropdown;
                      _showAnimalDropdown = false;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                // Select Animal Dropdown
                Expanded(
                  child: _CustomDropdown(
                    label: _selectedAnimal?.name ?? 'Select Animal',
                    isOpen: _showAnimalDropdown,
                    onTap: () => setState(() {
                      _showAnimalDropdown = !_showAnimalDropdown;
                      _showTypeDropdown = false;
                      _searchQ = '';
                      _searchCtrl.clear();
                    }),
                  ),
                ),
              ],
            ),
          ),

          // ── Dropdown Overlays (Mocked as widgets in the column) ──
          if (_showTypeDropdown)
            Flexible(
              child: _DropdownListOverlay(
                items: const ['Cow', 'Bull'],
                onSelect: (val) => setState(() {
                  _selectedType = val;
                  _showTypeDropdown = false;
                  _selectedAnimal = null; // Reset animal when type changes
                }),
              ),
            )
          else if (_showAnimalDropdown)
            Flexible(
              child: _DropdownListOverlay(
                items: _filteredAnimals.map((a) => a.name).toList(),
                hasSearch: true,
                searchCtrl: _searchCtrl,
                onSearchChanged: (v) => setState(() => _searchQ = v),
                onSelect: (name) => setState(() {
                  _selectedAnimal = _dewormingAnimals.firstWhere(
                    (a) => a.name == name,
                  );
                  _showAnimalDropdown = false;
                }),
              ),
            ),

          // ── Content ──────────────────────────────────────────
          if (!_showTypeDropdown && !_showAnimalDropdown)
            Expanded(
              child: _selectedAnimal == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _selectedAnimal!.records.isEmpty
                          ? const _NoDataFound()
                          : Column(
                              children: [
                                _AnimalProfileCard(animal: _selectedAnimal!),
                                const SizedBox(height: 16),
                                ..._selectedAnimal!.records.map(
                                  (r) => _DewormingRecordCard(record: r),
                                ),
                              ],
                            ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String label;
  final bool isOpen;
  final VoidCallback onTap;

  const _CustomDropdown({
    required this.label,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _kLightGrey,
          borderRadius: BorderRadius.circular(10),
          border: isOpen ? Border.all(color: Colors.grey.shade400) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownListOverlay extends StatelessWidget {
  final List<String> items;
  final Function(String) onSelect;
  final bool hasSearch;
  final TextEditingController? searchCtrl;
  final ValueChanged<String>? onSearchChanged;

  const _DropdownListOverlay({
    required this.items,
    required this.onSelect,
    this.hasSearch = false,
    this.searchCtrl,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasSearch)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 22, color: Colors.grey.shade400),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        autofocus: true,
                        onChanged: onSearchChanged,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search here...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                          fillColor: Colors.transparent,
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Flexible(
            child: items.isEmpty
                ? const SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: _NoDataFound(),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) => InkWell(
                      onTap: () => onSelect(items[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            items[i],
                            style: GoogleFonts.poppins(fontSize: 14),
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
}

// ============================================================
// 3. DATE WISE DEWORMING DOSE REPORT
// ============================================================

class DateWiseDewormingDoseReportScreen extends StatefulWidget {
  const DateWiseDewormingDoseReportScreen({super.key});

  @override
  State<DateWiseDewormingDoseReportScreen> createState() =>
      _DateWiseDewormingDoseReportScreenState();
}

class _DateWiseDewormingDoseReportScreenState
    extends State<DateWiseDewormingDoseReportScreen> {
  DateTime _fromDate = DateTime(2025, 6, 30);
  DateTime _toDate = DateTime(2025, 12, 30);

  List<_DewormingAnimal> get _filtered {
    return _dewormingAnimals.where((a) {
      return a.records.any(
        (r) => !r.date.isBefore(_fromDate) && !r.date.isAfter(_toDate),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cows = _filtered;
    final fmt = DateFormat('dd MMM, yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Date Wise Deworming Dose Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: _kLightGrey,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _fromDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: _kOlive,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (d != null) {
                          setState(() {
                            _fromDate = d;
                            if (_toDate.isBefore(_fromDate))
                              _toDate = _fromDate;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fmt.format(_fromDate),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: _kOlive,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'to',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: _kLightGrey,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _toDate,
                          firstDate: _fromDate,
                          lastDate: DateTime(2100),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: _kOlive,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (d != null) setState(() => _toDate = d);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fmt.format(_toDate),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: _kOlive,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Total ${cows.length} Animal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          Expanded(
            child: cows.isEmpty
                ? const _NoDataFound()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) {
                      final c = cows[i];
                      // For showing in "Date Wise", we pick the latest record in range or just first one
                      final r = c.records.first;
                      return _DateWiseAnimalDewormingCard(animal: c, record: r);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARDS & COMPONENTS
// ============================================================

class _AnimalProfileCard extends StatelessWidget {
  final _DewormingAnimal animal;
  const _AnimalProfileCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDeco(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              animal.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _kLightGrey,
                width: 80,
                height: 80,
                child: const Icon(Icons.pets),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F1DC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFD4B96A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sell_outlined,
                        size: 11,
                        color: Color(0xFFB8942C),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Tag No.: ${animal.tagNo}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB8942C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No. : ${animal.no}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DewormingRecordCard extends StatelessWidget {
  final _DewormingRecord record;
  const _DewormingRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _kLightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      fmt.format(record.date),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.calendar_month, size: 14),
                  ],
                ),
              ),
              Text(
                record.dosage,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kOlive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailLine(icon: Icons.pets, label: 'Age:', value: record.age),
          _DetailLine(
            icon: Icons.business,
            label: 'Company Name:',
            value: record.medicine,
          ),
          _DetailLine(
            icon: Icons.person,
            label: 'Doctor Name:',
            value: record.doctor,
          ),
          _DetailLine(
            icon: Icons.calendar_today_outlined,
            label: 'Last Dose Date:',
            value: record.lastDose,
          ),
          _DetailLine(
            icon: Icons.update,
            label: 'Next Dose Date:',
            value: fmt.format(record.nextDose),
          ),
        ],
      ),
    );
  }
}

class _DateWiseAnimalDewormingCard extends StatelessWidget {
  final _DewormingAnimal animal;
  final _DewormingRecord record;
  const _DateWiseAnimalDewormingCard({
    required this.animal,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _kLightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      fmt.format(record.date),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.calendar_month, size: 14),
                  ],
                ),
              ),
              Text(
                record.dosage,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kOlive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Inner Animal Card
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    animal.imagePath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            animal.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '- ${animal.type}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F1DC),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFD4B96A),
                              ),
                            ),
                            child: Text(
                              'Tag No.: ${animal.tagNo}',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: const Color(0xFFB8942C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'No. : ${animal.no}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DetailLine(icon: Icons.pets, label: 'Age:', value: record.age),
          _DetailLine(
            icon: Icons.business,
            label: 'Company Name:',
            value: record.medicine,
          ),
          _DetailLine(
            icon: Icons.person,
            label: 'Doctor Name:',
            value: record.doctor,
          ),
          _DetailLine(
            icon: Icons.calendar_today_outlined,
            label: 'Last Dose Date:',
            value: record.lastDose,
          ),
          _DetailLine(
            icon: Icons.update,
            label: 'Next Dose Date:',
            value: fmt.format(record.nextDose),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
