import 'package:flutter/material.dart';

extension AppTextX on BuildContext {
  _AppText get tr => _AppText(Localizations.localeOf(this).languageCode);
}

class _AppText {
  const _AppText(this.languageCode);

  final String languageCode;

  bool get _isHindi => languageCode == 'hi';
  bool get _isGujarati => languageCode == 'gu';

  String get retry => _pick(
        en: 'Retry',
        hi: 'फिर से प्रयास करें',
        gu: 'ફરી પ્રયાસ કરો',
      );

  String get cancel => _pick(
        en: 'Cancel',
        hi: 'रद्द करें',
        gu: 'રદ કરો',
      );

  String get delete => _pick(
        en: 'Delete',
        hi: 'डिलीट करें',
        gu: 'ડિલીટ કરો',
      );

  String get searchHere => _pick(
        en: 'Search here...',
        hi: 'यहाँ खोजें...',
        gu: 'અહીં શોધો...',
      );

  String get searchSomething => _pick(
        en: 'Search something...',
        hi: 'कुछ खोजें...',
        gu: 'કંઈક શોધો...',
      );

  String get searchByNameOrTag => _pick(
        en: 'Search by name or tag...',
        hi: 'नाम या टैग से खोजें...',
        gu: 'નામ અથવા ટેગથી શોધો...',
      );

  String get searchByCowNameOrTag => _pick(
        en: 'Search by cow name or tag...',
        hi: 'गाय के नाम या टैग से खोजें...',
        gu: 'ગાયના નામ અથવા ટેગથી શોધો...',
      );

  String get noDataFound => _pick(
        en: 'No data found',
        hi: 'कोई डेटा नहीं मिला',
        gu: 'કોઈ ડેટા મળ્યો નથી',
      );

  String get noRecordsFound => _pick(
        en: 'No records found',
        hi: 'कोई रिकॉर्ड नहीं मिला',
        gu: 'કોઈ રેકોર્ડ મળ્યા નથી',
      );

  String get deleteRecord => _pick(
        en: 'Delete Record',
        hi: 'रिकॉर्ड डिलीट करें',
        gu: 'રેકોર્ડ ડિલીટ કરો',
      );

  String get deleteRecordConfirmation => _pick(
        en: 'Are you sure you want to delete this record?',
        hi: 'क्या आप वाकई इस रिकॉर्ड को डिलीट करना चाहते हैं?',
        gu: 'શું તમે ખરેખર આ રેકોર્ડ ડિલીટ કરવા માંગો છો?',
      );

  String get deleteConceptionRecordConfirmation => _pick(
        en: 'Are you sure you want to delete this conception record?',
        hi: 'क्या आप वाकई इस गर्भाधान रिकॉर्ड को डिलीट करना चाहते हैं?',
        gu: 'શું તમે ખરેખર આ ગર્ભાધાન રેકોર્ડ ડિલીટ કરવા માંગો છો?',
      );

  String get serviceNotAvailable => _pick(
        en: 'Service not available',
        hi: 'सेवा उपलब्ध नहीं है',
        gu: 'સેવા ઉપલબ્ધ નથી',
      );

  String get report => _pick(
        en: 'Report',
        hi: 'रिपोर्ट',
        gu: 'રિપોર્ટ',
      );

  String get cowReport => _pick(
        en: 'Cow Report',
        hi: 'गाय रिपोर्ट',
        gu: 'ગાય રિપોર્ટ',
      );

  String get bullReport => _pick(
        en: 'Bull Report',
        hi: 'सांड रिपोर्ट',
        gu: 'બળદ રિપોર્ટ',
      );

  String get milkReport => _pick(
        en: 'Milk Report',
        hi: 'दूध रिपोर्ट',
        gu: 'દૂધ રિપોર્ટ',
      );

  String get heatRecordReport => _pick(
        en: 'Heat Record Report',
        hi: 'हीट रिकॉर्ड रिपोर्ट',
        gu: 'હીટ રેકોર્ડ રિપોર્ટ',
      );

  String get pregnancyReport => _pick(
        en: 'Pregnancy Report',
        hi: 'गर्भावस्था रिपोर्ट',
        gu: 'ગર્ભાવસ્થા રિપોર્ટ',
      );

  String get dewormingReport => _pick(
        en: 'Deworming Report',
        hi: 'डीवॉर्मिंग रिपोर्ट',
        gu: 'ડીવોર્મિંગ રિપોર્ટ',
      );

  String get medicalReport => _pick(
        en: 'Medical Report',
        hi: 'मेडिकल रिपोर्ट',
        gu: 'મેડિકલ રિપોર્ટ',
      );

