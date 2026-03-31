import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/health_event.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/di/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import '../../../cattle/domain/entities/cattle.dart';
import '../../../../core/utils/app_feedback.dart';

class AddVaccinationScreen extends StatefulWidget {
  final HealthEvent? existingRecord;
  const AddVaccinationScreen({super.key, this.existingRecord});

  @override
  State<AddVaccinationScreen> createState() => _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends State<AddVaccinationScreen> {
  static const String _kOtherId = '__OTHER__';
  String _animalType = 'Cow';
  Cattle? _selectedAnimal;
  bool _isSubmitting = false;
  DateTime _doseDate = DateTime.now();
  String _doseType = 'First Dose';
  List<Map<String, dynamic>> _vaccines = [];
  String? _selectedVaccineId;
  bool _isLoadingVaccines = true;
  String? _vaccineLoadError;
  final TextEditingController _otherVaccineCtrl = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  List<Cattle> _currentCattleList(BuildContext context) {
    final state = context.read<CattleBloc>().state;
    if (state is CattleListLoaded) {
      return state.cattleList.where((c) {
        bool typeMatch = _animalType == 'Cow'
            ? c.gender.toUpperCase().startsWith('F')
            : c.gender.toUpperCase().startsWith('M');
        return typeMatch && c.isActive;
      }).toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadVaccines();
    if (widget.existingRecord != null) {
      final r = widget.existingRecord!;
      // Editing existing records might try to map names. For now simply load the rest
      _doseDate = r.eventDate;
      _doseType = r.doseType ?? 'First Dose';
      _remarkController.text = r.remark ?? '';
    }
  }

  Future<void> _loadVaccines() async {
    setState(() {
      _isLoadingVaccines = true;
      _vaccineLoadError = null;
    });

    try {
      final list = await sl<ApiService>().getVaccines();
      if (!mounted) return;

      final vaccines = list
          .whereType<Map>()
          .map((v) => Map<String, dynamic>.from(v))
          .map((v) => {
                'id': v['_id']?.toString() ?? v['id']?.toString() ?? '',
                'name': v['name']?.toString() ?? 'Unknown',
              })
          .where((v) =>
              (v['id'] as String).isNotEmpty &&
              (v['name'] as String).trim().isNotEmpty)
          .toList();

      String? selectedId = _selectedVaccineId;
      if (widget.existingRecord != null && selectedId == null) {
        final existingName = widget.existingRecord!.vaccineName?.trim();
        if (existingName != null && existingName.isNotEmpty) {
          final match = vaccines.cast<Map<String, dynamic>?>().firstWhere(
                (v) =>
                    v?['name']?.toString().trim().toLowerCase() ==
                    existingName.toLowerCase(),
                orElse: () => null,
              );
          if (match != null) {
            selectedId = match['id'] as String;
          } else {
            selectedId = _kOtherId;
            _otherVaccineCtrl.text = existingName;
          }
        }
      }

      setState(() {
        _vaccines = vaccines;
        _selectedVaccineId = selectedId;
        _isLoadingVaccines = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingVaccines = false;
        _vaccineLoadError = 'Could not load vaccines. Tap to retry.';
      });
    }
  }

  @override
  void dispose() {
    _otherVaccineCtrl.dispose();
    _remarkController.dispose();
    super.dispose();
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
          widget.existingRecord == null
              ? 'Add Vaccine Information'
              : 'Edit Vaccine Information',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cow / Bull Toggle
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _animalType = 'Cow';
                        _selectedAnimal = null;
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _animalType == 'Cow'
                              ? const Color(0xFF99AA5A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cow',
                          style: GoogleFonts.poppins(
                            color: _animalType == 'Cow'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _animalType = 'Bull';
                        _selectedAnimal = null;
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _animalType == 'Bull'
                              ? const Color(0xFF99AA5A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Bull',
                          style: GoogleFonts.poppins(
                            color: _animalType == 'Bull'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Name'),
            _CattleDropdown(
              value: _selectedAnimal,
              hint: _animalType == 'Cow'
                  ? 'Select cow name'
                  : 'Select bull name',
              items: _currentCattleList(context),
              onChanged: (val) => setState(() => _selectedAnimal = val),
            ),
            const SizedBox(height: 20),

            _buildLabel('Dose Date'),
            _DatePickerField(
              date: _doseDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _doseDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _doseDate = picked);
              },
            ),
            const SizedBox(height: 20),

            _buildLabel('Dose Type'),
            Row(
              children: [
                _RadioOption(
                  label: 'First Dose',
                  value: 'First Dose',
                  groupValue: _doseType,
                  onChanged: (val) => setState(() => _doseType = val!),
                ),
                _RadioOption(
                  label: 'Booster Dose',
                  value: 'Booster Dose',
                  groupValue: _doseType,
                  onChanged: (val) => setState(() => _doseType = val!),
                ),
                _RadioOption(
                  label: 'Repeat Dose',
                  value: 'Repeat Dose',
                  groupValue: _doseType,
                  onChanged: (val) => setState(() => _doseType = val!),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildLabel('Vaccine'),
            _buildVaccineDropdown(),
            if (_selectedVaccineId == _kOtherId) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _otherVaccineCtrl,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter vaccine name',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF99AA5A)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            _buildLabel('Remark'),
            TextField(
              controller: _remarkController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add remarks or notes (optional)',
                hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF5F6F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99AA5A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        _showVaccineSearchSheet(context, items, onChanged);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: GoogleFonts.inter(
                  color: value == null ? Colors.grey : Colors.black,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showVaccineSearchSheet(
    BuildContext context,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _VaccineSearchSheet(items: items, onSelect: onChanged);
      },
    );
  }

  void _submit() async {
    if (_selectedAnimal == null || _selectedVaccineId == null) {
      if (mounted) {
        AppFeedback.showError(context, 'Please fill required fields');
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String resolvedVaccineId;
      if (_selectedVaccineId == _kOtherId) {
        final name = _otherVaccineCtrl.text.trim();
        if (name.isEmpty) {
          AppFeedback.showError(context, 'Please enter the vaccine name.');
          setState(() => _isSubmitting = false);
          return;
        }
        final result = await sl<ApiService>().addVaccine(name: name);
        resolvedVaccineId = result['_id']?.toString() ??
            result['id']?.toString() ??
            (result['data'] is Map
                ? ((result['data'] as Map)['_id']?.toString() ??
                    (result['data'] as Map)['id']?.toString() ??
                    '')
                : '');
        if (resolvedVaccineId.isEmpty) {
          throw Exception('Failed to create vaccine master entry');
        }
      } else {
        resolvedVaccineId = _selectedVaccineId!;
      }

      await sl<ApiService>().addVaccinationRecord(
        animalId: _selectedAnimal!.id,
        doseDate: _doseDate,
        doseType: _doseType.toUpperCase().contains('FIRST')
            ? 'FIRST'
            : 'BOOSTER',
        vaccineId: resolvedVaccineId,
        remark: _remarkController.text,
        );
        if (mounted) {
          await AppFeedback.showSuccess(
            context,
            'Vaccination record added successfully',
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

  Widget _buildVaccineDropdown() {
    if (_isLoadingVaccines) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF99AA5A),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading vaccines...',
              style: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (_vaccineLoadError != null) {
      return GestureDetector(
        onTap: _loadVaccines,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.refresh, color: Colors.red.shade400, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _vaccineLoadError!,
                  style: GoogleFonts.inter(
                    color: Colors.red.shade400,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final vaccineItems = [
      ..._vaccines,
      {'id': _kOtherId, 'name': 'Other'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedVaccineId,
              hint: Text(
                vaccineItems.length == 1 ? 'Select Other' : 'Select vaccine',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
              ),
              isExpanded: true,
              items: vaccineItems.map((vaccine) {
                return DropdownMenuItem<String>(
                  value: vaccine['id'] as String,
                  child: Text(
                    vaccine['name'] as String,
                    style: GoogleFonts.inter(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVaccineId = value;
                  if (value != _kOtherId) {
                    _otherVaccineCtrl.clear();
                  }
                });
              },
            ),
          ),
        ),
        if (_vaccines.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'No vaccines found from backend. Use Other to add one.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }
}

class _VaccineSearchSheet extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String?> onSelect;
  const _VaccineSearchSheet({required this.items, required this.onSelect});

  @override
  State<_VaccineSearchSheet> createState() => _VaccineSearchSheetState();
}

class _VaccineSearchSheetState extends State<_VaccineSearchSheet> {
  late List<String> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _filteredItems = widget.items
                    .where((e) => e.toLowerCase().contains(val.toLowerCase()))
                    .toList();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search here...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF5F6F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _filteredItems[index],
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  onTap: () {
                    widget.onSelect(_filteredItems[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF99AA5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
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

class _DatePickerField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DatePickerField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('dd MMM, yyyy').format(date),
                style: GoogleFonts.inter(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.calendar_today, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF99AA5A)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
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
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isSelected ? Colors.black : Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
