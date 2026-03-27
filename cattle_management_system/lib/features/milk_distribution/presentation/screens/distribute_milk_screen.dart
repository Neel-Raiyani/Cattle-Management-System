import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localized_assets.dart';
import '../../../../core/localization/localized_ui.dart';
import '../../../../core/utils/app_feedback.dart';

class DistributeMilkScreen extends StatefulWidget {
  const DistributeMilkScreen({super.key});

  @override
  State<DistributeMilkScreen> createState() => _DistributeMilkScreenState();
}

class _DistributeMilkScreenState extends State<DistributeMilkScreen> {
  static const String _hiddenDistributionTitleIdsKey =
      'hidden_distribution_title_ids';
  static const String _hiddenDistributionTitleNamesKey =
      'hidden_distribution_title_names';

  DateTime _selectedDate = DateTime.now();
  String _selectedShift = 'Morning'; // Morning, Evening
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _categories = [];
  final Map<String, double> _distributionValues = {};
  double _totalMilkProduced = 0.0;
  double _alreadyDistributed = 0.0;
  String? _error;
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  String get _apiSession => _selectedShift.toUpperCase();

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  bool _isSameDate(dynamic rawDate, String expectedDate) {
    final value = rawDate?.toString() ?? '';
    if (value.isEmpty) return false;
    return value == expectedDate || value.startsWith('${expectedDate}T');
  }

