import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../domain/entities/cattle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cow_group/presentation/bloc/cow_group_bloc.dart';
import '../../../../cow_group/presentation/bloc/cow_group_state.dart';
import '../../../../cow_group/presentation/bloc/cow_group_event.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../bloc/cattle_bloc.dart';
import '../../bloc/cattle_event.dart';
import '../../bloc/cattle_state.dart';
import '../../../../../core/utils/app_feedback.dart';

class EditCowDetailsScreen extends StatefulWidget {
  final Cattle cattle;

  const EditCowDetailsScreen({super.key, required this.cattle});

  @override
  State<EditCowDetailsScreen> createState() => _EditCowDetailsScreenState();
}

class _EditCowDetailsScreenState extends State<EditCowDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _tagController;
  late TextEditingController _animalNumberController;
  late TextEditingController _parityController;
  late TextEditingController _birthDateController;
  late TextEditingController _adultDateController;
  late TextEditingController _problemController;

  // Dropdown Values
  String? _selectedCowType;
  String? _selectedCowGroup;
  String? _selectedMother;
  String? _selectedFather;

  // Toggles & Radio
  bool _isHandicapped = false;
  String _acquisitionSource = 'Birth'; // Birth, Donation, Purchase
  bool _isUdderClosedFL = false;
  bool _isUdderClosedFR = false;
  bool _isUdderClosedBL = false;
  bool _isUdderClosedBR = false;

  File? _selectedImage;
  bool _isUploading = false;
  bool _imageDeleted = false;

  // Live listing for dropdowns
  List<Map<String, dynamic>> _cows = []; // mothers
  List<Map<String, dynamic>> _bulls = []; // fathers
  List<String> _cowLabels = [];
  List<String> _bullLabels = [];
  bool _loadingParents = false;
  List<String> _breeds = [];
  bool _loadingBreeds = false;

  Future<void> _fetchParentAnimals() async {
    setState(() => _loadingParents = true);
    try {
      final api = sl<ApiService>();
      final results = await Future.wait([
        api.getCows(limit: 500),
        api.getBulls(limit: 500),
      ]);

      _cows = results[0]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _bulls = results[1]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      _cowLabels = _cows.map((c) => '${c['name']} (${c['tagNumber']})').toList();
      _bullLabels = _bulls
          .map((b) => '${b['name']} (${b['tagNumber']})')
          .toList();

      if (widget.cattle.motherId != null) {
        final match = _cows.indexWhere(
          (c) => (c['_id'] ?? c['id']) == widget.cattle.motherId,
        );
        if (match != -1) _selectedMother = _cowLabels[match];
      } else if (widget.cattle.motherName != null) {
        final match = _cows.indexWhere((c) => c['name'] == widget.cattle.motherName);
        if (match != -1) _selectedMother = _cowLabels[match];
      }

      if (widget.cattle.fatherId != null) {
        final match = _bulls.indexWhere(
          (b) => (b['_id'] ?? b['id']) == widget.cattle.fatherId,
        );
        if (match != -1) _selectedFather = _bullLabels[match];
      } else if (widget.cattle.fatherName != null) {
        final match = _bulls.indexWhere((b) => b['name'] == widget.cattle.fatherName);
        if (match != -1) _selectedFather = _bullLabels[match];
      }
    } catch (e) {
      debugPrint('Error fetching parent animals: $e');
    } finally {
      if (mounted) setState(() => _loadingParents = false);
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

  void _deletePhoto() {
    setState(() {
      _selectedImage = null;
      _imageDeleted = true;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<CowGroupBloc>().add(LoadCowGroups());
    _initializeControllers();
    _fetchParentAnimals();
    _fetchBreeds();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.cattle.name);
    _tagController = TextEditingController(text: widget.cattle.tagNumber);
    _animalNumberController = TextEditingController(
      text: widget.cattle.serialNumber ?? '',
    );
    _parityController = TextEditingController(
      text: (widget.cattle.parity ?? 0).toString(),
    );
    _birthDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.cattle.dateOfBirth),
    );
    _adultDateController = TextEditingController(
      text: widget.cattle.dateOfAdult != null
          ? DateFormat('dd/MM/yyyy').format(widget.cattle.dateOfAdult!)
          : '',
    );
    _problemController = TextEditingController();

    _selectedCowType = widget.cattle.breed;
    _selectedCowGroup = widget.cattle.cowGroup;

    // Initialize acquisition source from entity
    if (widget.cattle.acquisitionType != null) {
      final src = widget.cattle.acquisitionType!.toLowerCase();
      if (src == 'birth')
        _acquisitionSource = 'Birth';
      else if (src == 'donation')
        _acquisitionSource = 'Donation';
      else if (src == 'purchase')
        _acquisitionSource = 'Purchase';
    }

    _isUdderClosedFL = widget.cattle.isUdderClosedFL ?? false;
    _isUdderClosedFR = widget.cattle.isUdderClosedFR ?? false;
    _isUdderClosedBL = widget.cattle.isUdderClosedBL ?? false;
    _isUdderClosedBR = widget.cattle.isUdderClosedBR ?? false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CattleBloc, CattleState>(
      listener: (context, state) {
        if (state is CattleUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cow updated successfully!'),
              backgroundColor: Color(0xFFA4C639),
            ),
          );
          Navigator.pop(context);
        } else if (state is CattleError || state is CattleActionError) {
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
            'Edit Cow Details',
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
                                color: const Color(
                                  0xff99AA5A,
                                ), // Matching the greenish-olive border
                                width: 2, // Thicker border as shown in image
                              ),
                            ),
                            child: ClipOval(
                              child: _imageDeleted
                                  ? Center(
                                      child: Icon(
                                        Icons.pets,
                                        size: 60,
                                        color: Colors.brown[300],
                                      ),
                                    )
                                  : _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : (widget.cattle.imageUrl != null &&
                                        widget.cattle.imageUrl!.isNotEmpty)
                                  ? Image.network(
                                      widget.cattle.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Center(
                                                child: Icon(
                                                  Icons.pets,
                                                  size: 60,
                                                  color: Colors.brown[300],
                                                ),
                                              ),
                                    )
                                  : Center(
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
                                padding: const EdgeInsets.all(
                                  12,
                                ), // Larger padding for button
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xff99AA5A,
                                  ), // Matching button color
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
                        onTap: _deletePhoto,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
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
                              const SizedBox(width: 4),
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

                // Cow Type & Group
                Row(
                  children: [
                    Expanded(
                      child: _loadingBreeds
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
                            groupNames = state.groups
                                .map((g) => g.name)
                                .toList();
                          }
                          return _buildDropdown(
                            'Cow Group',
                            'Select cow group',
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

                // Cow Name
                _buildTextField('Cow Name', 'Enter cow name', _nameController),
                const SizedBox(height: 16),

                // Tag No. & Animal Number
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

                // Parity
                _buildTextField(
                  'Parity',
                  'Enter cow parity',
                  _parityController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Handicapped Toggle
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

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        'Birth Date',
                        _birthDateController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePicker(
                        'Adult Date',
                        _adultDateController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Udder Selection
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
                    _buildUdderItem('FL', _isUdderClosedFL,
                        (val) => setState(() => _isUdderClosedFL = val)),
                    _buildUdderItem('FR', _isUdderClosedFR,
                        (val) => setState(() => _isUdderClosedFR = val)),
                    _buildUdderItem('BL', _isUdderClosedBL,
                        (val) => setState(() => _isUdderClosedBL = val)),
                    _buildUdderItem('BR', _isUdderClosedBR,
                        (val) => setState(() => _isUdderClosedBR = val)),
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
                      backgroundColor: const Color(0xFFA4C639),
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
                const SizedBox(height: 32),

                // Source of Acquisition
                Text(
                  'Source of Acquistion',
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mother Name',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_loadingParents)
                            const Center(child: LinearProgressIndicator())
                          else
                            _buildDropdown(
                              'Mother',
                              'Select mother',
                              _cowLabels,
                              _selectedMother,
                              (val) => setState(() => _selectedMother = val),
                              showLabel: false,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Father Name',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_loadingParents)
                            const Center(child: LinearProgressIndicator())
                          else
                            _buildDropdown(
                              'Father',
                              'Select father',
                              _bullLabels,
                              _selectedFather,
                              (val) => setState(() => _selectedFather = val),
                              showLabel: false,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
    ValueChanged<String?> onChanged, {
    bool showLabel = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value != null && items.contains(value) ? value : null,
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
      onTap: () {
        setState(() {
          _acquisitionSource = value;
        });
      },
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

      debugPrint('[IMG] S3 status: ${s3Response.statusCode}');

      if (s3Response.statusCode != 200 && s3Response.statusCode != 204) {
        debugPrint('[IMG] S3 upload failed: ${s3Response.statusCode}');
        return 'ERROR_S3_${s3Response.statusCode}';
      }

      debugPrint('[IMG] Upload success! Key: $key');
      return key;
    } catch (e) {
      debugPrint('Image upload exception: $e');
      return null;
    }
  }

  void _submitForm() async {
    if (_nameController.text.trim().isEmpty) {
      AppFeedback.showError(context, 'Please enter cow name');
      return;
    }

    // Upload image if a new one was selected
    String? newPhotoKey;
    if (_selectedImage != null) {
      setState(() => _isUploading = true);
      newPhotoKey = await _uploadImageAndGetKey(_selectedImage!);
      if (mounted) setState(() => _isUploading = false);

      if (newPhotoKey != null && newPhotoKey.startsWith('ERROR_')) {
        String errorMsg = 'Image upload failed';
        if (newPhotoKey.contains('401'))
          errorMsg = 'Unauthorized: Please re-login';
        if (newPhotoKey.contains('S3')) errorMsg = 'Server storage error';

        AppFeedback.showWarning(
          context,
          '$errorMsg. Saving other changes...',
        );
        newPhotoKey = null; // Don't save the error code as URL
      } else if (newPhotoKey == null && mounted) {
        AppFeedback.showWarning(
          context,
          'Image upload failed. Saving other changes...',
        );
      }
    }

    // Extract parent IDs and names
    String? motherId;
    String? motherName;
    if (_selectedMother != null) {
      final index = _cowLabels.indexOf(_selectedMother!);
      if (index != -1) {
        motherId = _cows[index]['_id'] ?? _cows[index]['id'];
        motherName = _cows[index]['name'];
      }
    }

    String? fatherId;
    String? fatherName;
    if (_selectedFather != null) {
      final index = _bullLabels.indexOf(_selectedFather!);
      if (index != -1) {
        fatherId = _bulls[index]['_id'] ?? _bulls[index]['id'];
        fatherName = _bulls[index]['name'];
      }
    }

    final dob = _birthDateController.text.isNotEmpty
        ? DateFormat('dd/MM/yyyy').parse(_birthDateController.text)
        : widget.cattle.dateOfBirth;

    final adultDate = _adultDateController.text.isNotEmpty
        ? DateFormat('dd/MM/yyyy').parse(_adultDateController.text)
        : null;

    // Determine status flags based on group
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

    final updatedCattle = Cattle(
      id: widget.cattle.id,
      tagNumber: _tagController.text.trim().isNotEmpty
          ? _tagController.text.trim()
          : widget.cattle.tagNumber,
      name: _nameController.text.trim(),
      breed: _selectedCowType ?? widget.cattle.breed,
      gender: widget.cattle.gender,
      dateOfBirth: dob,
      status: widget.cattle.status,
      // Use newly uploaded key if available, otherwise keep existing photoUrl unless deleted
      imageUrl: _imageDeleted ? null : (newPhotoKey ?? widget.cattle.imageUrl),
      acquisitionType: _acquisitionSource.toUpperCase(),
      isLactating: isLactating ?? widget.cattle.isLactating,
      isHeifer: isHeifer ?? widget.cattle.isHeifer,
      isPregnant: widget.cattle.isPregnant,
      isDryOff: isDryOff ?? widget.cattle.isDryOff,
      isRetired: widget.cattle.isRetired,
      parity: int.tryParse(_parityController.text) ?? widget.cattle.parity ?? 0,
      serialNumber: _animalNumberController.text.trim().isNotEmpty
          ? _animalNumberController.text.trim()
          : widget.cattle.serialNumber,
      motherId: motherId,
      motherName: motherName,
      fatherId: fatherId,
      fatherName: fatherName,
      dateOfAdult: adultDate,
      createdAt: widget.cattle.createdAt,
      updatedAt: DateTime.now(),
      cowGroup: _selectedCowGroup,
      isHandicapped: _isHandicapped,
      handicapReason: _isHandicapped ? _problemController.text : null,
      isUdderClosedFL: _isUdderClosedFL,
      isUdderClosedFR: _isUdderClosedFR,
      isUdderClosedBL: _isUdderClosedBL,
      isUdderClosedBR: _isUdderClosedBR,
      // Purchase info and other fields would need to be populated if added to UI
      purchaseDate: widget.cattle.purchaseDate,
      purchasedFrom: widget.cattle.purchasedFrom,
      purchasePrice: widget.cattle.purchasePrice,
      ownerName: widget.cattle.ownerName,
      ownerMobile: widget.cattle.ownerMobile,
    );

    if (mounted) {
      context.read<CattleBloc>().add(UpdateCattle(updatedCattle));
    }
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
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
                    controller.text.isEmpty ? 'Select date' : controller.text,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: controller.text.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
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