  String get vaccinationReport => _pick(
        en: 'Vaccination Report',
        hi: 'टीकाकरण रिपोर्ट',
        gu: 'રસીકરણ રિપોર્ટ',
      );

  String get labTestingReport => _pick(
        en: 'Lab Testing Report',
        hi: 'लैब टेस्ट रिपोर्ट',
        gu: 'લેબ ટેસ્ટ રિપોર્ટ',
      );

  String comingSoon(String name) => _pick(
        en: '$name - Coming soon!',
        hi: '$name - जल्द आ रहा है!',
        gu: '$name - જલ્દી આવશે!',
      );

  String total(int count) => _pick(
        en: 'Total: $count',
        hi: 'कुल: $count',
        gu: 'કુલ: $count',
      );

  String addRecord(String recordType) => _pick(
        en: 'Add ${recordTypeLabel(recordType)}',
        hi: '${recordTypeLabel(recordType)} जोड़ें',
        gu: '${recordTypeLabel(recordType)} ઉમેરો',
      );

  String addRecordTitle(String recordType) => _pick(
        en: 'Add ${recordTypeLabel(recordType)} Record',
        hi: '${recordTypeLabel(recordType)} रिकॉर्ड जोड़ें',
        gu: '${recordTypeLabel(recordType)} રેકોર્ડ ઉમેરો',
      );

  String recordTypeLabel(String recordType) {
    switch (recordType) {
      case 'Sell':
        return _pick(en: 'Sell', hi: 'बिक्री', gu: 'વેચાણ');
      case 'Death':
        return _pick(en: 'Death', hi: 'मृत्यु', gu: 'મૃત્યુ');
      case 'Donation':
        return _pick(en: 'Donation', hi: 'दान', gu: 'દાન');
      default:
        return recordType;
    }
  }

  String recordDateLabel(String recordType) => _pick(
        en: '${recordTypeLabel(recordType)} Date',
        hi: '${recordTypeLabel(recordType)} तिथि',
        gu: '${recordTypeLabel(recordType)} તારીખ',
      );

  String get pleaseSelectCow => _pick(
        en: 'Please select a cow',
        hi: 'कृपया एक गाय चुनें',
        gu: 'કૃપા કરીને એક ગાય પસંદ કરો',
      );

  String get pleaseSelectDate => _pick(
        en: 'Please select a date',
        hi: 'कृपया एक तारीख चुनें',
        gu: 'કૃપા કરીને તારીખ પસંદ કરો',
      );

  String get cow => _pick(
        en: 'Cow',
        hi: 'गाय',
        gu: 'ગાય',
      );

  String get selectCowName => _pick(
        en: 'Select cow name',
        hi: 'गाय का नाम चुनें',
        gu: 'ગાયનું નામ પસંદ કરો',
      );

  String get selectDate => _pick(
        en: 'Select date',
        hi: 'तारीख चुनें',
        gu: 'તારીખ પસંદ કરો',
      );

  String get buyerName => _pick(
        en: 'Buyer Name',
        hi: 'खरीदार का नाम',
        gu: 'ખરીદદારનું નામ',
      );

  String get enterBuyerName => _pick(
        en: 'Enter buyer name',
        hi: 'खरीदार का नाम दर्ज करें',
        gu: 'ખરીદદારનું નામ દાખલ કરો',
      );

  String get donatedTo => _pick(
        en: 'Donated To',
        hi: 'दान दिया गया',
        gu: 'દાન આપવામાં આવ્યું',
      );

  String get enterDoneeTrustName => _pick(
        en: 'Enter donee / trust name',
        hi: 'प्राप्तकर्ता / ट्रस्ट का नाम दर्ज करें',
        gu: 'પ્રાપ્તકર્તા / ટ્રસ્ટનું નામ દાખલ કરો',
      );

  String get amountRupees => _pick(
        en: 'Amount (Rs.)',
        hi: 'राशि (रु.)',
        gu: 'રકમ (રૂ.)',
      );

  String get enterSaleAmount => _pick(
        en: 'Enter sale amount',
        hi: 'बिक्री राशि दर्ज करें',
        gu: 'વેચાણ રકમ દાખલ કરો',
      );

  String get causeOfDeath => _pick(
        en: 'Cause of Death',
        hi: 'मृत्यु का कारण',
        gu: 'મૃત્યુનું કારણ',
      );

  String get enterCauseOfDeath => _pick(
        en: 'Enter cause of death',
        hi: 'मृत्यु का कारण दर्ज करें',
        gu: 'મૃત્યુનું કારણ દાખલ કરો',
      );

