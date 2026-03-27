import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cattle_management_system/core/localization/app_text.dart';
import 'death_report_screen.dart';
import 'donation_report_screen.dart';
import 'sell_report_screen.dart';
import '../../domain/entities/animal_left_record.dart';
import '../../../../core/utils/app_feedback.dart';

// ---------------------------------------------------------------------------
// Mock data factory
// ---------------------------------------------------------------------------
List<AnimalLeftRecord> _mockFor(String type) {
  switch (type) {
    case 'Sell':
      return [
        AnimalLeftRecord(
          id: 's1',
          cowName: 'Meghna',
          cowTagNumber: '101',
          cowSerialNumber: '0002',
          recordType: 'Sell',
          date: DateTime(2025, 10, 14),
          buyerOrDoneeName: 'Rameshbhai Patel',
          amount: '₹55,000',
          note: 'Sold to nearby gaushala',
          createdAt: DateTime(2025, 10, 14),
        ),
      ];
    case 'Death':
      return [
        AnimalLeftRecord(
          id: 'd1',
          cowName: 'Sundari',
          cowTagNumber: '103',
          cowSerialNumber: '0003',
          recordType: 'Death',
          date: DateTime(2025, 11, 8),
          cause: 'Old age / natural death',
          note: 'Buried inside gaushala premises',
          createdAt: DateTime(2025, 11, 8),
        ),
      ];
    case 'Donation':
      return [
        AnimalLeftRecord(
          id: 'don1',
          cowName: 'Ganga',
          cowTagNumber: '106',
          cowSerialNumber: '0006',
          recordType: 'Donation',
          date: DateTime(2025, 12, 1),
          buyerOrDoneeName: 'Shri Ram Trust, Surat',
          note: 'Donated on auspicious occasion',
          createdAt: DateTime(2025, 12, 1),
        ),
      ];
    default:
      return [];
  }
}

const _knownCows = [
  'Kalyanee',
  'Radha',
  'Ganga',
  'Yamuna',
  'Meghna',
  'Lakshmi',
  'Sundari',
];

// ── Per-type UI helpers ──────────────────────────────────────────────────
Color _typeColor(String type) {
  switch (type) {
    case 'Sell':
      return Colors.orange;
    case 'Death':
      return Colors.grey;
    case 'Donation':
      return Colors.green;
    default:
      return const Color(0xFF99AA5A);
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case 'Sell':
      return Icons.home_work;
    case 'Death':
      return Icons.warning_amber_rounded;
    case 'Donation':
      return Icons.volunteer_activism;
    default:
      return Icons.info;
  }
}

// ---------------------------------------------------------------------------
// AnimalLeftScreen
// ---------------------------------------------------------------------------
class AnimalLeftScreen extends StatefulWidget {
  final String recordType; // 'Sell' | 'Death' | 'Donation'

  const AnimalLeftScreen({super.key, required this.recordType});

  @override
  State<AnimalLeftScreen> createState() => _AnimalLeftScreenState();
}

