import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../features/cattle/data/models/cattle_model.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';

class AddDonationRecordScreen extends StatefulWidget {
  const AddDonationRecordScreen({super.key});

  @override
  State<AddDonationRecordScreen> createState() =>
      _AddDonationRecordScreenState();
}

class _AddDonationRecordScreenState extends State<AddDonationRecordScreen> {
  static const String _cattleCacheKey = 'CACHED_CATTLE_LIST';
  bool _isCow = true;
  Cattle? _selectedAnimal;
  bool _showAnimalDropdown = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQ = '';

  final _gaushalaNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  List<Cattle> _getAvailableAnimals(List<Cattle> allCattle) {
    final gender = _isCow ? 'Female' : 'Male';
    var list = allCattle
        .where(
          (a) =>
              a.status.toUpperCase() == 'ACTIVE' &&
              a.isRetired != true &&
              (a.gender.toLowerCase() == gender.toLowerCase() ||
                  a.gender.toLowerCase() == (_isCow ? 'cow' : 'bull')),
        )
        .toList();
    if (_searchQ.isNotEmpty) {
      list = list
          .where((a) => a.name.toLowerCase().contains(_searchQ.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
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
          'Add Donation Record',
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
          if (state is CattleListLoaded) {
            cattleList = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            cattleList = [state.cattle];
          }
          final _availableAnimals = _getAvailableAnimals(cattleList);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle
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
                              label: 'Cow',
                              isSelected: _isCow,
                              onTap: () => setState(() {
                                _isCow = true;
                                _selectedAnimal = null;
                              }),
                            ),
                            _ToggleBtn(
                              label: 'Bull',
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

                    // Fields
                    _FieldLabel(label: 'Name'),
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
                                  'Select ${_isCow ? 'cow' : 'bull'} name',
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

                    _FieldLabel(label: 'Gaushala Name'),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      hint: 'Enter gaushala name',
                      controller: _gaushalaNameCtrl,
                    ),
                    const SizedBox(height: 20),

                    _FieldLabel(label: 'Mobile No.'),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      hint: 'Enter mobile number',
                      controller: _mobileCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    _FieldLabel(label: 'Reference By'),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      hint: 'Enter reference name',
                      controller: _refCtrl,
                    ),
                    const SizedBox(height: 20),

                    _FieldLabel(label: 'Photo at Time of Donation'),
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
                            'Select Photo',
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
                              'Select Photo',
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
                              padding: const EdgeInsets.all(12),
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
                    onPressed: _isSubmitting ? null : _submitDonation,
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

  Future<void> _submitDonation() async {
    if (_selectedAnimal == null) {
      AppFeedbackService.showPopup(
        message: 'Please select an animal',
        type: AppFeedbackType.warning,
      );
      return;
    }
    if (_gaushalaNameCtrl.text.isEmpty) {
      AppFeedbackService.showPopup(
        message: 'Please enter gaushala name',
        type: AppFeedbackType.warning,
      );
      return;
    }
    if (_mobileCtrl.text.isEmpty) {
      AppFeedbackService.showPopup(
        message: 'Please enter mobile number',
        type: AppFeedbackType.warning,
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final donatedAt = DateTime.now();
      await sl<ApiService>().recordDonation(
        animalId: _selectedAnimal!.id,
        donatedTo: _gaushalaNameCtrl.text,
        mobileNumber: _mobileCtrl.text,
        referenceBy: _refCtrl.text.isNotEmpty ? _refCtrl.text : null,
        donatedAt: donatedAt,
      );
      await _updateCachedAnimal(
        _selectedAnimal!.copyWith(
          status: 'DONATED',
          updatedAt: donatedAt,
        ),
      );
      if (mounted) {
        context.read<CattleBloc>().add(
          UpsertLocalCattle(
            _selectedAnimal!.copyWith(
              status: 'DONATED',
              updatedAt: donatedAt,
            ),
          ),
        );
        AppFeedbackService.showPopup(
          message: 'Donation record added successfully',
          type: AppFeedbackType.success,
        );
        Navigator.pop(context, true);
      }
    } on ServerException catch (e) {
      if (mounted) {
        AppFeedbackService.showPopup(
          message: e.message,
          type: AppFeedbackType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackService.showPopup(
          message: 'Error: $e',
          type: AppFeedbackType.error,
        );
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

class _CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        fillColor: const Color(0xFFF5F6F7),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
