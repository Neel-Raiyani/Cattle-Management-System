import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Smart Gaushala'**
  String get appName;

  /// No description provided for @userGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get userGreeting;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to Smart Gaushala and stay connected with Gau Seva and daily Gaushala activities.'**
  String get loginSubtitle;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @mobileHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get mobileHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @registerGaushala.
  ///
  /// In en, this message translates to:
  /// **'Register your Gaushala'**
  String get registerGaushala;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get languageGujarati;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Gaushala'**
  String get registerTitle;

  /// No description provided for @gaushalaName.
  ///
  /// In en, this message translates to:
  /// **'Gaushala Name'**
  String get gaushalaName;

  /// No description provided for @gaushalaNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Gaushala name'**
  String get gaushalaNameHint;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get addressHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPasswordHint;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful! Please Login.'**
  String get registerSuccess;

  /// No description provided for @registerError.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed. Try again.'**
  String get registerError;

  /// No description provided for @userExists.
  ///
  /// In en, this message translates to:
  /// **'User already exists!'**
  String get userExists;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name / નામ / नाम'**
  String get labelName;

  /// No description provided for @hintName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get hintName;

  /// No description provided for @labelMobileTrilingual.
  ///
  /// In en, this message translates to:
  /// **'Mobile no. / મોબાઈલ નં. / मोबाइल नं.'**
  String get labelMobileTrilingual;

  /// No description provided for @hintMobileTrilingual.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get hintMobileTrilingual;

  /// No description provided for @labelCity.
  ///
  /// In en, this message translates to:
  /// **'City / ગામ / गाँव'**
  String get labelCity;

  /// No description provided for @hintCity.
  ///
  /// In en, this message translates to:
  /// **'Select your city name'**
  String get hintCity;

  /// No description provided for @labelGaushalaTrilingual.
  ///
  /// In en, this message translates to:
  /// **'Gaushala name / ગૌશાળા નું નામ / गौशाला का नाम'**
  String get labelGaushalaTrilingual;

  /// No description provided for @hintGaushalaTrilingual.
  ///
  /// In en, this message translates to:
  /// **'Enter gaushala name'**
  String get hintGaushalaTrilingual;

  /// No description provided for @labelCow.
  ///
  /// In en, this message translates to:
  /// **'Total cow / કુલ ગાય / कुल गाय'**
  String get labelCow;

  /// No description provided for @hintCow.
  ///
  /// In en, this message translates to:
  /// **'Enter total cow'**
  String get hintCow;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Smart Gaushala'**
  String get joinTitle;

  /// No description provided for @joinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your Smart Gaushala account and be part of Gau Seva.'**
  String get joinSubtitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password?'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your password to keep your account secure.'**
  String get changePasswordSubtitle;

  /// No description provided for @labelOldPass.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get labelOldPass;

  /// No description provided for @hintOldPass.
  ///
  /// In en, this message translates to:
  /// **'Enter your old password'**
  String get hintOldPass;

  /// No description provided for @labelNewPass.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get labelNewPass;

  /// No description provided for @hintNewPass.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get hintNewPass;

  /// No description provided for @labelConfirmPass.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get labelConfirmPass;

  /// No description provided for @hintConfirmPass.
  ///
  /// In en, this message translates to:
  /// **'Enter your confirm password'**
  String get hintConfirmPass;

  /// No description provided for @btnChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get btnChangePassword;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number and we\'ll help you reset it.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @verifyPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get verifyPhoneTitle;

  /// No description provided for @verifyPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a one-time code to your phone number.'**
  String get verifyPhoneSubtitle;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your {mobile}'**
  String otpSentTo(Object mobile);

  /// No description provided for @didntGetIt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get didntGetIt;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @createPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get createPasswordTitle;

  /// No description provided for @createPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password to keep your account safe and secure.'**
  String get createPasswordSubtitle;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @youreAllSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get youreAllSet;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated. You can now sign in with your new password.'**
  String get passwordUpdated;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get menuChangePassword;

  /// No description provided for @menuChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get menuChangeLanguage;

  /// No description provided for @menuPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get menuPrivacyPolicy;

  /// No description provided for @menuShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get menuShareApp;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menuLogout;

  /// No description provided for @menuUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get menuUser;

  /// No description provided for @menuCowGroup.
  ///
  /// In en, this message translates to:
  /// **'Cow Group'**
  String get menuCowGroup;

  /// No description provided for @menuAIBull.
  ///
  /// In en, this message translates to:
  /// **'AI Bull'**
  String get menuAIBull;

  /// No description provided for @menuAnimalLeft.
  ///
  /// In en, this message translates to:
  /// **'Animal Left From Gaushala'**
  String get menuAnimalLeft;

  /// No description provided for @menuDistribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution Title'**
  String get menuDistribution;

  /// No description provided for @menuMyPost.
  ///
  /// In en, this message translates to:
  /// **'My Post'**
  String get menuMyPost;

  /// No description provided for @menuAboutDevelopers.
  ///
  /// In en, this message translates to:
  /// **'About Developers'**
  String get menuAboutDevelopers;

  /// No description provided for @menuAboutGaushala.
  ///
  /// In en, this message translates to:
  /// **'About Gaushala'**
  String get menuAboutGaushala;

  /// No description provided for @menuGuidance.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get menuGuidance;

  /// No description provided for @menuFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get menuFeedback;

  /// No description provided for @menuContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get menuContactUs;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sectionSettings;

  /// No description provided for @sectionAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get sectionAboutUs;

  /// No description provided for @titleUserList.
  ///
  /// In en, this message translates to:
  /// **'User List'**
  String get titleUserList;

  /// No description provided for @titleAddUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get titleAddUser;

  /// No description provided for @titleEditUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get titleEditUser;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get hintEmail;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get noDataFound;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @titleCowList.
  ///
  /// In en, this message translates to:
  /// **'Cow'**
  String get titleCowList;

  /// No description provided for @lblAllCows.
  ///
  /// In en, this message translates to:
  /// **'All Cows'**
  String get lblAllCows;

  /// No description provided for @lblLactating.
  ///
  /// In en, this message translates to:
  /// **'Lactating'**
  String get lblLactating;

  /// No description provided for @lblHeifer.
  ///
  /// In en, this message translates to:
  /// **'Heifer'**
  String get lblHeifer;

  /// No description provided for @lblPregnant.
  ///
  /// In en, this message translates to:
  /// **'Pregnant'**
  String get lblPregnant;

  /// No description provided for @lblDryOff.
  ///
  /// In en, this message translates to:
  /// **'Dry Off'**
  String get lblDryOff;

  /// No description provided for @lblRetiredCow.
  ///
  /// In en, this message translates to:
  /// **'Retired Cow'**
  String get lblRetiredCow;

  /// No description provided for @lblTotalCow.
  ///
  /// In en, this message translates to:
  /// **'Total {count} Cow'**
  String lblTotalCow(Object count);

  /// No description provided for @lblTagNo.
  ///
  /// In en, this message translates to:
  /// **'Tag No.'**
  String get lblTagNo;

  /// No description provided for @lblNo.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get lblNo;

  /// No description provided for @lblBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get lblBirthday;

  /// No description provided for @lblAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get lblAge;

  /// No description provided for @lblParity.
  ///
  /// In en, this message translates to:
  /// **'Parity'**
  String get lblParity;

  /// No description provided for @lblParityMilk.
  ///
  /// In en, this message translates to:
  /// **'Parity Milk'**
  String get lblParityMilk;

  /// No description provided for @lblLastDelivery.
  ///
  /// In en, this message translates to:
  /// **'Last Delivery'**
  String get lblLastDelivery;

  /// No description provided for @btnAddNewCow.
  ///
  /// In en, this message translates to:
  /// **'Add New Cow'**
  String get btnAddNewCow;

  /// No description provided for @menuOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get menuOpen;

  /// No description provided for @menuShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get menuShare;

  /// No description provided for @lblDetailNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Detail not available'**
  String get lblDetailNotAvailable;

  /// No description provided for @unitLPerDay.
  ///
  /// In en, this message translates to:
  /// **'L/day'**
  String get unitLPerDay;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
