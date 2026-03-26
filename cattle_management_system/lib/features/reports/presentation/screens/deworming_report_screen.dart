import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/app_feedback.dart';

const _kOlive = Color(0xFF99AA5A);
const _kLightGrey = Color(0xFFF5F6F7);

class DewormingReportHubScreen extends StatelessWidget {
  const DewormingReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Deworming Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HubTile(
            label: 'Animal Wise Deworming Report',
            icon: Icons.pets,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnimalWiseDewormingReportScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _HubTile(
            label: 'Date Wise Deworming Dose Report',
            icon: Icons.calendar_month_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DateWiseDewormingDoseReportScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimalWiseDewormingReportScreen extends StatefulWidget {
  const AnimalWiseDewormingReportScreen({super.key});

  @override
  State<AnimalWiseDewormingReportScreen> createState() =>
      _AnimalWiseDewormingReportScreenState();
}

class _AnimalWiseDewormingReportScreenState
    extends State<AnimalWiseDewormingReportScreen> {
  String _animalType = 'COW';
  List<Map<String, dynamic>> _animals = [];
  String? _selectedAnimalId;
  List<Map<String, dynamic>> _records = [];
  bool _isLoadingAnimals = true;
  bool _isLoadingRecords = false;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    setState(() {
      _isLoadingAnimals = true;
      _selectedAnimalId = null;
      _records = [];
    });
    try {
      final data = await sl<ApiService>().getDewormingReportDropdown(
        type: _animalType,
      );
      if (!mounted) return;
      setState(() {
        _animals = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _isLoadingAnimals = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingAnimals = false);
      AppFeedback.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _loadRecords() async {
    if (_selectedAnimalId == null || _selectedAnimalId!.isEmpty) return;
    setState(() => _isLoadingRecords = true);
    try {
      final data = await sl<ApiService>().getDewormingReport(
        animalId: _selectedAnimalId,
      );
      if (!mounted) return;
      setState(() {
        _records = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _isLoadingRecords = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRecords = false);
      AppFeedback.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedAnimal = _animals.cast<Map<String, dynamic>?>().firstWhere(
          (animal) =>
              (animal?['id'] ?? animal?['_id'])?.toString() == _selectedAnimalId,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Animal Wise Deworming Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _SimpleDropdown<String>(
                    value: _animalType,
                    hint: 'Animal Type',
                    items: const ['COW', 'BULL'],
                    labelBuilder: (value) => value == 'COW' ? 'Cow' : 'Bull',
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _animalType = value);
                      await _loadAnimals();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SimpleDropdown<String>(
                    value: _selectedAnimalId,
                    hint: _isLoadingAnimals ? 'Loading...' : 'Select Animal',
                    items: _animals
                        .map((animal) =>
                            (animal['id'] ?? animal['_id'] ?? '').toString())
                        .where((id) => id.isNotEmpty)
                        .toList(),
                    labelBuilder: (id) {
                      final animal = _animals.firstWhere(
                        (item) => (item['id'] ?? item['_id']).toString() == id,
                        orElse: () => <String, dynamic>{},
                      );
                      final name = animal['name']?.toString() ?? 'Unknown';
                      final tag = animal['tagNumber']?.toString() ?? '';
                      return tag.isEmpty ? name : '$name ($tag)';
                    },
                    onChanged: (value) async {
                      setState(() => _selectedAnimalId = value);
                      await _loadRecords();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (selectedAnimal != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _AnimalHeaderCard(animal: selectedAnimal),
            ),
          if (selectedAnimal != null) const SizedBox(height: 12),
          Expanded(
            child: _isLoadingRecords
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? const _NoDataFound()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: _records.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) =>
                            _DewormingRecordCard(record: _records[index]),
                      ),
          ),
        ],
      ),
    );
  }
}

class DateWiseDewormingDoseReportScreen extends StatefulWidget {
  const DateWiseDewormingDoseReportScreen({super.key});

  @override
  State<DateWiseDewormingDoseReportScreen> createState() =>
      _DateWiseDewormingDoseReportScreenState();
}

class _DateWiseDewormingDoseReportScreenState
    extends State<DateWiseDewormingDoseReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 180));
  DateTime _toDate = DateTime.now();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final data = await sl<ApiService>().getDewormingReport(
        from: _fromDate,
        to: _toDate,
      );
      if (!mounted) return;
      setState(() {
        _records = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppFeedback.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      } else {
        _toDate = picked;
      }
    });
    await _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Date Wise Deworming Dose Report',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _DateField(
                    date: _fromDate,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('to'),
                ),
                Expanded(
                  child: _DateField(
                    date: _toDate,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? const _NoDataFound()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: _records.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) =>
                            _DewormingRecordCard(record: _records[index]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HubTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: _kOlive),
        title: Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

class _AnimalHeaderCard extends StatelessWidget {
  final Map<String, dynamic> animal;

  const _AnimalHeaderCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (animal['imageUrl'] ??
            animal['viewUrl'] ??
            animal['photoUrl'] ??
            animal['photo'])
        ?.toString();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _animalImage(imageUrl, width: 60, height: 60),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal['name']?.toString() ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tag No : ${animal['tagNumber'] ?? '-'}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.brown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'No. : ${animal['animalNumber'] ?? animal['serialNumber'] ?? '-'}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DewormingRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const _DewormingRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final animal = record['animal'] is Map
        ? Map<String, dynamic>.from(record['animal'] as Map)
        : <String, dynamic>{};
    final imageUrl = (animal['imageUrl'] ??
            record['imageUrl'] ??
            animal['viewUrl'] ??
            animal['photoUrl'] ??
            record['photo'])
        ?.toString();
    final animalType = (() {
      final gender = (animal['gender'] ?? record['gender'] ?? '').toString().toUpperCase();
      return gender.startsWith('M') ? 'Bull' : 'Cow';
    })();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _infoChip(_formatDate(record['doseDate'] ?? record['date'])),
              const Spacer(),
              Text(
                _formatDoseLabel(record),
                style: GoogleFonts.poppins(
                  color: _kOlive,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _animalImage(imageUrl, width: 70, height: 70),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${animal['name'] ?? record['name'] ?? '-'} - $animalType',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _tagChip(
                            'Tag No : ${(animal['tagNumber'] ?? record['tagno'] ?? record['tagNumber'] ?? '-')}',
                          ),
                          Text(
                            'No. : ${animal['animalNumber'] ?? record['animalNo'] ?? record['animalNumber'] ?? record['serialNumber'] ?? '-'}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _detailRow('Age', record['age']?.toString() ?? '-'),
          _detailRow(
            'Company Name',
            (record['companyName'] ?? record['medicineName'] ?? record['drugName'] ?? '-')
                .toString(),
          ),
          _detailRow(
            'Doctor Name',
            (record['doctorName'] ?? record['vetName'] ?? '-').toString(),
          ),
          _detailRow(
            'Last Dose Date',
            _formatDate(record['lastDoseDate']),
          ),
          _detailRow(
            'Next Dose Date',
            _formatDate(record['nextDoseDate']),
          ),
        ],
      ),
    );
  }
}

