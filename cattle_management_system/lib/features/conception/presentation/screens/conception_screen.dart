import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
import '../../../../core/utils/animal_image_url.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/media_file_utils.dart';
import '../../../../core/localization/localized_ui.dart';
import 'package:cattle_management_system/core/widgets/no_data_found_widget.dart';

// ---------------------------------------------------------------------------
// ConceptionScreen
// ---------------------------------------------------------------------------

const _allCowsFilter = 'all';
const _pregnancyCheckPendingFilter = 'pending_check';
const _pregnantFilter = 'pregnant';
const _dryOffFilter = 'dry_off';
const _expectedDeliveryPendingFilter = 'delivery_pending';

class ConceptionScreen extends StatefulWidget {
  const ConceptionScreen({super.key});

  @override
  State<ConceptionScreen> createState() => _ConceptionScreenState();
}

class _ConceptionScreenState extends State<ConceptionScreen> {
  static const String _deliveredJourneyIdsKey = 'LOCALLY_DELIVERED_CONCEPTION_IDS';
  List<ConceptionRecord> _records = [];
  List<String> _breedOptions = const <String>[];
  final Set<String> _locallyDeliveredKeys = <String>{};
  List<String> _groupOptions = const <String>[];
  bool _isLoading = true;
  bool _isSubmittingJourneyAction = false;
  String? _errorMessage;
  String _activeFilter = _allCowsFilter;
  bool _filterOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList(forceRefresh: true));
    _loadBreedOptions();
    _loadGroupOptions();
    _restoreLocallyDeliveredIds();
  }

  Future<void> _loadGroupOptions() async {
    try {
      final groups = await sl<ApiService>().getCowGroups();
      if (!mounted) return;
      setState(() {
        _groupOptions = groups
            .map((g) => (g['name'] ?? g['groupName'] ?? '').toString().trim())
            .where((name) => name.isNotEmpty)
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _loadBreedOptions() async {
    try {
      final breeds = await sl<ApiService>().getBreeds();
      if (!mounted) return;
      setState(() {
        _breedOptions = breeds
            .map((breed) => breed.trim())
            .where((breed) => breed.isNotEmpty)
            .toList();
      });
    } catch (_) {
      // Keep dialog usable even if breed loading fails.
    }
  }

  Future<String?> _uploadImageAndGetKey(File imageFile) async {
    try {
      final fileName = imageFile.path.split(Platform.isWindows ? '\\' : '/').last;
      final contentType = resolveMimeTypeFromFileName(fileName);

      final presignedData = await sl<ApiService>().getPresignedUrl(
        fileName: fileName,
        contentType: contentType,
        type: 'PHOTO',
      );

      final uploadUrl = presignedData['uploadUrl'] as String?;
      final key = deriveAnimalImageStorageKey(
        key: presignedData['key']?.toString(),
        uploadUrl: uploadUrl,
        viewUrl: presignedData['viewUrl']?.toString(),
      );

      if (uploadUrl == null || key == null) return null;

      final Uint8List imageBytes = await imageFile.readAsBytes();
      final s3Response = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': contentType},
        body: imageBytes,
      );

      if (s3Response.statusCode != 200 && s3Response.statusCode != 204) {
        return 'ERROR_S3_${s3Response.statusCode}';
      }

      return key;
    } catch (_) {
      return null;
    }
  }

  Future<List<Cattle>> _loadActiveCattle() async {
    final result = await context.read<CattleBloc>().repository.getAllCattle();
    List<Cattle> cattleList = const <Cattle>[];
    result.fold((_) {}, (items) {
      cattleList = items.where((c) => c.isActive).toList();
    });
    return cattleList;
  }

  Future<void> _restoreLocallyDeliveredIds() async {
    final prefs = sl<SharedPreferences>();
    final savedIds = prefs.getStringList(_deliveredJourneyIdsKey) ?? const [];
    _locallyDeliveredKeys
      ..clear()
      ..addAll(savedIds.where((id) => id.trim().isNotEmpty));
    await _fetchRecords();
  }

  Future<void> _persistLocallyDeliveredIds() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setStringList(_deliveredJourneyIdsKey, _locallyDeliveredKeys.toList());
  }

  Future<void> _fetchRecords() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await sl<ApiService>().getActiveJourneys();
      final cattleList = await _loadActiveCattle();
      if (!mounted) return;
      setState(() {
        _records = data
            .map((j) => ConceptionRecord.fromJson(j))
            .map((record) => _enrichRecord(record, cattleList))
            .whereType<ConceptionRecord>()
            .where((record) => !record.isDelivered && !_isLocallyDelivered(record))
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
        return _records.where((r) => r.pregnancyStatus == 'Pregnancy Check Pending').toList();
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
    if (!_canRecordJourneyOutcome(record)) {
      await AppFeedback.showError(
        context,
        'Confirm pregnancy before recording dry off.',
      );
      return;
    }
    if (record.isDryOff || _isSubmittingJourneyAction) return;
    final dryOffDate = await _showSingleDateDialog(title: 'Record Dry Off', confirmLabel: 'Save Dry Off');
    if (dryOffDate == null) return;

    setState(() => _isSubmittingJourneyAction = true);
    try {
      final journeyId = await _resolveJourneyId(record);
      if (journeyId.isEmpty) {
        throw Exception('Unable to resolve journey id');
      }
      await sl<ApiService>().markJourneyDryOff(id: journeyId, dryOffDate: dryOffDate);
      if (!mounted) return;
      context.read<CattleBloc>().add(const LoadCattleList(forceRefresh: true));
      await _fetchRecords();
    } catch (_) {
      if (!mounted) return;
      await AppFeedback.showError(context, 'Failed to update dry off status');
    } finally {
      if (mounted) {
        setState(() => _isSubmittingJourneyAction = false);
      }
    }
  }

  Future<void> _recordDelivery(ConceptionRecord record) async {
    if (!_canRecordJourneyOutcome(record)) {
      await AppFeedback.showError(
        context,
        'Confirm pregnancy before recording delivery.',
      );
      return;
    }
    if (record.isDelivered || _isSubmittingJourneyAction) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final payload = await _showDeliveryDialog();
    if (payload == null) return;

    setState(() {
      _isLoading = true;
      _isSubmittingJourneyAction = true;
    });
    try {
      final journeyId = await _resolveJourneyId(record);
      if (journeyId.isEmpty) {
        throw Exception('Unable to resolve journey id');
      }
      
      await sl<ApiService>().deliverJourney(
        id: journeyId,
        deliveryDate: payload.deliveryDate,
        calfStatus: payload.calfStatus,
        calfGender: payload.calfGender,
        calfName: payload.calfName,
        calfTagNumber: payload.calfTagNumber,
        calfBreed: payload.calfBreed,
        calfGroup: payload.calfGroup,
        calfAppearance: payload.calfAppearance,
        calfWeight: payload.calfWeight,
        deliveryPhoto: payload.deliveryPhoto,
        calfPhoto: payload.calfPhoto,
      );
      
      if (!mounted) return;
      await AppFeedback.showSuccess(context, 'Delivery recorded successfully!');
      setState(() {
        _markLocallyDelivered(record);
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
    } catch (e) {
      if (!mounted) return;
      await AppFeedback.showError(context, 'Failed to record delivery');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmittingJourneyAction = false;
        });
      }
    }
  }

  void _markLocallyDelivered(ConceptionRecord record) {
    for (final key in _deliveryKeysForRecord(record)) {
      if (key.trim().isNotEmpty) _locallyDeliveredKeys.add(key);
    }
  }

  bool _isLocallyDelivered(ConceptionRecord record) {
    for (final key in _deliveryKeysForRecord(record)) {
      if (key.trim().isNotEmpty && _locallyDeliveredKeys.contains(key)) return true;
    }
    return false;
  }

  Set<String> _deliveryKeysForRecord(ConceptionRecord record) {
    final conceiveKey = record.conceiveDate.toIso8601String().split('T').first;
    final cowId = record.cowId?.trim() ?? '';
    final tag = record.cowTagNumber.trim().toLowerCase();
    final name = record.cowName.trim().toLowerCase();
    final serial = record.cowSerialNumber.trim().toLowerCase();
    return <String>{
      if (record.id.trim().isNotEmpty) record.id.trim(),
      if (cowId.isNotEmpty) 'cow:$cowId|date:$conceiveKey',
      if (tag.isNotEmpty && tag != '-') 'tag:$tag|date:$conceiveKey',
      if (serial.isNotEmpty && serial != '-') 'serial:$serial|date:$conceiveKey',
      if (name.isNotEmpty && name != 'unknown cow') 'name:$name|date:$conceiveKey',
    };
  }

  Future<void> _deleteRecord(String id) async {
    try {
      final record = _records.cast<ConceptionRecord?>().firstWhere((item) => item?.id == id, orElse: () => null);
      final journeyId = record == null ? id.trim() : await _resolveJourneyId(record);
      await sl<ApiService>().deleteJourney(id: journeyId);
      if (!mounted) return;
      setState(() => _records.removeWhere((r) => r.id == id));
      context.read<CattleBloc>().add(const LoadCattleList(forceRefresh: true));
    } catch (_) {
      if (!mounted) return;
      await AppFeedback.showError(context, 'Failed to delete record');
    }
  }

  bool _canRecordJourneyOutcome(ConceptionRecord record) {
    // Delivery and dry-off should only be allowed for confirmed pregnant journeys.
    if (record.isDelivered) return false;
    return record.isPregnant && record.pregnancyStatus.trim().toLowerCase() == 'pregnant';
  }

  Future<String> _resolveJourneyId(ConceptionRecord record) async {
    final fallbackId = record.id.trim();
    final objectIdPattern = RegExp(r'^[a-fA-F0-9]{24}$');
    // We search first, as fallbackId may be an animal ID instead of a journey ID.
    if (fallbackId.isEmpty) return '';

    try {
      final items = await sl<ApiService>().getActiveJourneys();
      final conceiveDateKey = record.conceiveDate.toIso8601String().split('T').first;
      final recordTag = record.cowTagNumber.trim().toLowerCase();
      final recordName = record.cowName.trim().toLowerCase();
      final recordCowId = record.cowId?.trim() ?? '';

      for (final item in items.whereType<Map>()) {
        final raw = Map<String, dynamic>.from(item);
        final rawId = _extractCanonicalJourneyId(raw);
        if (rawId.isEmpty || !objectIdPattern.hasMatch(rawId)) continue;

        final animal = raw['animal'] is Map
            ? Map<String, dynamic>.from(raw['animal'] as Map)
            : raw['animalId'] is Map
                ? Map<String, dynamic>.from(raw['animalId'] as Map)
                : <String, dynamic>{};
        final rawCowId = (raw['animalId'] is String ? raw['animalId'] : null)?.toString().trim() ??
            (animal['_id'] ?? animal['id'])?.toString().trim() ??
            '';
        final rawTag = (animal['tagNumber'] ?? raw['tagNumber'] ?? raw['tagno'])?.toString().trim().toLowerCase() ?? '';
        final rawName = (animal['name'] ?? raw['animalName'] ?? raw['name'])?.toString().trim().toLowerCase() ?? '';
        final rawConceiveDate = raw['conceiveDate']?.toString().split('T').first ?? '';

        final sameCow = recordCowId.isNotEmpty && rawCowId == recordCowId;
        final sameTag = recordTag.isNotEmpty && rawTag == recordTag;
        final sameName = recordName.isNotEmpty && rawName == recordName;
        final sameDate = rawConceiveDate == conceiveDateKey;

        if (sameDate && (sameCow || sameTag || sameName)) {
          return rawId;
        }
      }
    } catch (_) {
      // Fall through to validated fallback handling below.
    }

    if (objectIdPattern.hasMatch(fallbackId)) {
      return fallbackId;
    }

    return '';
  }

  String _extractCanonicalJourneyId(Map<String, dynamic> raw) {
    // Mutation endpoints should target the actual backend journey document id.
    // Prefer canonical ids first and only fall back to journeyId if needed.
    return (raw['_id'] ?? raw['id'] ?? raw['journeyId'])?.toString().trim() ?? '';
  }

  ConceptionRecord? _enrichRecord(ConceptionRecord record, List<Cattle> cattleList) {
    Cattle? match;
    for (final cattle in cattleList) {
      final sameId = record.cowId != null && record.cowId!.isNotEmpty && cattle.id == record.cowId;
      final sameTag = record.cowTagNumber != '-' && cattle.tagNumber.trim().toLowerCase() == record.cowTagNumber.trim().toLowerCase();
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

  Future<DateTime?> _showSingleDateDialog({required String title, required String confirmLabel}) async {
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
                if (picked != null) setLocalState(() => selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFF5F6F7), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(child: Text(DateFormat('dd MMM, yyyy').format(selectedDate))),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, selectedDate), child: Text(confirmLabel)),
            ],
          );
        },
      ),
    );
  }

  Future<_DeliveryPayload?> _showDeliveryDialog() async {
    return showDialog<_DeliveryPayload>(
      context: context,
      builder: (ctx) => _DeliveryDialog(
        breedOptions: _breedOptions,
        groupOptions: _groupOptions,
        onUploadImage: _uploadImageAndGetKey,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final filterOptions = <MapEntry<String, String>>[
      MapEntry(_allCowsFilter, context.tr.allCows),
      MapEntry(_pregnancyCheckPendingFilter, context.tr.pregnancyCheckPending),
      MapEntry(_pregnantFilter, context.tr.pregnant),
      MapEntry(_dryOffFilter, context.tr.dryOff),
      MapEntry(_expectedDeliveryPendingFilter, context.tr.expectedDeliveryPending),
    ];
    final activeFilterLabel = filterOptions.firstWhere((option) => option.key == _activeFilter).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          context.tr.conception,
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFF99AA5A), shape: BoxShape.circle),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => setState(() => _filterOpen = !_filterOpen),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, size: 18, color: Color(0xFF99AA5A)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(activeFilterLabel, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87))),
                          Icon(_filterOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_filterOpen)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            child: Row(
                              children: [
                                Expanded(child: Text(opt.value, style: GoogleFonts.inter(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal, color: isSelected ? const Color(0xFF99AA5A) : Colors.black87))),
                                if (isSelected) const Icon(Icons.check, size: 16, color: Color(0xFF99AA5A)),
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
                              Text(context.tr.total(filtered.length), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ...filtered.map((r) => _ConceptionCard(
                                    record: r,
                                    canRecordJourneyOutcome: _canRecordJourneyOutcome(r),
                                    isActionInProgress: _isSubmittingJourneyAction,
                                    onAddPregnancy: () async {
                                      final newR = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(builder: (_) => AddPregnancyScreen(knownCows: (context.read<CattleBloc>().state is CattleListLoaded) ? (context.read<CattleBloc>().state as CattleListLoaded).cattleList : const [], prefillCow: r.cowName, prefillParity: r.parity)),
                                      );
                                      if (newR == true) _fetchRecords();
                                    },
                                    onToggleDryOff: (v) => _recordDryOff(r),
                                    onToggleDelivered: (v) => _recordDelivery(r),
                                    onDelete: () => _showDeleteDialog(r.id),
                                  )),
                            ],
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newR = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => AddPregnancyScreen(knownCows: (context.read<CattleBloc>().state is CattleListLoaded) ? (context.read<CattleBloc>().state as CattleListLoaded).cattleList : const [])));
          if (newR == true) _fetchRecords();
        },
        backgroundColor: const Color(0xFF99AA5A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(context.tr.addPregnancy, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const NoDataFoundWidget();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(context.ui.noDataFoundImage, width: 180),
          const SizedBox(height: 16),
          Text(_errorMessage ?? context.tr.serviceNotAvailable, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _fetchRecords, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF99AA5A), foregroundColor: Colors.white), child: Text(context.tr.retry)),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr.deleteRecord, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(context.tr.deleteConceptionRecordConfirmation, style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.tr.cancel, style: GoogleFonts.inter(color: Colors.grey))),
          TextButton(onPressed: () { Navigator.pop(ctx); _deleteRecord(id); }, child: Text(context.tr.delete, style: GoogleFonts.inter(color: Colors.red))),
        ],
      ),
    );
  }
}

