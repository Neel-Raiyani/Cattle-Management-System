import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';

class GenericAlertScreen extends StatefulWidget {
  final String title;
  const GenericAlertScreen({super.key, required this.title});

  @override
  State<GenericAlertScreen> createState() => _GenericAlertScreenState();
}

class _GenericAlertScreenState extends State<GenericAlertScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final title = widget.title.toLowerCase();
      List<Map<String, dynamic>> items;

      if (title.contains('insemination')) {
        final journeys = await sl<ApiService>().getActiveJourneys();
        items = journeys
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .where((item) => (item['conceiveDate'] ?? item['pregnancyType']) != null)
            .toList();
      } else if (title.contains('delivery')) {
        final deliveries = await sl<ApiService>().getDeliveryReport();
        items = deliveries
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else if (title.contains('deworming')) {
        final deworming = await sl<ApiService>().getDewormingRecords();
        items = deworming
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else if (title.contains('lab')) {
        final labRecords = await sl<ApiService>().getLabRecords();
        items = labRecords
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        items = [];
      }

      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _isLoading = false;
      });
    }
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
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/no_data_found.png',
                        width: 200,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.notifications_off_outlined,
                          size: 100,
                          color: Colors.grey,
                        ),
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
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _GenericAlertCard(
                    title: widget.title,
                    item: _items[index],
                  ),
                ),
    );
  }
}

class _GenericAlertCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> item;

  const _GenericAlertCard({required this.title, required this.item});

  @override
  Widget build(BuildContext context) {
    final animal = _map(item['animal']) ?? _map(item['animalId']) ?? const {};
    final imageUrl = (animal['viewUrl'] ?? animal['photoUrl'] ?? animal['imageUrl'] ?? '').toString();
    final primaryValue = _primaryValue();
    final secondaryValue = _secondaryValue();

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
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackImage(),
                      )
                    : _fallbackImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (animal['name'] ?? item['animalName'] ?? 'Unknown').toString(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _tagBadge('Tag No.: ${(animal['tagNumber'] ?? '-').toString()}'),
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
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoColumn(_primaryLabel(), primaryValue),
              _infoColumn(_secondaryLabel(), secondaryValue, align: CrossAxisAlignment.end),
            ],
          ),
        ],
      ),
    );
  }

  String _primaryLabel() {
    final lower = title.toLowerCase();
    if (lower.contains('delivery')) return 'Delivery';
    if (lower.contains('lab')) return 'Sample Date';
    if (lower.contains('deworming')) return 'Dose Date';
    return 'Date';
  }

  String _secondaryLabel() {
    final lower = title.toLowerCase();
    if (lower.contains('lab')) return 'Result';
    if (lower.contains('deworming')) return 'Dose Type';
    if (lower.contains('delivery')) return 'Calf';
    return 'Type';
  }

  String _primaryValue() {
    final rawDate = item['deliveryDate'] ?? item['sampleDate'] ?? item['doseDate'] ?? item['conceiveDate'];
    final date = DateTime.tryParse((rawDate ?? '').toString());
    if (date == null) return '-';
    return DateFormat('dd MMM, yyyy').format(date);
  }

  String _secondaryValue() {
    final lower = title.toLowerCase();
    if (lower.contains('lab')) return (item['result'] ?? '-').toString();
    if (lower.contains('deworming')) return (item['doseType'] ?? '-').toString();
    if (lower.contains('delivery')) {
      return '${item['calfStatus'] ?? '-'} / ${item['calfGender'] ?? '-'}';
    }
    return (item['pregnancyType'] ?? item['breedingType'] ?? '-').toString();
  }

  Widget _fallbackImage() {
    return Container(
      width: 52,
      height: 52,
      color: Colors.grey.shade200,
      child: const Icon(Icons.pets, color: Colors.grey),
    );
  }

  Widget _tagBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1DC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD4B96A)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFB8942C),
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value, {CrossAxisAlignment align = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

Map<String, dynamic>? _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}
