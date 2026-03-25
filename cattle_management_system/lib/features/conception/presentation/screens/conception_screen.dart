import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cattle_management_system/core/localization/app_text.dart';
import 'add_pregnancy_screen.dart';
import '../../domain/entities/conception_record.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------------------
// ConceptionScreen
// ---------------------------------------------------------------------------

const _allCowsFilter = 'all';
const _pregnancyCheckPendingFilter = 'pending_check';
const _pregnantFilter = 'pregnant';
const _dryOffFilter = 'dry_off';
const _expectedDeliveryPendingFilter = 'delivery_pending';

// ---------------------------------------------------------------------------
// ConceptionScreen
// ---------------------------------------------------------------------------
class ConceptionScreen extends StatefulWidget {
  const ConceptionScreen({super.key});

  @override
  State<ConceptionScreen> createState() => _ConceptionScreenState();
}

class _ConceptionScreenState extends State<ConceptionScreen> {
  static const String _deliveredJourneyIdsKey =
      'LOCALLY_DELIVERED_CONCEPTION_IDS';
  List<ConceptionRecord> _records = [];
  final Set<String> _locallyDeliveredIds = <String>{};
  bool _isLoading = true;
  String? _errorMessage;
  String _activeFilter = _allCowsFilter;
  bool _filterOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
    _restoreLocallyDeliveredIds();
  }

  Future<void> _restoreLocallyDeliveredIds() async {
    final prefs = sl<SharedPreferences>();
    final savedIds = prefs.getStringList(_deliveredJourneyIdsKey) ?? const [];
    _locallyDeliveredIds
      ..clear()
      ..addAll(savedIds.where((id) => id.trim().isNotEmpty));
    await _fetchRecords();
  }

  Future<void> _persistLocallyDeliveredIds() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setStringList(
      _deliveredJourneyIdsKey,
      _locallyDeliveredIds.toList(),
    );
  }

  Future<void> _fetchRecords() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await sl<ApiService>().getActiveJourneys();
      final cattleState = context.read<CattleBloc>().state;
      final cattleList = cattleState is CattleListLoaded
          ? cattleState.cattleList.where((c) => c.isActive).toList()
          : <Cattle>[];
      if (!mounted) return;
      setState(() {
        _records = data
            .map((j) => ConceptionRecord.fromJson(j))
            .map((record) => _enrichRecord(record, cattleList))
            .whereType<ConceptionRecord>()
            .where(
              (record) =>
                  !record.isDelivered &&
                  !_locallyDeliveredIds.contains(record.id),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.tr.serviceNotAvailable;
      });
    }
  }

  List<ConceptionRecord> get _filtered {
    switch (_activeFilter) {
      case _pregnancyCheckPendingFilter:
        return _records
            .where((r) => r.pregnancyStatus == 'Pregnancy Check Pending')
            .toList();
      case _pregnantFilter:
        return _records.where((r) => r.isPregnant).toList();
      case _dryOffFilter:
        return _records.where((r) => r.isDryOff).toList();
      case _expectedDeliveryPendingFilter:
        return _records.where((r) => !r.isDelivered && r.isPregnant).toList();
      default:
        return _records;
    }
  }

  Future<void> _recordDryOff(ConceptionRecord record) async {
    if (record.isDryOff) return;
    final dryOffDate = await _showSingleDateDialog(
      title: 'Record Dry Off',
      confirmLabel: 'Save Dry Off',
    );
    if (dryOffDate == null) return;

    try {
      await sl<ApiService>().markJourneyDryOff(
        id: record.id,
        dryOffDate: dryOffDate,
      );
      if (!mounted) return;
      context.read<CattleBloc>().add(const LoadCattleList(forceRefresh: true));
      await _fetchRecords();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update dry off status')),
      );
    }
  }

  Future<void> _recordDelivery(ConceptionRecord record) async {
    if (record.isDelivered) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final payload = await _showDeliveryDialog();
    if (payload == null) return;

    try {
      await sl<ApiService>().deliverJourney(
        id: record.id,
        deliveryDate: payload.deliveryDate,
        calfStatus: payload.calfStatus,
        calfGender: payload.calfGender,
        calfName: payload.calfName,
        calfTagNumber: payload.calfTagNumber,
        calfGroup: payload.calfStatus == 'ALIVE'
            ? (payload.calfGender == 'FEMALE' ? 'Heifer' : 'Bull Calf')
            : null,
      );
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;
      setState(() {
        _locallyDeliveredIds.add(record.id);
        _records.removeWhere((item) => item.id == record.id);
      });
      await _persistLocallyDeliveredIds();
      Future.microtask(() {
        if (!mounted) return;
        context.read<CattleBloc>().add(const LoadCattleList(forceRefresh: true));
        context.read<CattleBloc>().add(const LoadCowsList(forceRefresh: true));
        context.read<CattleBloc>().add(const LoadBullsList(forceRefresh: true));
      });
      await _fetchRecords();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to record delivery')),
      );
    }
  }

  Future<void> _deleteRecord(String id) async {
    try {
      await sl<ApiService>().deleteJourney(id: id);
      if (!mounted) return;
      setState(() => _records.removeWhere((r) => r.id == id));
      context.read<CattleBloc>().add(const LoadCattleList(forceRefresh: true));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete record')),
      );
    }
  }

  ConceptionRecord? _enrichRecord(
    ConceptionRecord record,
    List<Cattle> cattleList,
  ) {
    Cattle? match;
    for (final cattle in cattleList) {
      final sameId = record.cowId != null &&
          record.cowId!.isNotEmpty &&
          cattle.id == record.cowId;
      final sameTag = record.cowTagNumber != '-' &&
          cattle.tagNumber.trim().toLowerCase() ==
              record.cowTagNumber.trim().toLowerCase();
      if (sameId || sameTag) {
        match = cattle;
        break;
      }
    }

    if (match == null) return null;

    return record.copyWith(
      cowName: match.name,
      cowTagNumber: match.tagNumber,
      cowSerialNumber: match.serialNumber ?? '-',
      cowImageUrl: match.imageUrl,
    );
  }

  Future<DateTime?> _showSingleDateDialog({
    required String title,
    required String confirmLabel,
  }) async {
    DateTime selectedDate = DateTime.now();
    return showDialog<DateTime>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: Text(title),
            content: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setLocalState(() => selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('dd MMM, yyyy').format(selectedDate),
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, selectedDate),
                child: Text(confirmLabel),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_DeliveryPayload?> _showDeliveryDialog() async {
    DateTime deliveryDate = DateTime.now();
    String calfStatus = 'ALIVE';
    String calfGender = 'FEMALE';
    final calfNameCtrl = TextEditingController();
    final calfTagCtrl = TextEditingController();

    final result = await showDialog<_DeliveryPayload>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: const Text('Record Delivery'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: deliveryDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setLocalState(() => deliveryDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('dd MMM, yyyy').format(deliveryDate),
                            ),
                          ),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: calfStatus,
                    decoration: const InputDecoration(labelText: 'Calf Status'),
                    items: const [
                      DropdownMenuItem(value: 'ALIVE', child: Text('Alive')),
                      DropdownMenuItem(value: 'DEAD', child: Text('Dead')),
                      DropdownMenuItem(value: 'ABORTED', child: Text('Aborted')),
                    ],
                    onChanged: (value) {
                      if (value != null) setLocalState(() => calfStatus = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: calfGender,
                    decoration: const InputDecoration(labelText: 'Calf Gender'),
                    items: const [
                      DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                      DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    ],
                    onChanged: (value) {
                      if (value != null) setLocalState(() => calfGender = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: calfNameCtrl,
                    decoration: const InputDecoration(labelText: 'Calf Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: calfTagCtrl,
                    decoration: const InputDecoration(labelText: 'Calf Tag Number'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await Future<void>.delayed(const Duration(milliseconds: 16));
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await Future<void>.delayed(const Duration(milliseconds: 16));
                  if (!ctx.mounted) return;
                  Navigator.pop(
                    ctx,
                    _DeliveryPayload(
                      deliveryDate: deliveryDate,
                      calfStatus: calfStatus,
                      calfGender: calfGender,
                      calfName: calfNameCtrl.text.trim(),
                      calfTagNumber: calfTagCtrl.text.trim(),
                    ),
                  );
                },
                child: const Text('Save Delivery'),
              ),
            ],
          );
        },
      ),
    );

    calfNameCtrl.dispose();
    calfTagCtrl.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final filterOptions = <MapEntry<String, String>>[
      MapEntry(_allCowsFilter, context.tr.allCows),
      MapEntry(
        _pregnancyCheckPendingFilter,
        context.tr.pregnancyCheckPending,
      ),
      MapEntry(_pregnantFilter, context.tr.pregnant),
      MapEntry(_dryOffFilter, context.tr.dryOff),
      MapEntry(
        _expectedDeliveryPendingFilter,
        context.tr.expectedDeliveryPending,
      ),
    ];
    final activeFilterLabel = filterOptions
        .firstWhere((option) => option.key == _activeFilter)
        .value;

    return Scaffold(
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
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          context.tr.conception,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF99AA5A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter bar ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter header row
                Material(
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
                          const Icon(
                            Icons.filter_list,
                            size: 18,
                            color: Color(0xFF99AA5A),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              activeFilterLabel,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.black87,
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
                // Filter options dropdown
                if (_filterOpen)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: filterOptions.map((opt) {
                        final isSelected = opt.key == _activeFilter;
                        return InkWell(
                          onTap: () => setState(() {
                            _activeFilter = opt.key;
                            _filterOpen = false;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    opt.value,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
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
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────
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
                        context.tr.total(filtered.length),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filtered.map(
                        (r) => _ConceptionCard(
                          record: r,
                          onAddPregnancy: () async {
                            final newR = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddPregnancyScreen(
                                  knownCows:
                                      (context.read<CattleBloc>().state
                                              is CattleListLoaded)
                                          ? (context.read<CattleBloc>().state
                                                  as CattleListLoaded)
                                              .cattleList
                                          : const [],
                                  prefillCow: r.cowName,
                                  prefillParity: r.parity,
                                ),
                              ),
                            );
                            if (newR == true) _fetchRecords();
                          },
                          onToggleDryOff: (v) => _recordDryOff(r),
                          onToggleDelivered: (v) => _recordDelivery(r),
                          onDelete: () => _showDeleteDialog(r.id),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final newR = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => AddPregnancyScreen(
                  knownCows: (context.read<CattleBloc>().state
                          is CattleListLoaded)
                      ? (context.read<CattleBloc>().state as CattleListLoaded)
                          .cattleList
                      : const [],
                ),
              ),
            );
            if (newR == true) _fetchRecords();
          },
          backgroundColor: const Color(0xFF99AA5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            context.tr.addPregnancy,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr.noDataFound,
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? context.tr.serviceNotAvailable,
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
            child: Text(context.tr.retry),
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
          context.tr.deleteRecord,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          context.tr.deleteConceptionRecordConfirmation,
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              await Future<void>.delayed(const Duration(milliseconds: 16));
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: Text(
              context.tr.cancel,
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              await Future<void>.delayed(const Duration(milliseconds: 16));
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              Future.microtask(() => _deleteRecord(id));
            },
            child: Text(
              context.tr.delete,
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ConceptionCard
// ---------------------------------------------------------------------------
class _ConceptionCard extends StatelessWidget {
  final ConceptionRecord record;
  final VoidCallback onAddPregnancy;
  final ValueChanged<bool> onToggleDryOff;
  final ValueChanged<bool> onToggleDelivered;
  final VoidCallback onDelete;

  const _ConceptionCard({
    required this.record,
    required this.onAddPregnancy,
    required this.onToggleDryOff,
    required this.onToggleDelivered,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    final days = record.daysSinceConception;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
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
          // ── Cow header row ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cow image
              Container(
                width: 56,
                height: 56,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + pregnancy badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.cowName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF99AA5A),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 7,
                                color: Color(0xFF99AA5A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                record.pregnancyStatus == 'Pregnant'
                                    ? 'Pregnant'
                                    : context.tr.checkPending,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4C7A27),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Tags row
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
                                    '${context.tr.tagNo}: ${record.cowTagNumber}',
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
                        Text(
                          '${context.tr.numberShort} ${record.cowSerialNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Pregnancy type chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.pregnancyType,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Parity ───────────────────────────────────────────────
          _DetailRow(
            iconBg: const Color(0xFFF5F5F5),
            iconColor: Colors.grey,
            icon: Icons.access_time_rounded,
            label: 'Parity',
            value: record.parity.toString(),
          ),
          const SizedBox(height: 10),

          // ── Conceive date + days badge ───────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conceive Date:',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmt.format(record.conceiveDate),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$days Days',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4C7A27),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Pregnant date + toggle ──────────────────────────────
          _DetailRow(
            iconBg: const Color(0xFFE8F5E9),
            iconColor: Colors.green,
            icon: Icons.eco_rounded,
            label: 'Pregnant:',
            value: fmt.format(record.pregnantDate),
          ),
          const SizedBox(height: 10),

          // ── Dry Off + toggle ────────────────────────────────────
          _ToggleRow(
            iconBg: const Color(0xFFFFF3E0),
            iconColor: Colors.orange,
            icon: Icons.brightness_3_rounded,
            label: 'Dry Off:',
            date: '${fmt.format(record.dryOffDate)} (Expected)',
            value: record.isDryOff,
            onChanged: onToggleDryOff,
          ),
          const SizedBox(height: 10),

          // ── Delivery + toggle ────────────────────────────────────
          _ToggleRow(
            iconBg: const Color(0xFFFCE4EC),
            iconColor: Colors.pink,
            icon: Icons.favorite_rounded,
            label: 'Delivery:',
            date: '${fmt.format(record.deliveryDate)} (Expected)',
            value: record.isDelivered,
            onChanged: onToggleDelivered,
          ),

          const SizedBox(height: 14),
          // ── Action buttons ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onAddPregnancy,
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
              const SizedBox(width: 10),
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
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DetailRow
// ---------------------------------------------------------------------------
class _DetailRow extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _ToggleRow
// ---------------------------------------------------------------------------
class _ToggleRow extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String date;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.date,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: value ? null : onChanged,
          activeColor: const Color(0xFF99AA5A),
        ),
      ],
    );
  }
}

class _DeliveryPayload {
  final DateTime deliveryDate;
  final String calfStatus;
  final String calfGender;
  final String calfName;
  final String calfTagNumber;

  const _DeliveryPayload({
    required this.deliveryDate,
    required this.calfStatus,
    required this.calfGender,
    required this.calfName,
    required this.calfTagNumber,
  });
}
