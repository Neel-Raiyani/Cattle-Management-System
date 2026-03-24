import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';

class VaccinationAlertScreen extends StatefulWidget {
  const VaccinationAlertScreen({super.key});

  @override
  State<VaccinationAlertScreen> createState() => _VaccinationAlertScreenState();
}

class _VaccinationAlertScreenState extends State<VaccinationAlertScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQ = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final records = await sl<ApiService>().getVaccinationHistory();
      if (!mounted) return;
      setState(() {
        _records = records.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _records = [];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchQ.isEmpty) return _records;
    return _records.where((item) {
      final animal = _map(item['animalId']) ?? _map(item['animal']) ?? const {};
      return (animal['name'] ?? '').toString().toLowerCase().contains(_searchQ.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
        ),
        title: Text(
          'Vaccination Alert',
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
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 22, color: Colors.grey.shade400),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQ = v),
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search here...',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/icons/no_data_found.png', width: 200),
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
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _VaccinationAlertCard(item: _filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _VaccinationAlertCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _VaccinationAlertCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final animal = _map(item['animalId']) ?? _map(item['animal']) ?? const {};
    final imageUrl = (animal['viewUrl'] ?? animal['photoUrl'] ?? animal['imageUrl'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackImage(),
                  )
                : _fallbackImage(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (animal['name'] ?? 'Unknown').toString(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vaccine Name : ${(item['vaccineName'] ?? (item['vaccineId'] is Map ? item['vaccineId']['name'] : 'Unknown')).toString()}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1DC),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFD4B96A)),
                      ),
                      child: Text(
                        'Tag No.: ${(animal['tagNumber'] ?? '-').toString()}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB8942C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No. : ${(animal['animalNumber'] ?? animal['serialNumber'] ?? '-').toString()}',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.colorize, color: Colors.blue, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade200,
      child: const Icon(Icons.pets, color: Colors.grey),
    );
  }
}

Map<String, dynamic>? _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}
