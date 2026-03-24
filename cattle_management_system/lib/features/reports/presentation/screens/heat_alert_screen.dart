import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';

class HeatAlertScreen extends StatefulWidget {
  const HeatAlertScreen({super.key});

  @override
  State<HeatAlertScreen> createState() => _HeatAlertScreenState();
}

class _HeatAlertScreenState extends State<HeatAlertScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQ = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _animals = [];

  @override
  void initState() {
    super.initState();
    _loadHeatAlerts();
  }

  Future<void> _loadHeatAlerts() async {
    setState(() => _isLoading = true);
    try {
      final data = await sl<ApiService>().getHeatEligibleAnimals();
      if (mounted) {
        setState(() {
          _animals = data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _animals = []);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredAnimals {
    if (_searchQ.isEmpty) return _animals;
    return _animals
        .where((animal) => (animal['name'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_searchQ.toLowerCase()))
        .toList();
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
          'Heat Alert',
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
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
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
                : _filteredAnimals.isEmpty
                    ? _buildNoData()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: _filteredAnimals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _HeatAlertCard(
                          animal: _filteredAnimals[i],
                        ),
                      ),
          ),
        ],
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

class _HeatAlertCard extends StatelessWidget {
  final Map<String, dynamic> animal;

  const _HeatAlertCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final heatDate = animal['lastHeatDate'] != null
        ? DateTime.tryParse(animal['lastHeatDate'].toString())
        : null;
    final days = heatDate == null ? '-' : DateTime.now().difference(heatDate).inDays.toString();
    final imageUrl = (animal['viewUrl'] ?? animal['photoUrl'] ?? '').toString();
    final dateText = heatDate == null ? '-' : DateFormat('dd MMM, yyyy').format(heatDate);

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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
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
                  color: Colors.pink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Colors.pink, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoCol(label: 'Heat Date', value: dateText),
              _InfoCol(label: 'Days', value: days, isCenter: true),
              const _InfoCol(label: 'Status', value: 'Eligible', isRight: true),
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
