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

class _VaccinationRecord {
  final DateTime date;
  final String vaccine;
  final String dose; // e.g. "First Dose"
  final String remarks;

  const _VaccinationRecord({
    required this.date,
    required this.vaccine,
    required this.dose,
    this.remarks = 'ત્રિમાસિક રસીકરણ અભિયાન',
  });

  factory _VaccinationRecord.fromMap(Map<String, dynamic> raw) {
    return _VaccinationRecord(
      date: DateTime.tryParse((raw['doseDate'] ?? raw['date'] ?? '').toString()) ??
          DateTime.now(),
      vaccine: (raw['vaccineName'] ??
              raw['vaccine'] ??
              (raw['vaccineId'] is Map ? raw['vaccineId']['name'] : null) ??
              'Unknown')
          .toString(),
      dose: (raw['doseType'] ?? raw['dose'] ?? 'Dose').toString(),
      remarks: (raw['remark'] ?? raw['remarks'] ?? '').toString(),
    );
  }
}

class _VaccinationAnimal {
  final String name;
  final String tagNo;
  final String no;
  final String type; // 'Cow' or 'Bull'
  final String imagePath;
  final List<_VaccinationRecord> records;

  const _VaccinationAnimal({
    required this.name,
    required this.tagNo,
    required this.no,
    required this.type,
    required this.imagePath,
    required this.records,
  });

  factory _VaccinationAnimal.fromMap(
    Map<String, dynamic> animal, {
    List<_VaccinationRecord> records = const [],
  }) {
    final typeSource = (animal['type'] ?? animal['gender'] ?? '').toString().toLowerCase();
    final isBull = typeSource.contains('bull') || typeSource.startsWith('m');
    return _VaccinationAnimal(
      name: (animal['name'] ?? 'Unknown').toString(),
      tagNo: (animal['tagNumber'] ?? animal['tagno'] ?? '-').toString(),
      no: (animal['animalNumber'] ?? animal['serialNumber'] ?? '-').toString(),
      type: isBull ? 'Bull' : 'Cow',
      imagePath: (animal['viewUrl'] ??
              animal['photoUrl'] ??
              animal['imageUrl'] ??
              (isBull ? 'assets/icons/father_cow.png' : 'assets/icons/cow_and_calf.png'))
          .toString(),
      records: records,
    );
  }
}

Widget _buildVaccinationImage(
  String path, {
  double width = 70,
  double height = 70,
}) {
  final fallback = Container(
    width: width,
    height: height,
    color: Colors.grey.shade200,
    child: const Icon(Icons.pets, color: Colors.grey),
  );
  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
  return Image.asset(
    path,
    width: width,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => fallback,
  );
}

// ============================================================
// MOCK DATA
// ============================================================

final _vaccineList = [
  'UNATTENDED CASES — દવાખાને ન લવાયેલ કેસ',
  'VIRAL DISEASES — વાયરસથી થતી બિમારીઓ',
  'URINARY SYSTEM — મૂત્ર માર્ગ સિસ્ટમ',
  'BACTERIAL DISEASES — બેક્ટેરિયા સંબંધિત બિમારીઓ',
  'NUTRITIONAL DISEASES — પોષણસંબંધિત બિમારીઓ',
  'MAJOR SURGICAL DISEASES — મુખ્ય શસ્ત્રક્રિયાની જરૂરીયાત બિમારીઓ',
  'DISEASES OF DIGESTIVE SYSTEM — પાચનતંત્રની બિમારીઓ',
  'REPRODUCTIVE DISEASES — પ્રજનન સંબંધિત બિમારીઓ',
  'OBSTETRICAL DISEASES — પ્રસૂતિસંબંધિત બિમારીઓ',
];

