import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cattle_management_system/core/di/injection_container.dart';
import 'package:cattle_management_system/core/services/api_service.dart';
import 'package:cattle_management_system/features/cattle/data/models/cattle_model.dart';
import '../../domain/entities/health_event.dart';
import '../../../cattle/domain/entities/cattle.dart';

class AddLabTestScreen extends StatefulWidget {
  final HealthEvent? existingRecord;
  const AddLabTestScreen({super.key, this.existingRecord});

  @override
  State<AddLabTestScreen> createState() => _AddLabTestScreenState();
}

class _AddLabTestScreenState extends State<AddLabTestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedAnimalType = 'Cow';
  Cattle? _selectedAnimal;
  DateTime? _sampleDate = DateTime.now();
  DateTime? _resultDate = DateTime.now();
  String? _selectedTest;
  String? _selectedResult;
  final _remarkCtrl = TextEditingController();

  List<Cattle> _cows = [];
  List<Cattle> _bulls = [];
  bool _isLoading = true;
  final List<String> _results = ['Positive', 'Negative'];

  final List<String> _labTests = [
    'Hematology (CBC) (હેમેટોલોજી – રક્ત તપાસ)',
    'Biochemistry (બાયોકેમિસ્ટ્રી – રાસાયણિક તપાસ)',
    'Urine Examination (મૂત્ર તપાસ)',
    'Faecal Examination (મળ તપાસ)',
    'Skin Scraping (ત્વચા ખંજવાળ તપાસ)',
    'Panel Test by Dry Biochemistry (ડ્રાય બાયોકેમિસ્ટ્રી પેનલ ટેસ્ટ)',
    'Allergen Special Test (એલર્જન વિશેષ પરીક્ષણ)',
    'Immuno Canine Vaccicheck (ઇમ્યુનો કેનાઇન વેક્સીચેક ટેસ્ટ)',
    'Microbial Culture (માઈક્રોબિયલ કલ્ચર)',
    'Microbial Culture & DST (માઈક્રોબિયલ કલ્ચર અને ડ્રગ સેન્સિટિવિટી ટેસ્ટ)',
    'Heart Diagnostic Test (હૃદય સંબંધિત નિદાન પરીક્ષણ)',
    'Special Test for Gene A1A2 By PCR (જિન A1A2 માટે પીસીઆર ટેસ્ટ)',
    'Milk (દૂધ તપાસ)',
    'Canine Rapid Diagnostic Test (કેનાઇન ઝડપી નિદાન ટેસ્ટ)',
    'Histopathology (હિસ્ટોપેથોલોજી – કોષસંરચનાત્મક પરીક્ષણ)',
    'Water Analysis (TDS + pH + Coliform count) (પાણી તપાસ: ટી.ડી.એસ + પીએચ + કોલિફોર્મ ગણતરી)',
    'Post mortem examination (મૃત્યુ પછીનું પરીક્ષણ)',
    'Molecular Diagnostics/PCR for diagnosis (અણુઆધારિત નિદાન / પી.સી.આર)',
    'Feline Rapid Diagnostic Test (ફિલાઇન ઝડપી નિદાન પરીક્ષણ)',
    'PCR based Diagnosis (પીસીઆર આધારિત નિદાન)',
    'Breed Purity Test (જાતિ શુદ્ધતા પરીક્ષણ)',
    'Gender Determination (લિંગ નિર્ધારણ)',
    'Air Sampling (Bacterial + Fungal) (4–6 Plates) (હવા તપાસ: બેક્ટેરિયલ + ફંગલ)',
    'Rabies Antibodies by RFFIT (International Pet Travel) (રેબીસ એન્ટીબોડી આરએફએફઆઈટી – આંતરરાષ્ટ્રીય પાળતુ પ્રાણી મુસાફરી)',
    'Rabies Antibodies by RFFIT (Sero-Monitoring) (રેબીસ એન્ટીબોડી આરએફએફઆઈટી – સેરો મોનીટરીંગ)',
    'Mineral / Metal Analysis (ખનિજ / ધાતુ વિશ્લેષણ)',
    'Brucellosi (બ્રુસેલોસિસ)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCattle();
    if (widget.existingRecord != null) {
      final r = widget.existingRecord!;
      _sampleDate = r.eventDate;
      _resultDate = r.nextDueDate;
      _selectedTest = r.testName;
      _selectedResult = r.status;
      _remarkCtrl.text = r.remark ?? '';
    }
  }

  Future<void> _fetchCattle() async {
    try {
      final api = sl<ApiService>();
      final cowResults = await api.getCows();
      final bullResults = await api.getBulls();
      
      final cows = cowResults.map((e) => CattleModel.fromJson(e)).where((c) => c.isActive).toList();
      final bulls = bullResults.map((e) => CattleModel.fromJson(e)).where((c) => c.isActive).toList();

      setState(() {
        _cows = cows;
        _bulls = bulls;
        _isLoading = false;

        if (widget.existingRecord != null) {
          try {
            final allCattle = [..._cows, ..._bulls];
            _selectedAnimal = allCattle.firstWhere(
              (c) => c.name == widget.existingRecord!.cowName,
            );
          } catch (_) {}
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Cattle> get _displayAnimals {
    return _selectedAnimalType == 'Cow' ? _cows : _bulls;
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.existingRecord != null;

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
          isEdit ? 'Edit Lab Test Information' : 'Add Lab Test Information',
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
              // Cow / Bull Tabs
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [_buildTabButton('Cow'), _buildTabButton('Bull')],
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('Name'),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _buildDropdown<Cattle>(
                      hint: 'Select ${_selectedAnimalType.toLowerCase()} name',
                      value: _selectedAnimal,
                      items: _displayAnimals,
                      itemLabelBuilder: (c) => '${c.name} (${c.tagNumber})',
                      onChanged: (val) => setState(() => _selectedAnimal = val),
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

              _buildLabel('Labtest'),
              _buildDropdown<String>(
                hint: 'Select the laboratory test',
                value: _selectedTest,
                items: _labTests,
                itemLabelBuilder: (val) => val,
                onChanged: (val) => setState(() => _selectedTest = val),
              ),
              const SizedBox(height: 16),

              _buildLabel('Result'),
              _buildDropdown<String>(
                hint: 'Select the test result',
                value: _selectedResult,
                items: _results,
                itemLabelBuilder: (val) => val,
                onChanged: (val) => setState(() => _selectedResult = val),
              ),
              const SizedBox(height: 16),

              _buildLabel('Result Attachment'),
              _buildAttachmentPicker(),
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
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99AA5A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
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
    bool isSelected = _selectedAnimalType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedAnimalType = type;
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
    T? value,
    required List<T> items,
    required String Function(T) itemLabelBuilder,
    required Function(T?) onChanged,
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
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    itemLabelBuilder(e),
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

  Widget _buildDatePickerField({
    DateTime? value,
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
                value != null ? DateFormat('dd MMM, yyyy').format(value) : hint,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: value != null ? Colors.black : Colors.grey,
                ),
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

  Widget _buildAttachmentPicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 32),
          const SizedBox(height: 8),
          Text(
            'Upload Attachment',
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF99AA5A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Select Attachment',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool isSampleDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isSampleDate ? _sampleDate : _resultDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    if (picked != null) {
      setState(() {
        if (isSampleDate) {
          _sampleDate = picked;
        } else {
          _resultDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_selectedAnimal == null ||
        _selectedTest == null ||
        _selectedResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final record = HealthEvent(
      id: widget.existingRecord?.id ?? const Uuid().v4(),
      cowName: _selectedAnimal!.name,
      cowTagNumber: _selectedAnimal!.tagNumber,
      cowSerialNumber: _selectedAnimal!.serialNumber ?? '',
      eventType: 'Lab Testing',
      testName: _selectedTest,
      eventDate: _sampleDate!,
      nextDueDate: _resultDate, // Using nextDueDate as result date here
      status: _selectedResult!,
      remark: _remarkCtrl.text,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, record);
  }
}
