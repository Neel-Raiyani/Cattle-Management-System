import 'package:flutter/widgets.dart';

extension LocalizedUiX on BuildContext {
  _LocalizedUi get ui => _LocalizedUi(Localizations.localeOf(this).languageCode);
}

class _LocalizedUi {
  const _LocalizedUi(this.languageCode);

  final String languageCode;

  bool get _isGujarati => languageCode == 'gu';
  bool get _isHindi => languageCode == 'hi';

  String _pick({
    required String en,
    required String gu,
    required String hi,
  }) {
    if (_isGujarati) return gu;
    if (_isHindi) return hi;
    return en;
  }

  String get welcomeBack => _pick(
        en: 'Welcome back',
        gu: '\u0aaa\u0abe\u0a9b\u0abe \u0a86\u0ab5\u0ab5\u0abe \u0aac\u0aa6\u0ab2 \u0ab8\u0acd\u0ab5\u0abe\u0a97\u0aa4',
        hi: '\u0935\u093e\u092a\u0938 \u0906\u0928\u0947 \u092a\u0930 \u0938\u094d\u0935\u093e\u0917\u0924',
      );

  String get gaushala => _pick(
        en: 'Gaushala',
        gu: '\u0a97\u0acc\u0ab6\u0abe\u0ab3\u0abe',
        hi: '\u0917\u094c\u0936\u093e\u0932\u093e',
      );

  String get gauGram => _pick(
        en: 'GauGram',
        gu: '\u0a97\u0acc\u0a97\u0acd\u0ab0\u0abe\u0aae',
        hi: '\u0917\u094c\u0917\u094d\u0930\u093e\u092e',
      );

  String get sell => _pick(
        en: 'Sell',
        gu: '\u0ab5\u0ac7\u0a9a\u0abe\u0aa3',
        hi: '\u092c\u093f\u0915\u094d\u0930\u0940',
      );

  String get death => _pick(
        en: 'Death',
        gu: '\u0aae\u0ac3\u0aa4\u0acd\u0aaf\u0ac1',
        hi: '\u092e\u0943\u0924\u094d\u092f\u0941',
      );

  String get donation => _pick(
        en: 'Donation',
        gu: '\u0aa6\u0abe\u0aa8',
        hi: '\u0926\u093e\u0928',
      );

  String get animalLeftFromGaushala => _pick(
        en: 'Animal Left from Gaushala',
        gu: '\u0a97\u0acc\u0ab6\u0abe\u0ab3\u0abe\u0aae\u0abe\u0a82\u0aa5\u0ac0 \u0a9c\u0aa4\u0abe \u0aaa\u0ab6\u0ac1',
        hi: '\u0917\u094c\u0936\u093e\u0932\u093e \u0938\u0947 \u0917\u090f \u092a\u0936\u0941',
      );

  String get animalHealthInformation => _pick(
        en: 'Animal Health Information',
        gu: '\u0aaa\u0ab6\u0ac1 \u0a86\u0ab0\u0acb\u0a97\u0acd\u0aaf \u0aae\u0abe\u0ab9\u0abf\u0aa4\u0ac0',
        hi: '\u092a\u0936\u0941 \u0938\u094d\u0935\u093e\u0938\u094d\u0925\u094d\u092f \u091c\u093e\u0928\u0915\u093e\u0930\u0940',
      );

  String get medical => _pick(
        en: 'Medical',
        gu: '\u0aae\u0ac7\u0aa1\u0abf\u0a95\u0ab2',
        hi: '\u092e\u0947\u0921\u093f\u0915\u0932',
      );

  String get vaccination => _pick(
        en: 'Vaccination',
        gu: '\u0ab0\u0ab8\u0ac0\u0a95\u0ab0\u0aa3',
        hi: '\u091f\u0940\u0915\u093e\u0915\u0930\u0923',
      );

  String get deworming => _pick(
        en: 'Deworming',
        gu: '\u0a95\u0acd\u0ab0\u0ac1\u0aae\u0abf \u0aa1\u0acb\u0ab8',
        hi: '\u0921\u0940\u0935\u0949\u0930\u094d\u092e\u093f\u0902\u0917',
      );

  String get labTesting => _pick(
        en: 'Lab Testing',
        gu: '\u0ab2\u0ac7\u0aac \u0a9f\u0ac7\u0ab8\u0acd\u0a9f\u0abf\u0a82\u0a97',
        hi: '\u0932\u0948\u092c \u091f\u0947\u0938\u094d\u091f\u093f\u0902\u0917',
      );

  String get photoGallery => _pick(
        en: 'Photo Gallery',
        gu: '\u0aab\u0acb\u0a9f\u0acb \u0a97\u0ac7\u0ab2\u0ac7\u0ab0\u0ac0',
        hi: '\u092b\u094b\u091f\u094b \u0917\u0948\u0932\u0930\u0940',
      );

  String get videoGallery => _pick(
        en: 'Video Gallery',
        gu: '\u0ab5\u0abf\u0aa1\u0abf\u0a93 \u0a97\u0ac7\u0ab2\u0ac7\u0ab0\u0ac0',
        hi: '\u0935\u0940\u0921\u093f\u092f\u094b \u0917\u0948\u0932\u0930\u0940',
      );

