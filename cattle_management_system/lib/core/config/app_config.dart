import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App Configuration Constants
class AppConfig {
  // App Information
  static const String appName = 'Cattle Management System';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.gaushala.cattle_management';

  // API Configuration
  static String get baseUrl =>
      dotenv.env['BASE_URL']?.trim().isNotEmpty == true
      ? dotenv.env['BASE_URL']!.trim()
      : 'https://week3reqbackend.empyreal.work';
  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const int connectionTimeout =
      30000; // 30 seconds (Reduced from 60s for faster failure)
  static const int receiveTimeout = 30000; // 30 seconds

  // Local Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  static const String isFirstLaunchKey = 'is_first_launch';

  // Hive Box Names
  static const String cattleBoxName = 'cattle_box';
  static const String healthRecordsBoxName = 'health_records_box';
  static const String milkProductionBoxName = 'milk_production_box';
  static const String breedingBoxName = 'breeding_box';
  static const String feedBoxName = 'feed_box';
  static const String expenseBoxName = 'expense_box';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Configuration
  static const int maxImageSizeMB = 5;
  static const int imageQuality = 85;

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'hi', 'gu'];
  static const String defaultLanguage = 'en';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
}