  double _extractProductionTotal(dynamic productionData) {
    final root = productionData is Map<String, dynamic>
        ? productionData
        : <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;

    final sessionTotal = _selectedShift == 'Morning'
        ? _asDouble(data['morning'])
        : _asDouble(data['evening']);
    if (sessionTotal > 0) return sessionTotal;

    final directTotal = _asDouble(data['total']);
    if (directTotal > 0) return directTotal;

    final items = (data['items'] as List?) ?? const [];
    double computed = 0.0;
    for (final item in items.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      final itemSessionTotal = _selectedShift == 'Morning'
          ? _asDouble(map['morning'])
          : _asDouble(map['evening']);
      computed += itemSessionTotal > 0 ? itemSessionTotal : _asDouble(map['total']);
    }
    if (computed > 0) return computed;

    final report = (data['report'] ?? root['report']) as List?;
    if (report != null && report.isNotEmpty) {
      double reportTotal = 0.0;
      for (final item in report.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        double val = _selectedShift == 'Morning'
            ? _asDouble(map['morning'])
            : _asDouble(map['evening']);
        
        // Fallback for simple list of entries that might use 'quantity' or 'total'
        if (val == 0) {
          val = _asDouble(map['quantity'] ?? map['amount'] ?? map['total'] ?? map['liters']);
        }
        reportTotal += val;
      }
      if (reportTotal > 0) return reportTotal;
    }

    final records = (data['records'] ?? root['records']) as List?;
    if (records != null && records.isNotEmpty) {
      double recordTotal = 0.0;
      for (final item in records.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        double val = _selectedShift == 'Morning'
            ? _asDouble(map['morning'])
            : _asDouble(map['evening']);
        if (val == 0) {
          val = _asDouble(map['quantity'] ?? map['amount'] ?? map['total'] ?? map['liters']);
        }
        recordTotal += val;
      }
      if (recordTotal > 0) return recordTotal;
    }

    return computed;
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      double totalProd = 0.0;
      try {
        final productionData = await sl<ApiService>().getDailyProductionReport(
          date: dateStr,
        );
        totalProd = _extractProductionTotal(productionData);

        if (totalProd <= 0) {
          final yields = await sl<ApiService>().getMilkYields();
          for (final item in yields.whereType<Map>()) {
            if (!_isSameDate(item['date'], dateStr)) continue;
            final sessionYield = _selectedShift == 'Morning'
                ? _asDouble(item['morning'])
                : _asDouble(item['evening']);
            totalProd += sessionYield > 0 ? sessionYield : _asDouble(item['total']);
          }
        }
      } catch (e) {
        debugPrint('Failed to fetch production total: $e');
      }

      final categories = await sl<ApiService>().getMilkCategories();
      final prefs = sl<SharedPreferences>();
      final hiddenIds = prefs.getStringList(_hiddenDistributionTitleIdsKey) ?? [];
      final hiddenNames =
          prefs.getStringList(_hiddenDistributionTitleNamesKey) ?? [];
      final visibleCategories = List<Map<String, dynamic>>.from(categories)
          .where((category) {
            final id =
                category['id']?.toString() ?? category['_id']?.toString() ?? '';
            final normalizedName =
                category['name']?.toString().trim().toLowerCase() ?? '';
            return !(id.isNotEmpty && hiddenIds.contains(id)) &&
                !(normalizedName.isNotEmpty &&
                    hiddenNames.contains(normalizedName));
          })
          .toList();

      double alreadyDist = 0.0;
      try {
        final distributions = await sl<ApiService>().getMilkDistributions(date: dateStr);
        for (var d in distributions) {
          final session = d['session']?.toString().toUpperCase();
          if (session != null && session.isNotEmpty && session != _apiSession) {
            continue;
          }
          alreadyDist += double.tryParse(d['amount']?.toString() ?? '0') ?? 0.0;
        }
      } catch (e) {
        debugPrint('Failed to fetch distribution history: $e');
      }

      if (mounted) {
        setState(() {
          _totalMilkProduced = totalProd;
          _alreadyDistributed = alreadyDist;
          _categories = visibleCategories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Service not available';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitDistribution() async {
    if (_isSubmitting) return;

    if (_distributionValues.isEmpty) {
      await AppFeedback.showWarning(
        context,
        context.ui.pleaseEnterDistributionValues,
      );
      return;
    }

    if (_totalMilkProduced <= 0) {
      await AppFeedback.showWarning(
        context,
        context.ui.noMilkProductionFound,
      );
      return;
    }

    // Validate if exceeding remaining
    double currentInputTotal = _distributionValues.values.fold(0, (sum, val) => sum + val);
    if ((_alreadyDistributed + currentInputTotal) > _totalMilkProduced) {
      await AppFeedback.showError(
        context,
        context.ui.distributionExceedsProduction,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Submit each distribution item
      for (var entry in _distributionValues.entries) {
        final category = _categories.firstWhere(
          (c) => c['name'] == entry.key,
          orElse: () => {},
        );
        if (category.isNotEmpty) {
          await sl<ApiService>().allocateMilk(
            categoryId: category['id'] ?? category['_id'],
            date: dateStr,
            session: _apiSession,
            quantity: entry.value,
            remarks: _remarksController.text,
          );
        }
      }

      if (mounted) {
        setState(() {
          _alreadyDistributed += currentInputTotal;
          _distributionValues.clear();
          _remarksController.clear();
        });
        await AppFeedback.showSuccess(
          context,
          context.ui.milkDistributedSuccessfully,
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        await AppFeedback.showError(
          context,
          context.ui.failedToDistributeMilk(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _distributionValues.clear(); // Reset inputs on date change
      });
      _fetchData();
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    double totalDistributed = _distributionValues.values.fold(
      0,
      (sum, val) => sum + val,
    );
    double displayDistribution = _alreadyDistributed + totalDistributed;
    double remaining = _totalMilkProduced - displayDistribution;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          context.ui.distributeMilk,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header: Date & Shift (Matching MilkProductionScreen style)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.ui.date,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Shift Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.ui.shift,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        // Using container to align height with Date picker roughly
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                          _buildRadioOption('Morning'),
                            const SizedBox(width: 12),
                          _buildRadioOption('Evening'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          context.noDataFoundAsset,
                          width: 150,
                          height: 150,
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
                          onPressed: _fetchData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                          child: Text(
                            context.ui.retry,
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : _categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          context.noDataFoundAsset,
                          width: 150,
                          height: 150,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.ui.noCategoriesFound,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Summary Cards
                        Row(
                          children: [
                            // Total - Yellowish/Orange
                            Expanded(
                              child: _buildSummaryCard(
                                context.ui.total,
                                _totalMilkProduced.toStringAsFixed(2),
                                const Color(0xFFFFF3E0),
                                Colors.orange.shade800,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Distribution - Greenish
                            Expanded(
                              child: _buildSummaryCard(
                                context.ui.distribution,
                                displayDistribution.toStringAsFixed(2),
                                const Color(0xFFE8F5E9),
                                Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Remain - Reddish
                            Expanded(
                              child: _buildSummaryCard(
                                context.ui.remain,
                                remaining.toStringAsFixed(2),
                                const Color(0xFFFFEBEE),
                                Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text(
                                  context.ui.serialNo,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  context.ui.category,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  context.ui.milk,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Table Rows
                        ..._categories.asMap().entries.map((entry) {
                          int index = entry.key;
                          String name = entry.value['name'] ?? '-';
                          bool isLast = index == _categories.length - 1;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                left: BorderSide(color: Colors.grey.shade200),
                                right: BorderSide(color: Colors.grey.shade200),
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                              borderRadius: isLast
                                  ? const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.inter(fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  height: 40,
                                  child: TextFormField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(fontSize: 14),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val.isEmpty) {
                                          _distributionValues.remove(name);
                                        } else {
                                          _distributionValues[name] =
                                              double.tryParse(val) ?? 0;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 80), // Space for button
                      ],
                    ),
                  ),
          ),

          // Submit Button
          if (!_isLoading && _categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitDistribution,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.ui.submit,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    bool isSelected = _selectedShift == value;
    return GestureDetector(
      onTap: () {
        if (_selectedShift == value) return;
        setState(() {
          _selectedShift = value;
          _distributionValues.clear();
        });
        _fetchData();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                width: 2,
              ),
            ),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value == 'Morning'
                ? context.ui.morning
                : value == 'Evening'
                    ? context.ui.evening
                    : value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
