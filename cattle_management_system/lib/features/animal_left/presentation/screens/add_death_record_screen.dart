import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cattle_management_system/core/localization/app_text.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/data/models/cattle_model.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_feedback.dart';

class AddDeathRecordScreen extends StatefulWidget {
  const AddDeathRecordScreen({super.key});

  @override
  State<AddDeathRecordScreen> createState() => _AddDeathRecordScreenState();
}

class _AddDeathRecordScreenState extends State<AddDeathRecordScreen> {
  static const String _cattleCacheKey = 'CACHED_CATTLE_LIST';
  bool _isCow = true;
  Cattle? _selectedAnimal;
  bool _showAnimalDropdown = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQ = '';

  DateTime? _selectedDate;
  final _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  List<Cattle> _getAvailableAnimals(List<Cattle> allCattle) {
    var list = allCattle.where((a) {
      if (a.isRetired == true || a.status == 'DEAD') return false;

      final genderMatch = _isCow
          ? (a.gender.toUpperCase().startsWith('F') ||
                a.gender.toLowerCase() == 'cow')
          : (a.gender.toUpperCase().startsWith('M') ||
                a.gender.toLowerCase() == 'bull');

      final statusMatch = a.status.toUpperCase() == 'ACTIVE';

      return genderMatch && statusMatch;
    }).toList();
    if (_searchQ.isNotEmpty) {
      list = list
          .where((a) => a.name.toLowerCase().contains(_searchQ.toLowerCase()))
          .toList();
    }
    return list;
  }

  bool _isTerminalStatus(String status) {
    final normalized = status.toUpperCase();
    return normalized == 'SOLD' ||
        normalized == 'DEAD' ||
        normalized == 'DONATED';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_selectedAnimal == null) {
      AppFeedbackService.showPopup(
        message: context.tr.pleaseSelectCow,
        type: AppFeedbackType.warning,
      );
      return;
    }

    final cattleState = context.read<CattleBloc>().state;
    final latestCattle = cattleState is CattleListLoaded
        ? cattleState.cattleList
        : <Cattle>[];
    final latestMatches = latestCattle
        .where((animal) => animal.id == _selectedAnimal!.id)
        .toList();
    final latestAnimal = latestMatches.isNotEmpty ? latestMatches.first : null;