Widget _animalImage(String? path, {double width = 70, double height = 70}) {
  final fallback = Container(
    width: width,
    height: height,
    color: Colors.grey.shade200,
    child: const Icon(Icons.pets, color: Colors.grey),
  );
  if (path != null && path.startsWith('http')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Image.asset(
      'assets/icons/cow_and_calf.png',
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    ),
  );
}

Widget _infoChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: _kLightGrey,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.calendar_today, size: 16),
      ],
    ),
  );
}

Widget _tagChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7D6),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFD4B96A)),
    ),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: const Color(0xFFB18400),
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFECEFFD),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.info_outline, color: Color(0xFF6C63FF), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SimpleDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?> onChanged;

  const _SimpleDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _kLightGrey,
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
                    labelBuilder(item),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kLightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMM, yyyy').format(date),
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.calendar_month_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

class _NoDataFound extends StatelessWidget {
  const _NoDataFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _circleBack(BuildContext context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
      ),
    );

String _formatDate(dynamic value) {
  if (value == null) return '-';
  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) return '-';
  return DateFormat('dd MMM, yyyy').format(parsed.toLocal());
}

String _formatDoseLabel(Map<String, dynamic> record) {
  final doseType = (record['doseType'] ?? '-').toString().toUpperCase();
  final quantity = (record['quantity'] ?? '').toString().trim();
  final displayDose = doseType == 'INJECTION'
      ? 'Injection'
      : doseType == 'TABLET'
          ? 'Tablet'
          : doseType;
  if (quantity.isEmpty) return displayDose;
  return '$displayDose ($quantity)';
}