final _vaccinationAnimals = <_VaccinationAnimal>[
  _VaccinationAnimal(
    name: 'ક્રિષ્ના',
    tagNo: '106',
    no: '0005',
    type: 'Cow',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _VaccinationRecord(
        date: DateTime(2025, 10, 04),
        vaccine: 'Foot and Mouth Disease (FMD)',
        dose: 'First Dose',
      ),
    ],
  ),
  _VaccinationAnimal(
    name: 'મેઘા',
    tagNo: '101',
    no: '0001',
    type: 'Cow',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _VaccinationRecord(
        date: DateTime(2025, 10, 04),
        vaccine: 'Foot and Mouth Disease (FMD)',
        dose: 'First Dose',
      ),
    ],
  ),
  _VaccinationAnimal(
    name: 'તુલસી',
    tagNo: '108',
    no: '0007',
    type: 'Cow',
    imagePath: 'assets/icons/cow_and_calf.png',
    records: [
      _VaccinationRecord(
        date: DateTime(2025, 10, 04),
        vaccine: 'Foot and Mouth Disease (FMD)',
        dose: 'First Dose',
      ),
    ],
  ),
  _VaccinationAnimal(
    name: 'રાજા',
    tagNo: '201',
    no: '0010',
    type: 'Bull',
    imagePath: 'assets/icons/father_cow.png',
    records: [
      _VaccinationRecord(
        date: DateTime(2025, 11, 15),
        vaccine: 'Brucellosis',
        dose: 'Booster Dose',
        remarks: 'વાર્ષિક રસીકરણ',
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
// 1. VACCINATION REPORT HUB
// ============================================================

class VaccinationReportHubScreen extends StatelessWidget {
  const VaccinationReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Vaccination Report',
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
            label: 'Animal Wise Vaccination Report',
            leadingIcon: Image.asset(
              'assets/icons/mother_cow.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.pets, color: _kOlive),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnimalWiseVaccinationReportScreen(),
              ),
            ),
          ),
          _HubTile(
            label: 'Date Wise Vaccination Report',
            leadingIcon: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF5B8FD4),
              size: 28,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DateWiseVaccinationReportScreen(),
              ),
            ),
          ),
          _HubTile(
            label: 'Vaccine Wise Report',
            leadingIcon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF5B8FD4),
              size: 24,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VaccineWiseReportScreen(),
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
// 2. ANIMAL WISE VACCINATION REPORT
// ============================================================

class AnimalWiseVaccinationReportScreen extends StatefulWidget {
  const AnimalWiseVaccinationReportScreen({super.key});

  @override
  State<AnimalWiseVaccinationReportScreen> createState() =>
      _AnimalWiseVaccinationReportScreenState();
}

