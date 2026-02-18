// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Smart Gaushala';

  @override
  String get userGreeting => 'Welcome Back';

  @override
  String get loginSubtitle =>
      'Log in to Smart Gaushala and stay connected with Gau Seva and daily Gaushala activities.';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get mobileHint => 'Enter your mobile number';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get registerGaushala => 'Register your Gaushala';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get continueButton => 'Continue';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGujarati => 'Gujarati';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get registerTitle => 'Register Gaushala';

  @override
  String get gaushalaName => 'Gaushala Name';

  @override
  String get gaushalaNameHint => 'Enter Gaushala name';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'Enter address';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get registerSuccess => 'Registration Successful! Please Login.';

  @override
  String get registerError => 'Registration Failed. Try again.';

  @override
  String get userExists => 'User already exists!';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get labelName => 'Name / નામ / नाम';

  @override
  String get hintName => 'Enter your name';

  @override
  String get labelMobileTrilingual => 'Mobile no. / મોબાઈલ નં. / मोबाइल नं.';

  @override
  String get hintMobileTrilingual => 'Enter your mobile number';

  @override
  String get labelCity => 'City / ગામ / गाँव';

  @override
  String get hintCity => 'Select your city name';

  @override
  String get labelGaushalaTrilingual =>
      'Gaushala name / ગૌશાળા નું નામ / गौशाला का नाम';

  @override
  String get hintGaushalaTrilingual => 'Enter gaushala name';

  @override
  String get labelCow => 'Total cow / કુલ ગાય / कुल गाय';

  @override
  String get hintCow => 'Enter total cow';

  @override
  String get submit => 'Submit';

  @override
  String get joinTitle => 'Join Smart Gaushala';

  @override
  String get joinSubtitle =>
      'Create your Smart Gaushala account and be part of Gau Seva.';

  @override
  String get changePasswordTitle => 'Change password?';

  @override
  String get changePasswordSubtitle =>
      'Update your password to keep your account secure.';

  @override
  String get labelOldPass => 'Old password';

  @override
  String get hintOldPass => 'Enter your old password';

  @override
  String get labelNewPass => 'New password';

  @override
  String get hintNewPass => 'Enter your new password';

  @override
  String get labelConfirmPass => 'Confirm password';

  @override
  String get hintConfirmPass => 'Enter your confirm password';

  @override
  String get btnChangePassword => 'Change Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter mobile number and we\'ll help you reset it.';

  @override
  String get verifyPhoneTitle => 'Verify your phone number';

  @override
  String get verifyPhoneSubtitle =>
      'We\'ve sent a one-time code to your phone number.';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String otpSentTo(Object mobile) {
    return 'OTP sent to your $mobile';
  }

  @override
  String get didntGetIt => 'Didn\'t get it?';

  @override
  String get resend => 'Resend';

  @override
  String get verify => 'Verify';

  @override
  String get createPasswordTitle => 'Create a new password';

  @override
  String get createPasswordSubtitle =>
      'Choose a new password to keep your account safe and secure.';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get youreAllSet => 'You\'re all set!';

  @override
  String get passwordUpdated =>
      'Your password has been updated. You can now sign in with your new password.';
}
