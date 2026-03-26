import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/cattle.dart';
import '../bloc/cattle_bloc.dart';
import '../bloc/cattle_event.dart';
import '../../../../core/utils/media_file_utils.dart';

class EditAiBullScreen extends StatefulWidget {
  final Cattle cattle;
  const EditAiBullScreen({super.key, required this.cattle});

  @override
  State<EditAiBullScreen> createState() => _EditAiBullScreenState();
}

class _EditAiBullScreenState extends State<EditAiBullScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _tagController;
  late TextEditingController _animalNumberController;
  late TextEditingController _motherMilkController;
  late TextEditingController _grandmotherMilkController;

  String? _selectedCowType;
  File? _selectedImage;
  bool _imageDeleted = false; // Track if user deleted the image
  bool _isUploading = false;
  List<String> _breeds = [];
  bool _loadingBreeds = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cattle.name);
    _tagController = TextEditingController(text: widget.cattle.tagNumber);
    _animalNumberController = TextEditingController(
      text: widget.cattle.serialNumber,
    );
    // Assuming milk stats are not in Cattle entity yet, so blank for now or mock
    _motherMilkController = TextEditingController(
      text: '4155 Ltr.',
    ); // Mock from image
    _grandmotherMilkController = TextEditingController(
      text: '6500 Ltr.',
    ); // Mock from image

    _selectedCowType = widget.cattle.breed;
    _fetchBreeds();
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
      final uploadUrl = presignedData['uploadUrl'] as String?;
      final key =
          presignedData['viewUrl'] as String? ?? presignedData['key'] as String?;

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
      debugPrint('[IMG] Upload exception: $e');
      return null;
    }
  }

  void _deletePhoto() {
    setState(() {
      _selectedImage = null;
      _imageDeleted = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _animalNumberController.dispose();
    _motherMilkController.dispose();
    _grandmotherMilkController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Upload image if a new one was selected
      String? newPhotoKey;
      if (_selectedImage != null) {
        setState(() => _isUploading = true);
        newPhotoKey = await _uploadImageAndGetKey(_selectedImage!);
        setState(() => _isUploading = false);

        if (newPhotoKey != null && newPhotoKey.startsWith('ERROR_')) {
          String errorMsg = 'Image upload failed';
          if (newPhotoKey.contains('401')) errorMsg = 'Unauthorized';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$errorMsg. Saving other changes...'),
              backgroundColor: Colors.orange,
            ),
          );
          newPhotoKey = null;
        }
      }

      final updatedCattle = Cattle(
        id: widget.cattle.id,
        tagNumber: _tagController.text,
        name: _nameController.text,
        breed: _selectedCowType ?? widget.cattle.breed,
        gender: widget.cattle.gender,
        dateOfBirth: widget.cattle.dateOfBirth,
        status: widget.cattle.status,
        parity: widget.cattle.parity,
        serialNumber: _animalNumberController.text,
        createdAt: widget.cattle.createdAt,
        updatedAt: DateTime.now(),
        imageUrl: _imageDeleted
            ? null
            : (newPhotoKey ?? widget.cattle.imageUrl),
        bullView: 'AI',
        motherMilk: double.tryParse(_motherMilkController.text.trim()),
        grandmotherMilk: double.tryParse(
          _grandmotherMilkController.text.trim(),
        ),
      );

      if (mounted) {
        context.read<CattleBloc>().add(UpdateCattle(updatedCattle));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Edit Bull Details', // AI Bull Edit Screen
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
              const SizedBox(height: 40),

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

              // Milk Stats
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
              const SizedBox(height: 32),

              // Submit Button
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
            ],
          ),
        ),
      ),
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
              value: value,
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
