import 'package:flutter/widgets.dart';

extension LocalizedTextX on BuildContext {
  String tx({
    required String en,
    String? hi,
    String? gu,
  }) {
    switch (Localizations.localeOf(this).languageCode) {
      case 'hi':
        return hi ?? en;
      case 'gu':
        return gu ?? en;
      default:
        return en;
    }
  }
}
