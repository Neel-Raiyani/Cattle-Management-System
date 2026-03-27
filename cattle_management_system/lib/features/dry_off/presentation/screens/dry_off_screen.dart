import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/dry_off_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_event.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import '../../../cattle/domain/entities/cattle.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localized_assets.dart';
import 'package:cattle_management_system/core/localization/localized_ui.dart';
import '../../../../core/utils/app_feedback.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

// Filter options — third option is Gujarati "ખાલી" (empty/not pregnant)
const _filterAll = 'all';
const _filterPregnant = 'pregnant';
const _filterEmpty = 'empty';

// ---------------------------------------------------------------------------
// DryOffScreen
// ---------------------------------------------------------------------------
class DryOffScreen extends StatefulWidget {
  const DryOffScreen({super.key});

  @override
  State<DryOffScreen> createState() => _DryOffScreenState();
}

class _DryOffScreenState extends State<DryOffScreen> {
  List<DryOffRecord> _records = [];
  List<DryOffRecord> _localRecords = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 30));
  String _activeFilter = _filterAll;
  bool _filterOpen = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final cattleBloc = context.read<CattleBloc>();
    if (cattleBloc.state is! CattleListLoaded) {
      cattleBloc.add(const LoadCowsList());
    }
    _fetchRecords();
  }

  List<Cattle> _getCowCandidates() {
    final cattleState = context.read<CattleBloc>().state;
    if (cattleState is! CattleListLoaded) return const <Cattle>[];

    return cattleState.cattleList.where((c) {
      return c.gender.toUpperCase().startsWith('F');
    }).toList();
  }

  Future<void> _fetchRecords() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cows = _getCowCandidates();
      if (cows.isEmpty) {
        if (!mounted) return;
        setState(() {
          _records = [];
          _isLoading = false;
          _errorMessage = null;
        });
        return;
      }

      final uniqueById = <String, DryOffRecord>{};
      for (final cow in cows) {
        final rawList = await sl<ApiService>().getDryOffReport(animalId: cow.id);
        for (final item in rawList) {
          var record = DryOffRecord.fromJson(item);
          final hasMatchingAnimalId =
              record.animalId.isNotEmpty && record.animalId == cow.id;
          final hasMatchingTag =
              record.cowTagNumber.trim().isNotEmpty &&
              record.cowTagNumber.trim() != '-' &&
              record.cowTagNumber.trim().toLowerCase() ==
                  cow.tagNumber.trim().toLowerCase();

          if (!hasMatchingAnimalId && !hasMatchingTag) {
            continue;
          }

          if (record.cowName == 'Unknown') {
            record = record.copyWith(
              animalId: record.animalId.isEmpty ? cow.id : record.animalId,
              cowName: cow.name,
              cowTagNumber: cow.tagNumber,
              cowSerialNumber: cow.serialNumber ?? '-',
              cowImageUrl: cow.imageUrl,
              isPregnant: cow.isPregnant ?? record.isPregnant,
            );
          }
          if (record.id.isNotEmpty) {
            uniqueById[record.id] = record;
          }
        }
      }
      if (!mounted) return;
      final fetchedRecords = uniqueById.values.toList();
      setState(() {
        _localRecords = _localRecords.where((local) {
          return !fetchedRecords.any(
            (remote) =>
                remote.animalId == local.animalId &&
                remote.dryOffDate.year == local.dryOffDate.year &&
                remote.dryOffDate.month == local.dryOffDate.month &&
                remote.dryOffDate.day == local.dryOffDate.day,
          );
        }).toList();
        _records = fetchedRecords;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            (e.toString().contains('404') || e.toString().contains('503'))
            ? context.ui.serviceNotAvailable
            : 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DryOffRecord> get _filtered {
    final mergedById = <String, DryOffRecord>{
      for (final record in _records) record.id: record,
      for (final record in _localRecords) record.id: record,
    };
    List<DryOffRecord> list = mergedById.values.toList();

    // Apply basic status filter
    if (_activeFilter == _filterPregnant) {
      list = list.where((r) => r.isPregnant).toList();
    } else if (_activeFilter == _filterEmpty) {
      list = list.where((r) => !r.isPregnant).toList();
    }

    // Apply date range filter (normalized to Date components only)
    final start = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
    final end = DateTime(_toDate.year, _toDate.month, _toDate.day, 23, 59, 59);

    list = list.where((r) {
      return !r.dryOffDate.isBefore(start) && !r.dryOffDate.isAfter(end);
    }).toList();

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) {
        return r.cowName.toLowerCase().contains(q) ||
            r.cowTagNumber.toLowerCase().contains(q);
      }).toList();
    }

    // Sort by dry off date descending
    list.sort((a, b) => b.dryOffDate.compareTo(a.dryOffDate));
    return list;
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF99AA5A),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      });
      _fetchRecords();
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF99AA5A),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _toDate = picked);
      _fetchRecords();
    }
  }


  Future<void> _deleteRecord(String id) async {
    setState(() => _isLoading = true);
    try {
      if (id.startsWith('local_')) {
        setState(() {
          _localRecords.removeWhere((record) => record.id == id);
          _isLoading = false;
        });
        if (!mounted) return;
        AppFeedback.showSuccess(context, context.ui.dryOffRecordDeletedSuccessfully);
        return;
      }
      final targetRecord = [
        ..._records,
        ..._localRecords,
      ].cast<DryOffRecord?>().firstWhere(
            (record) => record?.id == id,
            orElse: () => null,
          );
      final deleteId = targetRecord == null
          ? id
          : await _resolveDeleteId(targetRecord);
      await sl<ApiService>().deleteDryOff(id: deleteId);
      if (!mounted) return;
      _localRecords.removeWhere((record) => record.id == id);
      AppFeedback.showSuccess(context, context.ui.dryOffRecordDeletedSuccessfully);
      await _fetchRecords();
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<String> _resolveDeleteId(DryOffRecord record) async {
    if (record.id.isEmpty || record.id.startsWith('local_')) {
      throw Exception('Dry off record id is missing.');
    }

    try {
      final records = await sl<ApiService>().getDryOffReport(animalId: record.animalId);
      final targetDate = DateFormat('yyyy-MM-dd').format(record.dryOffDate);

      for (final item in records.whereType<Map>()) {
        final raw = Map<String, dynamic>.from(item);
        final rawAnimal =
            raw['animal'] is Map
                ? Map<String, dynamic>.from(raw['animal'] as Map)
                : raw['animalId'] is Map
                    ? Map<String, dynamic>.from(raw['animalId'] as Map)
                    : <String, dynamic>{};
        final rawDate = (raw['date'] ?? raw['dryOffDate'])?.toString();
        final normalizedDate =
            rawDate == null || rawDate.isEmpty
                ? ''
                : rawDate.split('T').first;
        final rawAnimalId =
            (raw['animalId'] is String ? raw['animalId'] : null)?.toString() ??
            rawAnimal['id']?.toString() ??
            rawAnimal['_id']?.toString() ??
            '';
        final rawTag =
            (raw['tagNumber'] ??
                    raw['tagNo'] ??
                    raw['tagno'] ??
                    rawAnimal['tagNumber'])
                ?.toString() ??
            '';

        final matchesAnimal =
            (record.animalId.isNotEmpty && rawAnimalId == record.animalId) ||
            (record.cowTagNumber.trim().isNotEmpty &&
                rawTag.trim().toLowerCase() ==
                    record.cowTagNumber.trim().toLowerCase());
        if (!matchesAnimal || normalizedDate != targetDate) {
          continue;
        }

        final resolvedId =
            raw['_id']?.toString() ??
            raw['id']?.toString() ??
            raw['dryOffId']?.toString() ??
            raw['recordId']?.toString() ??
            (raw['dryOff'] is Map
                ? (raw['dryOff']['_id'] ?? raw['dryOff']['id'])?.toString()
                : null) ??
            (raw['record'] is Map
                ? (raw['record']['_id'] ?? raw['record']['id'])?.toString()
                : null) ??
            '';
        if (resolvedId.isNotEmpty) {
          return resolvedId;
        }
      }
    } catch (_) {
      // Fall through to the current id when the refresh lookup fails.
    }

    return record.id;
  }

  void _openAddSheet({DryOffRecord? record}) async {
    final eligibleResponse = await sl<ApiService>().getDryOffEligibleAnimals();
    if (!mounted) return;
    final cattleById = {
      for (final cow in _getCowCandidates()) cow.id: cow,
    };
    final eligibleCattle = eligibleResponse
        .whereType<Map>()
        .map(
          (item) =>
              cattleById[item['id']?.toString() ?? item['_id']?.toString() ?? ''],
        )
        .whereType<Cattle>()
        .toList();

    final allCattle = [...eligibleCattle];
    if (record != null &&
        record.animalId.isNotEmpty &&
        !allCattle.any((cow) => cow.id == record.animalId)) {
      final existingCow = cattleById[record.animalId];
      if (existingCow != null) {
        allCattle.add(existingCow);
      }
    }

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddDryOffSheet(
        cattle: allCattle,
        initialRecord: record,
      ),
    );
    if (!mounted) return;
    if (result is DryOffRecord) {
      setState(() {
        _localRecords.removeWhere(
          (item) =>
              item.id == result.id ||
              (item.animalId == result.animalId &&
                  item.dryOffDate.year == result.dryOffDate.year &&
                  item.dryOffDate.month == result.dryOffDate.month &&
                  item.dryOffDate.day == result.dryOffDate.day),
        );
        _localRecords.insert(0, result);
      });
      _fetchRecords();
    } else if (result == true) {
      _fetchRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final fmt = DateFormat('dd MMM, yyyy');

    return BlocListener<CattleBloc, CattleState>(
      listener: (context, state) {
        if (state is CattleListLoaded) {
          _fetchRecords();
        }
      },
      child: GestureDetector(
        // Dismiss filter dropdown on outside tap
        onTap: () {
          if (_filterOpen) setState(() => _filterOpen = false);
        },
        child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          title: Text(
            context.ui.dryOffCow,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  // Toggle search bar visibility via filter panel
                  setState(() => _filterOpen = !_filterOpen);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF99AA5A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date range filter bar ──────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: _pickFromDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
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
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_rounded,
                                    size: 16,
                                    color: Color(0xFF99AA5A),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          context.ui.to,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: _pickToDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
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
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_rounded,
                                    size: 16,
                                    color: Color(0xFF99AA5A),
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

                // ── Filter bar (Dropdown) ──────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Material(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => setState(() => _filterOpen = !_filterOpen),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _activeFilter == _filterAll
                                    ? context.ui.filter
                                    : _activeFilter == _filterPregnant
                                        ? context.ui.pregnant
                                        : context.ui.emptyStatus,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Icon(
                              _filterOpen
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── List area ───────────────────────────────────────────
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? _buildErrorState()
                      : filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text(
                              '${context.ui.total}: ${filtered.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...filtered.map(
                              (r) => _DryOffCard(
                                record: r,
                                fmt: fmt,
                                onDelete: () => _showDeleteDialog(r.id),
                                onEdit: () => _openAddSheet(record: r),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),

            // ── Filter overlay panel ───────────────────────────────────
            if (_filterOpen)
              Positioned(
                top: 60, // just below the filter bar
                left: 16,
                right: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Search bar inside dropdown
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (v) =>
                                      setState(() => _searchQuery = v),
                                  style: GoogleFonts.inter(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Search here...',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      // Filter options
                      ...[_filterAll, _filterPregnant, _filterEmpty].map((opt) {
                        final isSelected = opt == _activeFilter;
                        return InkWell(
                          onTap: () => setState(() {
                            _activeFilter = opt;
                            _filterOpen = false;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    opt == _filterAll
                                        ? context.ui.allCow
                                        : opt == _filterPregnant
                                            ? context.ui.pregnant
                                            : context.ui.emptyStatus,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF99AA5A)
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Color(0xFF99AA5A),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: FloatingActionButton.extended(
            onPressed: () => _openAddSheet(),
            backgroundColor: const Color(0xFF99AA5A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Dry Off Cow',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            context.noDataFoundAsset,
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? context.ui.serviceNotAvailable,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchRecords,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF99AA5A),
              foregroundColor: Colors.white,
            ),
            child: Text(context.ui.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            context.noDataFoundAsset,
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 16),
          Text(
            context.ui.noDataFound,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8DA94D),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.ui.deleteRecord,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          context.ui.deleteDryOffRecordConfirmation,
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.ui.cancel, style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteRecord(id);
            },
            child: Text(context.ui.delete, style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DryOffCard
// ---------------------------------------------------------------------------
class _DryOffCard extends StatelessWidget {
  final DryOffRecord record;
  final DateFormat fmt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DryOffCard({
    required this.record,
    required this.fmt,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header strip ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4E8),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Dry Off Date: ${fmt.format(record.dryOffDate)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF5A6E2A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: record.isPregnant
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: record.isPregnant
                          ? const Color(0xFF99AA5A)
                          : Colors.grey.shade300,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 10,
                        color: record.isPregnant
                            ? const Color(0xFF99AA5A)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.isPregnant ? context.ui.pregnant : context.ui.emptyStatus,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: record.isPregnant
                              ? const Color(0xFF4C7A27)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Cow details row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Cow image
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF5F5F5),
                    image:
                        (record.cowImageUrl != null &&
                            record.cowImageUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(record.cowImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/icons/mother_cow.png'),
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.cowName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9C4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_offer,
                                    size: 10,
                                    color: Colors.brown,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${context.ui.tagNo}: ${record.cowTagNumber}',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.brown[800],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${context.ui.numberShort}: ${record.cowSerialNumber}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
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

          const Divider(height: 1),

          // ── Action buttons ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFA4C639),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
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

// ---------------------------------------------------------------------------
// _AddDryOffSheet  (bottom sheet)
// ---------------------------------------------------------------------------
class _AddDryOffSheet extends StatefulWidget {
  final List<Cattle> cattle;
  final DryOffRecord? initialRecord;

  const _AddDryOffSheet({required this.cattle, this.initialRecord});

  @override
  State<_AddDryOffSheet> createState() => _AddDryOffSheetState();
}

class _AddDryOffSheetState extends State<_AddDryOffSheet> {
  Cattle? _selectedCow;
  bool _isSubmitting = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialRecord?.dryOffDate;
    if (widget.initialRecord != null) {
      for (final cow in widget.cattle) {
        if (cow.id == widget.initialRecord!.animalId) {
          _selectedCow = cow;
          break;
        }
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF99AA5A),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
          highlightColor: Color(0xFFD4E29A),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() async {
    if (widget.cattle.isNotEmpty &&
        _selectedCow != null &&
        _selectedDate != null) {
      setState(() => _isSubmitting = true);
      try {
        late final DryOffRecord localRecord;
        if (widget.initialRecord == null) {
          final response = await sl<ApiService>().recordDryOff(
            animalId: _selectedCow!.id,
            date: _selectedDate!,
            reason: 'OTHER',
          );
          localRecord = DryOffRecord(
            id:
                response['id']?.toString() ??
                response['_id']?.toString() ??
                'local_${_selectedCow!.id}_${_selectedDate!.millisecondsSinceEpoch}',
            animalId: _selectedCow!.id,
            cowName: _selectedCow!.name,
            cowTagNumber: _selectedCow!.tagNumber,
            cowSerialNumber: _selectedCow!.serialNumber ?? '-',
            cowImageUrl: _selectedCow!.imageUrl,
            dryOffDate: _selectedDate!,
            reason: 'OTHER',
            remarks: null,
            isPregnant: _selectedCow!.isPregnant ?? false,
          );
        } else {
          await sl<ApiService>().updateDryOff(
            id: widget.initialRecord!.id,
            animalId: _selectedCow!.id,
            date: _selectedDate!,
            reason: widget.initialRecord!.reason,
            remarks: widget.initialRecord!.remarks,
          );
          localRecord = widget.initialRecord!.copyWith(
            animalId: _selectedCow!.id,
            cowName: _selectedCow!.name,
            cowTagNumber: _selectedCow!.tagNumber,
            cowSerialNumber: _selectedCow!.serialNumber ?? '-',
            cowImageUrl: _selectedCow!.imageUrl,
            dryOffDate: _selectedDate!,
            isPregnant: _selectedCow!.isPregnant ?? false,
          );
        }
        if (mounted) {
          AppFeedback.showSuccess(context, 
                widget.initialRecord == null
                    ? context.ui.dryOffRecordAddedSuccessfully
                    : context.ui.dryOffRecordUpdatedSuccessfully,
              );
          Navigator.pop(context, localRecord);
        }
      } on ServerException catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
      return;
    }
    if (_selectedCow == null) {
      AppFeedback.showError(context, 
            context.ui.pleaseSelectCow,
          );
      return;
    }
    if (_selectedDate == null) {
      AppFeedback.showError(context, 
            context.ui.pleaseSelectDryOffDate,
          );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.initialRecord == null
                      ? context.ui.dryOffCow
                      : 'Edit Dry Off Record',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF99AA5A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Name dropdown ────────────────────────────────────────
          Text(
            context.ui.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            hint: context.ui.selectCowName,
            value: _selectedCow,
            items: widget.cattle,
            onChanged: (v) => setState(() => _selectedCow = v),
          ),
          const SizedBox(height: 20),

          // ── Dry Off Date ─────────────────────────────────────────
          Text(
            context.ui.dryOffDate,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? context.ui.selectDryOffDate
                          : dateFmt.format(_selectedDate!),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _selectedDate == null
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Submit ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF99AA5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Text(
                context.ui.submit,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required Cattle? value,
    required List<Cattle> items,
    required ValueChanged<Cattle?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Cattle>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          ),
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
          items: items
              .map((n) => DropdownMenuItem(value: n, child: Text(n.name)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