  String get allCow => _pick(
        en: 'All Cow',
        gu: '\u0aac\u0aa7\u0abe \u0a97\u0abe\u0aaf',
        hi: '\u0938\u092d\u0940 \u0917\u093e\u092f',
      );

  String get allBull => _pick(
        en: 'All Bull',
        gu: '\u0aac\u0aa7\u0abe \u0aac\u0ab3\u0aa6',
        hi: '\u0938\u092d\u0940 \u092c\u0948\u0932',
      );

  String get cattleStatus => _pick(
        en: 'Cattle Status',
        gu: '\u0aaa\u0ab6\u0ac1 \u0ab8\u0acd\u0aa5\u0abf\u0aa4\u0abf',
        hi: '\u092a\u0936\u0941 \u0938\u094d\u0925\u093f\u0924\u093f',
      );

  String get lactating => _pick(
        en: 'Lactating',
        gu: '\u0aa6\u0ac2\u0aa7 \u0a86\u0aaa\u0aa4\u0ac0',
        hi: '\u0926\u0942\u0927 \u0926\u0947\u0928\u0947 \u0935\u093e\u0932\u0940',
      );

  String get heifer => _pick(
        en: 'Heifer',
        gu: '\u0aaa\u0abe\u0aa1\u0ac0',
        hi: '\u092c\u091b\u093f\u092f\u093e',
      );

  String get calving => _pick(
        en: 'Calving',
        gu: '\u0aac\u0abe\u0ab2\u0a82\u0aa4',
        hi: '\u092c\u094d\u092f\u093e\u0928\u0947 \u0935\u093e\u0932\u0940',
      );

  String get todaysProduction => _pick(
        en: "Today's Production",
        gu: '\u0a86\u0a9c\u0aa8\u0ac1\u0a82 \u0a89\u0aa4\u0acd\u0aaa\u0abe\u0aa6\u0aa8',
        hi: '\u0906\u091c \u0915\u093e \u0909\u0924\u094d\u092a\u093e\u0926\u0928',
      );

  String get morning => _pick(
        en: 'Morning',
        gu: '\u0ab8\u0ab5\u0abe\u0ab0',
        hi: '\u0938\u0941\u092c\u0939',
      );

  String get evening => _pick(
        en: 'Evening',
        gu: '\u0ab8\u0abe\u0a82\u0a9c',
        hi: '\u0936\u093e\u092e',
      );

  String get healthAndReproduction => _pick(
        en: 'Health & Reproduction',
        gu: '\u0a86\u0ab0\u0acb\u0a97\u0acd\u0aaf \u0a85\u0aa8\u0ac7 \u0aaa\u0acd\u0ab0\u0a9c\u0aa8\u0aa8',
        hi: '\u0938\u094d\u0935\u093e\u0938\u094d\u0925\u094d\u092f \u0914\u0930 \u092a\u094d\u0930\u091c\u0928\u0928',
      );

  String get heatRecord => _pick(
        en: 'Heat Record',
        gu: '\u0ab9\u0ac0\u0a9f \u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1',
        hi: '\u0939\u0940\u091f \u0930\u093f\u0915\u0949\u0930\u094d\u0921',
      );

  String get totalActive => _pick(
        en: 'Total Active',
        gu: '\u0a95\u0ac1\u0ab2 \u0ab8\u0a95\u0acd\u0ab0\u0abf\u0aaf',
        hi: '\u0915\u0941\u0932 \u0938\u0915\u094d\u0930\u093f\u092f',
      );

  String get conception => _pick(
        en: 'Conception',
        gu: '\u0a97\u0ab0\u0acd\u0aad\u0abe\u0aa7\u0abe\u0aa8',
        hi: '\u0917\u0930\u094d\u092d\u093e\u0927\u093e\u0928',
      );

  String get pregnancyStatus => _pick(
        en: 'Pregnancy Status',
        gu: '\u0a97\u0ab0\u0acd\u0aad\u0abe\u0ab5\u0ab8\u0acd\u0aa5\u0abe \u0ab8\u0acd\u0aa5\u0abf\u0aa4\u0abf',
        hi: '\u0917\u0930\u094d\u092d\u093e\u0935\u0938\u094d\u0925\u093e \u0938\u094d\u0925\u093f\u0924\u093f',
      );

  String get dryOffCow => _pick(
        en: 'Dry Off Cow',
        gu: '\u0aa1\u0acd\u0ab0\u0abe\u0aaf \u0a91\u0aab \u0a97\u0abe\u0aaf',
        hi: '\u0921\u094d\u0930\u093e\u0908 \u0911\u092b \u0917\u093e\u092f',
      );

  String get sickAnimal => _pick(
        en: 'Sick Animal',
        gu: '\u0aac\u0ac0\u0aae\u0abe\u0ab0 \u0aaa\u0ab6\u0ac1',
        hi: '\u092c\u0940\u092e\u093e\u0930 \u092a\u0936\u0941',
      );

