import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('sw', ''),
  ];
  
  // App strings
  String get appName => _localizedValues[locale.languageCode]?['app_name'] ?? 'Mifugo Care';
  String get navDiagnosis => _localizedValues[locale.languageCode]?['nav_diagnosis'] ?? 'Diagnosis';
  String get navHistory => _localizedValues[locale.languageCode]?['nav_history'] ?? 'History';
  String get navLivestock => _localizedValues[locale.languageCode]?['nav_livestock'] ?? 'Livestock';
  String get navSettings => _localizedValues[locale.languageCode]?['nav_settings'] ?? 'Settings';
  
  // Camera strings
  String get cameraPermissionRequired => _localizedValues[locale.languageCode]?['camera_permission_required'] ?? 'Camera permission required';
  String get captureImage => _localizedValues[locale.languageCode]?['capture_image'] ?? 'Capture Image';
  String get imageCaptured => _localizedValues[locale.languageCode]?['image_captured'] ?? 'Image captured';
  String get failedToCapture => _localizedValues[locale.languageCode]?['failed_to_capture'] ?? 'Failed to capture image';
  
  // Diagnosis strings
  String get analyzingImage => _localizedValues[locale.languageCode]?['analyzing_image'] ?? 'Analyzing image...';
  String get diagnosisResult => _localizedValues[locale.languageCode]?['diagnosis_result'] ?? 'Diagnosis Result';
  String get confidence => _localizedValues[locale.languageCode]?['confidence'] ?? 'Confidence';
  String get symptoms => _localizedValues[locale.languageCode]?['symptoms'] ?? 'Symptoms';
  String get treatment => _localizedValues[locale.languageCode]?['treatment'] ?? 'Treatment';
  String get prevention => _localizedValues[locale.languageCode]?['prevention'] ?? 'Prevention';
  
  // Disease names
  String get footAndMouthDisease => _localizedValues[locale.languageCode]?['foot_and_mouth_disease'] ?? 'Foot and Mouth Disease';
  String get mastitis => _localizedValues[locale.languageCode]?['mastitis'] ?? 'Mastitis';
  String get lumpySkinDisease => _localizedValues[locale.languageCode]?['lumpy_skin_disease'] ?? 'Lumpy Skin Disease';
  String get blackleg => _localizedValues[locale.languageCode]?['blackleg'] ?? 'Blackleg';
  String get anthrax => _localizedValues[locale.languageCode]?['anthrax'] ?? 'Anthrax';
  String get pneumonia => _localizedValues[locale.languageCode]?['pneumonia'] ?? 'Pneumonia';
  String get healthy => _localizedValues[locale.languageCode]?['healthy'] ?? 'Healthy';
  String get mange => _localizedValues[locale.languageCode]?['mange'] ?? 'Mange';
  String get ringworm => _localizedValues[locale.languageCode]?['ringworm'] ?? 'Ringworm';
  String get bloat => _localizedValues[locale.languageCode]?['bloat'] ?? 'Bloat';
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Mifugo Care',
      'nav_diagnosis': 'Diagnosis',
      'nav_history': 'History',
      'nav_livestock': 'Livestock',
      'nav_settings': 'Settings',
      'camera_permission_required': 'Camera permission required',
      'capture_image': 'Capture Image',
      'image_captured': 'Image captured',
      'failed_to_capture': 'Failed to capture image',
      'analyzing_image': 'Analyzing image...',
      'diagnosis_result': 'Diagnosis Result',
      'confidence': 'Confidence',
      'symptoms': 'Symptoms',
      'treatment': 'Treatment',
      'prevention': 'Prevention',
      'foot_and_mouth_disease': 'Foot and Mouth Disease',
      'mastitis': 'Mastitis',
      'lumpy_skin_disease': 'Lumpy Skin Disease',
      'blackleg': 'Blackleg',
      'anthrax': 'Anthrax',
      'pneumonia': 'Pneumonia',
      'healthy': 'Healthy',
      'mange': 'Mange',
      'ringworm': 'Ringworm',
      'bloat': 'Bloat',
    },
    'sw': {
      'app_name': 'Mifugo Care',
      'nav_diagnosis': 'Uchunguzi',
      'nav_history': 'Historia',
      'nav_livestock': 'Mifugo',
      'nav_settings': 'Mipangilio',
      'camera_permission_required': 'Ruhusa ya kamera inahitajika',
      'capture_image': 'Piga Picha',
      'image_captured': 'Picha imepigwa',
      'failed_to_capture': 'Imeshindwa kupiga picha',
      'analyzing_image': 'Inachambua picha...',
      'diagnosis_result': 'Matokeo ya Uchunguzi',
      'confidence': 'Uaminifu',
      'symptoms': 'Dalili',
      'treatment': 'Matibabu',
      'prevention': 'Kinga',
      'foot_and_mouth_disease': 'Ugonjwa wa Miguu na Mdomo',
      'mastitis': 'Ugonjwa wa Matiti',
      'lumpy_skin_disease': 'Ugonjwa wa Ngozi',
      'blackleg': 'Mguu Mweusi',
      'anthrax': 'Anthrax',
      'pneumonia': 'Ugonjwa wa Mapafu',
      'healthy': 'Afya',
      'mange': 'Ugonjwa wa Ngozi',
      'ringworm': 'Ugonjwa wa Ngozi',
      'bloat': 'Ugonjwa wa Tumbo',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'sw'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
