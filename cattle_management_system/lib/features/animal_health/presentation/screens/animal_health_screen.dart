import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/health_event.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Status colors ─────────────────────────────────────────────────────────

const _statusOptions = ['Healthy', 'Under Treatment', 'Recovered'];

// ── Status colors ─────────────────────────────────────────────────────────
Color _statusColor(String status) {
  switch (status) {
    case 'Under Treatment':
      return Colors.orange;
    case 'Recovered':
      return Colors.blue;
    default:
      return const Color(0xFF99AA5A);
  }
}

Color _statusBg(String status) {
  switch (status) {
    case 'Under Treatment':
      return const Color(0xFFFFF3E0);
    case 'Recovered':
      return const Color(0xFFE3F2FD);
    default:
      return const Color(0xFFE8F5E9);
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case 'Medical':
      return Icons.medical_services_outlined;
    case 'Vaccination':
      return Icons.colorize_outlined;
    case 'Deworming':
      return Icons.spa_outlined;
    case 'Lab Testing':
      return Icons.biotech_outlined;
    default:
      return Icons.health_and_safety_outlined;
  }
}

Color _typeColor(String type) {
  switch (type) {
    case 'Medical':
      return Colors.red;
    case 'Vaccination':
      return Colors.blue;
    case 'Deworming':
      return Colors.green;
    case 'Lab Testing':
      return Colors.purple;
    default:
      return const Color(0xFF99AA5A);
  }
}

String _specificLabel(String type) {
  switch (type) {
    case 'Medical':
      return 'Diagnosis';
    case 'Vaccination':
      return 'Vaccine Name';
    case 'Deworming':
      return 'Drug / Medicine';
    case 'Lab Testing':
      return 'Test Name';
    default:
      return 'Details';
  }
}

String? _specificValue(HealthEvent e) {
  switch (e.eventType) {
    case 'Medical':
      return e.diagnosis;
    case 'Vaccination':
      return e.vaccineName;
    case 'Deworming':
      return e.dewormingDrug;
    case 'Lab Testing':
      return e.testName;
    default:
      return null;
  }
}

// ---------------------------------------------------------------------------
// AnimalHealthScreen
// ---------------------------------------------------------------------------
class AnimalHealthScreen extends StatefulWidget {
  final String
  eventType; // 'Medical' | 'Vaccination' | 'Deworming' | 'Lab Testing'

  const AnimalHealthScreen({super.key, required this.eventType});

  @override
  State<AnimalHealthScreen> createState() => _AnimalHealthScreenState();
}

class _AnimalHealthScreenState extends State<AnimalHealthScreen> {
  List<HealthEvent> _records = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();

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
      final api = sl<ApiService>();
      List<dynamic> data = [];

      switch (widget.eventType) {
        case 'Medical':
          data = await api.getMedicalHistory();
          break;
        case 'Vaccination':
          data = await api.getVaccinationHistory();
          break;
        case 'Deworming':
          data = await api.getDewormingRecords();
          break;
        case 'Lab Testing':
          data = await api.getLabRecords();
          break;
        default:
          data = [];
      }

