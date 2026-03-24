import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:cattle_management_system/core/services/api_service.dart';
import 'package:cattle_management_system/core/di/injection_container.dart';
import 'package:cattle_management_system/features/cattle/domain/entities/cattle.dart';

class ParityModel {
  final String id;
  final int parityNumber;
  final bool isAlive;
  final bool isHeifer;
  final bool isAI;
  final int totalDays;
  final double totalMilk;
  final DateTime? pregnantDate;
  final DateTime? deliveryDate;
  final String bullName;
  final String tagNo;
  final String note;

  ParityModel({
    required this.id,
    required this.parityNumber,
    required this.isAlive,
    required this.isHeifer,
    required this.isAI,
    required this.totalDays,
    required this.totalMilk,
    this.pregnantDate,
    this.deliveryDate,
    required this.bullName,
    required this.tagNo,
    required this.note,
  });

  factory ParityModel.fromJson(Map<String, dynamic> json) {
    final animal = json['animal'] as Map<String, dynamic>?;
    final bull = json['bull'] as Map<String, dynamic>?;
    final calf = json['calf'] as Map<String, dynamic>?;
    final totalMilk =
        (json['totalMilk'] as num?)?.toDouble() ??
        (json['milk'] as num?)?.toDouble() ??
        (json['milkYield'] as num?)?.toDouble() ??
        0;
    final pregnantDateRaw =
        json['pregnantDate'] ?? json['pregnancyDate'] ?? json['conceiveDate'];
    final deliveryDateRaw = json['deliveryDate'] ?? json['calvingDate'];
    final parsedPregnantDate = pregnantDateRaw != null
        ? DateTime.tryParse(pregnantDateRaw.toString())
        : null;
    final parsedDeliveryDate = deliveryDateRaw != null
        ? DateTime.tryParse(deliveryDateRaw.toString())
        : null;

    return ParityModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      parityNumber:
          (json['parityNumber'] as num?)?.toInt() ??
          (json['parityNo'] as num?)?.toInt() ??
          (json['parity'] as num?)?.toInt() ??
          0,
      isAlive: json['isAlive'] ?? calf?['isAlive'] ?? true,
      isHeifer: json['isHeifer'] ?? animal?['isHeifer'] ?? false,
      isAI:
          json['isAI'] ??
          json['pregnancyType']?.toString().toUpperCase() == 'AI',
      totalDays:
          (json['totalDays'] as num?)?.toInt() ??
          (json['days'] as num?)?.toInt() ??
          ((parsedPregnantDate != null && parsedDeliveryDate != null)
              ? parsedDeliveryDate.difference(parsedPregnantDate).inDays
              : 0),
      totalMilk: totalMilk,
      pregnantDate: parsedPregnantDate,
      deliveryDate: parsedDeliveryDate,
      bullName:
          json['bullName']?.toString() ??
          bull?['name']?.toString() ??
          '-',
      tagNo:
          json['tagNo']?.toString() ??
          json['tagNumber']?.toString() ??
          animal?['tagNumber']?.toString() ??
          calf?['tagNumber']?.toString() ??
          '-',
      note: json['remarks']?.toString() ?? json['note']?.toString() ?? '-',
    );
  }
}

class CowParityScreen extends StatefulWidget {
  final Cattle cattle;

  const CowParityScreen({super.key, required this.cattle});

  @override
  State<CowParityScreen> createState() => _CowParityScreenState();
}

class _CowParityScreenState extends State<CowParityScreen> {
  final ApiService _apiService = sl<ApiService>();
  List<ParityModel> parities = [];
  bool _isLoading = true;
  String? _error;

  List<ParityModel> get _displayParities {
    if (parities.isNotEmpty) return parities;

    final fallbackCount = widget.cattle.parity ?? 0;
    if (fallbackCount <= 0) return const <ParityModel>[];

    return List.generate(fallbackCount, (index) {
      final parityNumber = index + 1;
      return ParityModel(
        id: 'fallback-parity-$parityNumber',
        parityNumber: parityNumber,
        isAlive: true,
        isHeifer: false,
        isAI: false,
        totalDays: 0,
        totalMilk: 0,
        pregnantDate: null,
        deliveryDate: parityNumber == fallbackCount
            ? widget.cattle.lastDeliveryDate
            : null,
        bullName: '-',
        tagNo: widget.cattle.tagNumber,
        note: 'Detailed breeding parity record not available.',
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchParities();
  }

  Future<void> _fetchParities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getBreedingParityReport(animalId: widget.cattle.id);
      setState(() {
        parities = data.map((e) => ParityModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load parity records';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayParities = _displayParities;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        title: Text(
          'Parity Details',
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  children: [
                    Text(
                      'Total ${displayParities.length} Parity',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (displayParities.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text("No parity records found."),
                        ),
                      )
                    else
                      ...displayParities
                          .map((parity) => _buildParityCard(parity))
                          .toList(),
                  ],
                ),
    );
  }

  Widget _buildParityCard(ParityModel parity) {
    final dateFormat = DateFormat('d MMM, yyyy');

    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
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
                  const SizedBox(height: 8),
                  if (parity.isHeifer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC5CAE9)),
                      ),
                      child: Text(
                        'Heifer',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF3F51B5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.cattle.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Parity: ${parity.parityNumber}',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (parity.isAlive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFA5D6A7)),
                            ),
                            child: Text(
                              'Alive',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (parity.isAI)
                          Text(
                            'AI',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
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
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Total Days:',
            '${parity.totalDays}',
            Icons.water_drop_outlined,
            'Total Milk:',
            '${parity.totalMilk.toInt()}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.child_care,
            'Pregnant:',
            parity.pregnantDate != null ? dateFormat.format(parity.pregnantDate!) : '-',
            Icons.event,
            'Delivery:',
            parity.deliveryDate != null ? dateFormat.format(parity.deliveryDate!) : '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.catching_pokemon,
            'Bull Name:',
            parity.bullName,
            Icons.confirmation_number_outlined,
            'Tag No :',
            parity.tagNo,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.note_alt_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Note:', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                    Text(
                      parity.note,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon1,
    String label1,
    String val1,
    IconData icon2,
    String label2,
    String val2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon1, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label1, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  Text(val1, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Icon(icon2, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label2, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  Text(val2, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
