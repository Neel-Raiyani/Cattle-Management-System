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
import '../../../../core/di/injection_container.dart';
import 'package:cattle_management_system/core/localization/localized_ui.dart';
import '../../../../core/utils/app_feedback.dart';
import 'package:cattle_management_system/core/widgets/no_data_found_widget.dart';

class DryOffScreen extends StatefulWidget {
  const DryOffScreen({super.key});

  @override
  State<DryOffScreen> createState() => _DryOffScreenState();
}

class _DryOffScreenState extends State<DryOffScreen> {
  List<DryOffRecord> _records = [];
  List<Cattle> _cowCandidates = const <Cattle>[];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 30));
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCowsList(forceRefresh: true));
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await context.read<CattleBloc>().repository.getAllCattle();
      List<Cattle> cows = [];
      result.fold((_) {}, (items) {
        cows = items.where((c) => c.isFemaleGender && c.isActive).toList();
      });

      if (cows.isEmpty) {
        if (mounted)
          setState(() {
            _cowCandidates = [];
            _records = [];
            _isLoading = false;
          });
        return;
      }

      final uniqueById = <String, DryOffRecord>{};
      for (final cow in cows) {
        final rawList = await sl<ApiService>().getDryOffReport(
          animalId: cow.id,
        );
        for (final item in rawList) {
          var record = DryOffRecord.fromJson(item);
          if (record.cowName == 'Unknown') {
            record = record.copyWith(
              animalId: record.animalId.isEmpty ? cow.id : record.animalId,
              cowName: cow.name,
              cowTagNumber: cow.tagNumber,
              cowSerialNumber: cow.serialNumber ?? '-',
              cowImageUrl: cow.imageUrl,
            );
          }
          if (record.id.isNotEmpty) uniqueById[record.id] = record;
        }
      }
      if (mounted) {
        setState(() {
          _cowCandidates = cows;
          _records = uniqueById.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = context.ui.serviceNotAvailable;
        });
      }
    }
  }

  List<DryOffRecord> get _filtered {
    List<DryOffRecord> list = [..._records];
    final start = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
    final end = DateTime(_toDate.year, _toDate.month, _toDate.day, 23, 59, 59);
    list = list
        .where(
          (r) => !r.dryOffDate.isBefore(start) && !r.dryOffDate.isAfter(end),
        )
        .toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (r) =>
                r.cowName.toLowerCase().contains(q) ||
                r.cowTagNumber.toLowerCase().contains(q),
          )
          .toList();
    }
    list.sort((a, b) => b.dryOffDate.compareTo(a.dryOffDate));
    return list;
  }

  void _openAddSheet({DryOffRecord? record}) async {
    final eligibleResponse = await sl<ApiService>().getDryOffEligibleAnimals();
    if (!mounted) return;
    final cattleById = {for (final cow in _cowCandidates) cow.id: cow};
    final eligibleCattle = eligibleResponse
        .whereType<Map>()
        .map(
          (item) =>
              cattleById[item['id']?.toString() ??
                  item['_id']?.toString() ??
                  ''],
        )
        .whereType<Cattle>()
        .toList();

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AddDryOffSheet(cattle: eligibleCattle, initialRecord: record),
    );
    if (result == true) _fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final fmt = DateFormat('dd MMM, yyyy');

    return BlocListener<CattleBloc, CattleState>(
      listener: (context, state) {
        if (state is CattleListLoaded) _fetchRecords();
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
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: _fromDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (p != null) setState(() => _fromDate = p);
                        _fetchRecords();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fmt.format(_fromDate),
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              size: 16,
                              color: Color(0xFF99AA5A),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('to'),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: _toDate,
                          firstDate: _fromDate,
                          lastDate: DateTime(2030),
                        );
                        if (p != null) setState(() => _toDate = p);
                        _fetchRecords();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fmt.format(_toDate),
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              size: 16,
                              color: Color(0xFF99AA5A),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const NoDataFoundWidget()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _DryOffCard(
                        record: filtered[index],
                        fmt: fmt,
                        onEdit: () => _openAddSheet(record: filtered[index]),
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
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
            ),
          ),
        ),
      ),
    );
  }
}

class _DryOffCard extends StatelessWidget {
  final DryOffRecord record;
  final DateFormat fmt;
  final VoidCallback onEdit;
  const _DryOffCard({
    required this.record,
    required this.fmt,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4E8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: record.isPregnant
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.isPregnant
                        ? context.ui.pregnant
                        : context.ui.emptyStatus,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: record.isPregnant
                          ? const Color(0xFF4C7A27)
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
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
                      Row(
                        children: [
                          Text(
                            '${context.ui.tagNo}: ${record.cowTagNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'No: ${record.cowSerialNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(18),
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
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
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

class _AddDryOffSheet extends StatefulWidget {
  final List<Cattle> cattle;
  final DryOffRecord? initialRecord;
  const _AddDryOffSheet({required this.cattle, this.initialRecord});
  @override
  State<_AddDryOffSheet> createState() => _AddDryOffSheetState();
}

class _AddDryOffSheetState extends State<_AddDryOffSheet> {
  Cattle? _selectedCow;
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialRecord?.dryOffDate;
    if (widget.initialRecord != null) {
      try {
        _selectedCow = widget.cattle.firstWhere(
          (c) => c.id == widget.initialRecord!.animalId,
        );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.initialRecord == null
                      ? context.ui.dryOffCow
                      : 'Edit Dry Off',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            context.ui.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          DropdownButton<Cattle>(
            value: _selectedCow,
            isExpanded: true,
            items: widget.cattle
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCow = v),
          ),
          const SizedBox(height: 20),
          Text(
            context.ui.dryOffDate,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () async {
              final p = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (p != null) setState(() => _selectedDate = p);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('dd MMM, yyyy').format(_selectedDate!),
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_selectedCow == null || _selectedDate == null) return;
                      setState(() => _isSubmitting = true);
                      try {
                        await sl<ApiService>().recordDryOff(
                          animalId: _selectedCow!.id,
                          date: _selectedDate!,
                          reason: 'OTHER',
                        );
                        if (mounted) Navigator.pop(context, true);
                      } catch (e) {
                        if (mounted) AppFeedback.showError(context, 'Failed');
                      } finally {
                        if (mounted) setState(() => _isSubmitting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF99AA5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                context.ui.submit,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
