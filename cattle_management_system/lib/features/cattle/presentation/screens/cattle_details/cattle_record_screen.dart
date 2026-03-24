import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:cattle_management_system/core/services/api_service.dart';
import 'package:cattle_management_system/core/di/injection_container.dart';
import 'package:cattle_management_system/features/cattle/domain/entities/cattle.dart';

class CowRecordScreen extends StatefulWidget {
  final Cattle cattle;
  final String title;
  final IconData icon;

  const CowRecordScreen({
    super.key,
    required this.cattle,
    required this.title,
    required this.icon,
  });

  @override
  State<CowRecordScreen> createState() => _CowRecordScreenState();
}

class _CowRecordScreenState extends State<CowRecordScreen> {
  final ApiService _apiService = sl<ApiService>();
  List<dynamic> _records = [];
  bool _isLoading = true;
  String? _error;

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
      List<dynamic> records = [];
      if (widget.title == 'Medical Records') {
        records = await _apiService.getMedicalHistory(animalId: widget.cattle.id);
      } else if (widget.title == 'Vaccination') {
        records = await _apiService.getVaccinationHistory(animalId: widget.cattle.id);
      } else if (widget.title == 'Deworming') {
        records = await _apiService.getDewormingRecords(animalId: widget.cattle.id);
      } else if (widget.title == 'Lab Testing') {
        records = await _apiService.getLabRecords(animalId: widget.cattle.id);
      }
      
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load ${widget.title.toLowerCase()} records';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Total ${_records.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCowHeaderCard(),
                    const SizedBox(height: 16),
                    if (_records.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'No records found',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._records.map((record) => _buildRecordCard(record)),
                  ],
                ),
    );
  }

  Widget _buildCowHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: widget.cattle.imageUrl != null && widget.cattle.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.cattle.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/icons/mother_cow.png'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cattle.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9C4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sell, size: 12, color: Colors.brown),
                          const SizedBox(width: 4),
                          Text(
                            'Tag No : ${widget.cattle.tagNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.brown,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'No. : ${widget.cattle.serialNumber ?? "-"}',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(dynamic record) {
    if (widget.title == 'Medical Records') {
      return _buildMedicalCard(record);
    } else if (widget.title == 'Vaccination') {
      return _buildVaccinationCard(record);
    } else if (widget.title == 'Deworming') {
      return _buildDewormingCard(record);
    } else if (widget.title == 'Lab Testing') {
      return _buildLabCard(record);
    }
    return const SizedBox();
  }

  Widget _buildMedicalCard(dynamic record) {
    final status = record['medicalStatus'] ?? 'Unknown';
    final Color statusColor = status == 'HEALTHY' ? const Color(0xFFA4C639) : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.pets,
            'Medical Status:',
            status,
            valueColor: statusColor,
            iconBgColor: const Color(0xFFF1F8E9),
            iconColor: Colors.green.shade700,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.medical_services_outlined,
            'Visit Type:',
            record['visitType'] ?? '-',
            iconBgColor: const Color(0xFFE3F2FD),
            iconColor: Colors.blue.shade700,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.coronavirus_outlined,
            'Disease:',
            record['diseaseName'] ?? record['disease'] ?? '-',
            iconBgColor: const Color(0xFFFAFAFA),
            iconColor: Colors.black54,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.person,
            'Doctor Name:',
            record['vetName'] ?? record['doctorName'] ?? '-',
            iconBgColor: const Color(0xFFE8F5E9),
            iconColor: Colors.green.shade700,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Visit Date:',
            _formatDate(record['visitDate']),
            iconBgColor: const Color(0xFFE8EAF6),
            iconColor: Colors.indigo.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(dynamic record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.vaccines,
            'Vaccine:',
            record['vaccineName'] ?? '-',
            iconBgColor: const Color(0xFFE3F2FD),
            iconColor: Colors.blue.shade700,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.category_outlined,
            'Dose Type:',
            record['doseType'] ?? '-',
            iconBgColor: const Color(0xFFF1F8E9),
            iconColor: Colors.green.shade700,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Dose Date:',
            _formatDate(record['doseDate']),
            iconBgColor: const Color(0xFFE8EAF6),
            iconColor: Colors.indigo.shade700,
          ),
          if (record['remark'] != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.note_outlined,
              'Remark:',
              record['remark'],
              iconBgColor: const Color(0xFFFAFAFA),
              iconColor: Colors.black54,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDewormingCard(dynamic record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.bug_report_outlined,
            'Dose Type:',
            record['doseType'] ?? '-',
            iconBgColor: const Color(0xFFF1F8E9),
            iconColor: Colors.green.shade700,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.business_outlined,
            'Company:',
            record['companyName'] ?? '-',
            iconBgColor: const Color(0xFFE3F2FD),
            iconColor: Colors.blue.shade700,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Dose Date:',
            _formatDate(record['doseDate']),
            iconBgColor: const Color(0xFFE8EAF6),
            iconColor: Colors.indigo.shade700,
          ),
          if (record['nextDoseDate'] != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.event_repeat_outlined,
              'Next Dose:',
              _formatDate(record['nextDoseDate']),
              iconBgColor: const Color(0xFFFFF9C4),
              iconColor: Colors.brown,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabCard(dynamic record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.science_outlined,
            'Test Type:',
            record['testType'] ?? '-',
            iconBgColor: const Color(0xFFF3E5F5),
            iconColor: Colors.purple.shade700,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.analytics_outlined,
            'Result:',
            record['result'] ?? 'Pending',
            valueColor: record['result'] != null ? Colors.blue : Colors.orange,
            iconBgColor: const Color(0xFFFAFAFA),
            iconColor: Colors.black54,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Test Date:',
            _formatDate(record['testDate']),
            iconBgColor: const Color(0xFFE8EAF6),
            iconColor: Colors.indigo.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    final parsed = DateTime.tryParse(date.toString());
    if (parsed == null) return date.toString();
    return DateFormat('dd MMM, yyyy').format(parsed);
  }
}
