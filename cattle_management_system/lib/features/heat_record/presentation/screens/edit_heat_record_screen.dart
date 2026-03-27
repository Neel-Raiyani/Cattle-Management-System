import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/heat_record.dart';
import '../../../../core/utils/app_feedback.dart';

class EditHeatRecordScreen extends StatefulWidget {
  final HeatRecord record;
  final List<String> knownCowNames;

  const EditHeatRecordScreen({
    super.key,
    required this.record,
    required this.knownCowNames,
  });

  @override
  State<EditHeatRecordScreen> createState() => _EditHeatRecordScreenState();
}

class _EditHeatRecordScreenState extends State<EditHeatRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late String? _selectedCowName;
  late TextEditingController _parityController;
  late bool _isConceived;
  late DateTime? _heatDate;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _selectedCowName = widget.record.cowName;
    _parityController =
        TextEditingController(text: widget.record.parity.toString());
    _isConceived = widget.record.isConceived;
    _heatDate = widget.record.heatDate;
    _noteController =
        TextEditingController(text: widget.record.note ?? '');
  }

  @override
  void dispose() {
    _parityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickHeatDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _heatDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF99AA5A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _heatDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_heatDate == null) {
      AppFeedback.showError(context, 
            'Please select a heat date',
          );
      return;
    }

    final updated = widget.record.copyWith(
      cowName: _selectedCowName,
      parity: int.tryParse(_parityController.text) ?? widget.record.parity,
      isConceived: _isConceived,
      heatDate: _heatDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
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
          'Edit Heat Record',
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
              // ── Name (read-only — cow is fixed when editing) ──────────
              _sectionLabel('Name'),
              const SizedBox(height: 8),
              _buildReadOnlyCowName(),
              const SizedBox(height: 20),

              // ── Parity ───────────────────────────────────────────────
              _sectionLabel('Parity'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _parityController,
                hint: 'Parity number',
                keyboardType: TextInputType.number,
                enabled: false,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // ── Breeding Status ───────────────────────────────────────
              _sectionLabel('Breeding Status'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RadioOption(
                    label: 'Conceived',
                    selected: _isConceived,
                    onTap: () => setState(() => _isConceived = true),
                  ),
                  const SizedBox(width: 24),
                  _RadioOption(
                    label: 'Not Conceived',
                    selected: !_isConceived,
                    onTap: () => setState(() => _isConceived = false),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Heat Date ─────────────────────────────────────────────
              _sectionLabel('Heat date'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickHeatDate,
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
                          _heatDate == null
                              ? 'Select heat date'
                              : DateFormat('dd MMM, yyyy').format(_heatDate!),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _heatDate == null
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
              const SizedBox(height: 20),

              // ── Note ──────────────────────────────────────────────────
              _sectionLabel('Note'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _noteController,
                  maxLines: 4,
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add any notes (optional)',
                    hintStyle:
                        GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // ── Submit ────────────────────────────────────────────────
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

  // ── helpers ──────────────────────────────────────────────────────────────

  /// Read-only display of the cow name — we don't allow changing the cow
  /// when editing an existing heat record.
  Widget _buildReadOnlyCowName() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        _selectedCowName ?? '',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: enabled ? Colors.black87 : Colors.grey[700],
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: enabled ? const Color(0xFFF5F6F7) : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }
}

// ── Local RadioOption widget (mirrors the one in add_heat_record_screen) ────
class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? const Color(0xFF99AA5A) : Colors.grey,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF99AA5A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
