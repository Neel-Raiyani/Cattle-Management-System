import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/api_service.dart';

class GenericAlertScreen extends StatefulWidget {
  final String title;
  final String alertType;
  final IconData icon;
  final Color iconColor;

  const GenericAlertScreen({
    super.key,
    required this.title,
    required this.alertType,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<GenericAlertScreen> createState() => _GenericAlertScreenState();
}

class _GenericAlertScreenState extends State<GenericAlertScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQ = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await sl<ApiService>().getAlertRecords(
        type: widget.alertType,
      );
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

  List<Map<String, dynamic>> get _filteredItems {
    if (_searchQ.trim().isEmpty) return _items;
    final query = _searchQ.trim().toLowerCase();
    return _items.where((item) {
      final animal = _map(item['animal']) ?? const <String, dynamic>{};
      final values = [
        item['name'],
        item['animalName'],
        item['tagNumber'],
        item['animalNumber'],
        animal['name'],
        animal['tagNumber'],
        animal['animalNumber'],
      ];
      return values.any(
        (value) => value != null &&
            value.toString().toLowerCase().contains(query),
      );
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
          widget.title,
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
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
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
                : _filteredItems.isEmpty
                    ? _buildNoData()
                    : RefreshIndicator(
                        onRefresh: _loadItems,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: _filteredItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => _GenericAlertCard(
                            title: widget.title,
                            alertType: widget.alertType,
                            icon: widget.icon,
                            iconColor: widget.iconColor,
                            item: _filteredItems[index],
                          ),
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
    );
  }
}

class _GenericAlertCard extends StatelessWidget {
  final String title;
  final String alertType;
  final IconData icon;
  final Color iconColor;
  final Map<String, dynamic> item;

  const _GenericAlertCard({
    required this.title,
    required this.alertType,
    required this.icon,
    required this.iconColor,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final animal = _map(item['animal']) ?? const <String, dynamic>{};
    final imageUrl = (animal['imageUrl'] ??
            item['imageUrl'] ??
            animal['viewUrl'] ??
            animal['photoUrl'] ??
            '')
        .toString();
    final name = (animal['name'] ??
            item['name'] ??
            item['animalName'] ??
            item['animalId'] ??
            'Unknown')
        .toString();
    final tagNumber =
        (animal['tagNumber'] ?? item['tagNumber'] ?? item['tagNo'] ?? '-')
            .toString();
    final animalNumber = (animal['animalNumber'] ??
            item['animalNumber'] ??
            item['serialNumber'] ??
            '-')
        .toString();

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
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _tagBadge('Tag No.: $tagNumber'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No. : $animalNumber',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoColumn(_primaryLabel(), _primaryValue()),
              _infoColumn(_secondaryLabel(), _secondaryValue(),
                  align: CrossAxisAlignment.end),
            ],
          ),
        ],
      ),
    );
  }

  String _primaryLabel() {
    switch (alertType) {
      case 'heat':
        return 'Heat Date';
      case 'pregnancy-check':
        return 'Conceive Date';
      case 'insemination':
        return 'Ready Since';
      case 'delivery':
        return 'Delivery Date';
      case 'deworming':
        return 'Dose Date';
      case 'adult':
        return 'Adult Date';
      case 'lab-test':
        return 'Sample Date';
      case 'vaccination':
        return 'Due Date';
      default:
        return 'Date';
    }
  }

  String _secondaryLabel() {
    switch (alertType) {
      case 'heat':
      case 'pregnancy-check':
      case 'insemination':
      case 'delivery':
      case 'deworming':
      case 'adult':
      case 'vaccination':
        return 'Status';
      case 'lab-test':
        return 'Result';
      default:
        return 'Details';
    }
  }

  String _primaryValue() {
    final rawDate = item['alertDate'] ??
        item['date'] ??
        item['dueDate'] ??
        item['nextDoseDate'] ??
        item['deliveryDate'] ??
        item['sampleDate'] ??
        item['conceiveDate'] ??
        item['dateOfAdult'];
    final parsed = DateTime.tryParse((rawDate ?? '').toString());
    if (parsed != null) {
      return DateFormat('dd MMM, yyyy').format(parsed);
    }
    return (rawDate ?? '-').toString();
  }

  String _secondaryValue() {
    switch (alertType) {
      case 'lab-test':
        return (item['result'] ??
                item['status'] ??
                item['labTestName'] ??
                'Pending')
            .toString();
      case 'vaccination':
        return (item['vaccineName'] ?? item['status'] ?? 'Due').toString();
      case 'deworming':
        return (item['doseType'] ??
                item['status'] ??
                item['remark'] ??
                'Due')
            .toString();
      case 'delivery':
        return (item['status'] ??
                item['calfStatus'] ??
                item['remark'] ??
                'Expected')
            .toString();
      case 'pregnancy-check':
        return (item['status'] ?? 'Pending').toString();
      case 'insemination':
        return (item['status'] ?? 'Eligible').toString();
      case 'heat':
        return (item['status'] ?? 'Due').toString();
      case 'adult':
        return (item['status'] ?? 'Eligible').toString();
      default:
        return (item['status'] ?? '-').toString();
    }
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

  Widget _infoColumn(
    String label,
    String value, {
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
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