  String get targetDate => _pick(
        en: 'Target Date',
        gu: '\u0ab2\u0a95\u0acd\u0ab7\u0acd\u0aaf \u0aa4\u0abe\u0ab0\u0ac0\u0a96',
        hi: '\u0932\u0915\u094d\u0937\u094d\u092f \u0924\u093e\u0930\u0940\u0916',
      );

  String get distributeMilk => _pick(
        en: 'Distribute Milk',
        gu: '\u0aa6\u0ac2\u0aa7 \u0ab5\u0abf\u0aa4\u0ab0\u0aa3',
        hi: '\u0926\u0942\u0927 \u0935\u093f\u0924\u0930\u0923',
      );

  String get trackDailyDelivery => _pick(
        en: 'Track daily delivery',
        gu: '\u0aa6\u0ac8\u0aa8\u0abf\u0a95 \u0ab5\u0abf\u0aa4\u0ab0\u0aa3 \u0a9f\u0acd\u0ab0\u0ac7\u0a95 \u0a95\u0ab0\u0acb',
        hi: '\u0926\u0948\u0928\u093f\u0915 \u0935\u093f\u0924\u0930\u0923 \u091f\u094d\u0930\u0948\u0915 \u0915\u0930\u0947\u0902',
      );

  String get reports => _pick(
        en: 'Reports',
        gu: '\u0ab0\u0abf\u0aaa\u0acb\u0ab0\u0acd\u0a9f\u0acd\u0ab8',
        hi: '\u0930\u093f\u092a\u094b\u0930\u094d\u091f\u094d\u0938',
      );

  String get alerts => _pick(
        en: 'Alerts',
        gu: '\u0a8f\u0ab2\u0ab0\u0acd\u0a9f\u0acd\u0ab8',
        hi: '\u0905\u0932\u0930\u094d\u091f\u094d\u0938',
      );

  String get viewAnalytics => _pick(
        en: 'View Analytics',
        gu: '\u0ab5\u0abf\u0ab6\u0acd\u0ab2\u0ac7\u0ab7\u0aa3 \u0a9c\u0ac1\u0a93',
        hi: '\u090f\u0928\u093e\u0932\u093f\u091f\u093f\u0915\u094d\u0938 \u0926\u0947\u0916\u0947\u0902',
      );

  String get viewAlerts => _pick(
        en: 'View Alerts',
        gu: '\u0a8f\u0ab2\u0ab0\u0acd\u0a9f\u0acd\u0ab8 \u0a9c\u0ac1\u0a93',
        hi: '\u0905\u0932\u0930\u094d\u091f\u094d\u0938 \u0926\u0947\u0916\u0947\u0902',
      );

  String get feedInventory => _pick(
        en: 'Feed Inventory',
        gu: '\u0a9a\u0abe\u0ab0\u0abe \u0a87\u0aa8\u0acd\u0ab5\u0ac7\u0a82\u0a9f\u0ab0\u0ac0',
        hi: '\u091a\u093e\u0930\u093e \u0907\u0928\u094d\u0935\u0947\u0902\u091f\u0930\u0940',
      );

  String get medicalReport => _pick(
        en: 'Medical Report',
        gu: '\u0aae\u0ac7\u0aa1\u0abf\u0a95\u0ab2 \u0ab0\u0abf\u0aaa\u0acb\u0ab0\u0acd\u0a9f',
        hi: '\u092e\u0947\u0921\u093f\u0915\u0932 \u0930\u093f\u092a\u094b\u0930\u094d\u091f',
      );

  String get animalWiseMedicalReport => _pick(
        en: 'Animal Wise Medical Report',
        gu: '\u0aaa\u0ab6\u0ac1 \u0ab5\u0abe\u0a87\u0a9d \u0aae\u0ac7\u0aa1\u0abf\u0a95\u0ab2 \u0ab0\u0abf\u0aaa\u0acb\u0ab0\u0acd\u0a9f',
        hi: '\u092a\u0936\u0941 \u0935\u093e\u0907\u091c \u092e\u0947\u0921\u093f\u0915\u0932 \u0930\u093f\u092a\u094b\u0930\u094d\u091f',
      );

  String get dateWiseMedicalReport => _pick(
        en: 'Date Wise Medical Report',
        gu: '\u0aa4\u0abe\u0ab0\u0ac0\u0a96 \u0ab5\u0abe\u0a87\u0a9d \u0aae\u0ac7\u0aa1\u0abf\u0a95\u0ab2 \u0ab0\u0abf\u0aaa\u0acb\u0ab0\u0acd\u0a9f',
        hi: '\u0924\u093e\u0930\u0940\u0916 \u0935\u093e\u0907\u091c \u092e\u0947\u0921\u093f\u0915\u0932 \u0930\u093f\u092a\u094b\u0930\u094d\u091f',
      );

  String get diseaseWiseReport => _pick(
        en: 'Disease Wise Report',
        gu: '\u0ab0\u0acb\u0a97 \u0ab5\u0abe\u0a87\u0a9d \u0ab0\u0abf\u0aaa\u0acb\u0ab0\u0acd\u0a9f',
        hi: '\u0930\u094b\u0917 \u0935\u093e\u0907\u091c \u0930\u093f\u092a\u094b\u0930\u094d\u091f',
      );

