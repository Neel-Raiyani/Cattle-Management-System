import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';

// 1. GLOBAL HELPER: Defined outside classes so both State and Card can access it.
Map<String, dynamic>? _readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

class PregnancyCheckingAlertScreen extends StatefulWidget {
  const PregnancyCheckingAlertScreen({super.key});

  @override
  State<PregnancyCheckingAlertScreen> createState() =>
      _PregnancyCheckingAlertScreenState();
}

class _PregnancyCheckingAlertScreenState
    extends State<PregnancyCheckingAlertScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQ = '';

  // 2. DATA STREAM: Replacing initState/setState logic with a Stream
  Stream<List<Map<String, dynamic>>> _getFilteredJourneysStream() async* {
    try {
      final data = await sl<ApiService>().getActiveJourneys();
      final now = DateTime.now();

      final filtered = data.whereType<Map>().map((item) {
        return Map<String, dynamic>.from(item);
      }).where((journey) {
        final conceiveDateRaw = journey['conceiveDate'];
        final conceiveDate = conceiveDateRaw == null
            ? null
            : DateTime.tryParse(conceiveDateRaw.toString());
        if (conceiveDate == null) return false;

        final days = now.difference(conceiveDate).inDays;
        // Business logic: Alert if between 30 and 90 days
        return days >= 30 && days <= 90;
      }).toList();

      yield filtered;
    } catch (_) {
      yield [];
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
          'Pregnancy Checking Alert',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getFilteredJourneysStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildNoData();
                }

                // Client-side Search Filtering
                final results = snapshot.data!.where((journey) {
                  final animal = _readMap(journey['animal']) ?? _readMap(journey['animalId']);
                  final name = (animal?['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQ.toLowerCase());
                }).toList();

                if (results.isEmpty) return _buildNoData();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _PregnancyCheckCard(
                    journey: results[i],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 200,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.search_off, size: 100, color: Colors.grey),
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

class _PregnancyCheckCard extends StatelessWidget {
  final Map<String, dynamic> journey;
  const _PregnancyCheckCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    final animal = _readMap(journey['animal']) ??
        _readMap(journey['animalId']) ??
        <String, dynamic>{};

    final conceiveDate = DateTime.tryParse((journey['conceiveDate'] ?? '').toString());
    final days = conceiveDate == null ? 0 : DateTime.now().difference(conceiveDate).inDays;
    final imageUrl = (animal['viewUrl'] ?? animal['photoUrl'] ?? '').toString();

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
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
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
                      (animal['name'] ?? 'Unknown').toString(),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _TagBadge(label: 'Tag No.: ${(animal['tagNumber'] ?? '-').toString()}'),
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
              const _StatusCircleIcon(),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoCol(
                label: 'Insemination Date',
                value: conceiveDate == null
                    ? '-'
                    : DateFormat('dd MMM, yyyy').format(conceiveDate),
              ),
              _InfoCol(label: 'Days', value: '$days', isCenter: true),
              const _InfoCol(label: 'Status', value: 'Pending', isRight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade200,
      child: const Icon(Icons.pets, color: Colors.grey),
    );
  }
}

// Sub-widgets for cleaner code
class _TagBadge extends StatelessWidget {
  final String label;
  const _TagBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1DC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD4B96A)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFB8942C),
        ),
      ),
    );
  }
}

class _StatusCircleIcon extends StatelessWidget {
  const _StatusCircleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.assignment_turned_in, color: Colors.green, size: 20),
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;
  final bool isCenter;
  final bool isRight;

  const _InfoCol({
    required this.label,
    required this.value,
    this.isCenter = false,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isCenter
          ? CrossAxisAlignment.center
          : (isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start),
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