class _ConceptionCard extends StatelessWidget {
  final ConceptionRecord record;
  final bool canRecordJourneyOutcome;
  final bool isActionInProgress;
  final VoidCallback onAddPregnancy;
  final ValueChanged<bool> onToggleDryOff;
  final ValueChanged<bool> onToggleDelivered;
  final VoidCallback onDelete;

  const _ConceptionCard({
    required this.record,
    required this.canRecordJourneyOutcome,
    required this.isActionInProgress,
    required this.onAddPregnancy,
    required this.onToggleDryOff,
    required this.onToggleDelivered,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.withOpacity(0.15)), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFFF5F5F5), image: (record.cowImageUrl != null && record.cowImageUrl!.isNotEmpty) ? DecorationImage(image: NetworkImage(record.cowImageUrl!), fit: BoxFit.cover) : const DecorationImage(image: AssetImage('assets/icons/mother_cow.png'), fit: BoxFit.contain)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(record.cowName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF99AA5A), width: 0.5)),
                          child: Row(children: [const Icon(Icons.circle, size: 7, color: Color(0xFF99AA5A)), const SizedBox(width: 4), Text(record.pregnancyStatus == 'Pregnant' ? 'Pregnant' : context.tr.checkPending, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF4C7A27)))]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.local_offer, size: 10, color: Colors.brown), const SizedBox(width: 4), Text('${context.tr.tagNo}: ${record.cowTagNumber}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.brown[800]))])),
                        const SizedBox(width: 8),
                        Text('${context.tr.numberShort} ${record.cowSerialNumber}', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _DetailRow(iconBg: const Color(0xFFF5F5F5), iconColor: Colors.grey, icon: Icons.access_time_rounded, label: 'Parity', value: record.parity.toString()),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle), child: const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Conceive Date:', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)), Text(fmt.format(record.conceiveDate), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)), child: Text('${record.daysSinceConception} Days', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF4C7A27)))),
            ],
          ),
          const SizedBox(height: 10),
          _DetailRow(iconBg: const Color(0xFFE8F5E9), iconColor: Colors.green, icon: Icons.eco_rounded, label: 'Pregnant:', value: fmt.format(record.pregnantDate)),
          const SizedBox(height: 10),
          _ToggleRow(iconBg: const Color(0xFFFFF3E0), iconColor: Colors.orange, icon: Icons.brightness_3_rounded, label: 'Dry Off:', date: '${fmt.format(record.dryOffDate)} (Expected)', value: record.isDryOff, enabled: canRecordJourneyOutcome && !isActionInProgress, onChanged: onToggleDryOff),
          const SizedBox(height: 10),
          _ToggleRow(iconBg: const Color(0xFFFCE4EC), iconColor: Colors.pink, icon: Icons.favorite_rounded, label: 'Delivery:', date: '${fmt.format(record.deliveryDate)} (Expected)', value: record.isDelivered, enabled: canRecordJourneyOutcome && !isActionInProgress, onChanged: onToggleDelivered),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: GestureDetector(onTap: onAddPregnancy, child: Container(height: 40, decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.edit_outlined, color: Color(0xFFA4C639), size: 18)))),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(onTap: onDelete, child: Container(height: 40, decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.delete_outline, color: Colors.red, size: 18)))),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 40, decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.info_outline, color: Colors.blue, size: 18))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final Color iconBg, iconColor; final IconData icon; final String label, value;
  const _DetailRow({required this.iconBg, required this.iconColor, required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle), child: Icon(icon, size: 14, color: iconColor)), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)), Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600))])]);
  }
}