  String get noteOptional => _pick(
        en: 'Note (optional)',
        hi: 'नोट (वैकल्पिक)',
        gu: 'નોંધ (વૈકલ્પિક)',
      );

  String get addAnyAdditionalNotes => _pick(
        en: 'Add any additional notes...',
        hi: 'कोई अतिरिक्त नोट जोड़ें...',
        gu: 'કોઈ વધારાની નોંધ ઉમેરો...',
      );

  String get conception => _pick(
        en: 'Conception',
        hi: 'गर्भाधान',
        gu: 'ગર્ભાધાન',
      );

  String get allCows => _pick(
        en: 'All Cows',
        hi: 'सभी गायें',
        gu: 'બધી ગાયો',
      );

  String get pregnancyCheckPending => _pick(
        en: 'Pregnancy check pending',
        hi: 'गर्भ जांच लंबित',
        gu: 'ગર્ભ તપાસ બાકી',
      );

  String get pregnant => _pick(
        en: 'Pregnant',
        hi: 'गर्भवती',
        gu: 'ગર્ભવતી',
      );

  String get dryOff => _pick(
        en: 'Dry Off',
        hi: 'ड्राई ऑफ',
        gu: 'ડ્રાય ઑફ',
      );

  String get expectedDeliveryPending => _pick(
        en: 'Expected Delivery Pending',
        hi: 'अपेक्षित डिलीवरी लंबित',
        gu: 'અપેક્ષિત ડિલિવરી બાકી',
      );

  String get addPregnancy => _pick(
        en: 'Add Pregnancy',
        hi: 'गर्भावस्था जोड़ें',
        gu: 'ગર્ભાવસ્થા ઉમેરો',
      );

  String get allBull => _pick(
        en: 'All Bull',
        hi: 'सभी सांड',
        gu: 'બધા બળદ',
      );

  String get bull => _pick(
        en: 'Bull',
        hi: 'सांड',
        gu: 'બળદ',
      );

  String get bullCalf => _pick(
        en: 'Bull Calf',
        hi: 'बछड़ा',
        gu: 'બળદનું બચ્ચું',
      );

  String get retiredBull => _pick(
        en: 'Retired Bull',
        hi: 'सेवानिवृत्त सांड',
        gu: 'નિવૃત્ત બળદ',
      );

  String totalBullCount(int count) => _pick(
        en: 'Total $count Bull',
        hi: 'कुल $count सांड',
        gu: 'કુલ $count બળદ',
      );

  String get addNewBull => _pick(
        en: 'Add New Bull',
        hi: 'नया सांड जोड़ें',
        gu: 'નવો બળદ ઉમેરો',
      );

  String get open => _pick(
        en: 'Open',
        hi: 'खोलें',
        gu: 'ખોલો',
      );

  String get share => _pick(
        en: 'Share',
        hi: 'शेयर करें',
        gu: 'શેર કરો',
      );

  String get unknownCow => _pick(
        en: 'Unknown Cow',
        hi: 'अज्ञात गाय',
        gu: 'અજ્ઞાત ગાય',
      );

  String get tagNo => _pick(
        en: 'Tag No.',
        hi: 'टैग नं.',
        gu: 'ટેગ નં.',
      );

  String get numberShort => _pick(
        en: 'No.',
        hi: 'नं.',
        gu: 'નં.',
      );

  String get checkPending => _pick(
        en: 'Check Pending',
        hi: 'जांच लंबित',
        gu: 'તપાસ બાકી',
      );

  String get buyer => _pick(
        en: 'Buyer',
        hi: 'खरीदार',
        gu: 'ખરીદદાર',
      );

  String get amount => _pick(
        en: 'Amount',
        hi: 'राशि',
        gu: 'રકમ',
      );

  String get cause => _pick(
        en: 'Cause',
        hi: 'कारण',
        gu: 'કારણ',
      );

  String get note => _pick(
        en: 'Note',
        hi: 'नोट',
        gu: 'નોંધ',
      );

  String get soldTo => _pick(
        en: 'Sold To',
        hi: 'बेचा गया',
        gu: 'વેચાયું',
      );

  String get pregnancyCheckPendingTitle => _pick(
        en: 'Pregnancy Check Pending',
        hi: 'गर्भ जांच लंबित',
        gu: 'ગર્ભ તપાસ બાકી',
      );

  String _pick({
    required String en,
    required String hi,
    required String gu,
  }) {
    if (_isHindi) return hi;
    if (_isGujarati) return gu;
    return en;
  }
}
