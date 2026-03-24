import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/health_event.dart';
import 'add_lab_test_screen.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';

class LabTestingInformationScreen extends StatefulWidget {
  const LabTestingInformationScreen({super.key});

  @override
  State<LabTestingInformationScreen> createState() =>
      _LabTestingInformationScreenState();
}

class _LabTestingInformationScreenState
    extends State<LabTestingInformationScreen> {
  List<HealthEvent> _records = [];
  bool _isLoading = true;
  String? _error;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await sl<ApiService>().getLabRecords();
      if (mounted) {
        setState(() {
          _records = data
              .map((json) => HealthEvent.fromJson(json, 'Lab Testing'))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Service not available';
          _isLoading = false;
        });
      }
    }
  }

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by name or tag...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(fontSize: 16),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              )
            : Text(
                'Lab Testing Information',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = '';
                    _searchController.clear();
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF99AA5A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => _pickDateRange(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${DateFormat('dd MMM, yyyy').format(_fromDate)}  to  ${DateFormat('dd MMM, yyyy').format(_toDate)}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Total ${_getFilteredRecords().length} Animals',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/no_data_found.png',
                      height: 150,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.error, size: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchRecords,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF99AA5A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_records.isEmpty || _getFilteredRecords().isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/no_data_found.png',
                      height: 150,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.error, size: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Records Found',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _getFilteredRecords().length,
                itemBuilder: (context, index) {
                  final record = _getFilteredRecords()[index];
                  return _LabTestingRecordCard(
                    record: record,
                    onUpdate: (updated) {
                      _fetchRecords();
                    },
                    onDelete: () => _showDeleteDialog(_records.indexOf(record)),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddLabTestScreen()),
            );
            if (result != null) {
              final today = DateTime.now();
              setState(() {
                _fromDate = DateTime(today.year, today.month, today.day);
                _toDate = DateTime(today.year, today.month, today.day);
              });
              _fetchRecords();
            }
          },
          backgroundColor: const Color(0xFF99AA5A),
          elevation: 4,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Lab Test',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  List<HealthEvent> _getFilteredRecords() {
    var filtered = _records.where((record) {
      final matchesSearch = _searchQuery.isEmpty ||
          record.cowName.toLowerCase().contains(_searchQuery) ||
          record.cowTagNumber.toLowerCase().contains(_searchQuery);

      final eventD = DateTime(record.eventDate.year, record.eventDate.month, record.eventDate.day);
      final fromD = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
      final toD = DateTime(_toDate.year, _toDate.month, _toDate.day);
      final matchesDate = !eventD.isBefore(fromD) && !eventD.isAfter(toD);

      return matchesSearch && matchesDate;
    }).toList();
    
    filtered.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return filtered;
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
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
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _fetchRecords();
    }
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Record',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this record?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _records.removeAt(index);
              });
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _LabTestingRecordCard extends StatelessWidget {
  final HealthEvent record;
  final Function(HealthEvent) onUpdate;
  final VoidCallback onDelete;

  const _LabTestingRecordCard({
    required this.record,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
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
                      Row(
                        children: [
                          Text(
                            record.cowName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '• Cow',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF6D8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE8D48A),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bookmark,
                                  color: Color(0xFFB38D1D),
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tag No. : ${record.cowTagNumber}',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFB38D1D),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'No. : ${record.cowSerialNumber}',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 10,
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.testName ?? '-',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        record.status,
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
                Row(
                  children: [
                    Expanded(
                      child: _buildDateInfo('Sample:', record.eventDate),
                    ),
                    Expanded(
                      child: _buildDateInfo(
                        'Result:',
                        record.nextDueDate ?? record.eventDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (record.remark != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remark:',
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              record.remark!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final updated = await Navigator.push<HealthEvent>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddLabTestScreen(existingRecord: record),
                        ),
                      );
                      if (updated != null) {
                        onUpdate(updated);
                      }
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF99AA5A),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: onDelete,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 11),
            ),
            Text(
              DateFormat('dd MMM, yyyy').format(date),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
