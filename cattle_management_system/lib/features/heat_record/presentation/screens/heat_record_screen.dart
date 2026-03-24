import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/heat_record.dart';
import 'add_heat_record_screen.dart';
import 'edit_heat_record_screen.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';

// ---------------------------------------------------------------------------
// Static mock data — replace with BLoC / API calls when backend is ready
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// HeatRecordScreen
// ---------------------------------------------------------------------------
class HeatRecordScreen extends StatefulWidget {
  const HeatRecordScreen({super.key});

  @override
  State<HeatRecordScreen> createState() => _HeatRecordScreenState();
}

class _HeatRecordScreenState extends State<HeatRecordScreen> {
  List<HeatRecord> _records = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now().add(const Duration(days: 1)); // Include today completely

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await sl<ApiService>().getHeatReport(
        from: _fromDate,
        to: _toDate,
      );
      if (!mounted) return;
      setState(() {
        _records = items.map((e) => HeatRecord.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            e.toString().contains('404') || e.toString().contains('503')
            ? 'Service not available'
            : 'Error: ${e.toString()}';
      });
    }
  }

  List<HeatRecord> get _filtered {
    var filtered = List<HeatRecord>.from(_records);
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF99AA5A),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate;
        }
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF99AA5A),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
      _fetchRecords();
    }
  }

  Future<void> _deleteRecord(HeatRecord record) async {
    setState(() => _isLoading = true);
    try {
      // ── Step 1: resolve the animalId from the CattleBloc ───────────────────
      // The heat report API returns no animalId/animalObjectId — only name & tagno.
      // We look up the cattle in our local BLoC state by tag number or name.
      String? animalId = (record.animalId != null && record.animalId!.isNotEmpty)
          ? record.animalId
          : null;

      if (animalId == null) {
        final state = context.read<CattleBloc>().state;
        if (state is CattleListLoaded) {
          try {
            final cow = state.cattleList.firstWhere(
              (c) =>
                  c.tagNumber == record.cowTagNumber ||
                  c.name.toLowerCase() == record.cowName.toLowerCase(),
            );
            animalId = cow.id;
            debugPrint('[HeatRecordScreen] Resolved animalId=$animalId via CattleBloc for "${record.cowName}"');
          } catch (_) {
            throw Exception('Could not find "${record.cowName}" (tag: ${record.cowTagNumber}) in the cattle list. Please refresh and try again.');
          }
        } else {
          throw Exception('Cattle list not loaded. Please go back and reopen this screen.');
        }
      }

      // ── Step 2: fetch the per-animal heat history to get the record _id ────
      // The report endpoint deliberately omits _id; the history endpoint has it.
      debugPrint('[HeatRecordScreen] Fetching heat history for animalId=$animalId');
      final history = await sl<ApiService>().getHeatHistory(animalId: animalId);

      final targetDateStr = record.heatDate.toIso8601String().split('T')[0];
      String deleteId = '';

      for (final item in history) {
        if (item is Map) {
          final itemDate = (item['date'] ?? '').toString().split('T')[0];
          if (itemDate == targetDateStr) {
            deleteId = item['_id']?.toString() ?? item['id']?.toString() ?? '';
            debugPrint('[HeatRecordScreen] Matched history record _id="$deleteId" on date $targetDateStr');
            break;
          }
        }
      }

      if (deleteId.isEmpty) {
        throw Exception('Could not find heat record for "${record.cowName}" on ${targetDateStr}. It may have already been deleted.');
      }

      // ── Step 3: delete ─────────────────────────────────────────────────────
      // gaushala-id header is auto-injected by ApiClient interceptor
      await sl<ApiService>().deleteHeatRecord(id: deleteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Heat record deleted successfully')),
        );
      }
      _fetchRecords();
    } catch (e) {
      debugPrint('[HeatRecordScreen] Deletion error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deletion failed: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Retry', onPressed: () => _deleteRecord(record)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final fmt = DateFormat('dd-MMM-yyyy');

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
          'Heat Record',
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
        children: [
          // Date range filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'to',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        'Total: ${filtered.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filtered.map(
                        (r) => _HeatRecordCard(
                          record: r,
                          onEdit: () async {
                            final updated = await Navigator.push<HeatRecord>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditHeatRecordScreen(
                                  record: r,
                                  knownCowNames: const [],
                                ),
                              ),
                            );
                            if (updated != null) {
                              _fetchRecords();
                            }
                          },
                          onDelete: () => _showDeleteDialog(r),
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
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddHeatRecordScreen(
                  cattle: context.read<CattleBloc>().state is CattleListLoaded
                      ? (context.read<CattleBloc>().state as CattleListLoaded)
                            .cattleList
                      : <Cattle>[],
                  knownCowNames: const [],
                ),
              ),
            );
            if (result == true || result is HeatRecord) {
              _fetchRecords();
            }
          },
          backgroundColor: const Color(0xFF99AA5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Heat Record',
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

  // ── helpers ──────────────────────────────────────────────────────────────

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
            'No data found',
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
            _errorMessage ?? 'Service not available',
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
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(HeatRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Record',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this heat record?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteRecord(record);
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HeatRecordCard
// ---------------------------------------------------------------------------
class _HeatRecordCard extends StatelessWidget {
  final HeatRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HeatRecordCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final heatDateFmt = DateFormat('dd MMM, yyyy').format(record.heatDate);

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
          // --- Top row: image + name + tags ---
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Tag No pill
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
                                    'Tag No.: ${record.cowTagNumber}',
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
                            'No. ${record.cowSerialNumber}',
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

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // --- Detail rows ---
          _DetailRow(
            iconBg: const Color(0xFFF5F5F5),
            iconColor: Colors.grey,
            icon: Icons.access_time_rounded,
            label: 'Parity:',
            value: record.parity.toString(),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            iconBg: const Color(0xFFE8F5E9),
            iconColor: Colors.green,
            icon: Icons.eco_rounded,
            label: 'Breeding Status:',
            valueWidget: Text(
              record.isConceived ? 'Conceived' : 'Not Conceived',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: record.isConceived ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            iconBg: const Color(0xFFE3F2FD),
            iconColor: Colors.blue,
            icon: Icons.calendar_today_rounded,
            label: 'Heat Date:',
            value: heatDateFmt,
          ),
          if (record.note != null && record.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetailRow(
              iconBg: const Color(0xFFF5F5F5),
              iconColor: Colors.grey,
              icon: Icons.notes_rounded,
              label: 'Note:',
              value: record.note!,
            ),
          ],

          const SizedBox(height: 14),
          // --- Action buttons ---
          Row(
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DetailRow helper
// ---------------------------------------------------------------------------
class _DetailRow extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              valueWidget ??
                  Text(
                    value ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
