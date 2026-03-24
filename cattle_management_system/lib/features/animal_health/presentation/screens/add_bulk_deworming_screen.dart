import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import '../../../cattle/presentation/bloc/cattle_event.dart';
import '../../../cattle/domain/entities/cattle.dart';

class AddBulkDewormingScreen extends StatefulWidget {
  const AddBulkDewormingScreen({super.key});

  @override
  State<AddBulkDewormingScreen> createState() => _AddBulkDewormingScreenState();
}

class _AddBulkDewormingScreenState extends State<AddBulkDewormingScreen> {
  String _selectedAnimalType = 'Cow';
  String? _selectedDoseType;
  final _companyCtrl = TextEditingController();
  String? _selectedDoctorName;
  DateTime _selectedDate = DateTime.now();
  bool _selectAll = false;
  bool _isSubmitting = false;

  final List<String> _doseTypes = ['Injection', 'Tablet'];
  List<Map<String, dynamic>> _veterinarians = [];
  bool _isLoadingVets = true;
  List<_AnimalBulkSelection> _displayAnimals = [];

  @override
  void initState() {
    super.initState();
    _loadVeterinarians();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDisplayAnimals();
    });
  }

  void _loadVeterinarians() async {
    try {
      final vets = await sl<ApiService>().getVeterinarians();
      if (mounted) {
        setState(() {
          _veterinarians = vets;
          _isLoadingVets = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingVets = false);
    }
  }

  void _updateDisplayAnimals() {
    final state = context.read<CattleBloc>().state;
    if (state is CattleListLoaded) {
      setState(() {
        _displayAnimals = state.cattleList.where((c) {
          if (_selectedAnimalType == 'Cow') return c.gender.toUpperCase().startsWith('F');
          return c.gender.toUpperCase().startsWith('M');
        }).map((c) => _AnimalBulkSelection(
          id: c.id,
          name: c.name,
          tag: c.tagNumber,
          serial: c.serialNumber?.toString() ?? '',
        )).toList();
      });
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
          'Add Bulk Entry',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cow / Bull Tabs
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton('Cow'),
                        _buildTabButton('Bull'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  BlocListener<CattleBloc, CattleState>(
                    listener: (context, state) {
                      if (state is CattleListLoaded) _updateDisplayAnimals();
                    },
                    child: const SizedBox.shrink(),
                  ),

                  // Filter Row 1
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallDropdown(
                          hint: 'Dose Type',
                          value: _selectedDoseType,
                          items: _doseTypes,
                          onChanged: (val) =>
                              setState(() => _selectedDoseType = val),
                        ),
                      ),

                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSmallTextField(
                          controller: _companyCtrl,
                          hint: 'Company Name',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Filter Row 2
                  Row(
                    children: [
                      Expanded(
                        child: _isLoadingVets
                            ? Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F6F7),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : _buildSmallDropdown(
                                hint: 'Doctor Name',
                                value: _selectedDoctorName,
                                items: _veterinarians.map((v) => v['name'] as String).toList(),
                                onChanged: (val) => setState(() => _selectedDoctorName = val),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSmallDatePickerField(
                          value: _selectedDate,
                          onTap: () => _pickDate(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Select All
                  Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        activeColor: const Color(0xFF99AA5A),
                        onChanged: (val) {
                          setState(() {
                            _selectAll = val!;
                            for (var a in _displayAnimals) {
                              a.isSelected = _selectAll;
                            }
                          });
                        },
                      ),
                      Text(
                        'Select all',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_displayAnimals.isEmpty)
                        Text(
                          'No cattle found',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Animal List
                  ..._displayAnimals.map((a) => _buildAnimalCard(a)).toList(),
                ],
              ),
            ),
          ),
          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
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
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String type) {
    bool isSelected = _selectedAnimalType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedAnimalType = type;
          _updateDisplayAnimals();
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

  Widget _buildSmallDropdown({
    required String hint,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: (value != null && items.contains(value)) ? value : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          hint: Text(
            hint,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.inter(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSmallTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallDatePickerField({
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMM, yyyy').format(value),
              style: GoogleFonts.inter(fontSize: 12),
            ),
            const Icon(
              Icons.calendar_month_rounded,
              size: 14,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalCard(_AnimalBulkSelection a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: a.isSelected,
                activeColor: const Color(0xFF99AA5A),
                onChanged: (val) => setState(() => a.isSelected = val!),
              ),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/mother_cow.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF6D8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Tag No. : ${a.tag}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Color(0xFFB38D1D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'No. : ${a.serial}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniInfo('Age', '-'),
              _buildMiniInfo('Last Dose Date', '0 Month'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.colorize, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Qty.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM, yyyy').format(_selectedDate),
                          style: GoogleFonts.inter(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$label : ',
          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF99AA5A),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() async {
    final selectedIds = _displayAnimals
        .where((a) => a.isSelected)
        .map((a) => a.id)
        .toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one animal')),
      );
      return;
    }
    if (_selectedDoseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dose type')),
      );
      return;
    }

    String? resolvedVetId;
    if (_selectedDoctorName != null && _veterinarians.isNotEmpty) {
      try {
        final vet = _veterinarians.firstWhere((v) => v['name'] == _selectedDoctorName);
        resolvedVetId = vet['id'] ?? vet['_id'];
      } catch (e) {}
    }

    setState(() => _isSubmitting = true);
    try {
      await sl<ApiService>().addBulkDewormingRecord(
        animalIds: selectedIds,
        doseDate: _selectedDate,
        doseType: _selectedDoseType!.toUpperCase(),
        companyName: _companyCtrl.text.isEmpty ? 'Unknown' : _companyCtrl.text,
        vetId: resolvedVetId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bulk deworming records added successfully')),
        );
        Navigator.pop(context, true);
      }
    } on ServerException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _AnimalBulkSelection {
  final String id;
  final String name;
  final String tag;
  final String serial;
  bool isSelected;

  _AnimalBulkSelection({
    required this.id,
    required this.name,
    required this.tag,
    required this.serial,
  }) : isSelected = false;
}
