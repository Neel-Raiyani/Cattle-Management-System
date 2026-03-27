import 'package:flutter/widgets.dart';

extension LocalizedAssetsX on BuildContext {
  String get noDataFoundAsset {
    switch (Localizations.localeOf(this).languageCode) {
      case 'gu':
        return 'assets/icons/no_data_gound_guj.png';
      case 'hi':
        return 'assets/icons/no_data_gound_hin.png';
      default:
        return 'assets/icons/no_data_found.png';
    }
  }
}