class _AnimalWiseVaccinationReportScreenState
    extends State<AnimalWiseVaccinationReportScreen> {
  String? _selectedType;
  _VaccinationAnimal? _selectedAnimal;
  bool _showTypeDropdown = false;
  bool _showAnimalDropdown = false;
  bool _isLoading = false;
  List<_VaccinationAnimal> _animals = [];

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  List<_VaccinationAnimal> get _filteredAnimals {
    var list = _animals;
    if (_selectedType != null) {
      list = list.where((a) => a.type == _selectedType).toList();
    }
    return list;
  }

  Future<void> _loadAnimals() async {
    setState(() => _isLoading = true);
    try {
      final cows = await sl<ApiService>().getCows();
      final bulls = await sl<ApiService>().getBulls();
      final allAnimals = [
        ...cows.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        ...bulls.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      ];

      final loaded = <_VaccinationAnimal>[];
      for (final animal in allAnimals) {
        final animalId = (animal['id'] ?? animal['_id'] ?? '').toString();
        if (animalId.isEmpty) continue;
        final history = await sl<ApiService>().getVaccinationHistory(animalId: animalId);
        loaded.add(
          _VaccinationAnimal.fromMap(
            animal,
            records: history
                .whereType<Map>()
                .map((item) => _VaccinationRecord.fromMap(Map<String, dynamic>.from(item)))
                .toList(),
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _animals = loaded;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _animals = [];
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
          'Animal Wise Vaccination Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kOlive))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
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
                Expanded(
                  child: _CustomDropdown(
                    label: _selectedAnimal?.name ?? 'Select Animal',
                    isOpen: _showAnimalDropdown,
                    onTap: () => setState(() {
                      _showAnimalDropdown = !_showAnimalDropdown;
                      _showTypeDropdown = false;
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
                  _selectedType = val;
                  _showTypeDropdown = false;
                  _selectedAnimal = null;
                }),
              ),
            )
          else if (_showAnimalDropdown)
            Flexible(
              child: _DropdownListOverlay(
                items: _filteredAnimals.map((a) => a.name).toList(),
                onSelect: (name) => setState(() {
                  _selectedAnimal = _animals.firstWhere(
                    (a) => a.name == name,
                  );
                  _showAnimalDropdown = false;
                }),
              ),
            ),
          if (!_showTypeDropdown && !_showAnimalDropdown)
            Expanded(
              child: _selectedAnimal == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _selectedAnimal!.records.isEmpty
                          ? const _NoDataFound()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total ${_selectedAnimal!.records.length}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _AnimalProfileCard(animal: _selectedAnimal!),
                                const SizedBox(height: 16),
                                ..._selectedAnimal!.records.map(
                                  (r) => _VaccinationRecordCard(record: r),
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

// ============================================================
// 3. DATE WISE VACCINATION REPORT
// ============================================================

class DateWiseVaccinationReportScreen extends StatefulWidget {
  const DateWiseVaccinationReportScreen({super.key});

  @override
  State<DateWiseVaccinationReportScreen> createState() =>
      _DateWiseVaccinationReportScreenState();
}

class _DateWiseVaccinationReportScreenState
    extends State<DateWiseVaccinationReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  String? _selectedType;
  bool _showTypeDropdown = false;
  bool _isLoading = false;
  List<_VaccinationAnimal> _animals = [];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  List<_VaccinationAnimal> get _filtered {
    var list = _animals.where((a) => a.records.isNotEmpty).toList();
    if (_selectedType != null) {
      list = list.where((a) => a.type == _selectedType).toList();
    }
    return list;
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final history = await sl<ApiService>().getVaccinationHistory(
        from: _fromDate,
        to: _toDate,
      );
      final grouped = <String, Map<String, dynamic>>{};
      for (final item in history.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        final animal = (map['animalId'] is Map)
            ? Map<String, dynamic>.from(map['animalId'] as Map)
            : (map['animal'] is Map)
                ? Map<String, dynamic>.from(map['animal'] as Map)
                : <String, dynamic>{};
        final animalId = (animal['id'] ?? animal['_id'] ?? map['animalId']).toString();
        final bucket = grouped.putIfAbsent(animalId, () {
          return {'animal': animal, 'records': <_VaccinationRecord>[]};
        });
        (bucket['records'] as List<_VaccinationRecord>).add(_VaccinationRecord.fromMap(map));
      }

      if (!mounted) return;
      setState(() {
        _animals = grouped.values
            .map((entry) => _VaccinationAnimal.fromMap(
                  Map<String, dynamic>.from(entry['animal'] as Map),
                  records: List<_VaccinationRecord>.from(entry['records'] as List),
                ))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _animals = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final animals = _filtered;
    final fmt = DateFormat('dd MMM, yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Date Wise Vaccination Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kOlive))
          : Column(
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
                          _loadReport();
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
                        if (d != null) {
                          setState(() => _toDate = d);
                          _loadReport();
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _CustomDropdown(
              label: _selectedType ?? 'Animal Type',
              isOpen: _showTypeDropdown,
              onTap: () =>
                  setState(() => _showTypeDropdown = !_showTypeDropdown),
            ),
          ),
          if (_showTypeDropdown)
            Flexible(
              child: _DropdownListOverlay(
                items: const ['Cow', 'Bull'],
                onSelect: (val) => setState(() {
                  _selectedType = val;
                  _showTypeDropdown = false;
                }),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Total ${animals.length} Animals',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: animals.isEmpty
                  ? const _NoDataFound()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: animals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (ctx, i) {
                        final a = animals[i];
                        return _VaccinationAnimalDoseCard(
                          animal: a,
                          record: a.records.first,
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
// 4. VACCINE WISE REPORT
// ============================================================

class VaccineWiseReportScreen extends StatefulWidget {
  const VaccineWiseReportScreen({super.key});

  @override
  State<VaccineWiseReportScreen> createState() =>
      _VaccineWiseReportScreenState();
}

class _VaccineWiseReportScreenState extends State<VaccineWiseReportScreen> {
  String? _selectedVaccine;
  bool _showVaccineDropdown = false;
  final _searchCtrl = TextEditingController();
  String _searchQ = '';
  List<String> _dynamicVaccineList = [];
  List<Map<String, dynamic>> _vaccineMatches = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchVaccineCategories();
  }

  Future<void> _fetchVaccineCategories() async {
    try {
      final vaccines = await sl<ApiService>().getVaccines();
      if (mounted) {
        setState(() {
          _dynamicVaccineList = vaccines.map((v) {
            final name = v['name'] ?? 'Unknown';
            final localName = v['localName'] != null ? ' — ${v['localName']}' : '';
            return '$name$localName';
          }).toList();
          if (_dynamicVaccineList.isEmpty) {
            _dynamicVaccineList = _vaccineList; // fallback to static if API empty
          }
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dynamicVaccineList = _vaccineList;
          _isLoadingCategories = false;
        });
      }
    }
  }

  List<String> get _filteredVaccines {
    if (_searchQ.isEmpty) return _dynamicVaccineList;
    return _dynamicVaccineList
        .where((v) => v.toLowerCase().contains(_searchQ.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> get _animalsWithVaccine {
    return _vaccineMatches;
    if (_selectedVaccine == null) return [];
    List<Map<String, dynamic>> result = [];

    // In real scenario, we'd filter by _selectedVaccine
    // For now, we only show data if it roughly matches our mock vaccine "Foot and Mouth Disease (FMD)"
    // If user selects something else from the category list, it will show empty (testing empty state)
    String selectedBase = _selectedVaccine!.split(' — ').first.toLowerCase();

    for (var a in _vaccinationAnimals) {
      for (var r in a.records) {
        if (r.vaccine.toLowerCase().contains(selectedBase) ||
            selectedBase.contains(r.vaccine.toLowerCase())) {
          result.add({'animal': a, 'record': r});
        }
      }
    }
    return result;
  }

  Future<void> _loadVaccineMatches() async {
    if (_selectedVaccine == null) {
      setState(() => _vaccineMatches = []);
      return;
    }
    setState(() => _isLoadingCategories = true);
    try {
      final vaccineName = _selectedVaccine!.split(' â€” ').first.trim().toLowerCase();
      final records = await sl<ApiService>().getVaccinationHistory();
      final matches = <Map<String, dynamic>>[];
      for (final item in records.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        final record = _VaccinationRecord.fromMap(map);
        if (!record.vaccine.toLowerCase().contains(vaccineName) &&
            !vaccineName.contains(record.vaccine.toLowerCase())) {
          continue;
        }
        final animal = (map['animalId'] is Map)
            ? Map<String, dynamic>.from(map['animalId'] as Map)
            : (map['animal'] is Map)
                ? Map<String, dynamic>.from(map['animal'] as Map)
                : <String, dynamic>{};
        matches.add({
          'animal': _VaccinationAnimal.fromMap(animal),
          'record': record,
        });
      }
      if (!mounted) return;
      setState(() {
        _vaccineMatches = matches;
        _isLoadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _vaccineMatches = [];
        _isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final matches = _animalsWithVaccine;
    matches.sort((a, b) => (b['record'] as _VaccinationRecord).date.compareTo((a['record'] as _VaccinationRecord).date));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Vaccine Wise Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vaccine',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                _CustomDropdown(
                  label: _selectedVaccine ?? 'Select vaccine',
                  isOpen: _showVaccineDropdown,
                  onTap: () => setState(
                    () => _showVaccineDropdown = !_showVaccineDropdown,
                  ),
                ),
              ],
            ),
          ),
          if (_showVaccineDropdown)
            Flexible(
              child: _DropdownListOverlay(
                items: _filteredVaccines,
                hasSearch: true,
                searchCtrl: _searchCtrl,
                onSearchChanged: (v) => setState(() => _searchQ = v),
                onSelect: (val) {
                  setState(() {
                    _selectedVaccine = val;
                    _showVaccineDropdown = false;
                  });
                  _loadVaccineMatches();
                },
              ),
            )
          else if (_selectedVaccine != null)
            Expanded(
              child: _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator(color: _kOlive))
                  : matches.isEmpty
                  ? const _NoDataFound()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Total ${matches.length} Animals',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: matches.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (ctx, i) {
                              return _VaccinationAnimalDoseCard(
                                animal: matches[i]['animal'],
                                record: matches[i]['record'],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED WIDGETS
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

class _AnimalProfileCard extends StatelessWidget {
  final _VaccinationAnimal animal;
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
            child: _buildVaccinationImage(
              animal.imagePath,
              width: 70,
              height: 70,
            ),
          ),
          const SizedBox(width: 14),
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
                    Text(
                      animal.type,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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

class _VaccinationRecordCard extends StatelessWidget {
  final _VaccinationRecord record;
  const _VaccinationRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.dose,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          _IconRow(
            icon: Icons.edit_outlined,
            label: 'Vaccine:',
            value: record.vaccine,
          ),
          _IconRow(
            icon: Icons.calendar_today_outlined,
            label: 'Dose Date:',
            value: fmt.format(record.date),
          ),
          _IconRow(icon: Icons.notes, label: 'Remark:', value: record.remarks),
        ],
      ),
    );
  }
}

class _VaccinationAnimalDoseCard extends StatelessWidget {
  final _VaccinationAnimal animal;
  final _VaccinationRecord record;
  const _VaccinationAnimalDoseCard({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildVaccinationImage(
              animal.imagePath,
              width: 50,
              height: 50,
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
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '— ${animal.type}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
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
                            border: Border.all(color: const Color(0xFFD4B96A)),
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
          const SizedBox(height: 16),
          Text(
            record.dose,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          _IconRow(
            icon: Icons.edit_outlined,
            label: 'Vaccine:',
            value: record.vaccine,
          ),
          _IconRow(
            icon: Icons.calendar_today_outlined,
            label: 'Dose Date:',
            value: fmt.format(record.date),
          ),
          _IconRow(icon: Icons.notes, label: 'Remark:', value: record.remarks),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 12),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
