import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/app_feedback.dart';

class LabTestReportHubScreen extends StatelessWidget {
  const LabTestReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Lab Test Report',
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
            label: 'Animal Wise Lab Test Report',
            icon: Icons.pets,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnimalWiseLabTestReportScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _HubTile(
            label: 'Date Wise Lab Test Report',
            icon: Icons.calendar_month_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DateWiseLabTestReportScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _HubTile(
            label: 'Lab Test Wise Report',
            icon: Icons.science_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LabTestWiseReportScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimalWiseLabTestReportScreen extends StatefulWidget {
  const AnimalWiseLabTestReportScreen({super.key});

  @override
  State<AnimalWiseLabTestReportScreen> createState() =>
      _AnimalWiseLabTestReportScreenState();
}

class _AnimalWiseLabTestReportScreenState
    extends State<AnimalWiseLabTestReportScreen> {
  String _animalType = 'Cow';
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
    setState(() => _isLoadingAnimals = true);
    try {
      final data = _animalType == 'Cow'
          ? await sl<ApiService>().getCows(limit: 500)
          : await sl<ApiService>().getBulls(limit: 500);
      if (!mounted) return;
      setState(() {
        _animals = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoadingAnimals = false;
      });
      if (_selectedAnimalId != null) {
        await _loadRecords();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingAnimals = false);
      AppFeedback.showError(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _loadRecords() async {
    if (_selectedAnimalId == null) return;
    setState(() => _isLoadingRecords = true);
    try {
      final data = await sl<ApiService>().getLabReport(animalId: _selectedAnimalId);
      if (!mounted) return;
      setState(() {
        _records = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoadingRecords = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRecords = false);
      AppFeedback.showError(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedAnimal = _animals.cast<Map<String, dynamic>?>().firstWhere(
          (animal) =>
              animal?['id']?.toString() == _selectedAnimalId ||
              animal?['_id']?.toString() == _selectedAnimalId,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _circleBack(context),
        title: Text(
          'Animal Wise Lab Test Report',
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
                    items: const ['Cow', 'Bull'],
                    labelBuilder: (value) => value,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        _animalType = value;
                        _selectedAnimalId = null;
                        _records = [];
                      });
                      await _loadAnimals();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SimpleDropdown<String>(
                    value: _selectedAnimalId,
                    hint: _isLoadingAnimals ? 'Loading...' : 'Select animal',
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
                            _LabReportRecordCard(record: _records[index]),
                      ),
          ),
        ],
      ),
    );
  }
}

class DateWiseLabTestReportScreen extends StatefulWidget {
  const DateWiseLabTestReportScreen({super.key});

  @override
  State<DateWiseLabTestReportScreen> createState() =>
      _DateWiseLabTestReportScreenState();
}

class _DateWiseLabTestReportScreenState extends State<DateWiseLabTestReportScreen> {
  DateTime _fromDate = DateTime.now();
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
      final data = await sl<ApiService>().getLabReport(
        from: _fromDate,
        to: _toDate,
      );
      if (!mounted) return;
      setState(() {
        _records = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppFeedback.showError(context, e.toString().replaceFirst('Exception: ', ''));
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
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate;
        }
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
          'Date Wise Lab Test Report',
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
                            _LabReportRecordCard(record: _records[index]),
                      ),
          ),
        ],
      ),
    );
  }
}

class LabTestWiseReportScreen extends StatefulWidget {
  const LabTestWiseReportScreen({super.key});

  @override
  State<LabTestWiseReportScreen> createState() => _LabTestWiseReportScreenState();
}

class _LabTestWiseReportScreenState extends State<LabTestWiseReportScreen> {
  List<Map<String, dynamic>> _labTests = [];
  String? _selectedLabTestId;
  List<Map<String, dynamic>> _records = [];
  bool _isLoadingTests = true;
  bool _isLoadingRecords = false;

  @override
  void initState() {
    super.initState();
    _loadLabTests();
  }

  Future<void> _loadLabTests() async {
    setState(() => _isLoadingTests = true);
    try {
      final data = await sl<ApiService>().getLabTestTypes();
      if (!mounted) return;
      setState(() {
        _labTests = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoadingTests = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingTests = false);
      AppFeedback.showError(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _loadRecords() async {
    if (_selectedLabTestId == null || _selectedLabTestId!.isEmpty) return;
    setState(() => _isLoadingRecords = true);
    try {
      final data = await sl<ApiService>().getLabReport(
        labtestId: _selectedLabTestId,
      );
      if (!mounted) return;
      setState(() {
        _records = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoadingRecords = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRecords = false);
      AppFeedback.showError(context, e.toString().replaceFirst('Exception: ', ''));
    }
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
          'Lab Test Wise Report',
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
            child: _SimpleDropdown<String>(
              value: _selectedLabTestId,
              hint: _isLoadingTests ? 'Loading lab tests...' : 'Select lab test',
              items: _labTests
                  .map((test) => (test['id'] ?? test['_id'] ?? '').toString())
                  .where((id) => id.isNotEmpty)
                  .toList(),
              labelBuilder: (id) {
                final item = _labTests.firstWhere(
                  (test) => (test['id'] ?? test['_id']).toString() == id,
                  orElse: () => <String, dynamic>{},
                );
                return item['name']?.toString() ?? 'Unknown';
              },
              onChanged: (value) async {
                setState(() => _selectedLabTestId = value);
                await _loadRecords();
              },
            ),
          ),
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
                            _LabReportRecordCard(record: _records[index]),
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
        leading: Icon(icon, color: const Color(0xFF99AA5A)),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/icons/mother_cow.png',
                        fit: BoxFit.contain,
                      ),
                    )
                  : Image.asset(
                      'assets/icons/mother_cow.png',
                      fit: BoxFit.contain,
                    ),
            ),
          ),
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

class _LabReportRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const _LabReportRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final animal = record['animal'] is Map
        ? Map<String, dynamic>.from(record['animal'] as Map)
        : <String, dynamic>{};
    final imageUrl = (animal['imageUrl'] ??
            animal['viewUrl'] ??
            animal['photoUrl'] ??
            animal['photo'])
        ?.toString();
    final sampleDate = _parseDate(record['sampleDate'] ?? record['date']);
    final resultDate = _parseDate(record['resultDate']);
    final result = (record['result'] ?? record['status'] ?? '-').toString();
    final testName =
        (record['labTestName'] ?? record['testName'] ?? '-').toString();
    final remark =
        (record['remark'] ?? record['remarks'] ?? '').toString().trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/icons/mother_cow.png',
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.asset(
                          'assets/icons/mother_cow.png',
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal['name']?.toString() ?? '-',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tag No : ${animal['tagNumber'] ?? '-'}',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.brown),
                    ),
                    Text(
                      'No. : ${animal['animalNumber'] ?? animal['serialNumber'] ?? '-'}',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF99AA5A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            testName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _dateInfo('Sample', sampleDate)),
              Expanded(child: _dateInfo('Result', resultDate)),
            ],
          ),
          if (remark.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Remark',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
            ),
            Text(
              remark,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateInfo(String label, DateTime? date) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
            ),
            Text(
              date == null ? '-' : DateFormat('dd MMM, yyyy').format(date),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
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
          color: const Color(0xFFF5F6F7),
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
      child: Text(
        'No Data Found',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
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

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
