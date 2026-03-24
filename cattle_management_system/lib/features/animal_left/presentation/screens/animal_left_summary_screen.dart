import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimalLeftSummaryScreen extends StatefulWidget {
  const AnimalLeftSummaryScreen({super.key});

  @override
  State<AnimalLeftSummaryScreen> createState() =>
      _AnimalLeftSummaryScreenState();
}

class _AnimalLeftSummaryScreenState extends State<AnimalLeftSummaryScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Sample Data matching the request
  final List<Map<String, dynamic>> _sampleData = [
    {
      'id': '1',
      'name': '123',
      'type': 'Bull',
      'tag': '106',
      'serial': '0006',
      'status': 'Donation',
      'imageUrl': 'assets/icons/mother_cow.png',
    },
    {
      'id': '2',
      'name': 'Ganga',
      'type': 'Cow',
      'tag': '101',
      'serial': '0001',
      'status': 'Sell',
      'imageUrl': 'assets/icons/mother_cow.png',
    },
  ];

  late List<Map<String, dynamic>> _records;

  @override
  void initState() {
    super.initState();
    _records = List.from(_sampleData);
  }

  int get _totalCount => _records.length;
  int get _cowCount => _records.where((r) => r['type'] == 'Cow').length;
  int get _bullCount => _records.where((r) => r['type'] == 'Bull').length;

  void _deleteRecord(int index) {
    setState(() {
      _records.removeAt(index);
    });
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Entry',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this entry?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecord(index);
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
                'Animal Left From Gaushala',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
        children: [
          // Summary Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildSummaryItem('Total', _totalCount),
                _buildVerticalDivider(),
                _buildSummaryItem('Cow', _cowCount),
                _buildVerticalDivider(),
                _buildSummaryItem('Bull', _bullCount),
              ],
            ),
          ),

          // Records List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getFilteredRecords().length,
              itemBuilder: (context, index) {
                final record = _getFilteredRecords()[index];
                return _buildAnimalCard(record, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count) {
    return Expanded(
      child: Text(
        '$label: $count',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 20, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildAnimalCard(Map<String, dynamic> record, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animal Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F2EE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/icons/mother_cow.png',
                    color: const Color(0xFF8B5E3C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                record['name'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                record['type'],
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF99AA5A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              record['status'],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTagBadge(record['tag']),
                          const SizedBox(width: 12),
                          _buildSerialInfo(record['serial']),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () => _showDeleteConfirmation(index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Color(0xFFEF5350),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark, color: Color(0xFF8B5E3C), size: 10),
          const SizedBox(width: 4),
          Text(
            'Tag No. : $value',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF8B5E3C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSerialInfo(String value) {
    return Text(
      'No. : $value',
      style: GoogleFonts.inter(
        fontSize: 11,
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredRecords() {
    if (_searchQuery.isEmpty) return _records;
    return _records.where((record) {
      final name = record['name'].toString().toLowerCase();
      final tag = record['tag'].toString().toLowerCase();
      return name.contains(_searchQuery) || tag.contains(_searchQuery);
    }).toList();
  }
}
