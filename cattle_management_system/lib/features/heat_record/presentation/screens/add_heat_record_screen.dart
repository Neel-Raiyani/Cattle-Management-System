import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/heat_record.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/localization/localized_ui.dart';
import '../../../../core/utils/app_feedback.dart';

class AddHeatRecordScreen extends StatefulWidget {
  /// Pass the list of actual Cattle objects so we can get their IDs for the API.
  /// For backward-compat we still accept knownCowNames (ignored when cattle provided).
  final List<String> knownCowNames;
  final List<Cattle> cattle;

  const AddHeatRecordScreen({
    super.key,
    this.knownCowNames = const [],
    this.cattle = const [],
  });

  @override
  State<AddHeatRecordScreen> createState() => _AddHeatRecordScreenState();
}

class _AddHeatRecordScreenState extends State<AddHeatRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  Cattle? _selectedCattle;
  final _parityController = TextEditingController();
  bool _isConceived = true;
  DateTime? _heatDate;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  String? _cowNameError;

  // Get female cows for heat records (only cows can be in heat)
  List<Cattle> get _femaleCattle => widget.cattle.where((c) {
    final g = c.gender.toLowerCase();
    return g == 'female' || g == 'cow' || g.startsWith('f');
  }).toList();

  @override
  void dispose() {
    _parityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickHeatDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  Future<void> _submit() async {
    if (_selectedCattle == null && widget.cattle.isNotEmpty) {
      setState(() => _cowNameError = context.ui.pleaseSelectCow);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_heatDate == null) {
      AppFeedback.showError(context, context.ui.pleaseSelectHeatDate);
      return;
    }

    // If we have real cattle, call the API
    if (widget.cattle.isNotEmpty && _selectedCattle != null) {
      setState(() => _isSubmitting = true);
      try {
        await sl<ApiService>().recordHeat(
          animalId: _selectedCattle!.id,
          date: _heatDate!,
          breedingType: _isConceived ? 'AI' : 'NATURAL',
        );

        if (mounted) {
          AppFeedback.showSuccess(context, 'Heat record added successfully');
          Navigator.pop(context, true);
        }
      } on ServerException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    } else {
      // Fallback for backward-compat (when called with string names only)
      final newRecord = HeatRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cowName: _selectedCattle?.name ?? '',
        cowTagNumber: _selectedCattle?.tagNumber ?? '',
        cowSerialNumber: _selectedCattle?.tagNumber ?? '',
        parity: int.tryParse(_parityController.text) ?? 0,
        isConceived: _isConceived,
        heatDate: _heatDate!,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        createdAt: DateTime.now(),
      );
      Navigator.pop(context, newRecord);
    }
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
          context.ui.addHeatRecord,
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
              // ── Name ────────────────────────────────────────────────────
              _sectionLabel(context.ui.name),
              const SizedBox(height: 8),
              _buildCowDropdown(),
              if (_cowNameError != null) ...[
                const SizedBox(height: 8),
                _buildErrorBanner(_cowNameError!),
              ],
              const SizedBox(height: 20),

              // ── Parity ───────────────────────────────────────────────────
              _sectionLabel(context.ui.parity),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _parityController,
                hint: context.ui.parityNumber,
                keyboardType: TextInputType.number,
                enabled: false, // User cannot edit parity
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // ── Breeding Status ────────────────────────────────────────
              _sectionLabel(context.ui.breedingStatus),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RadioOption(
                    label: context.ui.conceived,
                    selected: _isConceived,
                    onTap: () => setState(() => _isConceived = true),
                  ),
                  const SizedBox(width: 24),
                  _RadioOption(
                    label: context.ui.notConceived,
                    selected: !_isConceived,
                    onTap: () => setState(() => _isConceived = false),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Heat Date ─────────────────────────────────────────────
              _sectionLabel(context.ui.heatDate),
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
                              ? context.ui.selectHeatDate
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

              // ── Note ─────────────────────────────────────────────────
              _sectionLabel(context.ui.note),
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
                    hintText: context.ui.addAnyNotesOptional,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
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
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99AA5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
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
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Widget _buildCowDropdown() {
    final items = _femaleCattle.isNotEmpty ? _femaleCattle : <Cattle>[];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Cattle>(
          value: _selectedCattle,
          isExpanded: true,
          hint: Text(
            context.ui.selectCowName,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          ),
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
          items: items
              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedCattle = val;
              _cowNameError = null;
              if (val != null) {
                _parityController.text = (val.parity ?? 0).toString();
              } else {
                _parityController.text = '';
              }
            });
          },
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
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

// ---------------------------------------------------------------------------
// _RadioOption
// ---------------------------------------------------------------------------
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
