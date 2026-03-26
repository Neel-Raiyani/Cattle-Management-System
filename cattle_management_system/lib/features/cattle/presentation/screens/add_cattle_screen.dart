import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/cattle.dart';
import '../bloc/cattle_bloc.dart';
import '../bloc/cattle_event.dart';
import '../bloc/cattle_state.dart';
import '../../../cow_group/presentation/bloc/cow_group_bloc.dart';
import '../../../cow_group/presentation/bloc/cow_group_state.dart';
import '../../../cow_group/presentation/bloc/cow_group_event.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_feedback.dart';

class AddCattleScreen extends StatefulWidget {
  const AddCattleScreen({super.key});

  @override
  State<AddCattleScreen> createState() => _AddCattleScreenState();
}

class _AddCattleScreenState extends State<AddCattleScreen> {
  static const List<String> _cowBreedOptions = [
    'Gir',
    'Sahiwal',
    'Red Sindhi',
    'Tharparkar',
    'Kankrej',
    'Rathi',
    'Punganur',
    'Badri',
    'Hallikar',
    'Kangayam',
    'Hariana',
    'Mewati',
    'Nagori',
    'Nimadi',
    'Malvi',
    'Kherigarh',
    'Amritmahal',
    'Umblachery',
    'Pulikulam',
    'Bargur',
    'Ongole',
    'Red Kandhari',
    'Gaolao',
    'Gangatiri',
    'Siri',
    'Motu',
    'Vechur',
    'Jersey',
    'Holstein Friesian',
    'Brown Swiss',
  ];

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _animalNumberController = TextEditingController();
  final TextEditingController _parityController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _adultDateController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();

  // Purchase Fields
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _purchasedFromController =
  TextEditingController();

  // Dropdown Values
  String? _selectedCowType;
  String? _selectedCowGroup;
  String? _selectedMother;
  String? _selectedFather;

  // Toggles & Radio
  bool _isHandicapped = false;
  String _acquisitionSource = 'Birth';
  bool _isUdderClosedFL = false;
  bool _isUdderClosedFR = false;
  bool _isUdderClosedBL = false;
  bool _isUdderClosedBR = false;

  // Image
  File? _selectedImage;
  bool _isUploading = false;
  bool _isSubmitting = false;

  // Live listing for dropdowns
  List<Map<String, dynamic>> _cows = []; // mothers
  List<Map<String, dynamic>> _bulls = []; // fathers
  List<String> _cowLabels = [];
  List<String> _bullLabels = [];
  bool _loadingParents = false;
  final List<String> _breeds = List<String>.from(_cowBreedOptions);

  @override
  void initState() {
    super.initState();
    context.read<CowGroupBloc>().add(LoadCowGroups());
    _fetchParentAnimals();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _animalNumberController.dispose();
    _parityController.dispose();
    _birthDateController.dispose();
    _adultDateController.dispose();
    _problemController.dispose();
    _purchaseDateController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _priceController.dispose();
    _purchasedFromController.dispose();
    super.dispose();
  }