  String get milkProduction => _pick(
        en: 'Milk Production',
        gu: '\u0aa6\u0ac2\u0aa7 \u0a89\u0aa4\u0acd\u0aaa\u0abe\u0aa6\u0aa8',
        hi: '\u0926\u0942\u0927 \u0909\u0924\u094d\u092a\u093e\u0926\u0928',
      );

  String get addMilkEntry => _pick(
        en: 'Add Milk Entry',
        gu: '\u0aa6\u0ac2\u0aa7 \u0a8f\u0aa8\u0acd\u0a9f\u0acd\u0ab0\u0ac0 \u0a89\u0aae\u0ac7\u0ab0\u0acb',
        hi: '\u0926\u0942\u0927 \u090f\u0902\u091f\u094d\u0930\u0940 \u091c\u094b\u095c\u0947\u0902',
      );

  String get date => _pick(
        en: 'Date',
        gu: '\u0aa4\u0abe\u0ab0\u0ac0\u0a96',
        hi: '\u0924\u093e\u0930\u0940\u0916',
      );

  String get cowGroup => _pick(
        en: 'Cow Group',
        gu: '\u0a97\u0abe\u0aaf \u0a9c\u0ac2\u0aa5',
        hi: '\u0917\u093e\u092f \u0938\u092e\u0942\u0939',
      );

  String get all => _pick(
        en: 'All',
        gu: '\u0aac\u0aa7\u0abe',
        hi: '\u0938\u092d\u0940',
      );

  String totalCowCount(int count) => _pick(
        en: 'Total $count Cow',
        gu: '\u0a95\u0ac1\u0ab2 $count \u0a97\u0abe\u0aaf',
        hi: '\u0915\u0941\u0932 $count \u0917\u093e\u092f',
      );

  String get total => _pick(
        en: 'Total',
        gu: '\u0a95\u0ac1\u0ab2',
        hi: '\u0915\u0941\u0932',
      );

  String get cowName => _pick(
        en: 'Cow Name',
        gu: '\u0a97\u0abe\u0aaf\u0aa8\u0ac1\u0a82 \u0aa8\u0abe\u0aae',
        hi: '\u0917\u093e\u092f \u0915\u093e \u0928\u093e\u092e',
      );

  String get shift => _pick(
        en: 'Shift',
        gu: '\u0ab6\u0abf\u0aab\u0acd\u0a9f',
        hi: '\u0936\u093f\u092b\u094d\u091f',
      );

  String get distribution => _pick(
        en: 'Distribution',
        gu: '\u0ab5\u0abf\u0aa4\u0ab0\u0aa3',
        hi: '\u0935\u093f\u0924\u0930\u0923',
      );

  String get remain => _pick(
        en: 'Remain',
        gu: '\u0aac\u0abe\u0a95\u0ac0',
        hi: '\u0936\u0947\u0937',
      );

  String get category => _pick(
        en: 'Category',
        gu: '\u0ab6\u0acd\u0ab0\u0ac7\u0aa3\u0ac0',
        hi: '\u0936\u094d\u0930\u0947\u0923\u0940',
      );

  String get milk => _pick(
        en: 'Milk',
        gu: '\u0aa6\u0ac2\u0aa7',
        hi: '\u0926\u0942\u0927',
      );

  String get serialNo => _pick(
        en: 'Sr No.',
        gu: '\u0a95\u0acd\u0ab0\u0aae \u0aa8\u0a82.',
        hi: '\u0915\u094d\u0930. \u0938\u0902.',
      );

  String get noDataFound => _pick(
        en: 'No data found',
        gu: '\u0a95\u0acb\u0a88 \u0aa1\u0ac7\u0a9f\u0abe \u0aae\u0ab3\u0acd\u0aaf\u0acb \u0aa8\u0aa5\u0ac0',
        hi: '\u0915\u094b\u0908 \u0921\u0947\u091f\u093e \u0928\u0939\u0940\u0902 \u092e\u093f\u0932\u093e',
      );

  String get noRecordsFound => _pick(
        en: 'No Records Found',
        gu: '\u0a95\u0acb\u0a88 \u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1 \u0aae\u0ab3\u0acd\u0aaf\u0abe \u0aa8\u0aa5\u0ac0',
        hi: '\u0915\u094b\u0908 \u0930\u093f\u0915\u0949\u0930\u094d\u0921 \u0928\u0939\u0940\u0902 \u092e\u093f\u0932\u093e',
      );

  String get noCategoriesFound => _pick(
        en: 'No Categories Found',
        gu: '\u0a95\u0acb\u0a88 \u0ab6\u0acd\u0ab0\u0ac7\u0aa3\u0ac0 \u0aae\u0ab3\u0ac0 \u0aa8\u0aa5\u0ac0',
        hi: '\u0915\u094b\u0908 \u0936\u094d\u0930\u0947\u0923\u0940 \u0928\u0939\u0940\u0902 \u092e\u093f\u0932\u0940',
      );

