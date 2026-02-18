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
}
