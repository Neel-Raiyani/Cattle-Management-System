// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appName => 'Smart Gaushala';

  @override
  String get userGreeting => 'સ્વાગત છે';

  @override
  String get loginSubtitle =>
      'Smart Gaushala માં લોગિન કરો અને ગૌ સેવા અને દૈનિક ગૌશાળા પ્રવૃત્તિઓ સાથે જોડાયેલા રહો.';

  @override
  String get mobileNumber => 'મોબાઈલ નંબર';

  @override
  String get mobileHint => 'તમારો મોબાઈલ નંબર દાખલ કરો';

  @override
  String get password => 'પાસવર્ડ';

  @override
  String get passwordHint => 'તમારો પાસવર્ડ દાખલ કરો';

  @override
  String get forgotPassword => 'પાસવર્ડ ભૂલી ગયા છો?';

  @override
  String get signIn => 'લોગ ઇન કરો';

  @override
  String get registerGaushala => 'તમારી ગૌશાળા રજીસ્ટર કરો';

  @override
  String get selectLanguage => 'ભાષા પસંદ કરો';

  @override
  String get continueButton => 'ચાલુ રાખો';

  @override
  String get languageEnglish => 'અંગ્રેજી';

  @override
  String get languageGujarati => 'ગુજરાતી';

  @override
  String get languageHindi => 'હિન્દી';

  @override
  String get registerTitle => 'ગૌશાળા રજીસ્ટર કરો';

  @override
  String get gaushalaName => 'ગૌશાળાનું નામ';

  @override
  String get gaushalaNameHint => 'ગૌશાળાનું નામ દાખલ કરો';

  @override
  String get address => 'સરનામું';

  @override
  String get addressHint => 'સરનામું દાખલ કરો';

  @override
  String get confirmPassword => 'પાસવર્ડની પુષ્ટિ કરો';

  @override
  String get confirmPasswordHint => 'પાસવર્ડ ફરીથી દાખલ કરો';

  @override
  String get alreadyHaveAccount => 'શું પહેલેથી જ ખાતું છે?';

  @override
  String get registerSuccess => 'નોંધણી સફળ! કૃપા કરીને લોગિન કરો.';

  @override
  String get registerError => 'નોંધણી નિષ્ફળ. ફરી પ્રયાસ કરો.';

  @override
  String get userExists => 'વપરાશકર્તા પહેલાથી અસ્તિત્વમાં છે!';

  @override
  String get passwordMismatch => 'પાસવર્ડ મેચ નથી થતા';

  @override
  String get labelName => 'Name / નામ / नाम';

  @override
  String get hintName => 'તમારું નામ દાખલ કરો';

  @override
  String get labelMobileTrilingual => 'Mobile no. / મોબાઈલ નં. / मोबाइल नं.';

  @override
  String get hintMobileTrilingual => 'તમારો મોબાઈલ નંબર દાખલ કરો';

  @override
  String get labelCity => 'City / ગામ / गाँव';

  @override
  String get hintCity => 'તમારા શહેરનું નામ પસંદ કરો';

  @override
  String get labelGaushalaTrilingual =>
      'Gaushala name / ગૌશાળા નું નામ / गौशाला का नाम';

  @override
  String get hintGaushalaTrilingual => 'ગૌશાળાનું નામ દાખલ કરો';

  @override
  String get labelCow => 'Total cow / કુલ ગાય / कुल गाय';

  @override
  String get hintCow => 'કુલ ગાય દાખલ કરો';

  @override
  String get submit => 'સબમિટ કરો';

  @override
  String get joinTitle => 'Smart Gaushala માં જોડાઓ';

  @override
  String get joinSubtitle =>
      'તમારું Smart Gaushala એકાઉન્ટ બનાવો અને ગૌ સેવાનો ભાગ બનો.';

  @override
  String get changePasswordTitle => 'પાસવર્ડ બદલો?';

  @override
  String get changePasswordSubtitle =>
      'તમારું એકાઉન્ટ સુરક્ષિત રાખવા માટે તમારો પાસવર્ડ બદલો.';

  @override
  String get labelOldPass => 'જૂનો પાસવર્ડ';

  @override
  String get hintOldPass => 'તમારો જૂનો પાસવર્ડ દાખલ કરો';

  @override
  String get labelNewPass => 'નવો પાસવર્ડ';

  @override
  String get hintNewPass => 'તમારો નવો પાસવર્ડ દાખલ કરો';

  @override
  String get labelConfirmPass => 'પાસવર્ડની પુષ્ટિ કરો';

  @override
  String get hintConfirmPass => 'તમારો પાસવર્ડ ફરીથી દાખલ કરો';

  @override
  String get btnChangePassword => 'પાસવર્ડ બદલો';

  @override
  String get forgotPasswordSubtitle =>
      'મોબાઇલ નંબર દાખલ કરો અને અમે તેને રીસેટ કરવામાં મદદ કરીશું.';

  @override
  String get verifyPhoneTitle => 'તમારો ફોન નંબર ચકાસો';

  @override
  String get verifyPhoneSubtitle =>
      'અમે તમારા ફોન નંબર પર એક વન-ટાઇમ કોડ મોકલ્યો છે.';

  @override
  String get enterOtp => 'OTP દાખલ કરો';

  @override
  String otpSentTo(Object mobile) {
    return '$mobile પર OTP મોકલેલ છે';
  }

  @override
  String get didntGetIt => 'ન મળ્યું?';

  @override
  String get resend => 'ફરી મોકલો';

  @override
  String get verify => 'ચકાસો';

  @override
  String get createPasswordTitle => 'નવો પાસવર્ડ બનાવો';

  @override
  String get createPasswordSubtitle =>
      'તમારું એકાઉન્ટ સુરક્ષિત રાખવા માટે નવો પાસવર્ડ પસંદ કરો.';

  @override
  String get confirmNewPassword => 'નવા પાસવર્ડની પુષ્ટિ કરો';

  @override
  String get youreAllSet => 'તમે તૈયાર છો!';

  @override
  String get passwordUpdated =>
      'તમારો પાસવર્ડ અપડેટ કરવામાં આવ્યો છે. હવે તમે તમારા નવા પાસવર્ડ સાથે સાઇન ઇન કરી શકો છો.';

  @override
  String get menuHome => 'હોમ';

  @override
  String get menuChangePassword => 'પાસવર્ડ બદલો';

  @override
  String get menuChangeLanguage => 'ભાષા બદલો';

  @override
  String get menuPrivacyPolicy => 'ગોપનીયતા નીતિ';

  @override
  String get menuShareApp => 'એપ્લિકેશન શેર કરો';

  @override
  String get menuLogout => 'લોગ આઉટ';

  @override
  String get menuUser => 'વપરાશકર્તા';

  @override
  String get menuCowGroup => 'ગાય જૂથ';

  @override
  String get menuAIBull => 'AI બળદ';

  @override
  String get menuAnimalLeft => 'ગૌશાળા છોડેલા પ્રાણીઓ';

  @override
  String get menuDistribution => 'વિતરણ શીર્ષક';

  @override
  String get menuMyPost => 'મારી પોસ્ટ';

  @override
  String get menuAboutDevelopers => 'ડેવલપર્સ વિશે';

  @override
  String get menuAboutGaushala => 'ગૌશાળા વિશે';

  @override
  String get menuGuidance => 'માર્ગદર્શન';

  @override
  String get menuFeedback => 'પ્રતિસાદ';

  @override
  String get menuContactUs => 'અમારો સંપર્ક કરો';

  @override
  String get sectionAccount => 'એકાઉન્ટ';

  @override
  String get sectionSettings => 'સેટિંગ્સ';

  @override
  String get sectionAboutUs => 'અમારા વિશે';

  @override
  String get titleUserList => 'વપરાશકર્તા સૂચિ';

  @override
  String get titleAddUser => 'વપરાશકર્તા ઉમેરો';

  @override
  String get titleEditUser => 'વપરાશકર્તા સંપાદિત કરો';

  @override
  String get labelEmail => 'ઇમેઇલ';

  @override
  String get hintEmail => 'તમારું ઇમેઇલ દાખલ કરો';

  @override
  String get noDataFound => 'કોઈ ડેટા મળ્યો નથી';

  @override
  String get btnSave => 'સાચવો';

  @override
  String get titleCowList => 'ગાય';

  @override
  String get lblAllCows => 'બધી ગાયો';

  @override
  String get lblLactating => 'દૂધ આપતી';

  @override
  String get lblCalf => 'વાછરડી';

  @override
  String get lblHeifer => 'પાડી';

  @override
  String get lblPregnant => 'ગાભણ';

  @override
  String get lblDryOff => 'વસૂકી ગયેલી';

  @override
  String get lblRetiredCow => 'નિવૃત્ત ગાય';

  @override
  String lblTotalCow(Object count) {
    return 'કુલ $count ગાય';
  }

  @override
  String get lblTagNo => 'ટેગ નં.';

  @override
  String get lblNo => 'નં.';

  @override
  String get lblBirthday => 'જન્મ તારીખ';

  @override
  String get lblAge => 'ઉંમર';

  @override
  String get lblParity => 'વ્યાતર';

  @override
  String get lblParityMilk => 'દૈનિક દૂધ';

  @override
  String get lblLastDelivery => 'છેલ્લી ડિલિવરી';

  @override
  String get btnAddNewCow => 'નવી ગાય ઉમેરો';

  @override
  String get menuOpen => 'ખોલો';

  @override
  String get menuShare => 'શેર કરો';

  @override
  String get lblDetailNotAvailable => 'વિગત ઉપલબ્ધ નથી';

  @override
  String get unitLPerDay => 'લિટર/દિવસ';

  @override
  String get loggingIn => 'લૉગ ઇન થઈ રહ્યું છે';

  @override
  String get addCowDetails => 'ગાય વિગત ઉમેરો';

  @override
  String get hintParity => 'ગાયનો વ્યાતર દાખલ કરો';

  @override
  String get lblHandicapped => 'અપંગ';

  @override
  String get lblProblem => 'સમસ્યા શું છે?';

  @override
  String get lblBirthDate => 'જન્મ તારીખ';

  @override
  String get lblAdultDate => 'પ્રૌઢ તારીખ';

  @override
  String get hintSelectDate => 'તારીખ પસંદ કરો';

  @override
  String get lblUdderClosed => 'જો ગાયનું કોઈ આઉ બંધ હોય, તો આઉ પર ક્લિક કરો';

  @override
  String get lblSourceOfAcquisition => 'પ્રાપ્તિ સ્ત્રોત';

  @override
  String get optionBirth => 'જન્મ';

  @override
  String get optionDonation => 'દાન';

  @override
  String get optionPurchase => 'ખરીદી';

  @override
  String get lblMotherName => 'માતાનું નામ';

  @override
  String get lblFatherName => 'પિતાનું નામ';

  @override
  String get hintSelectMother => 'માં પસંદ કરો';

  @override
  String get hintSelectFather => 'પિતા પસંદ કરો';

  @override
  String get lblCowType => 'ગાયનો પ્રકાર';

  @override
  String get lblCowGroup => 'ગાય જૂથ';

  @override
  String get lblCowName => 'ગાયનું નામ';

  @override
  String get lblAnimalNumber => 'પ્રાણી નંબર';

  @override
  String get lblDeletePhoto => 'ફોટો કાઢો';

  @override
  String get lblNoPhotoSelected => 'કોઈ ફોટો પસંદ નથી';

  @override
  String get lblNoCowsAvailable => 'કોઈ ગાય ઉપલબ્ધ નથી';

  @override
  String get lblNoBullsAvailable => 'કોઈ ષાઢ ઉપલબ્ધ નથી';

  @override
  String get lblNoCowGroupsAvailable => 'કોઈ ગાય જૂથ ઉપલબ્ધ નથી';

  @override
  String get btnApplyFilter => 'લાગુ કરો';

  @override
  String get msgApplyFilterHint =>
      'રેકોર્ડ જોવા માટે તારીખ શ્રેણી પસંદ કરો અને \'લાગુ કરો\' દબાવો';
}