  String get pleaseEnterDistributionValues => _pick(
        en: 'Please enter distribution values',
        gu: '\u0a95\u0ac3\u0aaa\u0abe \u0a95\u0ab0\u0ac0\u0aa8\u0ac7 \u0ab5\u0abf\u0aa4\u0ab0\u0aa3\u0aa8\u0abe \u0aae\u0ac2\u0ab2\u0acd\u0aaf \u0aa6\u0abe\u0a96\u0ab2 \u0a95\u0ab0\u0acb',
        hi: '\u0915\u0943\u092a\u092f\u093e \u0935\u093f\u0924\u0930\u0923 \u092e\u093e\u0928 \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902',
      );

  String get noMilkProductionFound => _pick(
        en: 'No milk production found for the selected date and shift',
        gu: '\u0aaa\u0ab8\u0a82\u0aa6 \u0a95\u0ab0\u0ac7\u0ab2\u0ac0 \u0aa4\u0abe\u0ab0\u0ac0\u0a96 \u0a85\u0aa8\u0ac7 \u0ab6\u0abf\u0aab\u0acd\u0a9f \u0aae\u0abe\u0a9f\u0ac7 \u0aa6\u0ac2\u0aa7 \u0a89\u0aa4\u0acd\u0aaa\u0abe\u0aa6\u0aa8 \u0aae\u0ab3\u0acd\u0aaf\u0ac1\u0a82 \u0aa8\u0aa5\u0ac0',
        hi: '\u091a\u092f\u0928\u093f\u0924 \u0924\u093e\u0930\u0940\u0916 \u0914\u0930 \u0936\u093f\u092b\u094d\u091f \u0915\u0947 \u0932\u093f\u090f \u0926\u0942\u0927 \u0909\u0924\u094d\u092a\u093e\u0926\u0928 \u0928\u0939\u0940\u0902 \u092e\u093f\u0932\u093e',
      );

  String get distributionExceedsProduction => _pick(
        en: 'Distribution exceeds total produced milk',
        gu: '\u0ab5\u0abf\u0aa4\u0ab0\u0aa3 \u0a95\u0ac1\u0ab2 \u0a89\u0aa4\u0acd\u0aaa\u0abe\u0aa6\u0abf\u0aa4 \u0aa6\u0ac2\u0aa7\u0aa5\u0ac0 \u0ab5\u0aa7\u0ac1 \u0a9b\u0ac7',
        hi: '\u0935\u093f\u0924\u0930\u0923 \u0915\u0941\u0932 \u0909\u0924\u094d\u092a\u093e\u0926\u093f\u0924 \u0926\u0942\u0927 \u0938\u0947 \u0905\u0927\u093f\u0915 \u0939\u0948',
      );

  String get milkDistributedSuccessfully => _pick(
        en: 'Milk distributed successfully',
        gu: '\u0aa6\u0ac2\u0aa7\u0aa8\u0ac1\u0a82 \u0ab5\u0abf\u0aa4\u0ab0\u0aa3 \u0ab8\u0aab\u0ab3\u0aa4\u0abe\u0aaa\u0ac2\u0ab0\u0acd\u0ab5\u0a95 \u0aa5\u0aaf\u0ac1\u0a82',
        hi: '\u0926\u0942\u0927 \u0935\u093f\u0924\u0930\u0923 \u0938\u092b\u0932\u0924\u093e\u092a\u0942\u0930\u094d\u0935\u0915 \u0939\u0941\u0906',
      );

  String failedToDistributeMilk(String error) => _pick(
        en: 'Failed to distribute milk: $error',
        gu: '\u0aa6\u0ac2\u0aa7 \u0ab5\u0abf\u0aa4\u0ab0\u0aa3 \u0aa8\u0abf\u0ab7\u0acd\u0aab\u0ab3 \u0a97\u0aaf\u0ac1\u0a82: $error',
        hi: '\u0926\u0942\u0927 \u0935\u093f\u0924\u0930\u0923 \u0935\u093f\u092b\u0932 \u0939\u0941\u0906: $error',
      );

  String get retry => _pick(
        en: 'Retry',
        gu: '\u0aab\u0ab0\u0ac0 \u0aaa\u0acd\u0ab0\u0aaf\u0abe\u0ab8 \u0a95\u0ab0\u0acb',
        hi: '\u092b\u093f\u0930 \u0938\u0947 \u092a\u094d\u0930\u092f\u093e\u0938 \u0915\u0930\u0947\u0902',
      );

  String get submit => _pick(
        en: 'Submit',
        gu: '\u0ab8\u0aac\u0aae\u0abf\u0a9f \u0a95\u0ab0\u0acb',
        hi: '\u0938\u092c\u092e\u093f\u091f \u0915\u0930\u0947\u0902',
      );

  String get selectCowName => _pick(
        en: 'Select cow name',
        gu: '\u0a97\u0abe\u0aaf\u0aa8\u0ac1\u0a82 \u0aa8\u0abe\u0aae \u0aaa\u0ab8\u0a82\u0aa6 \u0a95\u0ab0\u0acb',
        hi: '\u0917\u093e\u092f \u0915\u093e \u0928\u093e\u092e \u091a\u0941\u0928\u0947\u0902',
      );

  String get parity => _pick(
        en: 'Parity',
        gu: '\u0aaa\u0ac7\u0ab0\u0abf\u0a9f\u0ac0',
        hi: '\u092a\u0948\u0930\u093f\u091f\u0940',
      );

