import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/health_event.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/di/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_event.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import '../../../cattle/domain/entities/cattle.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  const AddMedicalRecordScreen({super.key});

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _animalType = 'Cow';
  Cattle? _selectedAnimal;
  bool _isSubmitting = false;
  String _visitType = 'Illness';
  String _medicalStatus = 'Sick';
  DateTime _visitDate = DateTime.now();

  // ── Disease — loaded from backend ─────────────────────────────────────────
  // Each item is {id, name}. 'OTHER' is a sentinel value for custom input.
  static const String _kOtherId = '__OTHER__';
  List<Map<String, dynamic>> _diseases = [];
  String? _selectedDiseaseId; // the backend _id or _kOtherId
  bool _isLoadingDiseases = true;
  String? _diseaseLoadError;

  // ── Vet / Doctor ───────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _veterinarians = [];
  Map<String, dynamic>? _selectedVet;
  bool _isLoadingVets = true;
  String? _vetLoadError;

  final _visitNoCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _rescueProcedureCtrl = TextEditingController();
  final _otherDiseaseCtrl = TextEditingController(); // used when 'Other' is selected

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cattleState = context.read<CattleBloc>().state;
      if (cattleState is! CattleListLoaded) {
        context.read<CattleBloc>().add(const LoadCattleList());
      }
    });
    _loadVeterinarians();
    _loadDiseases();
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
          _vetLoadError = 'Could not load veterinarians. Tap to retry.';
        });
      }
    }
  }

  Future<void> _loadDiseases() async {
    setState(() {
      _isLoadingDiseases = true;
      _diseaseLoadError = null;
    });
    try {
      final list = await sl<ApiService>().getDiseases();
      if (mounted) {
        setState(() {
          _diseases = list
              .whereType<Map<String, dynamic>>()
              .map((d) => {
                    'id': d['_id']?.toString() ?? d['id']?.toString() ?? '',
                    'name': d['name']?.toString() ?? 'Unknown',
                  })
              .where((d) =>
                  (d['id'] as String).isNotEmpty &&
                  (d['name'] as String).trim().isNotEmpty)
              .toList();
          _isLoadingDiseases = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDiseases = false;
          _diseaseLoadError = 'Could not load diseases. Tap to retry.';
        });
      }
    }
  }

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
  void dispose() {
    _visitNoCtrl.dispose();
    _symptomsCtrl.dispose();
    _treatmentCtrl.dispose();
    _rescueProcedureCtrl.dispose();
    _otherDiseaseCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedAnimal != null) {
      setState(() => _isSubmitting = true);
      try {
        // Resolve the real diseaseId
        String? resolvedDiseaseId;
        if (_selectedDiseaseId == _kOtherId) {
          // Create a new disease on the backend, get its _id
          final name = _otherDiseaseCtrl.text.trim();
          if (name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter the disease name.')),
            );
            setState(() => _isSubmitting = false);
            return;
          }
          final result = await sl<ApiService>().addDisease(name: name);
          resolvedDiseaseId = result['_id']?.toString() ??
              result['id']?.toString() ??
              (result['data'] is Map
                  ? ((result['data'] as Map)['_id']?.toString() ??
                      (result['data'] as Map)['id']?.toString())
                  : null);
        } else {
          resolvedDiseaseId = _selectedDiseaseId; // may be null — backend accepts null
        }

        await sl<ApiService>().addMedicalRecord(
          animalId: _selectedAnimal!.id,
          visitType: _visitType.toUpperCase() == 'ILLNESS' ? 'ILLNESS' : 'CHECKUP',
          visitDate: _visitDate,
          visitNumber: _visitNoCtrl.text.isEmpty ? null : _visitNoCtrl.text,
          vetId: _selectedVet?['id'] as String?,
          diseaseId: resolvedDiseaseId,
          medicalStatus: _medicalStatus.toUpperCase(),
          symptoms: _symptomsCtrl.text.isEmpty ? null : _symptomsCtrl.text,
          treatment: _treatmentCtrl.text.isEmpty ? null : _treatmentCtrl.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medical record added successfully')),
          );
          Navigator.pop(context, true);
        }
      } on ServerException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    } else if (_selectedAnimal == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an animal first.')),
        );
      }
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
          'Add Medical Information',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cow / Bull Toggle ──────────────────────────────────────────
              Center(
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Cow',
                                style: GoogleFonts.poppins(
                                  color: _animalType == 'Cow' ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Bull',
                                style: GoogleFonts.poppins(
                                  color: _animalType == 'Bull' ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Animal name ────────────────────────────────────────────────
              _FieldLabel(label: 'Name'),
              _CattleDropdown(
                value: _selectedAnimal,
                hint: 'Select ${_animalType.toLowerCase()} name',
                items: _currentCattleList(context),
                onChanged: (val) => setState(() => _selectedAnimal = val),
              ),
              const SizedBox(height: 16),

              // ── Visit Type ─────────────────────────────────────────────────
              _FieldLabel(label: 'Visit Type'),
              Row(
                children: [
                  _RadioOption(
                    label: 'Illness',
                    value: 'Illness',
                    groupValue: _visitType,
                    onChanged: (val) => setState(() => _visitType = val!),
                  ),
                  const SizedBox(width: 24),
                  _RadioOption(
                    label: 'General Check-up',
                    value: 'General Check-up',
                    groupValue: _visitType,
                    onChanged: (val) => setState(() => _visitType = val!),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Visit Date + Visit No ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(label: 'Visit Date'),
                        _DatePickerField(date: _visitDate, onTap: _pickVisitDate),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(label: 'Visit No.'),
                        _CustomTextField(
                          controller: _visitNoCtrl,
                          hint: 'Enter visit number',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Doctor Name — fetched from backend ─────────────────────────
              _FieldLabel(label: 'Doctor Name (optional)'),
              _buildVetDropdown(),
              if (_veterinarians.isEmpty && !_isLoadingVets && _vetLoadError == null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'No veterinarians found. Add staff with role VETERINARIAN via admin.',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
              const SizedBox(height: 16),

              // ── Disease — loaded from backend ─────────────────────────────
              _FieldLabel(label: 'Disease (optional)'),
              _buildDiseaseDropdown(),
              // If 'Other' is selected, show a text field to enter a custom name
              if (_selectedDiseaseId == _kOtherId) ...[  
                const SizedBox(height: 10),
                TextFormField(
                  controller: _otherDiseaseCtrl,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter disease name',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              const SizedBox(height: 16),

              // ── Medical Status ─────────────────────────────────────────────
              _FieldLabel(label: 'Medical Status'),
              Row(
                children: [
                  _RadioOption(
                    label: 'Sick',
                    value: 'Sick',
                    groupValue: _medicalStatus,
                    onChanged: (val) => setState(() => _medicalStatus = val!),
                  ),
                  const SizedBox(width: 24),
                  _RadioOption(
                    label: 'Healthy',
                    value: 'Healthy',
                    groupValue: _medicalStatus,
                    onChanged: (val) => setState(() => _medicalStatus = val!),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Symptoms ───────────────────────────────────────────────────
              _FieldLabel(label: 'Symptoms'),
              _CustomTextField(
                controller: _symptomsCtrl,
                hint: 'Describe observed symptoms (optional)',
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // ── Treatment ──────────────────────────────────────────────────
              _FieldLabel(label: 'Treatment'),
              _CustomTextField(
                controller: _treatmentCtrl,
                hint: 'Enter treatment details (optional)',
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // ── Rescue Procedure ───────────────────────────────────────────
              _FieldLabel(label: 'Rescue Procedure'),
              _CustomTextField(
                controller: _rescueProcedureCtrl,
                hint: 'Describe rescue steps taken (optional)',
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // ── Submit ─────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99AA5A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

  /// Dropdown that shows veterinarians fetched from the backend.
  /// Handles loading / error / empty states gracefully.
  Widget _buildVetDropdown() {
    if (_isLoadingVets) {
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
              'Loading veterinarians…',
              style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_vetLoadError != null) {
      return GestureDetector(
        onTap: _loadVeterinarians,
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
                  _vetLoadError!,
                  style: GoogleFonts.inter(color: Colors.red.shade400, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_veterinarians.isEmpty) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          'No veterinarians found in your gaushala.',
          style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedVet,
          hint: Text(
            'Select doctor name',
            style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
          ),
          isExpanded: true,
          items: _veterinarians.map((vet) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: vet,
              child: Text(
                vet['name'] as String,
                style: GoogleFonts.inter(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedVet = val),
        ),
      ),
    );
  }

  /// Dropdown that shows diseases fetched from the backend.
  /// Uses the disease ID for known diseases and exposes an "Other" path
  /// that creates a new master disease entry before submitting the record.
  Widget _buildDiseaseDropdown() {
    if (_isLoadingDiseases) {
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
              'Loading diseases...',
              style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_diseaseLoadError != null) {
      return GestureDetector(
        onTap: _loadDiseases,
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
                  _diseaseLoadError!,
                  style: GoogleFonts.inter(color: Colors.red.shade400, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final diseaseItems = [
      ..._diseases,
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
              value: _selectedDiseaseId,
              hint: Text(
                diseaseItems.length == 1 ? 'Select Other' : 'Select disease',
                style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
              ),
              isExpanded: true,
              items: diseaseItems.map((disease) {
                return DropdownMenuItem<String>(
                  value: disease['id'] as String,
                  child: Text(
                    disease['name'] as String,
                    style: GoogleFonts.inter(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDiseaseId = value;
                  if (value != _kOtherId) {
                    _otherDiseaseCtrl.clear();
                  }
                });
              },
            ),
          ),
        ),
        if (_diseases.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'No diseases found from backend. Use Other to add one.',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
      ],
    );
  }

  Future<void> _pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF99AA5A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _visitDate = picked);
    }
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _CustomTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F6F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final Function(String?) onChanged;

  const _CustomDropdown({
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
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13)),
          isExpanded: true,
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: GoogleFonts.inter(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
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
          hint: Text(hint, style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            const SizedBox(width: 4),
            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black),
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
  final Function(String?) onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF99AA5A) : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF99AA5A) : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isSelected ? Colors.black : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