      if (!mounted) return;
      setState(() {
        _records = data
            .map((e) => HealthEvent.fromJson(e, widget.eventType))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Service not available';
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<HealthEvent> get _filtered {
    if (_searchQuery.isEmpty) return _records;
    final q = _searchQuery.toLowerCase();
    return _records
        .where(
          (r) =>
              r.cowName.toLowerCase().contains(q) ||
              r.cowTagNumber.toLowerCase().contains(q) ||
              (r.doctorName?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  void _addRecord(HealthEvent e) => _fetchRecords();
  void _deleteRecord(String id) =>
      _fetchRecords(); // Ideally call API DELETE, but refresh for now

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final color = _typeColor(widget.eventType);

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
          widget.eventType,
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
              onTap: () => setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                }
              }),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _searchOpen ? color : const Color(0xFF99AA5A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _searchOpen ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ─────────────────────────────────────────────
          if (_searchOpen)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: GoogleFonts.inter(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search by cow or doctor...',
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

          // ── List ───────────────────────────────────────────────────
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
                        (r) => _HealthEventCard(
                          record: r,
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
            final newR = await Navigator.push<HealthEvent>(
              context,
              MaterialPageRoute(
                builder: (_) => AddHealthEventScreen(
                  eventType: widget.eventType,
                  knownCows:
                      (context.read<CattleBloc>().state is CattleListLoaded)
                      ? (context.read<CattleBloc>().state as CattleListLoaded)
                            .cattleList
                            .map((c) => c.name)
                            .toList()
                      : [],
                ),
              ),
            );
            if (newR != null) _addRecord(newR);
          },
          backgroundColor: const Color(0xFF99AA5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add ${widget.eventType}',
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
            'No records found',
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
          'Delete Record',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this record?',
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
              _deleteRecord(id);
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HealthEventCard
// ---------------------------------------------------------------------------
class _HealthEventCard extends StatelessWidget {
  final HealthEvent record;
  final VoidCallback onDelete;

  const _HealthEventCard({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    final color = _typeColor(record.eventType);
    final specificVal = _specificValue(record);

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
          // ── Top: cow + status ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF5F5F5),
                  image: const DecorationImage(
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
                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBg(record.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            record.status,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _statusColor(record.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
                        Text(
                          'No. ${record.cowSerialNumber}',
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

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Details ────────────────────────────────────────────────
          if (specificVal != null) ...[
            _InfoRow(
              iconBg: color.withOpacity(0.12),
              iconColor: color,
              icon: _typeIcon(record.eventType),
              label: _specificLabel(record.eventType),
              value: specificVal,
            ),
            const SizedBox(height: 8),
          ],
          if (record.doctorName != null) ...[
            _InfoRow(
              iconBg: const Color(0xFFF5F5F5),
              iconColor: Colors.grey,
              icon: Icons.person_outline,
              label: 'Doctor / Technician',
              value: record.doctorName!,
            ),
            const SizedBox(height: 8),
          ],
          _InfoRow(
            iconBg: const Color(0xFFE3F2FD),
            iconColor: Colors.blue,
            icon: Icons.calendar_today_rounded,
            label: 'Event Date',
            value: fmt.format(record.eventDate),
          ),
          if (record.nextDueDate != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              iconBg: const Color(0xFFFFF3E0),
              iconColor: Colors.orange,
              icon: Icons.event_repeat_rounded,
              label: 'Next Due Date',
              value: fmt.format(record.nextDueDate!),
            ),
          ],
          if (record.note != null && record.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              iconBg: const Color(0xFFF5F5F5),
              iconColor: Colors.grey,
              icon: Icons.notes_rounded,
              label: 'Note',
              value: record.note!,
            ),
          ],

          const SizedBox(height: 14),
          // ── Action buttons ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
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
// _InfoRow helper
// ---------------------------------------------------------------------------
class _InfoRow extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
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
              Text(
                value,
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

// ---------------------------------------------------------------------------
// AddHealthEventScreen
// ---------------------------------------------------------------------------
class AddHealthEventScreen extends StatefulWidget {
  final String eventType;
  final List<String> knownCows;

  const AddHealthEventScreen({
    super.key,
    required this.eventType,
    required this.knownCows,
  });

  @override
  State<AddHealthEventScreen> createState() => _AddHealthEventScreenState();
}

class _AddHealthEventScreenState extends State<AddHealthEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCow;
  String _selectedStatus = 'Healthy';
  final _specificCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime? _eventDate;
  DateTime? _nextDueDate;

  @override
  void dispose() {
    _specificCtrl.dispose();
    _doctorCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isNext) async {
    final initial = isNext
        ? (_nextDueDate ?? DateTime.now().add(const Duration(days: 30)))
        : (_eventDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
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
    if (picked != null) {
      setState(() {
        if (isNext) {
          _nextDueDate = picked;
        } else {
          _eventDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_selectedCow == null) {
      _snack('Please select a cow');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_eventDate == null) {
      _snack('Please select an event date');
      return;
    }

    final record = HealthEvent(
      id: const Uuid().v4(),
      cowName: _selectedCow!,
      cowTagNumber: '${widget.knownCows.indexOf(_selectedCow!) + 100}',
      cowSerialNumber: '000${widget.knownCows.indexOf(_selectedCow!) + 1}',
      eventType: widget.eventType,
      diagnosis: widget.eventType == 'Medical' ? _specificCtrl.text : null,
      vaccineName: widget.eventType == 'Vaccination'
          ? _specificCtrl.text
          : null,
      dewormingDrug: widget.eventType == 'Deworming'
          ? _specificCtrl.text
          : null,
      testName: widget.eventType == 'Lab Testing' ? _specificCtrl.text : null,
      doctorName: _doctorCtrl.text.isNotEmpty ? _doctorCtrl.text : null,
      eventDate: _eventDate!,
      nextDueDate: _nextDueDate,
      note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
      status: _selectedStatus,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, record);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF99AA5A),
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Add ${widget.eventType}',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cow ──────────────────────────────────────────────
              _label('Cow'),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: 'Select cow',
                value: _selectedCow,
                items: List<String>.from(widget.knownCows),
                onChanged: (v) => setState(() => _selectedCow = v),
              ),
              const SizedBox(height: 20),

              // ── Specific field (Diagnosis / Vaccine / Drug / Test) ──
              _label(_specificLabel(widget.eventType)),
              const SizedBox(height: 8),
              _buildTextField(
                ctrl: _specificCtrl,
                hint: 'Enter ${_specificLabel(widget.eventType).toLowerCase()}',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // ── Doctor / Technician ──────────────────────────────
              _label('Doctor / Technician'),
              const SizedBox(height: 8),
              _buildTextField(
                ctrl: _doctorCtrl,
                hint: 'Enter doctor or technician name',
              ),
              const SizedBox(height: 20),

              // ── Status ───────────────────────────────────────────
              _label('Status'),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: 'Select status',
                value: _selectedStatus,
                items: List<String>.from(_statusOptions),
                onChanged: (v) =>
                    setState(() => _selectedStatus = v ?? 'Healthy'),
              ),
              const SizedBox(height: 20),

              // ── Event Date ───────────────────────────────────────
              _label('Event Date'),
              const SizedBox(height: 8),
              _dateTile(
                label: _eventDate == null
                    ? 'Select event date'
                    : dateFmt.format(_eventDate!),
                onTap: () => _pickDate(false),
                hasValue: _eventDate != null,
              ),
              const SizedBox(height: 20),

              // ── Next Due Date (optional) ──────────────────────────
              _label('Next Due Date (optional)'),
              const SizedBox(height: 8),
              _dateTile(
                label: _nextDueDate == null
                    ? 'Select next due date'
                    : dateFmt.format(_nextDueDate!),
                onTap: () => _pickDate(true),
                hasValue: _nextDueDate != null,
              ),
              const SizedBox(height: 20),

              // ── Note ──────────────────────────────────────────────
              _label('Note (optional)'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add any additional notes...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99AA5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Submit',
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
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
  );

  Widget _dateTile({
    required String label,
    required VoidCallback onTap,
    required bool hasValue,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: hasValue ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          ),
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
          items: items
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController ctrl,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F6F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