class _ToggleRow extends StatelessWidget {
  final Color iconBg, iconColor; final IconData icon; final String label, date; final bool value, enabled; final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.iconBg, required this.iconColor, required this.icon, required this.label, required this.date, required this.value, required this.enabled, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle), child: Icon(icon, size: 14, color: iconColor)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)), Text(date, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600))])),
        SizedBox(width: 48, height: 48, child: (value == false && enabled) ? Switch.adaptive(value: value, onChanged: onChanged, activeColor: const Color(0xFF99AA5A)) : (value == true ? const Icon(Icons.check_circle, color: Color(0xFF99AA5A)) : const Opacity(opacity: 0.5, child: Switch.adaptive(value: false, onChanged: null)))),
      ],
    );
  }
}

class _PhotoUploadField extends StatelessWidget {
  final String label;
  final File? file;
  final bool isUploading;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _PhotoUploadField({
    required this.label,
    required this.file,
    required this.isUploading,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUploading ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: isUploading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Icon(
                  file == null ? Icons.upload_rounded : Icons.check_circle,
                  color: file == null ? Colors.grey : const Color(0xFF99AA5A),
                ),
        ),
        child: file == null
            ? const Text('Tap to upload image')
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file!.path.split(Platform.isWindows ? '\\' : '/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onClear != null)
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
      ),
    );
  }
}

