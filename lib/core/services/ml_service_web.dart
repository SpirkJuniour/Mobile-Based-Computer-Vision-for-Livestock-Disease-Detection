import 'package:flutter/services.dart';

/// ML Service for web platform (stub implementation)
/// TensorFlow Lite doesn't work on web, so we provide a mock implementation
class MLService {
  static final MLService instance = MLService._init();

  List<String>? _labels;

  static const String labelsPath = 'assets/disease_labels.txt';

  bool get isInitialized => _labels != null;

  MLService._init();

  /// Initialize the ML model (web stub)
  Future<void> initialize() async {
    try {
      print('🔄 Initializing ML Service for web (mock mode)...');

      // Load labels only
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();

      print(
          '✅ ML Service initialized for web with ${_labels!.length} disease labels');
      print('⚠️  Note: Actual ML inference is not available on web platform');
      print('   Consider using TensorFlow.js for web-based inference');
    } catch (e) {
      print('❌ Error initializing ML Service: $e');
      rethrow;
    }
  }

  /// Predict disease from image (web stub - returns mock data)
  Future<Map<String, dynamic>> predictDisease(dynamic imageFile) async {
    if (!isInitialized) {
      throw Exception('ML Service not initialized. Call initialize() first.');
    }

    // Return a mock prediction for web
    print(
        '⚠️  Web platform: Returning mock prediction (ML inference not supported)');

    // Simulate some processing time
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'disease': 'ML Inference Not Available on Web',
      'confidence': 0.0,
      'diseaseIndex': -1,
      'rawLabel': 'web_mock',
      'probabilities': List.filled(_labels!.length, 0.0),
      'allLabels': _labels,
      'inferenceTimeMs': 0,
      'modelType': 'web_stub',
      'error': 'TensorFlow Lite is not supported on web platform. '
          'Consider using TensorFlow.js for web-based ML inference.',
    };
  }

  /// Get disease information
  Future<Map<String, dynamic>?> getDiseaseInfo(String diseaseName) async {
    final diseaseMap = <String, Map<String, dynamic>>{
      'Bovine Respiratory Disease (BRD)': {
        'symptoms': [
          'Coughing and nasal discharge',
          'Difficulty breathing',
          'High fever (40-41°C)',
          'Loss of appetite',
          'Depression and lethargy',
          'Rapid or labored breathing'
        ],
        'treatments': [
          'Antibiotics (as prescribed by vet)',
          'Anti-inflammatory drugs',
          'Supportive care with fluids',
          'Isolate affected animals',
          'Improve ventilation'
        ],
        'prevention': [
          'Reduce stress factors',
          'Proper ventilation in housing',
          'Vaccination programs',
          'Good nutrition and hygiene',
          'Minimize overcrowding'
        ],
        'severity': 75,
      },
      'Lumpy Skin Disease': {
        'symptoms': [
          'Skin nodules (lumps)',
          'High fever',
          'Reduced milk production',
          'Weight loss',
          'Swollen lymph nodes'
        ],
        'treatments': [
          'Vaccination (preventive)',
          'Antibiotics for secondary infections',
          'Anti-inflammatory drugs',
          'Supportive care and nutrition'
        ],
        'prevention': [
          'Annual vaccination',
          'Vector control (flies, mosquitoes)',
          'Isolate infected animals',
          'Biosecurity measures'
        ],
        'severity': 75,
      },
      'Contagious Dermatitis': {
        'symptoms': [
          'Skin lesions and scabs',
          'Pustules and blisters',
          'Thickened, crusty skin',
          'Hair loss in affected areas',
          'May affect mouth, muzzle, or udder'
        ],
        'treatments': [
          'Topical antiseptic solutions',
          'Antibiotics for secondary infections',
          'Isolate affected animals',
          'Keep affected areas clean and dry',
          'Supportive care'
        ],
        'prevention': [
          'Good hygiene practices',
          'Quarantine new animals',
          'Avoid contact with infected animals',
          'Disinfect equipment regularly',
          'Improve nutrition and immunity'
        ],
        'severity': 50,
      },
      'Contagious Ecthyma (Orf)': {
        'symptoms': [
          'Lesions on lips, muzzle, and mouth',
          'Scabs and pustules',
          'Difficulty eating or drinking',
          'Weight loss',
          'Swollen lymph nodes',
          'May spread to udder or feet'
        ],
        'treatments': [
          'Topical antiseptics (iodine)',
          'Antibiotics for secondary infections',
          'Soft feed for affected animals',
          'Isolate infected animals',
          'Usually self-limiting (2-4 weeks)'
        ],
        'prevention': [
          'Vaccination (in endemic areas)',
          'Quarantine new animals',
          'Disinfect equipment',
          'Avoid contact with infected animals',
          'Good biosecurity measures'
        ],
        'severity': 45,
      },
      'Respiratory Disease': {
        'symptoms': [
          'Coughing and sneezing',
          'Nasal discharge',
          'Difficulty breathing',
          'Fever',
          'Reduced appetite',
          'Lethargy'
        ],
        'treatments': [
          'Antibiotics (if bacterial)',
          'Anti-inflammatory drugs',
          'Improve ventilation',
          'Supportive care with fluids',
          'Isolate affected animals'
        ],
        'prevention': [
          'Proper ventilation in housing',
          'Reduce overcrowding',
          'Vaccination programs',
          'Good nutrition',
          'Minimize stress'
        ],
        'severity': 65,
      },
      'Bovine Disease (General)': {
        'symptoms': [
          'General signs of illness',
          'Loss of appetite',
          'Lethargy or depression',
          'Changes in behavior',
          'Reduced productivity'
        ],
        'treatments': [
          'Consult a veterinarian for diagnosis',
          'Supportive care',
          'Isolate affected animals',
          'Monitor symptoms closely'
        ],
        'prevention': [
          'Regular health checks',
          'Proper nutrition',
          'Good hygiene practices',
          'Vaccination programs',
          'Biosecurity measures'
        ],
        'severity': 50,
      },
      'Disease Detected (Unspecified)': {
        'symptoms': [
          'Visible signs of illness',
          'Abnormal behavior',
          'Changes in appearance',
          'Requires further examination'
        ],
        'treatments': [
          'Contact a veterinarian immediately',
          'Isolate the animal',
          'Monitor closely',
          'Provide supportive care'
        ],
        'prevention': [
          'Regular veterinary check-ups',
          'Maintain good hygiene',
          'Proper nutrition',
          'Timely vaccinations'
        ],
        'severity': 60,
      },
      'Unknown Condition': {
        'symptoms': [
          'Unclear or mixed symptoms',
          'Requires professional diagnosis',
          'May need laboratory tests'
        ],
        'treatments': [
          'Consult a veterinarian urgently',
          'Do not attempt self-treatment',
          'Isolate the animal',
          'Keep records of symptoms'
        ],
        'prevention': [
          'Regular health monitoring',
          'Professional veterinary care',
          'Good management practices',
          'Maintain health records'
        ],
        'severity': 70,
      },
      'Healthy - No Disease Detected': {
        'symptoms': [
          'Normal appetite',
          'Active and alert',
          'Normal body temperature',
          'No visible lesions',
          'Good body condition'
        ],
        'treatments': [
          'Continue regular monitoring',
          'Maintain vaccination schedule',
          'Provide balanced nutrition',
          'Ensure clean water supply'
        ],
        'prevention': [
          'Regular health checks',
          'Timely vaccinations',
          'Good hygiene practices',
          'Balanced diet and minerals'
        ],
        'severity': 0,
      },
    };

    return diseaseMap[diseaseName];
  }

  /// Close/dispose
  void close() {
    _labels = null;
  }
}