class _AnimalLeftScreenState extends State<AnimalLeftScreen> {
  late List<AnimalLeftRecord> _records;
  String _searchQuery = '';
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _records = _mockFor(widget.recordType);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AnimalLeftRecord> get _filtered {
    if (_searchQuery.isEmpty) return _records;
    final q = _searchQuery.toLowerCase();
    return _records
        .where((r) =>
            r.cowName.toLowerCase().contains(q) ||
            r.cowTagNumber.toLowerCase().contains(q) ||
            (r.buyerOrDoneeName?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void _addRecord(AnimalLeftRecord r) => setState(() => _records.add(r));
  void _deleteRecord(String id) =>
      setState(() => _records.removeWhere((r) => r.id == id));

  @override
  Widget build(BuildContext context) {
    if (widget.recordType == 'Sell') {
      return const SellReportScreen();
    }
    if (widget.recordType == 'Death') {
      return const DeathReportScreen();
    }
    if (widget.recordType == 'Donation') {
      return const DonationReportScreen();
    }

    final filtered = _filtered;
    final color = _typeColor(widget.recordType);

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
              icon: const Icon(Icons.arrow_back,
                  color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          widget.recordType,
          style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20),
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
                    shape: BoxShape.circle),
                child: Icon(
                    _searchOpen ? Icons.close : Icons.search,
                    color: Colors.white,
                    size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──────────────────────────────────────────
          if (_searchOpen)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v),
                        style: GoogleFonts.inter(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: context.tr.searchByCowNameOrTag,
                          hintStyle: GoogleFonts.inter(
                              fontSize: 13, color: Colors.grey),
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
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(context.tr.total(filtered.length),
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...filtered.map((r) => _AnimalLeftCard(
                            record: r,
                            onDelete: () =>
                                _showDeleteDialog(r.id),
                          )),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final newR = await Navigator.push<AnimalLeftRecord>(
              context,
              MaterialPageRoute(
                builder: (_) => AddAnimalLeftScreen(
                  recordType: widget.recordType,
                  knownCows: _knownCows,
                ),
              ),
            );
            if (newR != null) _addRecord(newR);
          },
          backgroundColor: const Color(0xFF99AA5A),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            context.tr.addRecord(widget.recordType),
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14),
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
            errorBuilder: (_, __, ___) => const Icon(
                Icons.search_off_rounded,
                size: 100,
                color: Color(0xFFB5C97A)),
          ),
          const SizedBox(height: 16),
          Text(context.tr.noRecordsFound,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8DA94D))),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr.deleteRecord,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(context.tr.deleteRecordConfirmation,
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr.cancel,
                  style: GoogleFonts.inter(color: Colors.grey))),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _deleteRecord(id);
              },
              child: Text(context.tr.delete,
                  style: GoogleFonts.inter(color: Colors.red))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AnimalLeftCard
// ---------------------------------------------------------------------------
class _AnimalLeftCard extends StatelessWidget {
  final AnimalLeftRecord record;
  final VoidCallback onDelete;

