import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../cattle/domain/entities/cattle.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_event.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';
import '../../domain/entities/health_event.dart';

class AddLabTestScreen extends StatefulWidget {
  final HealthEvent? existingRecord;

  const AddLabTestScreen({super.key, this.existingRecord});

  @override
  State<AddLabTestScreen> createState() => _AddLabTestScreenState();
}

class _AddLabTestScreenState extends State<AddLabTestScreen> {
  static const String _kOtherId = '__OTHER__';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otherLabTestCtrl = TextEditingController();
  final TextEditingController _remarkCtrl = TextEditingController();

  String _animalType = 'Cow';
  Cattle? _selectedAnimal;
  DateTime _sampleDate = DateTime.now();
  DateTime _resultDate = DateTime.now();
  String? _selectedLabTestId;
  String _selectedResult = 'POSITIVE';
  bool _isSubmitting = false;
  bool _isLoadingLabTests = true;
  String? _labTestLoadError;
  List<Map<String, dynamic>> _labTests = [];

  static const List<String> _results = ['POSITIVE', 'NEGATIVE'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cattleState = context.read<CattleBloc>().state;
      if (cattleState is! CattleListLoaded) {
        context.read<CattleBloc>().add(const LoadCattleList());
      }
    });
    _loadLabTests();
    _hydrateExistingRecord();
  }

  void _hydrateExistingRecord() {
    final existing = widget.existingRecord;
    if (existing == null) return;
    _sampleDate = existing.eventDate;
    _resultDate = existing.nextDueDate ?? existing.eventDate;
    _selectedResult = existing.status.trim().toUpperCase();
    _remarkCtrl.text = existing.remark ?? '';
  }

  void _syncExistingAnimal(List<Cattle> cattleList) {
    final existing = widget.existingRecord;
    if (existing == null || _selectedAnimal != null) return;

    final match = cattleList.cast<Cattle?>().firstWhere(
          (cattle) =>
              cattle?.name == existing.cowName &&
              cattle?.tagNumber == existing.cowTagNumber,
          orElse: () => null,
        );
    if (match == null) return;

    _selectedAnimal = match;
    _animalType =
        match.gender.toUpperCase().startsWith('M') ? 'Bull' : 'Cow';
  }

  @override
  void dispose() {
    _otherLabTestCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLabTests() async {
    setState(() {
      _isLoadingLabTests = true;
      _labTestLoadError = null;
    });

    try {
      final list = await sl<ApiService>().getLabTestTypes();
      if (!mounted) return;

      final labTests = list
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map((item) => {
                'id': item['id']?.toString() ?? item['_id']?.toString() ?? '',
                'name': item['name']?.toString() ?? 'Unknown',
              })
          .where((item) =>
              (item['id'] as String).isNotEmpty &&
              (item['name'] as String).trim().isNotEmpty)
          .toList();

      String? selectedId = _selectedLabTestId;
      final existingName = widget.existingRecord?.testName?.trim();
      if (selectedId == null &&
          existingName != null &&
          existingName.isNotEmpty) {
        final match = labTests.cast<Map<String, dynamic>?>().firstWhere(
              (item) =>
                  item?['name']?.toString().trim().toLowerCase() ==
                  existingName.toLowerCase(),
              orElse: () => null,
            );
        if (match != null) {
          selectedId = match['id'] as String;
        } else {
          selectedId = _kOtherId;
          _otherLabTestCtrl.text = existingName;
        }
      }

      setState(() {
        _labTests = labTests;
        _selectedLabTestId = selectedId;
        _isLoadingLabTests = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingLabTests = false;
        _labTestLoadError = 'Could not load lab tests. Tap to retry.';
      });
    }
  }

  List<Cattle> _currentCattleList(BuildContext context) {
    final state = context.read<CattleBloc>().state;
    if (state is CattleListLoaded) {
      return state.cattleList.where((cattle) {
        final isMatch = _animalType == 'Cow'
            ? cattle.gender.toUpperCase().startsWith('F')
            : cattle.gender.toUpperCase().startsWith('M');
        return isMatch && cattle.isActive;
      }).toList();
    }
    return [];
  }

  Future<void> _pickDate(bool isSampleDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isSampleDate ? _sampleDate : _resultDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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
    if (picked == null) return;
    setState(() {
      if (isSampleDate) {
        _sampleDate = picked;
        if (_resultDate.isBefore(_sampleDate)) {
          _resultDate = _sampleDate;
        }
      } else {
        _resultDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedAnimal == null || _selectedLabTestId == null) {
      AppFeedback.showError(context, 'Please fill required fields');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String resolvedLabTestId;
      if (_selectedLabTestId == _kOtherId) {
        final name = _otherLabTestCtrl.text.trim();
        if (name.isEmpty) {
          AppFeedback.showError(context, 'Please enter the lab test name.');
          setState(() => _isSubmitting = false);
          return;
        }
        final result = await sl<ApiService>().addLabTestType(name: name);
        resolvedLabTestId = result['_id']?.toString() ??
            result['id']?.toString() ??
            (result['data'] is Map
                ? ((result['data'] as Map)['_id']?.toString() ??
                    (result['data'] as Map)['id']?.toString() ??
                    '')
                : '');
        if (resolvedLabTestId.isEmpty) {
          throw Exception('Failed to create lab test master entry');
        }
        final createdName = name.trim();
        setState(() {
          _labTests = [
            ..._labTests.where(
              (item) => item['id']?.toString() != resolvedLabTestId,
            ),
            {'id': resolvedLabTestId, 'name': createdName},
          ];
          _selectedLabTestId = resolvedLabTestId;
        });
      } else {
        resolvedLabTestId = _selectedLabTestId!;
      }

      if (widget.existingRecord == null) {
        await sl<ApiService>().addLabRecord(
          animalId: _selectedAnimal!.id,
          labtestId: resolvedLabTestId,
          sampleDate: _sampleDate,
          resultDate: _resultDate,
          result: _selectedResult,
          remark: _remarkCtrl.text.trim().isEmpty ? null : _remarkCtrl.text.trim(),
        );
      } else {
        await sl<ApiService>().updateLabRecord(
          id: widget.existingRecord!.id,
          labtestId: resolvedLabTestId,
          sampleDate: _sampleDate,
          resultDate: _resultDate,
          result: _selectedResult,
          remark: _remarkCtrl.text.trim().isEmpty ? null : _remarkCtrl.text.trim(),
        );
      }

      if (!mounted) return;
      await AppFeedback.showSuccess(
        context,
        widget.existingRecord == null
            ? 'Lab test record added successfully'
            : 'Lab test record updated successfully',
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ServerException catch (e) {
      AppFeedback.showError(context, e.message);
    } catch (e) {
      AppFeedback.showError(context, 'Failed to save lab test: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          widget.existingRecord == null
              ? 'Add Lab Test Information'
              : 'Edit Lab Test Information',
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
              const SizedBox(height: 20),
              _buildLabel('Name'),
              BlocBuilder<CattleBloc, CattleState>(
                builder: (context, state) {
                  if (state is CattleListLoaded) {
                    _syncExistingAnimal(state.cattleList);
                  }
                  final items = _currentCattleList(context);
                  if (state is CattleLoading && items.isEmpty) {
                    return const CircularProgressIndicator();
                  }

                  return _buildDropdown<Cattle>(
                    hint: 'Select ${_animalType.toLowerCase()} name',
                    value: _selectedAnimal,
                    items: items,
                    itemLabelBuilder: (cattle) =>
                        '${cattle.name} (${cattle.tagNumber})',
                    onChanged: (value) => setState(() => _selectedAnimal = value),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Sample Date'),
                        _buildDatePickerField(
                          value: _sampleDate,
                          onTap: () => _pickDate(true),
                          hint: 'Select the sample date',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Result Date'),
                        _buildDatePickerField(
                          value: _resultDate,
                          onTap: () => _pickDate(false),
                          hint: 'Select the result date',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Lab Test'),
              _buildLabTestDropdown(),
              if (_selectedLabTestId == _kOtherId) ...[
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _otherLabTestCtrl,
                  hint: 'Enter the lab test name',
                ),
              ],
              const SizedBox(height: 16),
              _buildLabel('Result'),
              _buildDropdown<String>(
                hint: 'Select the test result',
                value: _selectedResult,
                items: _results,
                itemLabelBuilder: (value) => value,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedResult = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildLabel('Remark'),
              _buildTextField(
                controller: _remarkCtrl,
                hint: 'Add remarks or notes (optional)',
                maxLines: 4,
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
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
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
    final isSelected = _animalType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _animalType = type;
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

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabelBuilder(item),
                    style: GoogleFonts.inter(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLabTestDropdown() {
    if (_isLoadingLabTests) {
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
              'Loading lab tests...',
              style: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (_labTestLoadError != null) {
      return GestureDetector(
        onTap: _loadLabTests,
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
                  _labTestLoadError!,
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

    final items = [
      ..._labTests,
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
              value: _selectedLabTestId,
              hint: Text(
                items.length == 1 ? 'Select Other' : 'Select lab test',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
              ),
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'] as String,
                  child: Text(
                    item['name'] as String,
                    style: GoogleFonts.inter(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLabTestId = value;
                  if (value != _kOtherId) {
                    _otherLabTestCtrl.clear();
                  }
                });
              },
            ),
          ),
        ),
        if (_labTests.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'No lab tests found from backend. Use Other to add one.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required DateTime value,
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
            Expanded(
              child: Text(
                DateFormat('dd MMM, yyyy').format(value),
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
                overflow: TextOverflow.ellipsis,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14),
        maxLines: maxLines,
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
}
