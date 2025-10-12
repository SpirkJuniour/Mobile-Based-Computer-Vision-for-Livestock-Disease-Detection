import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';

/// ML Service for disease classification
/// Note: TensorFlow Lite temporarily disabled - returns mock data
class MLService {
  static final MLService instance = MLService._init();

  List<String>? _labels;

  bool get isInitialized => _labels != null;

  MLService._init();

  /// Initialize the ML model
  Future<void> initialize() async {
    try {
      // Load labels
      final labelsData =
          await rootBundle.loadString('assets/disease_labels.txt');
      _labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();

      print('ML Service initialized with ${_labels!.length} disease labels');
    } catch (e) {
      print('Error loading ML labels: $e');
      // Fallback labels
      _labels = [
        'East Coast Fever (ECF)',
        'Lumpy Skin Disease',
        'Foot and Mouth Disease (FMD)',
        'Mastitis',
        'Mange (Scabies)',
        'Tick Infestation',
        'Ringworm',
        'CBPP (Contagious Bovine Pleuropneumonia)',
        'Healthy - No Disease Detected',
      ];
    }
  }

  /// Predict disease from image (MOCK - returns random results)
  Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    if (!isInitialized) {
      throw Exception('ML Service not initialized');
    }

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    // Return mock prediction
    final random = Random();
    final diseaseIndex = random.nextInt(_labels!.length);
    final confidence = 75.0 + (random.nextDouble() * 20); // 75-95%

    return {
      'disease': _labels![diseaseIndex],
      'confidence': confidence,
      'diseaseIndex': diseaseIndex,
    };
  }

  /// Get disease information
  Future<Map<String, dynamic>?> getDiseaseInfo(String diseaseName) async {
    final diseaseMap = <String, Map<String, dynamic>>{
      'East Coast Fever (ECF)': {
        'symptoms': [
          'High fever (40-41°C)',
          'Swollen lymph nodes',
          'Nasal discharge',
          'Difficulty breathing',
          'Loss of appetite'
        ],
        'treatments': [
          'Early antibiotic treatment (Oxytetracycline)',
          'Tick control measures',
          'Supportive therapy with fluids',
          'Consult a veterinarian immediately'
        ],
        'prevention': [
          'Regular tick control (dipping/spraying)',
          'Vaccination in endemic areas',
          'Pasture management',
          'Quarantine new animals'
        ],
        'severity': 85,
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
      'Foot and Mouth Disease (FMD)': {
        'symptoms': [
          'Blisters on mouth, feet, teats',
          'Excessive drooling',
          'Lameness',
          'Fever',
          'Reluctance to move or eat'
        ],
        'treatments': [
          'No specific cure - supportive care',
          'Isolate affected animals',
          'Soft feed and clean water',
          'Consult veterinarian'
        ],
        'prevention': [
          'Regular vaccination',
          'Movement restrictions',
          'Quarantine new animals',
          'Biosecurity protocols'
        ],
        'severity': 90,
      },
      'Mastitis': {
        'symptoms': [
          'Swollen, hard udder',
          'Abnormal milk (clots, blood)',
          'Fever',
          'Reduced milk production',
          'Pain when milking'
        ],
        'treatments': [
          'Antibiotics (intramammary or systemic)',
          'Anti-inflammatory drugs',
          'Frequent milking',
          'Proper hygiene during milking'
        ],
        'prevention': [
          'Clean milking equipment',
          'Teat dipping after milking',
          'Dry cow therapy',
          'Good housing conditions'
        ],
        'severity': 60,
      },
      'Mange (Scabies)': {
        'symptoms': [
          'Intense itching',
          'Hair loss (alopecia)',
          'Thickened, wrinkled skin',
          'Scabs and crusty lesions',
          'Weight loss'
        ],
        'treatments': [
          'Acaricide sprays or dips',
          'Ivermectin injections',
          'Isolate infected animals',
          'Repeat treatment after 10-14 days'
        ],
        'prevention': [
          'Regular inspection of animals',
          'Quarantine new animals',
          'Clean and disinfect equipment',
          'Avoid overcrowding'
        ],
        'severity': 55,
      },
      'Tick Infestation': {
        'symptoms': [
          'Visible ticks on skin',
          'Anemia (pale gums)',
          'Weight loss',
          'Restlessness',
          'Reduced productivity'
        ],
        'treatments': [
          'Acaricide dips or sprays',
          'Manual tick removal',
          'Ivermectin treatment',
          'Treat underlying diseases (ECF, etc.)'
        ],
        'prevention': [
          'Weekly dipping or spraying',
          'Pasture rotation',
          'Keep grass short',
          'Inspect animals daily'
        ],
        'severity': 50,
      },
      'Ringworm': {
        'symptoms': [
          'Circular patches of hair loss',
          'Scaly, crusty skin',
          'Grey-white lesions',
          'Usually on head, neck, back',
          'Minimal itching'
        ],
        'treatments': [
          'Topical antifungal creams',
          'Oral antifungals (severe cases)',
          'Isolate infected animals',
          'Disinfect equipment and housing'
        ],
        'prevention': [
          'Good hygiene practices',
          'Avoid contact with infected animals',
          'Disinfect equipment regularly',
          'Improve nutrition and immunity'
        ],
        'severity': 40,
      },
      'CBPP (Contagious Bovine Pleuropneumonia)': {
        'symptoms': [
          'Persistent coughing',
          'Labored breathing',
          'High fever',
          'Nasal discharge',
          'Weight loss and weakness'
        ],
        'treatments': [
          'Antibiotics (early stage)',
          'Supportive therapy',
          'Isolation from herd',
          'Slaughter in severe cases (disease control)'
        ],
        'prevention': [
          'Vaccination',
          'Movement control',
          'Quarantine infected herds',
          'Report to veterinary authorities'
        ],
        'severity': 95,
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
