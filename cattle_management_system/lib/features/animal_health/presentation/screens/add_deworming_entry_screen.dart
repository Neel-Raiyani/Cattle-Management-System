import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/health_event.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/di/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import '../../../cattle/domain/entities/cattle.dart';

class AddDewormingEntryScreen extends StatefulWidget {
  final HealthEvent? existingRecord;
  const AddDewormingEntryScreen({super.key, this.existingRecord});

  @override
  State<AddDewormingEntryScreen> createState() =>
      _AddDewormingEntryScreenState();
}

class _AddDewormingEntryScreenState extends State<AddDewormingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedAnimalType = 'Cow';
  Cattle? _selectedAnimal;
  bool _isSubmitting = false;
  DateTime? _doseDate = DateTime.now();
  DateTime? _nextDoseDate;
  String _doseType = 'Tablet';
  final _companyCtrl = TextEditingController();
  String? _selectedQuantity;
  String? _selectedDoctorName;

  List<Cattle> _currentCattleList(BuildContext context) {
    final state = context.read<CattleBloc>().state;
    if (state is CattleListLoaded) {
      return state.cattleList.where((c) {
        bool typeMatch = _selectedAnimalType == 'Cow'
            ? c.gender.toUpperCase().startsWith('F')
            : c.gender.toUpperCase().startsWith('M');
        return typeMatch && c.isActive;
      }).toList();
    }
    return [];
  }

  final List<String> _quantities = ['1 Qty.', '2 Qty.', '3 Qty.'];
  List<Map<String, dynamic>> _veterinarians = [];
  bool _isLoadingVets = true;
  String? _vetLoadError;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      final r = widget.existingRecord!;
      // _selectedAnimal initialization from r.cowName would happen here
      _doseDate = r.eventDate;
      _nextDoseDate = r.nextDueDate;
      _doseType = r.doseType?.contains('Injection') == true
          ? 'Injection'
          : 'Tablet';
      _companyCtrl.text = r.dewormingDrug ?? '';
      _selectedDoctorName = r.doctorName;
      // Extract quantity if possible
      if (r.doseType != null) {
        final match = RegExp(r'\((\d+ Qty\.)\)').firstMatch(r.doseType!);
        if (match != null) {
          _selectedQuantity = match.group(1);
        }
      }
    }
    _loadVeterinarians();
  }

  Future<void> _loadVeterinarians() async {
    setState(() {
      _isLoadingVets = true;
      _vetLoadError = null;
    });
    try {
      final vets = await sl<ApiService>().getVeterinarians();
      if (mounted) {
        setState(() {
          _veterinarians = vets;
          _isLoadingVets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVets = false;
          _vetLoadError = 'Could not load doctors';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.existingRecord != null;

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
          isEdit ? 'Edit Krumi Dose' : 'Add Single Entry',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cow / Bull Tabs
              if (!isEdit)
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [_buildTabButton('Cow'), _buildTabButton('Bull')],
                  ),
                ),
              if (!isEdit) const SizedBox(height: 20),

              _buildLabel('Name'),
              _CattleDropdown(
                hint: 'Select ${_selectedAnimalType.toLowerCase()} name',
                value: _selectedAnimal,
                items: _currentCattleList(context),
                onChanged: (val) => setState(() => _selectedAnimal = val),
              ),
              const SizedBox(height: 16),

              _buildLabel('Dose Date'),
              _buildDatePickerField(
                value: _doseDate,
                onTap: () => _pickDate(true),
                hint: 'Select the dose date',
              ),
              const SizedBox(height: 16),

              if (isEdit) ...[
                _buildLabel('Next Dose Date'),
                _buildDatePickerField(
                  value: _nextDoseDate,
                  onTap: () => _pickDate(false),
                  hint: 'Select next dose date',
                ),
                const SizedBox(height: 16),
                // Info Bar (Age/Last Dose)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Age: 4 Year 1 Month',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Last Dose Date: 6 Month',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              _buildLabel('Dose Type'),
              Row(
                children: [
                  _buildRadioButton('Injection'),
                  const SizedBox(width: 24),
                  _buildRadioButton('Tablet'),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Company Name'),
              _buildTextField(
                controller: _companyCtrl,
                hint: 'Select the medicine company',
              ),
              const SizedBox(height: 16),

              _buildLabel('Quantity'),
              _buildDropdown(
                hint: 'Select the dose quantity',
                value: _selectedQuantity,
                items: _quantities,
                onChanged: (val) => setState(() => _selectedQuantity = val),
              ),
              const SizedBox(height: 16),

              _buildLabel('Doctor Name'),
              if (_vetLoadError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text(_vetLoadError!, style: GoogleFonts.inter(color: Colors.red, fontSize: 12)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _loadVeterinarians,
                        child: Text('Retry', style: GoogleFonts.inter(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              _isLoadingVets
                  ? Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _buildDropdown(
                      hint: 'Select the doctor\'s name',
                      value: _selectedDoctorName,
                      items: _veterinarians.map((v) => v['name'] as String).toList(),
                      onChanged: (val) => setState(() => _selectedDoctorName = val),
                    ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99AA5A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String type) {
    bool isSelected = _selectedAnimalType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedAnimalType = type;
          _selectedAnimal = null;
        }),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF99AA5A) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            type,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.inter(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    DateTime? value,
    required VoidCallback onTap,
    required String hint,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null ? DateFormat('dd MMM, yyyy').format(value) : hint,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: value != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(String value) {
    bool isSelected = _doseType == value;
    return GestureDetector(
      onTap: () => setState(() => _doseType = value),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF99AA5A) : Colors.grey,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 6,
              backgroundColor: isSelected
                  ? const Color(0xFF99AA5A)
                  : Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isDoseDose) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isDoseDose ? _doseDate : _nextDoseDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF99AA5A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDoseDose) {
          _doseDate = picked;
        } else {
          _nextDoseDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_selectedAnimal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an animal name')),
      );
      return;
    }
    if (_doseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a dose date')),
      );
      return;
    }

    String? resolvedVetId;
    if (_selectedDoctorName != null && _veterinarians.isNotEmpty) {
      try {
        final vet = _veterinarians.firstWhere(
          (v) => v['name'] == _selectedDoctorName,
        );
        resolvedVetId = vet['id'] ?? vet['_id'];
      } catch (e) {}
    }

    setState(() => _isSubmitting = true);
    try {
      await sl<ApiService>().addDewormingRecord(
        animalId: _selectedAnimal!.id,
        doseDate: _doseDate!,
        doseType: _doseType.toUpperCase() == 'INJECTION' ? 'INJECTION' : 'ORAL',
        companyName: _companyCtrl.text.isNotEmpty
            ? _companyCtrl.text
            : 'Unknown',
        quantity: _selectedQuantity,
        vetId: resolvedVetId,
        nextDoseDate: _nextDoseDate,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deworming record added successfully')),
        );
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
  }
}

class _CattleDropdown extends StatelessWidget {
  final Cattle? value;
  final String hint;
  final List<Cattle> items;
  final Function(Cattle?) onChanged;

  const _CattleDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Cattle>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
          ),
          isExpanded: true,
          items: items.map((Cattle val) {
            return DropdownMenuItem<Cattle>(
              value: val,
              child: Text(val.name, style: GoogleFonts.inter(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
