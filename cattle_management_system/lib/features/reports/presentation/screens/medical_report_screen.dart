import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';
import '../../../../features/animal_health/domain/entities/health_event.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
import '../../../../core/localization/localized_ui.dart';
import '../../../../l10n/app_localizations.dart';

// ============================================================
// CONSTANTS & COLORS
// ============================================================
const _kOlive = Color(0xFF99AA5A);
const _kLightGrey = Color(0xFFF5F6F7);
const _kHealthyGreen = Color(0xFF4CAF50);
const _kSickRed = Color(0xFFE53935);

class _NoDataFound extends StatelessWidget {
  const _NoDataFound();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/no_data_found.png', width: 200),
          const SizedBox(height: 16),
          Text(
            l10n?.noDataFound ?? 'No Data Found',
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

final List<String> _diseaseList = [
  'UNATTENDED CASES — બિનહાજર કેસો',
  'VIRAL DISEASES — વાયરસજન્ય રોગો',
  'URINARY SYSTEM — મૂત્રતંત્ર',
  'BACTERIAL DISEASES — બેક્ટેરિયલ રોગો',
  'NUTRITIONAL DISORDERS — પોષણ સંબંધિત વિકારો',
  'INJURY SURGICAL DISORDERS — ઇજા/શસ્ત્રક્રિયા સંબંધિત વિકારો',
  'DISEASES OF DIGESTIVE SYSTEM — પાચનતંત્રના રોગો',
  'REPRODUCTIVE DISEASES — પ્રજનન સંબંધિત રોગો',
  'OBSTETRICAL DISORDERS — પ્રસૂતિ સંબંધિત વિકારો',
  'OTHER MISCELLANEOUS CAUSES — અન્ય વિવિધ કારણો',
  'DISEASES OF MS SYSTEM — માસ્પેશી/હાડકાં તંત્રના રોગો',
  'ALLERGIC CONDITIONS — એલર્જી સંબંધિત પરિસ્થિતિઓ',
  'SKIN DISEASES — ચામડીના રોગો',
  'RESPIRATORY DISEASES — શ્વસનતંત્રના રોગો',
  'PARASITIC DISEASES — પરજીવીજન્ય રોગો',
  'MAMMARY GLAND DISEASES — સ્તનગ્રંથિના રોગો',
  'METABOLIC DISORDERS — ચયાપચય સંબંધિત વિકારો',
  'CARDIOVASCULAR DISEASES — હૃદય અને રક્તવાહિની તંત્રના રોગો',
  'POISONING — ઝેરીકરણ',
  'NERVOUS SYSTEM — નર્વસ સિસ્ટમ / નાડીતંત્ર',
  'EYE AND EAR — આંખ અને કાન',
  'ARTIFICIAL INSEMINATION — કૃત્રિમ ગર્ભાધાન',
  'PROTOZOAL DISEASES — પ્રોટોઝોઆજન્ય રોગો',
  'Ketosis — કીટોસિસ',
  'Other — અન્ય',
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
// 1. MEDICAL REPORT HUB
// ============================================================

class MedicalReportHubScreen extends StatelessWidget {
  const MedicalReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          context.ui.medicalReport,
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
            label: context.ui.animalWiseMedicalReport,
            leadingIcon: Image.asset(
              'assets/icons/mother_cow.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.pets, color: _kOlive),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnimalWiseMedicalReportScreen(),
              ),
            ),
          ),
          _HubTile(
            label: context.ui.dateWiseMedicalReport,
            leadingIcon: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF5B8FD4),
              size: 28,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DateWiseMedicalReportScreen(),
              ),
            ),
          ),
          _HubTile(
            label: context.ui.diseaseWiseReport,
            leadingIcon: const Icon(
              Icons.sick_outlined,
              color: Colors.blueGrey,
              size: 28,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DiseaseWiseMedicalReportScreen(),
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
// 2. ANIMAL WISE MEDICAL REPORT
// ============================================================

class AnimalWiseMedicalReportScreen extends StatefulWidget {
  const AnimalWiseMedicalReportScreen({super.key});

  @override
  State<AnimalWiseMedicalReportScreen> createState() =>
      _AnimalWiseMedicalReportScreenState();
}

class _AnimalWiseMedicalReportScreenState
    extends State<AnimalWiseMedicalReportScreen> {
  String? _selectedType;
  Cattle? _selectedAnimal;
  List<HealthEvent> _medicalRecords = [];
  bool _isLoadingRecords = false;
  String? _recordsError;
  bool _showTypeDropdown = false;
  bool _showAnimalDropdown = false;
  final _searchCtrl = TextEditingController();
  String _searchQ = '';

  Future<void> _loadMedicalRecordsForSelectedAnimal() async {
    final animalId = _selectedAnimal?.id;
    if (animalId == null || animalId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _medicalRecords = [];
        _recordsError = null;
        _isLoadingRecords = false;
      });
      return;
    }

    setState(() {
      _isLoadingRecords = true;
      _recordsError = null;
    });

    try {
      final records = await sl<ApiService>().getMedicalHistory(animalId: animalId);
      if (!mounted) return;
      setState(() {
        _medicalRecords = records
            .whereType<Map>()
            .map(
              (json) => HealthEvent.fromJson(
                Map<String, dynamic>.from(json),
                'Medical',
              ),
            )
            .toList()
          ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
        _isLoadingRecords = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _medicalRecords = [];
        _recordsError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingRecords = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  List<Cattle> _getFilteredAnimals(List<Cattle> allCattle) {
    var list = allCattle;
    if (_selectedType != null) {
      list = list.where((a) {
        final gender = a.gender.toLowerCase();
        return gender == _selectedType!.toLowerCase() ||
            (gender == 'female' && _selectedType == 'Cow') ||
            (gender == 'male' && _selectedType == 'Bull');
      }).toList();
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
          'Animal Wise Medical Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          List<Cattle> cattleList = [];
          if (state is CattleListLoaded) {
            cattleList = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            cattleList = [state.cattle];
          }
          final filteredAnimals = _getFilteredAnimals(cattleList);

          return Column(
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
                          _searchQ = '';
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
                        _selectedType = val;
                        _showTypeDropdown = false;
                        _selectedAnimal = null;
                        _medicalRecords = [];
                        _recordsError = null;
                      }),
                    ),
                  )
              else if (_showAnimalDropdown)
                Flexible(
                  child: _DropdownListOverlay(
                    items: filteredAnimals.map((a) => a.name).toList(),
                    hasSearch: true,
                    searchCtrl: _searchCtrl,
                      onSearchChanged: (v) => setState(() => _searchQ = v),
                      onSelect: (name) => setState(() {
                        _selectedAnimal = filteredAnimals.firstWhere(
                          (a) => a.name == name,
                        );
                        _showAnimalDropdown = false;
                        _loadMedicalRecordsForSelectedAnimal();
                      }),
                    ),
                  ),
              if (!_showTypeDropdown && !_showAnimalDropdown)
                Expanded(
                  child: _selectedAnimal == null
                      ? const SizedBox.shrink()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _AnimalProfileCard(animal: _selectedAnimal!),
                                const SizedBox(height: 16),
                                if (_isLoadingRecords)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 24),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (_recordsError != null)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: Text(
                                        _recordsError!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                else if (_medicalRecords.isEmpty)
                                  const _NoDataFound()
                                else
                                  Column(
                                    children: _medicalRecords
                                        .map(
                                          (record) => _MedicalRecordCard(
                                            record: record,
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// 3. DATE WISE MEDICAL REPORT
// ============================================================

class DateWiseMedicalReportScreen extends StatefulWidget {
  const DateWiseMedicalReportScreen({super.key});

  @override
  State<DateWiseMedicalReportScreen> createState() =>
      _DateWiseMedicalReportScreenState();
}

class _DateWiseMedicalReportScreenState
    extends State<DateWiseMedicalReportScreen> {
  DateTime _fromDate = DateTime(2025, 11, 30);
  DateTime _toDate = DateTime(2025, 12, 30);
  String? _selectedType;
  bool _showTypeDropdown = false;

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  List<Map<String, dynamic>> _getFiltered(List<Cattle> allCattle) {
    List<Map<String, dynamic>> results = [];
    // Currently no records in API, returning empty
    return results;
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
          'Date Wise Medical Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          List<Cattle> cattleList = [];
          if (state is CattleListLoaded) {
            cattleList = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            cattleList = [state.cattle];
          }
          final matches = _getFiltered(cattleList);
          final fmt = DateFormat('dd MMM, yyyy');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
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
                                    if (_toDate.isBefore(_fromDate)) {
                                      _toDate = _fromDate;
                                    }
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                    const SizedBox(height: 12),
                    _CustomDropdown(
                      label: _selectedType ?? 'Animal Type',
                      isOpen: _showTypeDropdown,
                      onTap: () => setState(
                        () => _showTypeDropdown = !_showTypeDropdown,
                      ),
                    ),
                  ],
                ),
              ),
              if (_showTypeDropdown)
                _DropdownListOverlay(
                  items: const ['Cow', 'Bull'],
                  onSelect: (val) => setState(() {
                    _selectedType = val;
                    _showTypeDropdown = false;
                  }),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Total ${matches.length} Records',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: matches.isEmpty
                      ? const _NoDataFound()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: matches.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (ctx, i) {
                            return _MedicalAnimalDoseCard(
                              animal: matches[i]['animal'],
                              record: matches[i]['record'],
                            );
                          },
                        ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// 4. DISEASE WISE MEDICAL REPORT
// ============================================================

class DiseaseWiseMedicalReportScreen extends StatefulWidget {
  const DiseaseWiseMedicalReportScreen({super.key});

  @override
  State<DiseaseWiseMedicalReportScreen> createState() =>
      _DiseaseWiseMedicalReportScreenState();
}

class _DiseaseWiseMedicalReportScreenState
    extends State<DiseaseWiseMedicalReportScreen> {
  String? _selectedDisease;
  bool _showDiseaseDropdown = false;
  final _searchCtrl = TextEditingController();
  String _searchQ = '';

  List<String> get _filteredDiseases {
    if (_searchQ.isEmpty) return _diseaseList;
    return _diseaseList
        .where((d) => d.toLowerCase().contains(_searchQ.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  List<Map<String, dynamic>> _getAnimalsWithDisease(List<Cattle> allCattle) {
    if (_selectedDisease == null) return [];
    List<Map<String, dynamic>> result = [];
    // Currently no records in API, returning empty
    return result;
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
          'Disease Wise Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          List<Cattle> cattleList = [];
          if (state is CattleListLoaded) {
            cattleList = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            cattleList = [state.cattle];
          }
          final matches = _getAnimalsWithDisease(cattleList);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _CustomDropdown(
                  label: _selectedDisease ?? 'Select disease',
                  isOpen: _showDiseaseDropdown,
                  onTap: () => setState(
                    () => _showDiseaseDropdown = !_showDiseaseDropdown,
                  ),
                ),
              ),
              if (_showDiseaseDropdown)
                Flexible(
                  child: _DropdownListOverlay(
                    items: _filteredDiseases,
                    hasSearch: true,
                    searchCtrl: _searchCtrl,
                    onSearchChanged: (v) => setState(() => _searchQ = v),
                    onSelect: (val) => setState(() {
                      _selectedDisease = val;
                      _showDiseaseDropdown = false;
                    }),
                  ),
                )
              else if (_selectedDisease != null)
                Expanded(
                  child: matches.isEmpty
                      ? const _NoDataFound()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: matches.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (ctx, i) {
                            return _MedicalAnimalDoseCard(
                              animal: matches[i]['animal'],
                              record: matches[i]['record'],
                            );
                          },
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// COMPONENTS
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
  final Cattle animal;
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
            child:
                (animal.imageUrl != null && animal.imageUrl!.startsWith('http'))
                ? Image.network(
                    animal.imageUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderIcon(70),
                  )
                : Image.asset(
                    'assets/icons/cow_and_calf.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
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
                      animal.isFemaleGender ||
                              animal.gender.toLowerCase() == 'cow'
                          ? 'Cow'
                          : 'Bull',
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
                        'Tag No.: ${animal.tagNumber}',
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
                  'No. : ${animal.serialNumber ?? "0000"}',
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

Widget _placeholderIcon(double size) {
  return Container(
    width: size,
    height: size,
    color: Colors.grey.shade100,
    child: const Icon(Icons.pets, color: Colors.grey),
  );
}

class _MedicalRecordCard extends StatefulWidget {
  final dynamic record;
  const _MedicalRecordCard({required this.record});

  @override
  State<_MedicalRecordCard> createState() => _MedicalRecordCardState();
}

class _MedicalRecordCardState extends State<_MedicalRecordCard> {
  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final fmt = DateFormat('dd MMM, yyyy');
    // Default to healthy if r is dynamic and status is missing
    final color = (r is Map && r['status'] == 'Sick')
        ? _kSickRed
        : _kHealthyGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconRow(
            icon: Icons.pets,
            label: 'Medical Status:',
            value: r.status,
            valueColor: color,
          ),
          _IconRow(
            icon: Icons.personal_injury_outlined,
            label: 'Visit Type:',
            value: r.visitType,
          ),
          _IconRow(
            icon: Icons.sick_outlined,
            label: 'Disease:',
            value: r.disease,
          ),
          _IconRow(
            icon: Icons.person_outline,
            label: 'Doctor Name:',
            value: r.doctorName,
          ),
          _IconRow(
            icon: Icons.calendar_today_outlined,
            label: 'Visit Date:',
            value: (r is Map) ? fmt.format(r['date']) : fmt.format(r.eventDate),
          ),

          if (((r is Map && r['symptoms'] != null) ||
                  (r is! Map && r.symptoms != null)) ||
              ((r is Map && r['treatment'] != null) ||
                  (r is! Map && r.treatment != null)) ||
              ((r is Map && r['rescueProcedure'] != null) ||
                  (r is! Map && r.rescueProcedure != null))) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _ExpandableSection(
              title: 'Symptoms',
              items: (r is Map) ? r['symptoms'] : r.symptoms,
            ),
            _ExpandableSection(
              title: 'Treatment',
              items: (r is Map) ? r['treatment'] : r.treatment,
            ),
            _ExpandableSection(
              title: 'Rescue Procedure',
              items: (r is Map) ? r['rescueProcedure'] : r.rescueProcedure,
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _MedicalAnimalDoseCard extends StatelessWidget {
  final Cattle animal;
  final dynamic record;
  const _MedicalAnimalDoseCard({required this.animal, required this.record});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    final status = (record is Map) ? record['status'] : record.status;
    final statusColor = status == 'Healthy' ? _kHealthyGreen : _kSickRed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    (animal.imageUrl != null &&
                        animal.imageUrl!.startsWith('http'))
                    ? Image.network(
                        animal.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderIcon(50),
                      )
                    : Image.asset(
                        'assets/icons/cow_and_calf.png',
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
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• $status',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
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
                            'Tag No.: ${animal.tagNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: const Color(0xFFB8942C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No. : ${animal.serialNumber ?? "0000"}',
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
          _IconRow(
            icon: Icons.personal_injury_outlined,
            label: 'Visit Type:',
            value: (record is Map)
                ? (record['visitType'] ?? '-')
                : (record.visitType ?? '-'),
          ),
          _IconRow(
            icon: Icons.sick_outlined,
            label: 'Disease:',
            value: (record is Map)
                ? (record['disease'] ?? '-')
                : (record.disease ?? '-'),
          ),
          _IconRow(
            icon: Icons.person_outline,
            label: 'Doctor Name:',
            value: (record is Map)
                ? (record['doctorName'] ?? '-')
                : (record.doctorName ?? '-'),
          ),
          _IconRow(
            icon: Icons.calendar_today_outlined,
            label: 'Visit Date:',
            value: (record is Map)
                ? (record['date'] != null ? fmt.format(record['date']) : '-')
                : fmt.format(record.eventDate),
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
  final Color? valueColor;
  const _IconRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
                    color: valueColor ?? Colors.black87,
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

class _ExpandableSection extends StatefulWidget {
  final String title;
  final dynamic items; // Can be List<String> or String
  final bool isLast;
  const _ExpandableSection({
    required this.title,
    required this.items,
    this.isLast = false,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    List<String> list = [];
    if (widget.items is List) {
      list = (widget.items as List).map((e) => e.toString()).toList();
    } else if (widget.items is String) {
      final s = widget.items as String;
      if (s.isNotEmpty) list = [s];
    }

    if (list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 8),
      child: Container(
        decoration: BoxDecoration(
          color: _kLightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            trailing: Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 18,
            ),
            onExpansionChanged: (v) => setState(() => _expanded = v),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.circle,
                                size: 4,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