  const _AnimalLeftCard({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, yyyy');
    final color = _typeColor(record.recordType);

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
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header strip ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(_typeIcon(record.recordType),
                    size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${record.recordType} Date: ${fmt.format(record.date)}',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Cow row ───────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF5F5F5),
                  image: const DecorationImage(
                      image: AssetImage('assets/icons/mother_cow.png'),
                      fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.cowName,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_offer,
                                    size: 10,
                                    color: Colors.brown),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${context.tr.tagNo}: ${record.cowTagNumber}',
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.brown[800]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${context.tr.numberShort} ${record.cowSerialNumber}',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Type-specific detail rows ─────────────────────────────
          if (record.buyerOrDoneeName != null)
            _infoRow(
              icon: record.recordType == 'Sell'
                  ? Icons.person_outline
                  : Icons.handshake_outlined,
              iconBg: color.withOpacity(0.1),
              iconColor: color,
              label: record.recordType == 'Sell'
                  ? context.tr.buyer
                  : context.tr.donatedTo,
              value: record.buyerOrDoneeName!,
            ),
          if (record.amount != null) ...[
            const SizedBox(height: 8),
            _infoRow(
              icon: Icons.currency_rupee,
              iconBg: Colors.green.withOpacity(0.1),
              iconColor: Colors.green,
              label: context.tr.amount,
              value: record.amount!,
            ),
          ],
          if (record.cause != null) ...[
            const SizedBox(height: 8),
            _infoRow(
              icon: Icons.report_outlined,
              iconBg: Colors.grey.withOpacity(0.1),
              iconColor: Colors.grey,
              label: context.tr.cause,
              value: record.cause!,
            ),
          ],
          if (record.note != null && record.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(
              icon: Icons.notes_rounded,
              iconBg: const Color(0xFFF5F5F5),
              iconColor: Colors.grey,
              label: context.tr.note,
              value: record.note!,
            ),
          ],

          const SizedBox(height: 14),
          // ── Action buttons ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.edit_outlined,
                      color: Color(0xFFA4C639), size: 18),
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
                        borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration:
              BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// AddAnimalLeftScreen
// ---------------------------------------------------------------------------
class AddAnimalLeftScreen extends StatefulWidget {
  final String recordType;
  final List<String> knownCows;

  const AddAnimalLeftScreen({
    super.key,
    required this.recordType,
    required this.knownCows,
  });

  @override
  State<AddAnimalLeftScreen> createState() => _AddAnimalLeftScreenState();
}

class _AddAnimalLeftScreenState extends State<AddAnimalLeftScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCow;
  DateTime? _selectedDate;
  final _buyerCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _causeCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _buyerCtrl.dispose();
    _amountCtrl.dispose();
    _causeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (_selectedCow == null) {
      _snack(context.tr.pleaseSelectCow);
      return;
    }
    if (_selectedDate == null) {
      _snack(context.tr.pleaseSelectDate);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final record = AnimalLeftRecord(
      id: const Uuid().v4(),
      cowName: _selectedCow!,
      cowTagNumber:
          '${widget.knownCows.indexOf(_selectedCow!) + 100}',
      cowSerialNumber:
          '000${widget.knownCows.indexOf(_selectedCow!) + 1}',
      recordType: widget.recordType,
      date: _selectedDate!,
      buyerOrDoneeName: (widget.recordType == 'Sell' ||
              widget.recordType == 'Donation')
          ? (_buyerCtrl.text.isNotEmpty ? _buyerCtrl.text : null)
          : null,
      amount: widget.recordType == 'Sell'
          ? (_amountCtrl.text.isNotEmpty ? '₹${_amountCtrl.text}' : null)
          : null,
      cause: widget.recordType == 'Death'
          ? (_causeCtrl.text.isNotEmpty ? _causeCtrl.text : null)
          : null,
      note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, record);
  }

  void _snack(String msg) {
    AppFeedback.showError(context, msg);
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
              icon: const Icon(Icons.arrow_back,
                  color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(context.tr.addRecordTitle(widget.recordType),
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cow ──────────────────────────────────────────────
              _label(context.tr.cow),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: context.tr.selectCowName,
                value: _selectedCow,
                items: List<String>.from(widget.knownCows),
                onChanged: (v) => setState(() => _selectedCow = v),
              ),
              const SizedBox(height: 20),

              // ── Date ─────────────────────────────────────────────
              _label(context.tr.recordDateLabel(widget.recordType)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  height: 50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? context.tr.selectDate
                              : dateFmt.format(_selectedDate!),
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _selectedDate == null
                                  ? Colors.grey
                                  : Colors.black87),
                        ),
                      ),
                      const Icon(Icons.calendar_today,
                          size: 18, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Sell-specific ────────────────────────────────────
              if (widget.recordType == 'Sell') ...[
                _label(context.tr.buyerName),
                const SizedBox(height: 8),
                _buildTextField(
                    ctrl: _buyerCtrl, hint: context.tr.enterBuyerName),
                const SizedBox(height: 20),
                _label(context.tr.amountRupees),
                const SizedBox(height: 8),
                _buildTextField(
                    ctrl: _amountCtrl,
                    hint: 'Enter sale amount',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 20),
              ],

              // ── Donation-specific ─────────────────────────────────
              if (widget.recordType == 'Donation') ...[
                _label(context.tr.donatedTo),
                const SizedBox(height: 8),
                _buildTextField(
                    ctrl: _buyerCtrl,
                    hint: context.tr.enterDoneeTrustName),
                const SizedBox(height: 20),
              ],

              // ── Death-specific ─────────────────────────────────────
              if (widget.recordType == 'Death') ...[
                _label(context.tr.causeOfDeath),
                const SizedBox(height: 8),
                _buildTextField(
                    ctrl: _causeCtrl,
                    hint: context.tr.enterCauseOfDeath),
                const SizedBox(height: 20),
              ],

              // ── Note ─────────────────────────────────────────────
              _label(context.tr.noteOptional),
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
                    hintText: context.tr.addAnyAdditionalNotes,
                    hintStyle: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey),
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
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  child: Text(context.tr.addRecord(widget.recordType),
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, fontSize: 14));

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
          hint: Text(hint,
              style:
                  GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
          style: GoogleFonts.inter(
              fontSize: 13, color: Colors.black87),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F6F7),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
      ),
    );
  }
}
