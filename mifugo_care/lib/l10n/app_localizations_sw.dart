// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appName => 'Mifugo Care';

  @override
  String get welcomeBack => 'Karibu tena!';

  @override
  String get monitorHerds =>
      'Angalia mifugo yako na kuendelea kuwasiliana na waganga wa wanyama.';

  @override
  String get signInToContinue => 'Ingia ili kuendelea';

  @override
  String get email => 'Barua pepe';

  @override
  String get password => 'Nenosiri';

  @override
  String get forgotPassword => 'Umesahau nenosiri?';

  @override
  String get signIn => 'Ingia';

  @override
  String get signInWithGoogle => 'Ingia kwa Google';

  @override
  String get signInWithApple => 'Ingia kwa Apple';

  @override
  String get newToMifugoCare => 'Ni mpya kwa Mifugo Care?';

  @override
  String get createYourAccount => 'Unda akaunti yako';

  @override
  String get pleaseEnterEmail => 'Tafadhali ingiza barua pepe yako';

  @override
  String get pleaseEnterValidEmail => 'Tafadhali ingiza barua pepe halali';

  @override
  String get pleaseEnterPassword => 'Tafadhali ingiza nenosiri lako';

  @override
  String get passwordMinLength => 'Nenosiri lazima liwe na angalau herufi 6';

  @override
  String loginFailed(String error) {
    return 'Kuingia kumeshindwa: $error';
  }

  @override
  String get farmers => 'Wakulima';

  @override
  String get veterinarians => 'Waganga wa wanyama';

  @override
  String get smartScans => 'Uchambuzi wa Kisasa';

  @override
  String get createYourProfile => 'Unda wasifu wako';

  @override
  String get tailoredTools =>
      'Zana zilizotengenezwa kwa wakulima na waganga wa wanyama mahali pamoja.';

  @override
  String get chooseYourRole => 'Chagua jukumu lako';

  @override
  String get farmer => 'Mkulima';

  @override
  String get farmerDescription => 'Fuatilia mifugo, omba utambuzi';

  @override
  String get veterinarian => 'Mganga wa wanyama';

  @override
  String get veterinarianDescription => 'Kagua kesi, simamia matibabu';

  @override
  String get fullName => 'Jina kamili';

  @override
  String get pleaseEnterName => 'Tafadhali ingiza jina lako';

  @override
  String get phoneNumberOptional => 'Nambari ya simu (si lazima)';

  @override
  String get confirmPassword => 'Thibitisha nenosiri';

  @override
  String get pleaseConfirmPassword => 'Tafadhali thibitisha nenosiri lako';

  @override
  String get passwordsDoNotMatch => 'Nenosiri hazifanani';

  @override
  String get pleaseEnterPasswordField => 'Tafadhali ingiza nenosiri';

  @override
  String get passwordRequirements =>
      'Tumia herufi 10+ zenye kubwa, ndogo, nambari, ishara';

  @override
  String get strongPasswordGenerated => 'Nenosiri lenye nguvu limetengenezwa!';

  @override
  String get createAccount => 'Unda Akaunti';

  @override
  String signUpFailed(String error) {
    return 'Kujisajili kumeshindwa: $error';
  }

  @override
  String get connectWithVets => 'Wasiliana na waganga wa wanyama';

  @override
  String get livestockAnalytics => 'Uchanganuzi wa mifugo';

  @override
  String get secureRecords => 'Rekodi salama';

  @override
  String get home => 'Nyumbani';

  @override
  String get livestock => 'Mifugo';

  @override
  String get history => 'Historia';

  @override
  String get profile => 'Wasifu';

  @override
  String get scanLivestock => 'Chambua Mifugo';

  @override
  String get editProfile => 'Hariri wasifu';

  @override
  String get updateYourInfo => 'Sasisha jina lako, mawasiliano na picha yako';

  @override
  String get notifications => 'Arifa';

  @override
  String get configureAlerts => 'Sanidi arifa na ukumbusho';

  @override
  String get settings => 'Mipangilio';

  @override
  String get customizePreferences => 'Sanidi mapendeleo';

  @override
  String get signOut => 'Toka';

  @override
  String get logOutOfMifugoCare => 'Toka kwenye Mifugo Care';

  @override
  String get language => 'Lugha';

  @override
  String get selectLanguage => 'Chagua Lugha';

  @override
  String get english => 'Kiingereza';

  @override
  String get kiswahili => 'Kiswahili';

  @override
  String get languageChanged => 'Lugha imebadilishwa kwa mafanikio';

  @override
  String get selectPreferredLanguage => 'Chagua lugha unayopendelea';

  @override
  String get yourLanguage => 'Lugha Yako';
}
