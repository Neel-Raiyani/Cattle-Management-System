import 'package:shared_preferences/shared_preferences.dart';

abstract class FeedLocalDataSource {
  Future<double> getFeedStock();
  Future<void> updateFeedStock(double newStock);
  Future<void> deductFeedStock(double amount);
}

class FeedLocalDataSourceImpl implements FeedLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _feedStockKey = 'CACHED_FEED_STOCK';

  FeedLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<double> getFeedStock() async {
    final stock = sharedPreferences.getDouble(_feedStockKey);
    // Initial stock if not set
    if (stock == null) {
      await updateFeedStock(0.0);
      return 0.0;
    }
    return stock;
  }

  @override
  Future<void> updateFeedStock(double newStock) async {
    await sharedPreferences.setDouble(_feedStockKey, newStock);
  }

  @override
  Future<void> deductFeedStock(double amount) async {
    final currentStock = await getFeedStock();
    final newStock = currentStock - amount;
    await updateFeedStock(newStock > 0 ? newStock : 0);
  }
}