class _DeliveryPayload {
  final DateTime deliveryDate;
  final String calfStatus;
  final String calfGender;
  final String calfName;
  final String calfTagNumber;
  final String calfBreed;
  final String calfGroup;
  final String calfAppearance;
  final double? calfWeight;
  final String deliveryPhoto;
  final String calfPhoto;

  const _DeliveryPayload({
    required this.deliveryDate,
    required this.calfStatus,
    required this.calfGender,
    required this.calfName,
    required this.calfTagNumber,
    required this.calfBreed,
    required this.calfGroup,
    required this.calfAppearance,
    required this.calfWeight,
    required this.deliveryPhoto,
    required this.calfPhoto,
  });
}

class _DeliveryDialog extends StatefulWidget {
  final List<String> breedOptions;
  final List<String> groupOptions;
  final Future<String?> Function(File) onUploadImage;

  const _DeliveryDialog({
    required this.breedOptions,
    required this.groupOptions,
    required this.onUploadImage,
  });

  @override
  State<_DeliveryDialog> createState() => _DeliveryDialogState();
}

class _DeliveryDialogState extends State<_DeliveryDialog> {
  DateTime _deliveryDate = DateTime.now();
  String _calfStatus = 'ALIVE';
  String _calfGender = 'FEMALE';
  late final TextEditingController _calfNameCtrl;
  late final TextEditingController _calfTagCtrl;
  late final TextEditingController _calfAppearanceCtrl;
  late final TextEditingController _calfWeightCtrl;
  String? _calfBreed;
  String? _calfGroup;
  File? _deliveryPhotoFile;
  File? _calfPhotoFile;
  String _deliveryPhotoKey = '';
  String _calfPhotoKey = '';
  bool _isUploadingDeliveryPhoto = false;
  bool _isUploadingCalfPhoto = false;
  bool _isSavingDelivery = false;