  String get parityNumber => _pick(
        en: 'Parity number',
        gu: '\u0aaa\u0ac7\u0ab0\u0abf\u0a9f\u0ac0 \u0aa8\u0a82\u0aac\u0ab0',
        hi: '\u092a\u0948\u0930\u093f\u091f\u0940 \u0928\u0902\u092c\u0930',
      );

  String get breedingStatus => _pick(
        en: 'Breeding Status',
        gu: '\u0aaa\u0acd\u0ab0\u0a9c\u0aa8\u0aa8 \u0ab8\u0acd\u0aa5\u0abf\u0aa4\u0abf',
        hi: '\u092a\u094d\u0930\u091c\u0928\u0928 \u0938\u094d\u0925\u093f\u0924\u093f',
      );

  String get conceived => _pick(
        en: 'Conceived',
        gu: '\u0a97\u0ab0\u0acd\u0aad\u0abe\u0aa7\u0abe\u0aa8 \u0aa5\u0aaf\u0ac1\u0a82',
        hi: '\u0917\u0930\u094d\u092d\u0927\u093e\u0930\u0923 \u0939\u0941\u0906',
      );

  String get notConceived => _pick(
        en: 'Not Conceived',
        gu: '\u0a97\u0ab0\u0acd\u0aad\u0abe\u0aa7\u0abe\u0aa8 \u0aa5\u0aaf\u0ac1\u0a82 \u0aa8\u0aa5\u0ac0',
        hi: '\u0917\u0930\u094d\u092d\u0927\u093e\u0930\u0923 \u0928\u0939\u0940\u0902 \u0939\u0941\u0906',
      );

  String get heatDate => _pick(
        en: 'Heat date',
        gu: '\u0ab9\u0ac0\u0a9f \u0aa4\u0abe\u0ab0\u0ac0\u0a96',
        hi: '\u0939\u0940\u091f \u0924\u093e\u0930\u0940\u0916',
      );

  String get selectHeatDate => _pick(
        en: 'Select heat date',
        gu: '\u0ab9\u0ac0\u0a9f \u0aa4\u0abe\u0ab0\u0ac0\u0a96 \u0aaa\u0ab8\u0a82\u0aa6 \u0a95\u0ab0\u0acb',
        hi: '\u0939\u0940\u091f \u0924\u093e\u0930\u0940\u0916 \u091a\u0941\u0928\u0947\u0902',
      );

  String get note => _pick(
        en: 'Note',
        gu: '\u0aa8\u0acb\u0a82\u0aa7',
        hi: '\u0928\u094b\u091f',
      );

  String get name => _pick(
        en: 'Name',
        gu: '\u0aa8\u0abe\u0aae',
        hi: '\u0928\u093e\u092e',
      );

  String get addAnyNotesOptional => _pick(
        en: 'Add any notes (optional)',
        gu: '\u0a95\u0acb\u0a88 \u0aa8\u0acb\u0a82\u0aa7 \u0a89\u0aae\u0ac7\u0ab0\u0acb (\u0ab5\u0ac8\u0a95\u0ab2\u0acd\u0aaa\u0abf\u0a95)',
        hi: '\u0915\u094b\u0908 \u0928\u094b\u091f \u091c\u094b\u095c\u0947\u0902 (\u0935\u0948\u0915\u0932\u094d\u092a\u093f\u0915)',
      );

  String get filter => _pick(
        en: 'Filter',
        gu: '\u0aab\u0abf\u0ab2\u0acd\u0a9f\u0ab0',
        hi: '\u092b\u093c\u093f\u0932\u094d\u091f\u0930',
      );

  String totalAnimals(int count) => _pick(
        en: 'Total $count Animals',
        gu: '\u0a95\u0ac1\u0ab2 $count \u0aaa\u0ab6\u0ac1',
        hi: '\u0915\u0941\u0932 $count \u092a\u0936\u0941',
      );

  String get addHeatRecord => _pick(
        en: 'Add Heat Record',
        gu: '\u0ab9\u0ac0\u0a9f \u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1 \u0a89\u0aae\u0ac7\u0ab0\u0acb',
        hi: '\u0939\u0940\u091f \u0930\u093f\u0915\u0949\u0930\u094d\u0921 \u091c\u094b\u095c\u0947\u0902',
      );

  String get dryOffDate => _pick(
        en: 'Dry Off Date',
        gu: '\u0aa1\u0acd\u0ab0\u0abe\u0aaf \u0a91\u0aab \u0aa4\u0abe\u0ab0\u0ac0\u0a96',
        hi: '\u0921\u094d\u0930\u093e\u0908 \u0911\u092b \u0924\u093e\u0930\u0940\u0916',
      );

  String get selectDryOffDate => _pick(
        en: 'Select dry off date',
        gu: '\u0aa1\u0acd\u0ab0\u0abe\u0aaf \u0a91\u0aab \u0aa4\u0abe\u0ab0\u0ac0\u0a96 \u0aaa\u0ab8\u0a82\u0aa6 \u0a95\u0ab0\u0acb',
        hi: '\u0921\u094d\u0930\u093e\u0908 \u0911\u092b \u0924\u093e\u0930\u0940\u0916 \u091a\u0941\u0928\u0947\u0902',
      );

