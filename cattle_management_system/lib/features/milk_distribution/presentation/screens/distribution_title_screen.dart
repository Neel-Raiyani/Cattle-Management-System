import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../widgets/add_distribution_title_bottom_sheet.dart';

class DistributionTitleScreen extends StatefulWidget {
  const DistributionTitleScreen({super.key});

  @override
  State<DistributionTitleScreen> createState() => _DistributionTitleScreenState();
}

class _DistributionTitleScreenState extends State<DistributionTitleScreen> {
  static const String _hiddenDistributionTitleIdsKey =
      'hidden_distribution_title_ids';
  static const String _hiddenDistributionTitleNamesKey =
      'hidden_distribution_title_names';

  List<Map<String, dynamic>> _distributionTitles = []; 
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final categories = await sl<ApiService>().getMilkCategories();
      final prefs = sl<SharedPreferences>();
      final hiddenIds = prefs.getStringList(_hiddenDistributionTitleIdsKey) ?? [];
      final hiddenNames =
          prefs.getStringList(_hiddenDistributionTitleNamesKey) ?? [];
      setState(() {
        _distributionTitles = List<Map<String, dynamic>>.from(categories)
            .where((category) => !_isHiddenCategory(category, hiddenIds, hiddenNames))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Service not available';
        _isLoading = false;
      });
    }
  }

  void _onCategoryAdded() {
    _fetchCategories();
  }

  bool _isHiddenCategory(
    Map<String, dynamic> category,
    List<String> hiddenIds,
    List<String> hiddenNames,
  ) {
    final id = category['id']?.toString() ?? category['_id']?.toString() ?? '';
    final normalizedName = _normalizeCategoryName(category['name']);
    return (id.isNotEmpty && hiddenIds.contains(id)) ||
        (normalizedName.isNotEmpty && hiddenNames.contains(normalizedName));
  }

  String _normalizeCategoryName(dynamic value) {
    return value?.toString().trim().toLowerCase() ?? '';
  }

  Future<void> _hideCategoryLocally(Map<String, dynamic> category) async {
    final prefs = sl<SharedPreferences>();
    final hiddenIds =
        List<String>.from(prefs.getStringList(_hiddenDistributionTitleIdsKey) ?? []);
    final hiddenNames = List<String>.from(
      prefs.getStringList(_hiddenDistributionTitleNamesKey) ?? [],
    );

    final id = category['id']?.toString() ?? category['_id']?.toString() ?? '';
    final normalizedName = _normalizeCategoryName(category['name']);

    if (id.isNotEmpty && !hiddenIds.contains(id)) {
      hiddenIds.add(id);
    }
    if (normalizedName.isNotEmpty && !hiddenNames.contains(normalizedName)) {
      hiddenNames.add(normalizedName);
    }

    await prefs.setStringList(_hiddenDistributionTitleIdsKey, hiddenIds);
    await prefs.setStringList(_hiddenDistributionTitleNamesKey, hiddenNames);

    if (!mounted) return;
    setState(() {
      _distributionTitles.removeWhere(
        (item) =>
            (id.isNotEmpty &&
                (item['id']?.toString() == id || item['_id']?.toString() == id)) ||
            _normalizeCategoryName(item['name']) == normalizedName,
      );
    });
  }

  Future<void> _confirmDeleteCategory(Map<String, dynamic> category) async {
    final name = category['name']?.toString() ?? 'this title';
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Distribution Title',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Delete "$name" from this mobile device? It may still exist on the backend.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _hideCategoryLocally(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Text(
          'Distribution Title',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/no_data_found.png',
                        width: 150,
                        height: 150,
                        color: Colors.grey.withOpacity(0.5),
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.error_outline,
                          size: 100,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCategories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
              : _distributionTitles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9), // Light Green bg
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                       children: [
                         const Icon(Icons.content_paste, size: 80, color: Color(0xFF8DA94D)), // Placeholder icon
                         Positioned(
                           bottom: 30, right: 30,
                           child: Container(
                             padding: const EdgeInsets.all(4),
                             decoration: const BoxDecoration(color: Color(0xFF8DA94D), shape: BoxShape.circle),
                             child: const Icon(Icons.close, color: Colors.white, size: 20),
                           ),
                         )
                       ]
                    ),
                   ), // Using Icon as asset not available. Or use generate_image tool? For now icon.
                   // The image is "No data found" illustration. I'll use a placeholder or check assets.
                   // Assuming no asset available, using simple styling.
                  const SizedBox(height: 24),
                  Text(
                    'No data found',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8DA94D),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _distributionTitles.length,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = _distributionTitles[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category['name'] ?? '-',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmDeleteCategory(category),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddDistributionTitleBottomSheet(
              onAdd: (name) => _onCategoryAdded(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Distribution Title',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
