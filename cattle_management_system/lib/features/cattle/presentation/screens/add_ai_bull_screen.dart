import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import '../../domain/entities/cattle.dart';
import '../bloc/cattle_bloc.dart';
import '../bloc/cattle_event.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/cattle_state.dart';
import '../../../cow_group/presentation/bloc/cow_group_bloc.dart';
import '../../../cow_group/presentation/bloc/cow_group_event.dart';
import '../../../cow_group/presentation/bloc/cow_group_state.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/media_file_utils.dart';

class AddAiBullScreen extends StatefulWidget {
  const AddAiBullScreen({super.key});

  @override
  State<AddAiBullScreen> createState() => _AddAiBullScreenState();
}

class _AddAiBullScreenState extends State<AddAiBullScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _animalNumberController = TextEditingController();
  final TextEditingController _motherMilkController = TextEditingController();
  final TextEditingController _grandmotherMilkController =
      TextEditingController();

  String? _selectedCowType;
  String? _selectedCowGroup;
  File? _selectedImage;
  bool _isUploading = false;
  bool _isSubmitting = false;
  List<String> _breeds = [];
  bool _loadingBreeds = false;

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

      debugPrint('[IMG] S3 status: ${s3Response.statusCode}');

      if (s3Response.statusCode != 200 && s3Response.statusCode != 204) {
        return 'ERROR_S3_${s3Response.statusCode}';
      }

      return key;
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

  @override
  void initState() {
    super.initState();
    context.read<CowGroupBloc>().add(LoadCowGroups());
    _fetchBreeds();
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
    if (_isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() => _isSubmitting = true);
      }
      // Upload image if selected
      String? photoKey;
      if (_selectedImage != null) {
        setState(() => _isUploading = true);
        photoKey = await _uploadImageAndGetKey(_selectedImage!);
        setState(() => _isUploading = false);

        if (photoKey != null && photoKey.startsWith('ERROR_')) {
          String errorMsg = 'Image upload failed';
          if (photoKey.contains('401'))
            errorMsg = 'Unauthorized: Please re-login';
          if (photoKey.contains('S3')) errorMsg = 'Server storage error';

          AppFeedback.showWarning(
            context,
            '$errorMsg. Adding AI bull without photo...',
          );
          photoKey = null;
        }
      }

      final newCattle = Cattle(
        id: '', // empty → toJson() skips it → MongoDB auto-generates it
        tagNumber: _tagController.text,
        name: _nameController.text,
        breed: _selectedCowType ?? 'Gir',
        gender: 'MALE',
        dateOfBirth: DateTime.now(),
        status: 'ACTIVE',
        parity: 0,
        serialNumber: _animalNumberController.text,
        acquisitionType: 'BIRTH',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: photoKey, // S3 key
        isRetired: false,
        cowGroup: _selectedCowGroup,
        bullType: 'AI',
        bullView: 'AI',
        motherMilk: double.tryParse(_motherMilkController.text.trim()),
        grandmotherMilk: double.tryParse(
          _grandmotherMilkController.text.trim(),
        ),
      );

      if (mounted) {
        context.read<CattleBloc>().add(AddCattle(newCattle));
      }
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
          Navigator.pop(context, true);
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
            'Add Bull Details', // AI Bull Add Screen
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
                // Profile Image Picker
                Center(
                  child: Stack(
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
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? Center(
                                child: Image.asset(
                                  'assets/icons/father_cow.png',
                                  width: 80,
                                  height: 80,
                                  color: Colors.brown[400],
                                ),
                              ) // Placeholder icon
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
                              border: Border.all(color: Colors.white, width: 2),
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
                ),
                const SizedBox(height: 40),

                // Cow Type
                _loadingBreeds
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
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
                          List<String> groupNames = [
                            'Milking',
                            'Dry',
                            'Heifer',
                            'Calf',
                          ];
                          if (state is CowGroupLoaded) {
                            if (state.groups.isNotEmpty) {
                              groupNames = state.groups.map((g) => g.name).toList();
                            }
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

                // Bull Name
                _buildTextField(
                  'Bull Name',
                  'Enter bull name',
                  _nameController,
                ),
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
                    onPressed: (_isUploading || _isSubmitting) ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff99AA5A),
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
              ],
            ),
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
