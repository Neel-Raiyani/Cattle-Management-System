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

class AddBullScreen extends StatefulWidget {
  const AddBullScreen({super.key});

  @override
  State<AddBullScreen> createState() => _AddBullScreenState();
}

class _AddBullScreenState extends State<AddBullScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _animalNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _adultDateController = TextEditingController();

  final TextEditingController _bullViewController = TextEditingController();
  final TextEditingController _motherMilkController = TextEditingController();
  final TextEditingController _grandmotherMilkController =
  TextEditingController();

  // Purchase info
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _purchasedFromController =
  TextEditingController();

  // Dropdown values
  String? _selectedCowType;
  String? _selectedCowGroup;
  String? _selectedMother;
  String? _selectedFather;

  // Toggles & Radio
  String _acquisitionSource = 'Birth';
  File? _selectedImage;
  bool _isUploading = false;
  List<String> _breeds = [];
  bool _loadingBreeds = false;

  // Live listing for dropdowns
  List<Map<String, dynamic>> _cows = []; // mothers
  List<Map<String, dynamic>> _bulls = []; // fathers
  List<String> _cowLabels = [];
  List<String> _bullLabels = [];
  bool _loadingParents = false;

  @override
  void initState() {
    super.initState();
    context.read<CowGroupBloc>().add(LoadCowGroups());
    _fetchParentAnimals();
    _fetchBreeds();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _animalNumberController.dispose();
    _birthDateController.dispose();
    _adultDateController.dispose();
    _bullViewController.dispose();
    _motherMilkController.dispose();
    _grandmotherMilkController.dispose();
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

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

  Future<void> _fetchBreeds() async {
    setState(() => _loadingBreeds = true);
    try {
      final breeds = await sl<ApiService>().getBreeds();
      setState(() {
        _breeds = breeds;
      });
    } catch (e) {
      debugPrint('Error fetching breeds: $e');
    } finally {
      if (mounted) setState(() => _loadingBreeds = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CattleBloc, CattleState>(
      listener: (context, state) {
        if (state is CattleAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bull added successfully!'),
              backgroundColor: Color(0xff99AA5A),
            ),
          );
          Navigator.pop(context);
        } else if (state is CattleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding bull: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
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
            'Add Bull Details',
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
                                color: const Color(0xfff7fdf4),
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
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _loadingBreeds
                          ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : _buildDropdown(
                        'Bull Type',
                        'Select breed',
                        _breeds,
                        _selectedCowType,
                            (val) => setState(() => _selectedCowType = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BlocBuilder<CowGroupBloc, CowGroupState>(
                        builder: (context, state) {
                          List<String> groupNames = [
                            'Bulls',
                            'Nandi',
                          ];
                          if (state is CowGroupLoaded && state.groups.isNotEmpty) {
                            groupNames = state.groups.map((g) => g.name).toList();
                          }
                          return _buildDropdown(
                            'Bull Group',
                            'Select bull group',
                            groupNames,
                            _selectedCowGroup,
                                (val) => setState(() => _selectedCowGroup = val),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField('Bull Name', 'Enter bull name', _nameController),
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
                        'Enter bull number',
                        _animalNumberController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        'Birth Date',
                        _birthDateController,
                        onDateSelected: (date) {
                          final adultDate = DateTime(
                            date.year + 1,
                            date.month,
                            date.day,
                          );
                          setState(() {
                            _birthDateController.text =
                                DateFormat('dd MMM yyyy').format(date);
                            _adultDateController.text =
                                DateFormat('dd MMM yyyy').format(adultDate);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePicker(
                        'Adult Date',
                        _adultDateController,
                        enabled: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  'Bull View',
                  'Enter bull view details',
                  _bullViewController,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Mother Milk Yield',
                        'Enter income',
                        _motherMilkController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Grand Mother Milk Yield',
                        'Enter income',
                        _grandmotherMilkController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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
                          'Enter purchased from name',
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
                  const SizedBox(height: 24),
                ],

                if (_acquisitionSource == 'Birth') ...[
                  if (_loadingParents)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Color(0xff99AA5A),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            'Mother Name',
                            _cowLabels.isEmpty ? 'No cows available' : 'Select mother',
                            _cowLabels,
                            (_cowLabels.contains(_selectedMother))
                                ? _selectedMother
                                : null,
                                (val) => setState(() => _selectedMother = val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            'Father Name',
                            _bullLabels.isEmpty ? 'No bulls available' : 'Select father',
                            _bullLabels,
                            (_bullLabels.contains(_selectedFather))
                                ? _selectedFather
                                : null,
                                (val) => setState(() => _selectedFather = val),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff99AA5A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
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
          style: GoogleFonts.inter(fontSize: 14),
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
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String label,
      String hint,
      List<String> items,
      String? value,
      ValueChanged<String?> onChanged,
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
              isExpanded: true,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

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
              firstDate: DateTime(1980),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              if (onDateSelected != null) {
                onDateSelected(pickedDate);
              } else {
                setState(() {
                  controller.text =
                      DateFormat('dd MMM yyyy').format(pickedDate);
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: enabled ? const Color(0xFFF5F6F7) : Colors.grey[200],
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
                  color: enabled ? Colors.grey : Colors.grey[400],
                ),
              ],
            ),
          ),
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
                    ? const Color(0xff99AA5A)
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
                  color: Color(0xff99AA5A),
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
        color: const Color(0xff99AA5A).withOpacity(0.8),
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
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter bull name')),
      );
      return;
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

    DateTime dob = DateTime.now();
    try {
      if (_birthDateController.text.isNotEmpty) {
        dob = DateFormat('dd MMM yyyy').parse(_birthDateController.text);
      }
    } catch (e) {}

    DateTime? adultDate;
    try {
      if (_adultDateController.text.isNotEmpty) {
        adultDate = DateFormat('dd MMM yyyy').parse(_adultDateController.text);
      }
    } catch (e) {}

    String? motherId;
    String? motherName;
    String? fatherId;
    String? fatherName;

    if (_selectedMother != null) {
      final index = _cowLabels.indexOf(_selectedMother!);
      if (index != -1) {
        motherId = _cows[index]['id'];
        motherName = _cows[index]['name'];
      }
    }

    if (_selectedFather != null) {
      final index = _bullLabels.indexOf(_selectedFather!);
      if (index != -1) {
        fatherId = _bulls[index]['id'];
        fatherName = _bulls[index]['name'];
      }
    }

    final newBull = Cattle(
      id: '',
      tagNumber: _tagController.text.isNotEmpty
          ? _tagController.text
          : 'NEW-BULL',
      name: _nameController.text,
      breed: _selectedCowType ?? 'Unknown',
      gender: 'MALE',
      dateOfBirth: dob,
      status: 'ACTIVE',
      parity: 0,
      serialNumber: _animalNumberController.text,
      acquisitionType: _acquisitionSource.toUpperCase(),
      motherId: motherId,
      motherName: motherName,
      fatherId: fatherId,
      fatherName: fatherName,
      dateOfAdult: adultDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: photoKey,
      isRetired: false,
      cowGroup: _selectedCowGroup,
      motherMilk: double.tryParse(_motherMilkController.text),
      grandmotherMilk: double.tryParse(_grandmotherMilkController.text),
      bullView: _bullViewController.text,
      purchaseDate: _purchaseDateController.text.isNotEmpty
          ? DateFormat('dd MMM yyyy').parse(_purchaseDateController.text)
          : null,
      purchasedFrom: _purchasedFromController.text,
      purchasePrice: double.tryParse(_priceController.text),
      ownerName: _ownerNameController.text,
      ownerMobile: _mobileController.text,
    );

    if (mounted) {
      context.read<CattleBloc>().add(AddCattle(newBull));
    }
  }
}
