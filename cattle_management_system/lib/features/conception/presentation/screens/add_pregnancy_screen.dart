import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../../../cattle/domain/entities/cattle.dart';

class AddPregnancyScreen extends StatefulWidget {
  final List<Cattle> knownCows;
  final String? prefillCow;
  final int? prefillParity;

  const AddPregnancyScreen({
    super.key,
    required this.knownCows,
    this.prefillCow,
    this.prefillParity,
  });

  @override
  State<AddPregnancyScreen> createState() => _AddPregnancyScreenState();
}

class _AddPregnancyScreenState extends State<AddPregnancyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parityCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();

  Cattle? _selectedCow;
  String _pregnancyType = 'Natural';
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _loadingBulls = false;
  String? _selectedBullId;
  List<Map<String, String>> _bullOptions = [];

  @override
  void initState() {
    super.initState();
    if (widget.prefillCow != null) {
      for (final cow in widget.knownCows) {
        if (cow.name == widget.prefillCow) {
          _selectedCow = cow;
          break;
        }
      }
    }
    if (widget.prefillParity != null) {
      _parityCtrl.text = widget.prefillParity.toString();
    }
    _fetchEligibleBulls();
  }

  @override
  void dispose() {
    _parityCtrl.dispose();
    _serialCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchEligibleBulls() async {
    setState(() => _loadingBulls = true);
    try {
      final data = await sl<ApiService>().getEligibleBulls();
      final options = data.map<Map<String, String>>((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = (map['_id'] ?? map['id'] ?? '').toString();
        final name = (map['name'] ?? 'Unknown Bull').toString();
        final tag = (map['tagNumber'] ?? '').toString();
        final label = tag.isEmpty ? name : '$name ($tag)';
        return {'id': id, 'label': label};
      }).where((item) => item['id']!.isNotEmpty).toList();

      if (mounted) {
        setState(() => _bullOptions = options);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _bullOptions = []);
      }
    } finally {
      if (mounted) setState(() => _loadingBulls = false);
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
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedCow == null) {
      _showError('Please select a cow');
      return;
    }
    if (_pregnancyType == 'Natural' && _selectedBullId == null) {
      _showError('Please select a bull');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Please select a date');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await sl<ApiService>().initiatePregnancy(
        animalId: _selectedCow!.id,
        conceiveDate: _selectedDate!,
        pregnancyType: _pregnancyType.toUpperCase(),
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ServerException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Failed to add pregnancy: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF99AA5A),
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  DateTime? get _alertDay30 => _selectedDate?.add(const Duration(days: 30));
  DateTime? get _alertDay60 => _selectedDate?.add(const Duration(days: 60));
  DateTime? get _alertDay90 => _selectedDate?.add(const Duration(days: 90));

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM, yyyy');
    final cowItems = widget.knownCows
        .where((cow) => cow.status.toUpperCase() == 'ACTIVE')
        .where((cow) => cow.gender.toUpperCase().startsWith('F'))
        .toList();

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
          'Add Pregnancy',
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
              _label('Cow'),
              const SizedBox(height: 8),
              _buildDropdown<Cattle>(
                hint: 'Select cow',
                value: _selectedCow,
                items: cowItems,
                labelBuilder: (cow) => '${cow.name} (${cow.tagNumber})',
                onChanged: (value) => setState(() => _selectedCow = value),
              ),
              const SizedBox(height: 20),
              _label('Type of Pregnancy'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RadioOpt(
                    label: 'Natural',
                    selected: _pregnancyType == 'Natural',
                    onTap: () => setState(() => _pregnancyType = 'Natural'),
                  ),
                  const SizedBox(width: 24),
                  _RadioOpt(
                    label: 'AI',
                    selected: _pregnancyType == 'AI',
                    onTap: () => setState(() => _pregnancyType = 'AI'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _label('Bull'),
              const SizedBox(height: 8),
              _loadingBulls
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _buildDropdown<String>(
                      hint: _bullOptions.isEmpty ? 'No bulls available' : 'Select bull',
                      value: _selectedBullId,
                      items: _bullOptions.map((bull) => bull['id']!).toList(),
                      labelBuilder: (id) {
                        final match = _bullOptions.firstWhere(
                          (bull) => bull['id'] == id,
                          orElse: () => const {'id': '', 'label': '-'},
                        );
                        return match['label']!;
                      },
                      onChanged: _bullOptions.isEmpty
                          ? null
                          : (value) => setState(() => _selectedBullId = value),
                    ),
              const SizedBox(height: 20),
              if (_pregnancyType == 'AI') ...[
                _label('Serial Number'),
                const SizedBox(height: 8),
                _buildTextField(
                  ctrl: _serialCtrl,
                  hint: 'Enter serial number',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required for AI' : null,
                ),
                const SizedBox(height: 20),
                _label('Company Name'),
                const SizedBox(height: 8),
                _buildTextField(
                  ctrl: _companyCtrl,
                  hint: 'Enter company name',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required for AI' : null,
                ),
                const SizedBox(height: 20),
              ],
              _label('Parity'),
              const SizedBox(height: 8),
              _buildTextField(
                ctrl: _parityCtrl,
                hint: 'Enter parity number',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _label('Date'),
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
                              ? 'Select date'
                              : dateFmt.format(_selectedDate!),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _selectedDate == null ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedDate != null) ...[
                _buildPregnancyAlert(dateFmt),
                const SizedBox(height: 20),
              ],
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
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
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

  Widget _buildPregnancyAlert(DateFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.red,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Pregnancy Check Alert',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                _AlertDateColumn(label: 'After 30 days', date: fmt.format(_alertDay30!)),
                _VerticalDivider(),
                _AlertDateColumn(label: 'After 60 days', date: fmt.format(_alertDay60!)),
                _VerticalDivider(),
                _AlertDateColumn(label: 'After 90 days', date: fmt.format(_alertDay90!)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
      );

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T item) labelBuilder,
    required ValueChanged<T?>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(labelBuilder(item)),
                  ))
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _RadioOpt extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOpt({
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

class _AlertDateColumn extends StatelessWidget {
  final String label;
  final String date;

  const _AlertDateColumn({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: Colors.red.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
