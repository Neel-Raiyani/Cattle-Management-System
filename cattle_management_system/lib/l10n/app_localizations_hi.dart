// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'स्मार्ट गौशाला';

  @override
  String get userGreeting => 'स्वागत है';

  @override
  String get loginSubtitle =>
      'स्मार्ट गौशाला में लॉग इन करें और गौ सेवा और दैनिक गौशाला गतिविधियों से जुड़े रहें।';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get mobileHint => 'अपना मोबाइल नंबर दर्ज करें';

  @override
  String get password => 'पासवर्ड';

  @override
  String get passwordHint => 'अपना पासवर्ड डालें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get registerGaushala => 'अपनी गौशाला रजिस्टर करें';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get languageEnglish => 'अंग्रेजी';

  @override
  String get languageGujarati => 'गुजराती';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get registerTitle => 'गौशाला रजिस्टर करें';

  @override
  String get gaushalaName => 'गौशाला का नाम';

  @override
  String get gaushalaNameHint => 'गौशाला का नाम दर्ज करें';

  @override
  String get address => 'पता';

  @override
  String get addressHint => 'पता दर्ज करें';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get confirmPasswordHint => 'पासवर्ड दोबारा दर्ज करें';

  @override
  String get alreadyHaveAccount => 'क्या पहले से खाता है?';

  @override
  String get registerSuccess => 'पंजीकरण सफल! कृपया लॉगिन करें।';

  @override
  String get registerError => 'पंजीकरण विफल। पुनः प्रयास करें।';

  @override
  String get userExists => 'उपयोगकर्ता पहले से मौजूद है!';

  @override
  String get passwordMismatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get labelName => 'Name / નામ / नाम';

  @override
  String get hintName => 'अपना नाम दर्ज करें';

  @override
  String get labelMobileTrilingual => 'Mobile no. / મોબાઈલ નં. / मोबाइल नं.';

  @override
  String get hintMobileTrilingual => 'अपना मोबाइल नंबर दर्ज करें';

  @override
  String get labelCity => 'City / ગામ / गाँव';

  @override
  String get hintCity => 'अपने शहर का नाम चुनें';

  @override
  String get labelGaushalaTrilingual =>
      'Gaushala name / ગૌશાળા નું નામ / गौशाला का नाम';

  @override
  String get hintGaushalaTrilingual => 'गौशाला का नाम दर्ज करें';

  @override
  String get labelCow => 'Total cow / કુલ ગાય / कुल गाय';

  @override
  String get hintCow => 'कुल गायें दर्ज करें';

  @override
  String get submit => 'सबमिट करें';

  @override
  String get joinTitle => 'स्मार्ट गौशाला से जुड़ें';

  @override
  String get joinSubtitle =>
      'अपना स्मार्ट गौशाला खाता बनाएं और गौ सेवा का हिस्सा बनें।';

  @override
  String get changePasswordTitle => 'पासवर्ड बदलें?';

  @override
  String get changePasswordSubtitle =>
      'अपना खाता सुरक्षित रखने के लिए अपना पासवर्ड अपडेट करें।';

  @override
  String get labelOldPass => 'पुराना पासवर्ड';

  @override
  String get hintOldPass => 'अपना पुराना पासवर्ड दर्ज करें';

  @override
  String get labelNewPass => 'नया पासवर्ड';

  @override
  String get hintNewPass => 'नया पासवर्ड दर्ज करें';

  @override
  String get labelConfirmPass => 'पासवर्ड की पुष्टि करें';

  @override
  String get hintConfirmPass => 'पासवर्ड की पुष्टि करें';

  @override
  String get btnChangePassword => 'पासवर्ड बदलें';

  @override
  String get forgotPasswordSubtitle =>
      'मोबाइल नंबर दर्ज करें और हम इसे रीसेट करने में आपकी सहायता करेंगे।';

  @override
  String get verifyPhoneTitle => 'अपना फोन नंबर सत्यापित करें';

  @override
  String get verifyPhoneSubtitle =>
      'हमने आपके फोन नंबर पर एक वन-टाइम कोड भेजा है।';

  @override
  String get enterOtp => 'OTP दर्ज करें';

  @override
  String otpSentTo(Object mobile) {
    return '$mobile पर OTP भेजा गया';
  }

  @override
  String get didntGetIt => 'नहीं मिला?';

  @override
  String get resend => 'पुनः भेजें';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get createPasswordTitle => 'नया पासवर्ड बनाएं';

  @override
  String get createPasswordSubtitle =>
      'अपना खाता सुरक्षित रखने के लिए एक नया पासवर्ड चुनें।';

  @override
  String get confirmNewPassword => 'नए पासवर्ड की पुष्टि करें';

  @override
  String get youreAllSet => 'आप बिल्कुल तैयार हैं!';

  @override
  String get passwordUpdated =>
      'आपका पासवर्ड अपडेट कर दिया गया है। अब आप अपने नए पासवर्ड के साथ साइन इन कर सकते हैं।';

  @override
  String get menuHome => 'होम';

  @override
  String get menuChangePassword => 'पासवर्ड बदलें';

  @override
  String get menuChangeLanguage => 'भाषा बदलें';

  @override
  String get menuPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get menuShareApp => 'ऐप साझा करें';

  @override
  String get menuLogout => 'लॉगआउट';

  @override
  String get menuUser => 'उपयोगकर्ता';

  @override
  String get menuCowGroup => 'गाय समूह';

  @override
  String get menuAIBull => 'AI सांड';

  @override
  String get menuAnimalLeft => 'गौशाला से छोड़े गए पशु';

  @override
  String get menuDistribution => 'वितरण शीर्षक';

  @override
  String get menuMyPost => 'मेरी पोस्ट';

  @override
  String get menuAboutDevelopers => 'डेवलपर्स के बारे में';

  @override
  String get menuAboutGaushala => 'गौशाला के बारे में';

  @override
  String get menuGuidance => 'मार्गदर्शन';

  @override
  String get menuFeedback => 'प्रतिक्रिया';

  @override
  String get menuContactUs => 'हमसे संपर्क करें';

  @override
  String get sectionAccount => 'खाता';

  @override
  String get sectionSettings => 'सेटिंग्स';

  @override
  String get sectionAboutUs => 'हमारे बारे में';

  @override
  String get titleUserList => 'उपयोगकर्ता सूची';

  @override
  String get titleAddUser => 'उपयोगकर्ता जोड़ें';

  @override
  String get titleEditUser => 'उपयोगकर्ता संपादित करें';

  @override
  String get labelEmail => 'ईमेल';

  @override
  String get hintEmail => 'ईमेल दर्ज करें';

  @override
  String get noDataFound => 'कोई डेटा नहीं मिला';

  @override
  String get btnSave => 'सहेजें';

  @override
  String get titleCowList => 'गाय';

  @override
  String get lblAllCows => 'सभी गायें';

  @override
  String get lblLactating => 'दुधारू';

  @override
  String get lblHeifer => 'बछिया';

  @override
  String get lblPregnant => 'गर्भवती';

  @override
  String get lblDryOff => 'सूखा';

  @override
  String get lblRetiredCow => 'सेवानिवृत्त गाय';

  @override
  String lblTotalCow(Object count) {
    return 'कुल $count गाय';
  }

  @override
  String get lblTagNo => 'टैग सं.';

  @override
  String get lblNo => 'सं.';

  @override
  String get lblBirthday => 'जन्मदिन';

  @override
  String get lblAge => 'आयु';

  @override
  String get lblParity => 'व्यांत';

  @override
  String get lblParityMilk => 'दैनिक दूध';

  @override
  String get lblLastDelivery => 'अंतिम प्रसव';

  @override
  String get btnAddNewCow => 'नई गाय जोड़ें';

  @override
  String get menuOpen => 'खोलें';

  @override
  String get menuShare => 'साझा करें';

  @override
  String get lblDetailNotAvailable => 'विवरण उपलब्ध नहीं है';

  @override
  String get unitLPerDay => 'ली/दिन';
}
