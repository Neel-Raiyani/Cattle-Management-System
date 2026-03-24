import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';

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

class _LabTestRecord {
  final DateTime sampleDate;
  final DateTime resultDate;
  final String testName;
  final String reportDescription;

  const _LabTestRecord({
    required this.sampleDate,
    required this.resultDate,
    required this.testName,
    required this.reportDescription,
  });
}

class _LabAnimal {
  final String name;
  final String tagNo;
  final String no;
  final String type; // 'Cow' or 'Bull'
  final String imagePath;
  final List<_LabTestRecord> records;

  const _LabAnimal({
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

final List<String> _labTestCategories = [
  'Hematology (CBC) — હેમેટોલોજી - રક્ત તપાસ',
  'Biochemistry — બાયોકેમિસ્ટ્રી - રસાયણિક તપાસ',
  'Urine Examination — મૂત્ર તપાસ',
  'Faecal Examination — મલ તપાસ',
  'Skin Scraping — ત્વચા ખંજવાળ તપાસ',
  'Panel Test by Dry Biochemistry — ડ્રાય બાયોકેમિસ્ટ્રી પેનલ ટેસ્ટ',
  'Allergen Special Test — એલર્જી વિશેષ પરીક્ષણ',
  'Immuno Canine VacciCheck — ઇમ્યુનો કેનાઇન વેક્સીચેક ટેસ્ટ',
  'Microbial Culture — માઇક્રોબિયલ કલ્ચર',
];

final _mockAnimals = [
  _LabAnimal(
    name: 'ક્રિષ્ના',
    tagNo: '106',
    no: '0005',
    type: 'Cow',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _LabTestRecord(
        sampleDate: DateTime(2025, 10, 16),
        resultDate: DateTime(2025, 10, 18),
        testName: 'Hematology (CBC) — હેમેટોલોજી - રક્ત તપાસ',
        reportDescription:
            'રક્તમાં હિમોગ્લોબિનનું પ્રમાણ સામાન્ય છે. શ્વેત કણોની સંખ્યામાં થોડો વધારો જોવા મળ્યો છે જે હળવા ચેપની નિશાની હોઈ શકે છે.',
      ),
    ],
  ),
  _LabAnimal(
    name: 'ઢિભા',
    tagNo: '706',
    no: '6006',
    type: 'Cow',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _LabTestRecord(
        sampleDate: DateTime(2025, 10, 16),
        resultDate: DateTime(2025, 10, 20),
        testName: 'Urine Examination — મૂત્ર તપાસ',
        reportDescription:
            'મૂત્રના નમૂનામાં પ્રોટીનનું પ્રમાણ સામાન્ય છે. ક્ષારોની હાજરી જોવા મળી નથી. વધારાના રિપોર્ટ માટે આવતા સપ્તાહે ફરીથી તપાસ કરવાની સલાહ છે.',
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
// HUB SCREEN
// ============================================================

class LabTestReportHubScreen extends StatelessWidget {
  const LabTestReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Lab Test Report',
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
            label: 'Animal Wise Lab Test Report',
            leadingIcon: Image.asset(
              'assets/icons/mother_cow.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.pets, color: _kOlive),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnimalWiseLabTestReportScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _HubTile(
            label: 'Date Wise Lab Test Report',
            leadingIcon: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF5B8FD4),
              size: 28,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DateWiseLabTestReportScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _HubTile(
            label: 'Lab Test Wise Report',
            leadingIcon: const Icon(
              Icons.science_outlined,
              color: Color(0xFF607D8B),
              size: 28,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LabTestWiseReportScreen(),
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
      decoration: _cardDeco(),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
// 1. ANIMAL WISE LAB TEST REPORT
// ============================================================

class AnimalWiseLabTestReportScreen extends StatefulWidget {
  const AnimalWiseLabTestReportScreen({super.key});

  @override
  State<AnimalWiseLabTestReportScreen> createState() =>
      _AnimalWiseLabTestReportScreenState();
}

class _AnimalWiseLabTestReportScreenState
    extends State<AnimalWiseLabTestReportScreen> {
  String? _animalType;
  _LabAnimal? _selectedAnimal;
  bool _showTypeDropdown = false;
  bool _showAnimalDropdown = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
          'Animal Wise Lab Test Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _CustomDropdown(
                    label: _animalType ?? 'Animal Type',
                    isOpen: _showTypeDropdown,
                    onTap: () => setState(() {
                      _showTypeDropdown = !_showTypeDropdown;
                      _showAnimalDropdown = false;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CustomDropdown(
                    label: _selectedAnimal?.name ?? 'Select Animal',
                    isOpen: _showAnimalDropdown,
                    onTap: () => setState(() {
                      _showAnimalDropdown = !_showAnimalDropdown;
                      _showTypeDropdown = false;
                      _searchQuery = '';
                      _searchCtrl.clear();
                    }),
                  ),
                ),
              ],
            ),
          ),
          if (_showTypeDropdown)
            Flexible(
              child: _DropdownListOverlay(
                items: const ['Cow', 'Bull'],
                onSelect: (val) => setState(() {
                  _animalType = val;
                  _showTypeDropdown = false;
                  _selectedAnimal = null;
                }),
              ),
            )
          else if (_showAnimalDropdown)
            Flexible(
              child: _DropdownListOverlay(
                items: _mockAnimals
                    .where((a) => a.type == _animalType)
                    .where(
                      (a) =>
                          a.name.contains(_searchQuery) ||
                          a.tagNo.contains(_searchQuery),
                    )
                    .map((a) => a.name)
                    .toList(),
                hasSearch: true,
                searchCtrl: _searchCtrl,
                onSearchChanged: (v) => setState(() => _searchQuery = v),
                onSelect: (val) {
                  setState(() {
                    _selectedAnimal = _mockAnimals.firstWhere(
                      (a) => a.name == val,
                    );
                    _showAnimalDropdown = false;
                  });
                },
              ),
            )
          else ...[
            if (_selectedAnimal != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ${_selectedAnimal!.records.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnimalHeader(animal: _selectedAnimal!),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: _selectedAnimal!.records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _LabTestCard(record: _selectedAnimal!.records[i]),
                ),
              ),
            ] else
              const Expanded(child: _NoDataFound()),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// 2. DATE WISE LAB TEST REPORT
// ============================================================

class DateWiseLabTestReportScreen extends StatefulWidget {
  const DateWiseLabTestReportScreen({super.key});

  @override
  State<DateWiseLabTestReportScreen> createState() =>
      _DateWiseLabTestReportScreenState();
}

class _DateWiseLabTestReportScreenState
    extends State<DateWiseLabTestReportScreen> {
  DateTime _fromDate = DateTime(2025, 11, 30);
  DateTime _toDate = DateTime(2025, 12, 30);

  List<Map<String, dynamic>> get _filteredData {
    List<Map<String, dynamic>> filtered = [];
    for (var animal in _mockAnimals) {
      for (var record in animal.records) {
        if (!record.sampleDate.isBefore(_fromDate) &&
            !record.sampleDate.isAfter(_toDate)) {
          filtered.add({'animal': animal, 'record': record});
        }
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');
    final results = _filteredData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Date Wise Lab Test Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
                              dateFmt.format(_fromDate),
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
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
                              dateFmt.format(_toDate),
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
            const SizedBox(height: 20),
            Text(
              'Total ${results.length} Animals',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: results.isEmpty
                  ? const _NoDataFound()
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final animal = results[i]['animal'] as _LabAnimal;
                        final record = results[i]['record'] as _LabTestRecord;
                        return Column(
                          children: [
                            _AnimalHeader(animal: animal),
                            const SizedBox(height: 8),
                            _LabTestCard(record: record),
                          ],
                        );
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
// 3. LAB TEST WISE REPORT
// ============================================================

class LabTestWiseReportScreen extends StatefulWidget {
  const LabTestWiseReportScreen({super.key});

  @override
  State<LabTestWiseReportScreen> createState() =>
      _LabTestWiseReportScreenState();
}

class _LabTestWiseReportScreenState extends State<LabTestWiseReportScreen> {
  String? _selectedCategory;
  bool _showCategoryDropdown = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  List<String> _dynamicLabCategories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchLabMasters();
  }

  Future<void> _fetchLabMasters() async {
    try {
      final masters = await sl<ApiService>().getLabTestTypes();
      if (mounted) {
        setState(() {
          _dynamicLabCategories = masters.map((m) {
            final name = m['name'] ?? 'Unknown';
            final localName = m['localName'] != null ? ' — ${m['localName']}' : '';
            return '$name$localName';
          }).toList();
          if (_dynamicLabCategories.isEmpty) {
            _dynamicLabCategories = _labTestCategories;
          }
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dynamicLabCategories = _labTestCategories;
          _isLoadingCategories = false;
        });
      }
    }
  }


  List<Map<String, dynamic>> get _filteredData {
    if (_selectedCategory == null) return [];
    List<Map<String, dynamic>> filtered = [];
    for (var animal in _mockAnimals) {
      for (var record in animal.records) {
        if (record.testName == _selectedCategory) {
          filtered.add({'animal': animal, 'record': record});
        }
      }
    }
    // Sort by resultDate descending
    filtered.sort((a, b) => (b['record'] as _LabTestRecord).resultDate.compareTo((a['record'] as _LabTestRecord).resultDate));
    return filtered;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCategories) {
       // logic can be added here if needed, but keeping it simple as per original
    }
    final results = _filteredData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Lab Test Wise Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _CustomDropdown(
              label: _selectedCategory ?? 'Select lab test',
              isOpen: _showCategoryDropdown,
              onTap: () => setState(() {
                _showCategoryDropdown = !_showCategoryDropdown;
                _searchQuery = '';
                _searchCtrl.clear();
              }),
            ),
          ),
          if (_showCategoryDropdown)
            Flexible(
              child: _DropdownListOverlay(
                items: _dynamicLabCategories
                    .where(
                      (c) =>
                          c.toLowerCase().contains(_searchQuery.toLowerCase()),
                    )
                    .toList(),
                hasSearch: true,
                searchCtrl: _searchCtrl,
                onSearchChanged: (v) => setState(() => _searchQuery = v),
                onSelect: (val) {
                  setState(() {
                    _selectedCategory = val;
                    _showCategoryDropdown = false;
                  });
                },
              ),
            )
          else ...[
            if (_selectedCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ${results.length} Animals',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            Expanded(
              child: results.isEmpty
                  ? const _NoDataFound()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final animal = results[i]['animal'] as _LabAnimal;
                        final record = results[i]['record'] as _LabTestRecord;
                        return Column(
                          children: [
                            _AnimalHeader(animal: animal),
                            const SizedBox(height: 8),
                            _LabTestCard(record: record),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// COMMON COMPONENTS
// ============================================================

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isOpen ? Colors.white : _kLightGrey,
          borderRadius: BorderRadius.circular(10),
          border: isOpen
              ? Border.all(color: Colors.grey.shade300, width: 1.5)
              : null,
          boxShadow: isOpen
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey,
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
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (ctx, i) => InkWell(
                      onTap: () => onSelect(items[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
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

class _AnimalHeader extends StatelessWidget {
  final _LabAnimal animal;
  const _AnimalHeader({required this.animal});

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
              width: 60,
              height: 60,
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _kOlive.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _kOlive),
                      ),
                      child: Text(
                        animal.type,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _kOlive,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.sell_outlined,
                      size: 14,
                      color: Color(0xFFD4B96A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tag No.: ${animal.tagNo}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'No.: ${animal.no}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
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
    );
  }
}

class _LabTestCard extends StatelessWidget {
  final _LabTestRecord record;
  const _LabTestCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.testName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _IconRow(
                icon: Icons.calendar_today_outlined,
                label: 'Sample',
                value: fmt.format(record.sampleDate),
              ),
              const SizedBox(width: 12),
              _IconRow(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Result',
                value: fmt.format(record.resultDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Report:',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            record.reportDescription,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _IconRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: _kLightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: _kOlive),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
