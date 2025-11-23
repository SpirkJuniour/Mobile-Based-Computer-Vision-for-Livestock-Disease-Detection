// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mifugo Care';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get monitorHerds => 'Monitor your herds and stay connected with vets.';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get newToMifugoCare => 'New to Mifugo Care?';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get farmers => 'Farmers';

  @override
  String get veterinarians => 'Veterinarians';

  @override
  String get smartScans => 'Smart Scans';

  @override
  String get createYourProfile => 'Create your profile';

  @override
  String get tailoredTools =>
      'Tailored tools for farmers and vets in one place.';

  @override
  String get chooseYourRole => 'Choose your role';

  @override
  String get farmer => 'Farmer';

  @override
  String get farmerDescription => 'Track livestock, request diagnoses';

  @override
  String get veterinarian => 'Veterinarian';

  @override
  String get veterinarianDescription => 'Review cases, manage treatments';

  @override
  String get fullName => 'Full name';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get phoneNumberOptional => 'Phone number (optional)';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseEnterPasswordField => 'Please enter a password';

  @override
  String get passwordRequirements =>
      'Use 10+ chars with upper, lower, number, symbol';

  @override
  String get strongPasswordGenerated => 'Strong password generated!';

  @override
  String get createAccount => 'Create Account';

  @override
  String signUpFailed(String error) {
    return 'Sign up failed: $error';
  }

  @override
  String get connectWithVets => 'Connect with vets';

  @override
  String get livestockAnalytics => 'Livestock analytics';

  @override
  String get secureRecords => 'Secure records';

  @override
  String get home => 'Home';

  @override
  String get livestock => 'Livestock';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get scanLivestock => 'Scan Livestock';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get updateYourInfo => 'Update your name, contact and avatar';

  @override
  String get notifications => 'Notifications';

  @override
  String get configureAlerts => 'Configure alerts and reminders';

  @override
  String get settings => 'Settings';

  @override
  String get customizePreferences => 'Customize preferences';

  @override
  String get signOut => 'Sign out';

  @override
  String get logOutOfMifugoCare => 'Log out of Mifugo Care';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get kiswahili => 'Kiswahili';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get selectPreferredLanguage => 'Select your preferred language';

  @override
  String get yourLanguage => 'Your Language';
}