  String get pregnant => _pick(
        en: 'Pregnant',
        gu: '\u0a97\u0ab0\u0acd\u0aad\u0ab5\u0aa4\u0ac0',
        hi: '\u0917\u0930\u094d\u092d\u0935\u0924\u0940',
      );

  String get emptyStatus => _pick(
        en: 'Empty',
        gu: '\u0a96\u0abe\u0ab2\u0ac0',
        hi: '\u0916\u093e\u0932\u0940',
      );

  String get serviceNotAvailable => _pick(
        en: 'Service not available',
        gu: '\u0ab8\u0ac7\u0ab5\u0abe \u0a89\u0aaa\u0ab2\u0aac\u0acd\u0aa7 \u0aa8\u0aa5\u0ac0',
        hi: '\u0938\u0947\u0935\u093e \u0909\u092a\u0932\u092c\u094d\u0927 \u0928\u0939\u0940\u0902 \u0939\u0948',
      );

  String get pleaseSelectCow => _pick(
        en: 'Please select a cow',
        gu: '\u0a95\u0ac3\u0aaa\u0abe \u0a95\u0ab0\u0ac0\u0aa8\u0ac7 \u0a97\u0abe\u0aaf \u0aaa\u0ab8\u0a82\u0aa6 \u0a95\u0ab0\u0acb',
        hi: '\u0915\u0943\u092a\u092f\u093e \u0917\u093e\u092f \u091a\u0941\u0928\u0947\u0902',
      );

  String get pleaseSelectHeatDate => _pick(
        en: 'Please select a heat date',
        gu: '\u0a95\u0ac3\u0aaa\u0abe \u0a95\u0ab0\u0ac0\u0aa8\u0ac7 \u0ab9\u0ac0\u0a9f \u0aa4\u0abe\u0ab0\u0ac0\u0a96 \u0aaa\u0ab8\u0a82\u0aa6 \u0a95\u0ab0\u0acb',
        hi: '\u0915\u0943\u092a\u092f\u093e \u0939\u0940\u091f \u0924\u093e\u0930\u0940\u0916 \u091a\u0941\u0928\u0947\u0902',
      );

  String get pleaseSelectDryOffDate => _pick(
        en: 'Please select a dry off date',
        gu: '\u0a95\u0ac3\u0aaa\u0abe \u0a95\u0ab0\u0ac0\u0aa8\u0ac7 \u0aa1\u0acd\u0ab0\u0abe\u0aaf \u0a91\u0aab \u0aa4\u0abe\u0ab0\u0ac0\u0a96 \u0aaa\u0ab8\u0a82\u0aa6 \u0a95\u0ab0\u0acb',
        hi: '\u0915\u0943\u092a\u092f\u093e \u0921\u094d\u0930\u093e\u0908 \u0911\u092b \u0924\u093e\u0930\u0940\u0916 \u091a\u0941\u0928\u0947\u0902',
      );

  String get to => _pick(
        en: 'to',
        gu: '\u0aa5\u0ac0',
        hi: '\u0938\u0947',
      );

  String get deleteRecord => _pick(
        en: 'Delete Record',
        gu: '\u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1 \u0aa1\u0abf\u0ab2\u0ac0\u0a9f \u0a95\u0ab0\u0acb',
        hi: '\u0930\u093f\u0915\u0949\u0930\u094d\u0921 \u0939\u091f\u093e\u090f\u0902',
      );

  String get cancel => _pick(
        en: 'Cancel',
        gu: '\u0ab0\u0aa6\u0acd\u0aa6 \u0a95\u0ab0\u0acb',
        hi: '\u0930\u0926\u094d\u0926 \u0915\u0930\u0947\u0902',
      );

  String get delete => _pick(
        en: 'Delete',
        gu: '\u0aa1\u0abf\u0ab2\u0ac0\u0a9f \u0a95\u0ab0\u0acb',
        hi: '\u0939\u091f\u093e\u090f\u0902',
      );

  String get deleteHeatRecordConfirmation => _pick(
        en: 'Are you sure you want to delete this heat record?',
        gu: '\u0ab6\u0ac1\u0a82 \u0aa4\u0aae\u0ac7 \u0a86 \u0ab9\u0ac0\u0a9f \u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1 \u0aa1\u0abf\u0ab2\u0ac0\u0a9f \u0a95\u0ab0\u0ab5\u0abe \u0aae\u0abe\u0a82\u0a97\u0acb \u0a9b\u0acb?',
        hi: '\u0915\u094d\u092f\u093e \u0906\u092a \u092f\u0939 \u0939\u0940\u091f \u0930\u093f\u0915\u0949\u0930\u094d\u0921 \u0939\u091f\u093e\u0928\u093e \u091a\u093e\u0939\u0924\u0947 \u0939\u0948\u0902?',
      );

