import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/localization/localized_ui.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/feed_local_data_source.dart';
import '../../../../core/utils/app_feedback.dart';

class FeedInventoryScreen extends StatefulWidget {
  const FeedInventoryScreen({super.key});

  @override
  State<FeedInventoryScreen> createState() => _FeedInventoryScreenState();
}

class _FeedInventoryScreenState extends State<FeedInventoryScreen> {
  double _feedStock = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshInventory();
  }

  /// Fetches real inventory from both server and local storage
  Future<void> _refreshInventory() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch current inventory from API
      final response = await sl<ApiService>().getFeedInventory();
      
      double totalStock = 0;
      
      if (response is Map<String, dynamic>) {
        // Handle variations: { "inventory": { ... } }, { "data": { "inventory": { ... } } }, or { "totalQuantity": N }
        dynamic dataObj = response.containsKey('data') ? response['data'] : response;
        
        if (dataObj is Map<String, dynamic>) {
          if (dataObj.containsKey('inventory')) {
            final inv = dataObj['inventory'] as Map<String, dynamic>;
            totalStock = (inv['totalQuantity'] as num? ?? inv['quantity'] as num?)?.toDouble() ?? 0.0;
          } else {
            // Check direct fields
            totalStock = (dataObj['totalQuantity'] as num? ?? dataObj['quantity'] as num?)?.toDouble() ?? 0.0;
          }
        } else if (dataObj is List) {
          for (var item in dataObj) {
            if (item is Map) {
              totalStock += (item['totalQuantity'] as num? ?? item['quantity'] as num?)?.toDouble() ?? 0.0;
            }
          }
        }
      } else if (response is List) {
        for (var item in response) {
          if (item is Map) {
            totalStock += (item['totalQuantity'] as num? ?? item['quantity'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      // 2. Sync total with local storage and update UI
      await sl<FeedLocalDataSource>().updateFeedStock(totalStock);
      
      if (mounted) {
        setState(() {
          _feedStock = totalStock;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error refreshing inventory: $e');
      
      // Fallback to local stock if API fails
      final localStock = await sl<FeedLocalDataSource>().getFeedStock();
      if (mounted) {
        setState(() => _feedStock = localStock);
      }
    }
  }

  Future<void> _loadStock() async {
    final stock = await sl<FeedLocalDataSource>().getFeedStock();
    setState(() {
      _feedStock = stock;
    });
  }

  void _updateStock() {
    final controller = TextEditingController(
      text: _feedStock.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update Feed Stock',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Stock: ${_feedStock.toInt()} Kg',
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter new stock amount',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixText: 'Kg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final newStock = double.parse(controller.text);

                try {
                  // 1. Update Backend Inventory first (UPSERT)
                  // We use "Maize Silage" as the key name
                  await sl<ApiService>().updateFeedInventory(
                    feedName: "Maize Silage",
                    quantity: newStock,
                  );

                  // 2. Update Local Data Source
                  await sl<FeedLocalDataSource>().updateFeedStock(newStock);

                  // 3. Refresh UI state
                  await _loadStock();

                  if (context.mounted) {
                    Navigator.pop(context);
                    AppFeedback.showSuccess(context, 'Inventory updated successfully on server.');
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppFeedback.showError(context, 'Failed to sync with server: $e');
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Update',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
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
        title: Text(
          context.ui.feedInventory,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshInventory,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshInventory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prominent Stock Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(
                        Icons.grass,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Available Feed Stock',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_feedStock.toInt()} Kg',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _updateStock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Update Stock',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Inventory Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildInfoCard(
                'Automatic Management',
                'The feed values entered in the "Add Milk Entry" section will automatically be deducted from this stock once the API is integrated.',
                Icons.auto_fix_high_outlined,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Stock Notifications',
                'You will receive notifications when your feed stock falls below 500 Kg.',
                Icons.notifications_active_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