    if (latestAnimal != null && _isTerminalStatus(latestAnimal.status)) {
      AppFeedbackService.showPopup(
        message:
            'This animal is already ${latestAnimal.status.toUpperCase()} and cannot be marked dead.',
        type: AppFeedbackType.warning,
      );
      if (mounted) {
        setState(() {
          _selectedAnimal = null;
        });
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final deathDate = _selectedDate ?? DateTime.now();

      // Call the real death API
      await sl<ApiService>().recordDeath(
        animalId: _selectedAnimal!.id,
        dateOfDeath: deathDate,
        reason: _reasonCtrl.text.isNotEmpty
            ? _reasonCtrl.text
            : 'Not specified',
      );

      await _updateCachedAnimal(
        _selectedAnimal!.copyWith(
          status: 'DEAD',
          deathDate: deathDate,
          deathReason: _reasonCtrl.text.isNotEmpty
              ? _reasonCtrl.text
              : 'Not specified',
          updatedAt: DateTime.now(),
        ),
      );

      // Also refresh local cattle list so dashboard updates
      if (mounted) {
        context.read<CattleBloc>().add(
          UpsertLocalCattle(
            _selectedAnimal!.copyWith(
              status: 'DEAD',
              deathDate: deathDate,
              deathReason: _reasonCtrl.text.isNotEmpty
                  ? _reasonCtrl.text
                  : 'Not specified',
              updatedAt: DateTime.now(),
            ),
          ),
        );
        final lang = Localizations.localeOf(context).languageCode;
        AppFeedback.showSuccess(context, 
              lang == 'hi'
                  ? 'मृत्यु रिकॉर्ड सफलतापूर्वक जोड़ा गया'
                  : lang == 'gu'
                  ? 'મૃત્યુ રેકોર્ડ સફળતાપૂર્વક ઉમેરાયો'
                  : 'Death record added successfully',
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

  Future<void> _updateCachedAnimal(Cattle updatedAnimal) async {
    final prefs = sl<SharedPreferences>();
    final cached = prefs.getString(_cattleCacheKey);
    if (cached == null || cached.isEmpty) return;

    final decoded = (jsonDecode(cached) as List<dynamic>)
        .map((item) => CattleModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final index = decoded.indexWhere((animal) => animal.id == updatedAnimal.id);
    if (index == -1) return;

    decoded[index] = CattleModel(
      id: updatedAnimal.id,
      tagNumber: updatedAnimal.tagNumber,
      name: updatedAnimal.name,
      breed: updatedAnimal.breed,
      gender: updatedAnimal.gender,
      dateOfBirth: updatedAnimal.dateOfBirth,
      color: updatedAnimal.color,
      weight: updatedAnimal.weight,
      status: updatedAnimal.status,
      imageUrl: updatedAnimal.imageUrl,
      acquisitionType: updatedAnimal.acquisitionType,
      isLactating: updatedAnimal.isLactating,
      isHeifer: updatedAnimal.isHeifer,
      isPregnant: updatedAnimal.isPregnant,
      isDryOff: updatedAnimal.isDryOff,
      isRetired: updatedAnimal.isRetired,
      createdAt: updatedAnimal.createdAt,
      updatedAt: updatedAnimal.updatedAt,
      parity: updatedAnimal.parity,
      lastDeliveryDate: updatedAnimal.lastDeliveryDate,
      dailyMilkProduction: updatedAnimal.dailyMilkProduction,
      serialNumber: updatedAnimal.serialNumber,
      motherId: updatedAnimal.motherId,
      fatherId: updatedAnimal.fatherId,
      motherName: updatedAnimal.motherName,
      fatherName: updatedAnimal.fatherName,
      dateOfAdult: updatedAnimal.dateOfAdult,
      deathReason: updatedAnimal.deathReason,
      deathDate: updatedAnimal.deathDate,
      cowGroup: updatedAnimal.cowGroup,
      isHandicapped: updatedAnimal.isHandicapped,
      handicapReason: updatedAnimal.handicapReason,
      isUdderClosedFL: updatedAnimal.isUdderClosedFL,
      isUdderClosedFR: updatedAnimal.isUdderClosedFR,
      isUdderClosedBL: updatedAnimal.isUdderClosedBL,
      isUdderClosedBR: updatedAnimal.isUdderClosedBR,
      purchaseDate: updatedAnimal.purchaseDate,
      purchasedFrom: updatedAnimal.purchasedFrom,
      purchasePrice: updatedAnimal.purchasePrice,
      ownerName: updatedAnimal.ownerName,
      ownerMobile: updatedAnimal.ownerMobile,
      retiredDate: updatedAnimal.retiredDate,
      bullView: updatedAnimal.bullView,
      motherMilk: updatedAnimal.motherMilk,
      grandmotherMilk: updatedAnimal.grandmotherMilk,
    );

    await prefs.setString(
      _cattleCacheKey,
      jsonEncode(decoded.map((animal) => animal.toJson()).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    String localize({
      required String en,
      required String hi,
      required String gu,
    }) {
      if (lang == 'hi') return hi;
      if (lang == 'gu') return gu;
      return en;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
        ),
        title: Text(
          context.tr.addRecordTitle('Death'),
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          List<Cattle> cattleList = [];
          bool isLoading = state is CattleLoading;

          if (state is CattleListLoaded) {
            cattleList = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            cattleList = [state.cattle];
          }
          final _availableAnimals = _getAvailableAnimals(cattleList);
          if (_selectedAnimal != null &&
              !_availableAnimals.any(
                (animal) => animal.id == _selectedAnimal!.id,
              )) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _selectedAnimal = null;
              });
            });
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cow/Bull Toggle
                    Center(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _ToggleBtn(
                              label: context.tr.cow,
                              isSelected: _isCow,
                              onTap: () => setState(() {
                                _isCow = true;
                                _selectedAnimal = null;
                              }),
                            ),
                            _ToggleBtn(
                              label: context.tr.bull,
                              isSelected: !_isCow,
                              onTap: () => setState(() {
                                _isCow = false;
                                _selectedAnimal = null;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Dropdown
                    _FieldLabel(label: context.tr.cow),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(
                        () => _showAnimalDropdown = !_showAnimalDropdown,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedAnimal?.name ??
                                  (_isCow
                                      ? context.tr.selectCowName
                                      : localize(
                                          en: 'Select bull name',
                                          hi: 'सांड का नाम चुनें',
                                          gu: 'બળદનું નામ પસંદ કરો',
                                        )),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: _selectedAnimal == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date of Death
                    _FieldLabel(label: context.tr.recordDateLabel('Death')),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? context.tr.selectDate
                                  : DateFormat(
                                      'dd MMM, yyyy',
                                    ).format(_selectedDate!),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: _selectedDate == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Death Reason
                    _FieldLabel(label: context.tr.causeOfDeath),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonCtrl,
                      maxLines: 4,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF5F6F7),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        hintText: context.tr.enterCauseOfDeath,
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _FieldLabel(
                      label: localize(
                        en: 'Last Photo at Time of Death',
                        hi: 'मृत्यु के समय की अंतिम फोटो',
                        gu: 'મૃત્યુ સમયેનો છેલ્લો ફોટો',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_upload,
                            color: Colors.grey,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localize(
                              en: 'Select Photo',
                              hi: 'फोटो चुनें',
                              gu: 'ફોટો પસંદ કરો',
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF99AA5A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              localize(
                                en: 'Select Photo',
                                hi: 'फोटो चुनें',
                                gu: 'ફોટો પસંદ કરો',
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Animal Selection Overlay
              if (_showAnimalDropdown)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _showAnimalDropdown = false),
                    child: Container(
                      color: Colors.black.withOpacity(0.05),
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Icon(Icons.search, size: 22, color: Colors.grey.shade400),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      autofocus: true,
                                      onChanged: (v) =>
                                      setState(() => _searchQ = v),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search here...',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.grey.shade400,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        isDense: true,
                                        fillColor: Colors.transparent,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _availableAnimals.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: Colors.grey.shade100,
                                ),
                                itemBuilder: (ctx, i) {
                                  final a = _availableAnimals[i];
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedAnimal = a;
                                        _showAnimalDropdown = false;
                                        _searchQ = '';
                                        _searchCtrl.clear();
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 16,
                                      ),
                                      child: Center(
                                        child: Text(
                                          a.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Submit Button
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF99AA5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
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
                            'Submit',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF99AA5A) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