  Future<void> _fetchParentAnimals() async {
    setState(() => _loadingParents = true);
    try {
      final cowData = await sl<ApiService>().getCows(limit: 500);
      final bullData = await sl<ApiService>().getBulls(limit: 500);

      setState(() {
        _cows = List<Map<String, dynamic>>.from(cowData);
        _cowLabels =
            _cows.map((c) => '${c['name']} (${c['tagNumber']})').toList();

        _bulls = List<Map<String, dynamic>>.from(bullData);
        _bullLabels =
            _bulls.map((b) => '${b['name']} (${b['tagNumber']})').toList();
      });
    } catch (e) {
      debugPrint('Error fetching parent animals: $e');
    } finally {
      if (mounted) setState(() => _loadingParents = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _removeImage() => setState(() => _selectedImage = null);

  Future<String?> _uploadImageAndGetKey(File imageFile) async {
    try {
      final fileName = imageFile.path
          .split(Platform.isWindows ? '\\' : '/')
          .last;
      const contentType = 'image/jpeg';

      final presignedData = await sl<ApiService>().getPresignedUrl(
        fileName: fileName,
        contentType: contentType,
        type: 'PHOTO',
      );

      final uploadUrl = presignedData['uploadUrl'] as String?;
      final key = presignedData['key'] as String?;

      if (uploadUrl == null || key == null) return null;

      final Uint8List imageBytes = await imageFile.readAsBytes();
      final s3Response = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': contentType},
        body: imageBytes,
      );

      if (s3Response.statusCode != 200 && s3Response.statusCode != 204) {
        return 'ERROR_S3_${s3Response.statusCode}';
      }

      return key;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CattleBloc, CattleState>(
      listener: (context, state) {
        if (state is CattleAdded) {
          if (mounted) {
            setState(() => _isSubmitting = false);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cow added successfully!'),
              backgroundColor: Color(0xFFA4C639),
            ),
          );
          Navigator.pop(context);
        } else if (state is CattleError || state is CattleActionError) {
          if (mounted) {
            setState(() => _isSubmitting = false);
          }
          final message = state is CattleError
              ? state.message
              : (state as CattleActionError).message;
          AppFeedback.showError(context, message);
        }
      },
      child: Scaffold(
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          title: Text(
            'Add Cow Details',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xff99AA5A),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: _selectedImage != null
                                  ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: const Color(0xFFF1F8E9),
                                child: Icon(
                                  Icons.pets,
                                  size: 60,
                                  color: Colors.brown[300],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -24,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xff99AA5A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedImage != null
                                ? const Color(0xFFFFEBEE)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete,
                                color: _selectedImage != null
                                    ? Colors.red
                                    : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedImage != null
                                    ? 'Delete Photo'
                                    : 'No Photo Selected',
                                style: GoogleFonts.inter(
                                  color: _selectedImage != null
                                      ? Colors.red
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'Cow Type',
                        'Select cow type',
                        _breeds,
                        _selectedCowType,
                        (val) => setState(() => _selectedCowType = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BlocBuilder<CowGroupBloc, CowGroupState>(
                        builder: (context, state) {
                          final groupNames = state is CowGroupLoaded
                              ? state.groups.map((g) => g.name).toList()
                              : const <String>[];
                          final hasGroups = groupNames.isNotEmpty;
                          return _buildDropdown(
                            'Cow Group',
                            hasGroups
                                ? 'Select cow group'
                                : 'No cow groups available',
                            groupNames,
                            _selectedCowGroup,
                            hasGroups
                                ? (val) =>
                                    setState(() => _selectedCowGroup = val)
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField('Cow Name', 'Enter cow name', _nameController),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Tag No.',
                        'Enter tag number',
                        _tagController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Animal Number',
                        'Enter animal number',
                        _animalNumberController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  'Parity',
                  'Enter cow parity',
                  _parityController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Handicapped',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Switch(
                      value: _isHandicapped,
                      onChanged: (val) => setState(() => _isHandicapped = val),
                      activeColor: const Color(0xFFA4C639),
                    ),
                  ],
                ),
                if (_isHandicapped) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    'What is the problem?',
                    'Enter details',
                    _problemController,
                  ),
                ],
                const SizedBox(height: 24),

                // â”€â”€ Date Section Modification â”€â”€
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        'Birth Date',
                        _birthDateController,
                        onDateSelected: (pickedDate) {
                          // Adult date is birth date + 1 year as per backend contract.
                          final adultDate = DateTime(
                            pickedDate.year + 1,
                            pickedDate.month,
                            pickedDate.day,
                          );
                          setState(() {
                            _birthDateController.text =
                                DateFormat('dd/MM/yyyy').format(pickedDate);
                            _adultDateController.text =
                                DateFormat('dd/MM/yyyy').format(adultDate);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePicker(
                        'Adult Date',
                        _adultDateController,
                        enabled: false, // User cannot edit this
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'If cow any udder is closed, click on udder',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildUdderItem('FL', _isUdderClosedFL, (val) => setState(() => _isUdderClosedFL = val)),
                    _buildUdderItem('FR', _isUdderClosedFR, (val) => setState(() => _isUdderClosedFR = val)),
                    _buildUdderItem('BL', _isUdderClosedBL, (val) => setState(() => _isUdderClosedBL = val)),
                    _buildUdderItem('BR', _isUdderClosedBR, (val) => setState(() => _isUdderClosedBR = val)),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'Source of Acquisition',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRadioButton('Birth'),
                    const SizedBox(width: 16),
                    _buildRadioButton('Donation'),
                    const SizedBox(width: 16),
                    _buildRadioButton('Purchase'),
                  ],
                ),
                const SizedBox(height: 24),

                if (_acquisitionSource == 'Purchase') ...[
                  _buildDatePicker('Purchase Date', _purchaseDateController),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Owner Name',
                          'Enter owner name',
                          _ownerNameController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          'Mobile Number',
                          'Enter mobile number',
                          _mobileController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Purchased From',
                          'Enter name',
                          _purchasedFromController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          'Price',
                          'Enter Price',
                          _priceController,
                          prefixText: 'â‚¹ ',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ] else if (_acquisitionSource == 'Birth') ...[
                  if (_loadingParents)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFFA4C639),
                        ),
                      ),
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            'Mother Name ',
                            _cowLabels.isEmpty
                                ? 'No cows available'
                                : 'Select mother',
                            _cowLabels,
                            _cowLabels.contains(_selectedMother)
                                ? _selectedMother
                                : null,
                            _cowLabels.isEmpty
                                ? null
                                : (val) =>
                                setState(() => _selectedMother = val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            'Father Name',
                            _bullLabels.isEmpty
                                ? 'No bulls available'
                                : 'Select father',
                            _bullLabels,
                            _bullLabels.contains(_selectedFather)
                                ? _selectedFather
                                : null,
                            _bullLabels.isEmpty
                                ? null
                                : (val) =>
                                setState(() => _selectedFather = val),
                          ),
                        ),
                      ],
                    ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildPedigreeButton(
                          'Add Mother Pedigree',
                          Icons.add,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPedigreeButton(
                          'Add Father Pedigree',
                          Icons.add,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isUploading || _isSubmitting) ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA4C639),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: (_isUploading || _isSubmitting)
                        ? const SizedBox(
                      width: 24,
                      height: 24,
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€ Modified Date Picker Helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildDatePicker(
      String label,
      TextEditingController controller, {
        void Function(DateTime)? onDateSelected,
        bool enabled = true,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: !enabled
              ? null
              : () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              if (onDateSelected != null) {
                onDateSelected(pickedDate);
              } else {
                setState(() {
                  controller.text =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              // Change background color if disabled to signify read-only
              color: enabled ? const Color(0xFFF5F6F7) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Select date' : controller.text,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: controller.text.isEmpty
                          ? Colors.grey
                          : (enabled ? Colors.black : Colors.black54),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: enabled ? Colors.grey : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // â”€â”€ Other Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildDropdown(
      String label,
      String hint,
      List<String> items,
      String? value,
      ValueChanged<String?>? onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value != null && items.contains(value)) ? value : null,
              hint: Text(
                hint,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller, {
        TextInputType? keyboardType,
        String? prefixText,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6F7),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            prefixText: prefixText,
            prefixStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRadioButton(String value) {
    return GestureDetector(
      onTap: () => setState(() => _acquisitionSource = value),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _acquisitionSource == value
                    ? const Color(0xFFA4C639)
                    : Colors.grey,
                width: 2,
              ),
            ),
            child: _acquisitionSource == value
                ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFA4C639),
                  shape: BoxShape.circle,
                ),
              ),
            )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            value,
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

  Widget _buildPedigreeButton(String label, IconData icon) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFA4C639).withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_isSubmitting) return;
    if (_nameController.text.isEmpty) {
      AppFeedback.showError(context, 'Please enter a cow name');
      return;
    }

    if (mounted) {
      setState(() => _isSubmitting = true);
    }

    String? photoKey;
    if (_selectedImage != null) {
      setState(() => _isUploading = true);
      photoKey = await _uploadImageAndGetKey(_selectedImage!);
      if (mounted) setState(() => _isUploading = false);

      if (photoKey != null && photoKey.startsWith('ERROR_')) {
        photoKey = null;
      }
    }

    final dob = _birthDateController.text.isNotEmpty
        ? DateFormat('dd/MM/yyyy').parse(_birthDateController.text)
        : DateTime.now();

    final adultDate = _adultDateController.text.isNotEmpty
        ? DateFormat('dd/MM/yyyy').parse(_adultDateController.text)
        : null;

    bool? isLactating;
    bool? isHeifer;
    bool? isDryOff;

    if (_selectedCowGroup != null) {
      final grp = _selectedCowGroup!.toLowerCase();
      if (grp == 'milking' || grp == 'lactating') {
        isLactating = true;
      } else if (grp == 'dry') {
        isDryOff = true;
      } else if (grp == 'heifer') {
        isHeifer = true;
      }
    }

    final parity = int.tryParse(_parityController.text) ?? 0;
    if (parity > 0) {
      isHeifer = false;
    }

    String? motherId;
    String? motherName;
    if (_selectedMother != null) {
      final index = _cowLabels.indexOf(_selectedMother!);
      if (index != -1) {
        motherId = _cows[index]['id'];
        motherName = _cows[index]['name'];
      }
    }

    String? fatherId;
    String? fatherName;
    if (_selectedFather != null) {
      final index = _bullLabels.indexOf(_selectedFather!);
      if (index != -1) {
        fatherId = _bulls[index]['id'];
        fatherName = _bulls[index]['name'];
      }
    }

    final newCattle = Cattle(
      id: '',
      tagNumber: _tagController.text.isNotEmpty
          ? _tagController.text
          : 'NEW-TAG',
      name: _nameController.text,
      breed: _selectedCowType ?? 'Unknown',
      gender: 'FEMALE',
      dateOfBirth: dob,
      status: 'ACTIVE',
      imageUrl: photoKey,
      parity: parity,
      serialNumber: _animalNumberController.text.isNotEmpty
          ? _animalNumberController.text
          : null,
      acquisitionType: _acquisitionSource.toUpperCase(),
      motherId: motherId,
      motherName: motherName,
      fatherId: fatherId,
      fatherName: fatherName,
      dateOfAdult: adultDate,
      isLactating: isLactating,
      isHeifer: isHeifer,
      isPregnant: false,
      isDryOff: isDryOff,
      isRetired: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      cowGroup: _selectedCowGroup,
      isHandicapped: _isHandicapped,
      handicapReason: _isHandicapped ? _problemController.text : null,
      isUdderClosedFL: _isUdderClosedFL,
      isUdderClosedFR: _isUdderClosedFR,
      isUdderClosedBL: _isUdderClosedBL,
      isUdderClosedBR: _isUdderClosedBR,
      purchaseDate: _purchaseDateController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(_purchaseDateController.text)
          : null,
      purchasedFrom: _purchasedFromController.text,
      purchasePrice: double.tryParse(_priceController.text),
      ownerName: _ownerNameController.text,
      ownerMobile: _mobileController.text,
    );

    if (mounted) {
      context.read<CattleBloc>().add(AddCattle(newCattle));
    }
  }

  Widget _buildUdderItem(String label, bool isClosed, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onChanged(!isClosed),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isClosed ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: isClosed ? Border.all(color: Colors.red) : Border.all(color: Colors.transparent),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.water_drop,
                  color: isClosed ? Colors.red[300] : Colors.brown[300],
                  size: 32,
                ),
                if (isClosed)
                  const Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isClosed ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }
}