  String get deleteDryOffRecordConfirmation => _pick(
        en: 'Are you sure you want to delete this dry off record?',
        gu: '\u0ab6\u0ac1\u0a82 \u0aa4\u0aae\u0ac7 \u0a86 \u0aa1\u0acd\u0ab0\u0abe\u0aaf \u0a91\u0aab \u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1 \u0aa1\u0abf\u0ab2\u0ac0\u0a9f \u0a95\u0ab0\u0ab5\u0abe \u0aae\u0abe\u0a82\u0a97\u0acb \u0a9b\u0acb?',
        hi: '\u0915\u094d\u092f\u093e \u0906\u092a \u092f\u0939 \u0921\u094d\u0930\u093e\u0908 \u0911\u092b \u0930\u093f\u0915\u0949\u0930\u094d\u0921 \u0939\u091f\u093e\u0928\u093e \u091a\u093e\u0939\u0924\u0947 \u0939\u0948\u0902?',
      );

  String get heatRecordDeletedSuccessfully => _pick(
        en: 'Heat record deleted successfully',
        gu: '\u0ab9\u0ac0\u0a9f \u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1 \u0ab8\u0aab\u0ab3\u0aa4\u0abe\u0aaa\u0ac2\u0ab0\u0acd\u0ab5\u0a95 \u0aa1\u0abf\u0ab2\u0ac0\u0a9f \u0aa5\u0aaf\u0acb',
        hi: '\u0939\u0940\u091f \u0930\u093f\u0915\u0949\u0930\u094d\u0921 \u0938\u092b\u0932\u0924\u093e\u092a\u0942\u0930\u094d\u0935\u0915 \u0939\u091f \u0917\u092f\u093e',
      );

  String deletionFailed(String error) => _pick(
        en: 'Deletion failed: $error',
        gu: '\u0aa1\u0abf\u0ab2\u0ac0\u0a9f \u0aa8\u0abf\u0ab7\u0acd\u0aab\u0ab3: $error',
        hi: '\u0939\u091f\u093e\u0928\u093e \u092e\u0947\u0902 \u0935\u093f\u092b\u0932: $error',
      );

  String get dryOffRecordDeletedSuccessfully => _pick(
        en: 'Dry off record deleted successfully',
        gu: '\u0aa1\u0acd\u0ab0\u0abe\u0aaf \u0a91\u0aab \u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1 \u0ab8\u0aab\u0ab3\u0aa4\u0abe\u0aaa\u0ac2\u0ab0\u0acd\u0ab5\u0a95 \u0aa1\u0abf\u0ab2\u0ac0\u0a9f \u0aa5\u0aaf\u0acb',
        hi: '\u0921\u094d\u0930\u093e\u0908 \u0911\u092b \u0930\u093f\u0915\u0949\u0930\u094d\u0921 \u0938\u092b\u0932\u0924\u093e\u092a\u0942\u0930\u094d\u0935\u0915 \u0939\u091f \u0917\u092f\u093e',
      );

  String get dryOffRecordAddedSuccessfully => _pick(
        en: 'Dry off record added successfully',
        gu: '\u0aa1\u0acd\u0ab0\u0abe\u0aaf \u0a91\u0aab \u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1 \u0ab8\u0aab\u0ab3\u0aa4\u0abe\u0aaa\u0ac2\u0ab0\u0acd\u0ab5\u0a95 \u0a89\u0aae\u0ac7\u0ab0\u0abe\u0aaf\u0acb',
        hi: '\u0921\u094d\u0930\u093e\u0908 \u0911\u092b \u0930\u093f\u0915\u0949\u0930\u094d\u0921 \u0938\u092b\u0932\u0924\u093e\u092a\u0942\u0930\u094d\u0935\u0915 \u091c\u094b\u095c\u093e \u0917\u092f\u093e',
      );

  String get dryOffRecordUpdatedSuccessfully => _pick(
        en: 'Dry off record updated successfully',
        gu: '\u0aa1\u0acd\u0ab0\u0abe\u0aaf \u0a91\u0aab \u0ab0\u0ac7\u0a95\u0acb\u0ab0\u0acd\u0aa1 \u0ab8\u0aab\u0ab3\u0aa4\u0abe\u0aaa\u0ac2\u0ab0\u0acd\u0ab5\u0a95 \u0a85\u0aaa\u0aa1\u0ac7\u0a9f \u0aa5\u0aaf\u0acb',
        hi: '\u0921\u094d\u0930\u093e\u0908 \u0911\u092b \u0930\u093f\u0915\u0949\u0930\u094d\u0921 \u0938\u092b\u0932\u0924\u093e\u092a\u0942\u0930\u094d\u0935\u0915 \u0905\u092a\u0921\u0947\u091f \u0939\u0941\u0906',
      );

  String get tagNo => _pick(
        en: 'Tag No.',
        gu: '\u0a9f\u0ac7\u0a97 \u0aa8\u0a82.',
        hi: '\u091f\u0948\u0917 \u0928\u0902.',
      );

  String get numberShort => _pick(
        en: 'No.',
        gu: '\u0aa8\u0a82.',
        hi: '\u0928\u0902.',
      );

  String get addVaccine => _pick(
        en: 'Add Vaccine',
        gu: '\u0ab0\u0ab8\u0ac0 \u0a89\u0aae\u0ac7\u0ab0\u0acb',
        hi: '\u091f\u0940\u0915\u093e \u091c\u094b\u095c\u0947\u0902',
      );
}