  @override
  void initState() {
    super.initState();
    _calfNameCtrl = TextEditingController();
    _calfTagCtrl = TextEditingController();
    _calfAppearanceCtrl = TextEditingController();
    _calfWeightCtrl = TextEditingController();
    _calfBreed = widget.breedOptions.isNotEmpty ? widget.breedOptions.first : 'Gir';
    _calfGroup = widget.groupOptions.isNotEmpty ? widget.groupOptions.first : null;
  }

  @override
  void dispose() {
    _calfNameCtrl.dispose();
    _calfTagCtrl.dispose();
    _calfAppearanceCtrl.dispose();
    _calfWeightCtrl.dispose();
    super.dispose();
  }

  String _displayBreedLabel(String breed) {
    return breed.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
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
                  initialDate: _deliveryDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => _deliveryDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFF5F6F7), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(child: Text(DateFormat('dd MMM, yyyy').format(_deliveryDate))),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _calfStatus,
              decoration: const InputDecoration(labelText: 'Calf Status'),
              items: const [
                DropdownMenuItem(value: 'ALIVE', child: Text('Alive')),
                DropdownMenuItem(value: 'DEAD', child: Text('Dead')),
                DropdownMenuItem(value: 'ABORTED', child: Text('Aborted')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _calfStatus = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _calfGender,
              decoration: const InputDecoration(labelText: 'Calf Gender'),
              items: const [
                DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                DropdownMenuItem(value: 'MALE', child: Text('Male')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _calfGender = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: _calfNameCtrl, decoration: const InputDecoration(labelText: 'Calf Name')),
            const SizedBox(height: 12),
            TextField(controller: _calfTagCtrl, decoration: const InputDecoration(labelText: 'Calf Tag Number')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _calfBreed,
              decoration: const InputDecoration(labelText: 'Calf Breed'),
              hint: const Text('Select calf breed'),
              items: widget.breedOptions
                  .map(
                    (breed) => DropdownMenuItem<String>(
                      value: breed,
                      child: Text(_displayBreedLabel(breed)),
                    ),
                  )
                  .toList(),
              onChanged: widget.breedOptions.isEmpty ? null : (value) => setState(() => _calfBreed = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: widget.groupOptions.contains(_calfGroup) ? _calfGroup : null,
              decoration: const InputDecoration(labelText: 'Calf Group'),
              hint: Text(
                widget.groupOptions.isEmpty ? 'No cow groups available' : 'Select calf group',
              ),
              items: widget.groupOptions
                  .map((g) => DropdownMenuItem<String>(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _calfGroup = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: _calfAppearanceCtrl, decoration: const InputDecoration(labelText: 'Calf Appearance')),
            const SizedBox(height: 12),
            TextField(controller: _calfWeightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Calf Weight')),
            const SizedBox(height: 12),
            _PhotoUploadField(
              label: 'Delivery Photo',
              file: _deliveryPhotoFile,
              isUploading: _isUploadingDeliveryPhoto,
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (pickedFile == null) return;
                final file = File(pickedFile.path);
                setState(() => _isUploadingDeliveryPhoto = true);
                final uploadedKey = await widget.onUploadImage(file);
                if (!mounted) return;
                setState(() {
                  _isUploadingDeliveryPhoto = false;
                  if (uploadedKey != null && uploadedKey.isNotEmpty && !uploadedKey.startsWith('ERROR_')) {
                    _deliveryPhotoFile = file;
                    _deliveryPhotoKey = uploadedKey;
                  }
                });
              },
              onClear: _deliveryPhotoFile == null ? null : () => setState(() { _deliveryPhotoFile = null; _deliveryPhotoKey = ''; }),
            ),
            const SizedBox(height: 12),
            _PhotoUploadField(
              label: 'Calf Photo',
              file: _calfPhotoFile,
              isUploading: _isUploadingCalfPhoto,
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (pickedFile == null) return;
                final file = File(pickedFile.path);
                setState(() => _isUploadingCalfPhoto = true);
                final uploadedKey = await widget.onUploadImage(file);
                if (!mounted) return;
                setState(() {
                  _isUploadingCalfPhoto = false;
                  if (uploadedKey != null && uploadedKey.isNotEmpty && !uploadedKey.startsWith('ERROR_')) {
                    _calfPhotoFile = file;
                    _calfPhotoKey = uploadedKey;
                  }
                });
              },
              onClear: _calfPhotoFile == null ? null : () => setState(() { _calfPhotoFile = null; _calfPhotoKey = ''; }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSavingDelivery || _isUploadingDeliveryPhoto || _isUploadingCalfPhoto
              ? null
              : () async {
                  setState(() => _isSavingDelivery = true);
                  if (_calfStatus == 'ALIVE' && (_calfNameCtrl.text.trim().isEmpty || _calfTagCtrl.text.trim().isEmpty)) {
                    setState(() => _isSavingDelivery = false);
                    await AppFeedback.showError(context, 'Calf name and calf tag number are required for a live delivery.');
                    return;
                  }
                  if (!mounted) return;
                  Navigator.pop(
                    context,
                    _DeliveryPayload(
                      deliveryDate: _deliveryDate,
                      calfStatus: _calfStatus,
                      calfGender: _calfGender,
                      calfName: _calfNameCtrl.text.trim(),
                      calfTagNumber: _calfTagCtrl.text.trim(),
                      calfBreed: _calfBreed?.trim() ?? '',
                      calfGroup: _calfGroup?.trim() ?? '',
                      calfAppearance: _calfAppearanceCtrl.text.trim(),
                      calfWeight: double.tryParse(_calfWeightCtrl.text.trim()),
                      deliveryPhoto: _deliveryPhotoKey,
                      calfPhoto: _calfPhotoKey,
                    ),
                  );
                },
          child: const Text('Save Delivery'),
        ),
      ],
    );
  }
}
