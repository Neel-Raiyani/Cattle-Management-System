import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/health_event.dart';
import 'medical_details_screen.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localized_assets.dart';
import 'package:cattle_management_system/core/localization/localized_ui.dart';

class SickAnimalScreen extends StatefulWidget {
  const SickAnimalScreen({super.key});

  @override
  State<SickAnimalScreen> createState() => _SickAnimalScreenState();
}

class _SickAnimalScreenState extends State<SickAnimalScreen> {
  List<HealthEvent> _records = [];
  bool _isLoading = true;
  String? _error;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSickAnimals();
  }

  Future<void> _fetchSickAnimals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<dynamic> data = await sl<ApiService>().getSickAnimals();
      if (mounted) {
        setState(() {
          _records = data
              .map((json) => HealthEvent.fromJson(Map<String, dynamic>.from(json), 'Medical'))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  List<HealthEvent> _getFilteredRecords() {
    var filtered = _records.where((record) {
      if (_searchQuery.isEmpty) return true;
      return record.cowName.toLowerCase().contains(_searchQuery) ||
          record.cowTagNumber.toLowerCase().contains(_searchQuery);
    }).toList();
    
    filtered.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();

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
                'Sick Animal',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        context.noDataFoundAsset,
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
                        onPressed: _fetchSickAnimals,
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
                )
              : filteredRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            context.noDataFoundAsset,
                            width: 150,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.error, size: 50),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.ui.noDataFound,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF99AA5A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return _MedicalRecordCard(
                          record: record,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MedicalDetailsScreen(record: record),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

class _MedicalRecordCard extends StatelessWidget {
  final HealthEvent record;
  final VoidCallback onTap;

  const _MedicalRecordCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = Colors.red;
    final statusBg = const Color(0xFFFFEBEE);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
          children: [
            Row(
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
                    child: Image.asset(
                      'assets/icons/father_cow.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.pets, color: Colors.grey),
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
                          Flexible(
                            child: Text(
                              record.cowName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              record.medicalStatus ?? 'Sick',
                              style: GoogleFonts.inter(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F3D3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bookmark,
                                    color: Color(0xFFC49A2D),
                                    size: 10,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Tag No : ${record.cowTagNumber}',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFC49A2D),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'No. : ${record.cowSerialNumber}',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade400,
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
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _InfoItem(
              icon: Icons.sync,
              label: 'Visit Type:',
              value: record.visitType ?? 'General Check-up',
              iconColor: const Color(0xFF5C9DCE),
              iconBg: const Color(0xFFE3F2FD),
            ),
            const SizedBox(height: 12),
            _InfoItem(
              icon: Icons.coronavirus_outlined,
              label: 'Disease:',
              value: record.disease ?? '-',
              iconColor: Colors.grey,
              iconBg: const Color(0xFFF5F5F5),
            ),
            const SizedBox(height: 12),
            _InfoItem(
              icon: Icons.person_outline,
              label: 'Doctor Name:',
              value: record.doctorName ?? '-',
              iconColor: const Color(0xFF99AA5A),
              iconBg: const Color(0xFFF1F8E9),
            ),
            const SizedBox(height: 12),
            _InfoItem(
              icon: Icons.calendar_today_outlined,
              label: 'Visit Date:',
              value: DateFormat('dd MMM, yyyy').format(record.eventDate),
              iconColor: const Color(0xFF5C9DCE),
              iconBg: const Color(0xFFE3F2FD),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
