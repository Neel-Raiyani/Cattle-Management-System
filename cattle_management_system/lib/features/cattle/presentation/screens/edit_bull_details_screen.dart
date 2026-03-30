import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import '../../domain/entities/cattle.dart';
import '../bloc/cattle_bloc.dart';
import '../bloc/cattle_event.dart';
import '../bloc/cattle_state.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/animal_image_url.dart';
import '../../../../core/utils/media_file_utils.dart';
import '../../../../core/utils/app_feedback.dart';

class EditBullDetailsScreen extends StatefulWidget {
  final Cattle cattle;
  const EditBullDetailsScreen({super.key, required this.cattle});

  @override
  State<EditBullDetailsScreen> createState() => _EditBullDetailsScreenState();
}

class _EditBullDetailsScreenState extends State<EditBullDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _tagController;
  late TextEditingController _animalNumberController;
  late TextEditingController _birthDateController;
  late TextEditingController _adultDateController;
  late TextEditingController _bullViewController;
  late TextEditingController _motherMilkController;
  late TextEditingController _grandmotherMilkController;

  // Purchase Fields
  late TextEditingController _purchaseDateController;
  late TextEditingController _ownerNameController;
  late TextEditingController _mobileController;
  late TextEditingController _priceController;
  late TextEditingController _purchasedFromController;

  // Dropdown Values
  String? _selectedCowType;

  // Toggles & Radio
  String _acquisitionSource = 'Birth';
  File? _selectedImage;
  bool _imageDeleted = false; // Track if user deleted the image
  bool _isUploading = false;
  List<String> _breeds = [];
  bool _loadingBreeds = false;

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
    _fetchBreeds();
    // Initialize controllers with existing data
    _nameController = TextEditingController(text: widget.cattle.name);
    _tagController = TextEditingController(text: widget.cattle.tagNumber);
    _animalNumberController = TextEditingController(
      text: widget.cattle.serialNumber ?? '',
    );
    _birthDateController = TextEditingController(
      text: DateFormat('dd MMM, yyyy').format(widget.cattle.dateOfBirth),
    );

    _adultDateController = TextEditingController(
      text: widget.cattle.dateOfAdult != null
          ? DateFormat('dd MMM, yyyy').format(widget.cattle.dateOfAdult!)
          : '',
    );

    // Bull View field - map from something?
    _bullViewController = TextEditingController();

    // Purchase info if any
    _purchaseDateController = TextEditingController();
    _ownerNameController = TextEditingController();
    _mobileController = TextEditingController();
    _priceController = TextEditingController();
    _purchasedFromController = TextEditingController();

    _motherMilkController = TextEditingController();
    _grandmotherMilkController = TextEditingController();

    _selectedCowType = widget.cattle.breed;

    // Status/Source mapping
    // If status implies source we could map it, but for now default 'Birth' or whatever is saved.
    // Since Cattle entity doesn't strictly have 'source', we stick to UI.
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageDeleted = false;
      });
    }
  }

  Future<String?> _uploadImageAndGetKey(File imageFile) async {
    try {
      final fileName = imageFile.path
          .split(Platform.isWindows ? '\\' : '/')
          .last;
      final contentType = resolveMimeTypeFromFileName(fileName);

      final presignedData = await sl<ApiService>().getPresignedUrl(
        fileName: fileName,
        contentType: contentType,
        type: 'PHOTO',
      );
      final uploadUrl = presignedData['uploadUrl']?.toString();
      final storablePhotoUrl = deriveAnimalImageStorageKey(
        key: presignedData['key']?.toString(),
        uploadUrl: uploadUrl,
        viewUrl: presignedData['viewUrl']?.toString(),
      );

      if (uploadUrl == null ||
          storablePhotoUrl == null ||
          storablePhotoUrl.isEmpty) {
        return null;
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();
      final s3Response = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': contentType},
        body: imageBytes,
      );

      if (s3Response.statusCode != 200 && s3Response.statusCode != 204) {
        return 'ERROR_S3_${s3Response.statusCode}';
      }

      return storablePhotoUrl;
    } catch (e) {
      debugPrint('[IMG] Upload exception: $e');
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

  void _deletePhoto() {
    setState(() {
      _selectedImage = null;
      _imageDeleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CattleBloc, CattleState>(
      listener: (context, state) {
        if (state is CattleUpdated) {
          Navigator.pop(context, true);
        } else if (state is CattleActionError) {
          AppFeedback.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
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
            'Edit Bull Details',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Profile Image
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
                            image: (_imageDeleted)
                                ? null
                                : (_selectedImage != null)
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : (widget.cattle.imageUrl != null &&
                                      widget.cattle.imageUrl!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(
                                      widget.cattle.imageUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              (_imageDeleted ||
                                  (_selectedImage == null &&
                                      (widget.cattle.imageUrl == null ||
                                          widget.cattle.imageUrl!.isEmpty)))
                              ? Padding(
                                  padding: EdgeInsets.all(30),
                                  child: Image.asset(
                                    'assets/icons/father_cow.png',
                                    color: Colors.brown[400],
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: -20,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xff99AA5A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Delete Photo Button
                    GestureDetector(
                      onTap: _deletePhoto,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE), // Light red bg
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete Photo',
                              style: GoogleFonts.poppins(
                                color: Colors.red,
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

              // Cow Type
              _loadingBreeds
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _buildDropdown(
                      'Cow Type',
                      'Select cow type',
                      _breeds,
                      _selectedCowType,
                      (val) => setState(() => _selectedCowType = val),
                    ),
              const SizedBox(height: 16),

              // Bull Name
              _buildTextField('Bull Name', 'Enter bull name', _nameController),
              const SizedBox(height: 16),

              // Tag No & Bull Number
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

              // Dates
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      'Birth Date',
                      _birthDateController,
                      showClear: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      'Adult Date',
                      _adultDateController,
                      showClear: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Source of Acquisition
              Text(
                'Source of Acquistion',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color:
                      Colors.grey[400], // Slight fade as per edit mode usually
                ),
              ),
              const SizedBox(height: 16),

              // Submit Button (Middle placement as per image logic somewhat, but standard form usually)
              // The user mentioned image 122 flow: Source -> Submit -> Pedigree...
              // I'll stick to bottom submit to avoid confusion unless explicitly told to fragment the form.
              // Wait, if I split it, it implies two potential updates?
              // I'll keep one big Submit at the bottom but include all fields.
              if (_acquisitionSource == 'Purchase') ...[
                // Purchase fields
              ],

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),

              // Pedigree / Relations (Below Submit as per image 122?)
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      'Mother Name',
                      'Select',
                      ['Kaveri'],
                      'Kaveri',
                      (val) {},
                    ),
                  ), // Dummy
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      'Father Name',
                      'Select father name',
                      [],
                      null,
                      (val) {},
                    ),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Or',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ),
              ),
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

              // Bull View
              _buildTextField(
                'Bull View',
                'Enter bull view',
                _bullViewController,
              ),
              const SizedBox(height: 16),

              // Milk
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Mother Milk',
                      'e.g. 100 Ltr.',
                      _motherMilkController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Grandmother Milk',
                      'e.g. 100 Ltr.',
                      _grandmotherMilkController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helpers
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
        if (label.isNotEmpty)
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 8),
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
        if (label.isNotEmpty)
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6F7),
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
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

  Widget _buildDatePicker(
    String label,
    TextEditingController controller, {
    bool showClear = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (showClear)
              GestureDetector(
                onTap: () => controller.clear(),
                child: Text(
                  'Clear',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xff99AA5A),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2050),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = DateFormat('dd MMM, yyyy').format(pickedDate);
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Select Date' : controller.text,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: controller.text.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPedigreeButton(String label, IconData icon) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xff99AA5A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                SizedBox(width: 4),
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
        ),
      ),
    );
  }

  void _submitForm() async {
    // Basic validation
    if (_nameController.text.isEmpty) return;

    // Upload image if a new one was selected
    String? newPhotoKey;
    if (_selectedImage != null) {
      setState(() => _isUploading = true);
      newPhotoKey = await _uploadImageAndGetKey(_selectedImage!);
      setState(() => _isUploading = false);

      if (newPhotoKey != null && newPhotoKey.startsWith('ERROR_')) {
        String errorMsg = 'Image upload failed';
        if (newPhotoKey.contains('401')) errorMsg = 'Unauthorized';

        AppFeedback.showError(context, '$errorMsg. Saving other changes...');
        newPhotoKey = null;
      }
    }

    // Parse Date
    DateTime dob = widget.cattle.dateOfBirth;
    try {
      if (_birthDateController.text.isNotEmpty) {
        dob = DateFormat('dd MMM, yyyy').parse(_birthDateController.text);
      }
    } catch (e) {}

    final updatedCattle = Cattle(
      id: widget.cattle.id,
      tagNumber: _tagController.text,
      name: _nameController.text,
      breed: _selectedCowType ?? widget.cattle.breed,
      gender: widget.cattle.gender,
      dateOfBirth: dob,
      status: widget.cattle.status,
      parity: widget.cattle.parity,
      serialNumber: _animalNumberController.text,
      createdAt: widget.cattle.createdAt,
      updatedAt: DateTime.now(),
      imageUrl: _imageDeleted ? null : (newPhotoKey ?? widget.cattle.imageUrl),
      bullType: widget.cattle.bullType ?? 'GAUSHALA',
      bullView: _bullViewController.text.isNotEmpty
          ? _bullViewController.text
          : widget.cattle.bullView,
    );

    if (mounted) {
      context.read<CattleBloc>().add(UpdateCattle(updatedCattle));
    }
  }
}
