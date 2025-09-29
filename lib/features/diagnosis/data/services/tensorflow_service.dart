import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../domain/entities/diagnosis_result.dart';

class TensorFlowService {
  static const String _modelPath =
      'assets/models/livestock_disease_model.tflite';
  static const String _diseasesPath = 'assets/diseases/disease_profiles.json';

  static const int _inputSize = 224;
  static const int _numClasses = 10;

  Interpreter? _interpreter;
  List<String> _diseaseNames = [];

  Future<void> initialize() async {
    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset(_modelPath);

      // Load disease names
      await _loadDiseaseNames();
    } catch (e) {
      throw Exception('Failed to initialize TensorFlow model: $e');
    }
  }

  Future<void> _loadDiseaseNames() async {
    try {
      final String jsonString = await rootBundle.loadString(_diseasesPath);
      // Parse JSON and extract disease names
      // For now, using hardcoded names from the original model
      _diseaseNames = [
        'Foot and Mouth Disease',
        'Mastitis',
        'Lumpy Skin Disease',
        'Blackleg',
        'Anthrax',
        'Pneumonia',
        'Healthy',
        'Mange',
        'Ringworm',
        'Bloat',
      ];
    } catch (e) {
      // Fallback to hardcoded names
      _diseaseNames = [
        'Foot and Mouth Disease',
        'Mastitis',
        'Lumpy Skin Disease',
        'Blackleg',
        'Anthrax',
        'Pneumonia',
        'Healthy',
        'Mange',
        'Ringworm',
        'Bloat',
      ];
    }
  }

  Future<DiagnosisResult> predictDisease(String imagePath) async {
    if (_interpreter == null) {
      throw Exception('TensorFlow model not initialized');
    }

    try {
      // Load and preprocess image
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image to model input size
      final resizedImage = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );

      // Convert to float array and normalize
      final inputArray = _preprocessImage(resizedImage);

      // Prepare output array
      final output = List.filled(_numClasses, 0.0).reshape([1, _numClasses]);

      // Run inference
      _interpreter!.run(inputArray, output);

      // Process results
      return _processOutput(output[0]);
    } catch (e) {
      throw Exception('Failed to predict disease: $e');
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final inputArray = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (_) => List.generate(_inputSize, (_) => List.generate(3, (_) => 0.0)),
      ),
    );

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;

        inputArray[0][y][x][0] = r;
        inputArray[0][y][x][1] = g;
        inputArray[0][y][x][2] = b;
      }
    }

    return inputArray;
  }

  DiagnosisResult _processOutput(List<double> predictions) {
    // Apply softmax to get probabilities
    final probabilities = _applySoftmax(predictions);

    // Find the class with highest confidence
    int maxIndex = 0;
    double maxConfidence = 0.0;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        maxIndex = i;
      }
    }

    // Get disease name
    final diseaseName = maxIndex < _diseaseNames.length
        ? _diseaseNames[maxIndex]
        : 'Unknown Disease';

    // Get disease information
    final severity = _getDiseaseSeverity(diseaseName);
    final symptoms = _getDiseaseSymptoms(diseaseName);
    final treatment = _getDiseaseTreatment(diseaseName);
    final prevention = _getDiseasePrevention(diseaseName);
    final contagious = _isDiseaseContagious(diseaseName);
    final affectedBodyParts = _getAffectedBodyParts(diseaseName);
    final mortalityRate = _getMortalityRate(diseaseName);
    final seasonality = _getSeasonality(diseaseName);

    return DiagnosisResult(
      diseaseName: diseaseName,
      confidence: maxConfidence,
      severity: severity,
      symptoms: symptoms,
      treatment: treatment,
      prevention: prevention,
      contagious: contagious,
      affectedBodyParts: affectedBodyParts,
      mortalityRate: mortalityRate,
      seasonality: seasonality,
    );
  }

  List<double> _applySoftmax(List<double> logits) {
    final probabilities = List<double>.filled(logits.length, 0.0);
    final double maxLogit = logits.reduce((a, b) => a > b ? a : b);

    // Calculate sum of exponentials
    double sum = 0.0;
    for (int i = 0; i < logits.length; i++) {
      probabilities[i] = math.exp(logits[i] - maxLogit);
      sum += probabilities[i];
    }

    // Normalize to get probabilities
    for (int i = 0; i < probabilities.length; i++) {
      probabilities[i] /= sum;
    }

    return probabilities;
  }

  String _getDiseaseSeverity(String diseaseName) {
    switch (diseaseName.toLowerCase()) {
      case 'anthrax':
      case 'blackleg':
        return 'Critical';
      case 'foot and mouth disease':
      case 'lumpy skin disease':
        return 'High';
      case 'mastitis':
      case 'pneumonia':
        return 'Medium';
      case 'mange':
      case 'ringworm':
      case 'bloat':
        return 'Low';
      case 'healthy':
        return 'None';
      default:
        return 'Unknown';
    }
  }

  String _getDiseaseSymptoms(String diseaseName) {
    switch (diseaseName.toLowerCase()) {
      case 'foot and mouth disease':
        return 'Fever, blisters in mouth and feet, lameness, excessive salivation';
      case 'mastitis':
        return 'Swollen udder, abnormal milk, fever, loss of appetite';
      case 'lumpy skin disease':
        return 'Firm nodules on skin, fever, reduced milk production';
      case 'blackleg':
        return 'Sudden death, lameness, swelling in muscles, fever';
      case 'anthrax':
        return 'Sudden death, bleeding from body openings, high fever';
      case 'pneumonia':
        return 'Coughing, difficulty breathing, fever, nasal discharge';
      case 'mange':
        return 'Itching, hair loss, skin thickening, restlessness';
      case 'ringworm':
        return 'Circular lesions, hair loss, scaly skin';
      case 'bloat':
        return 'Distended abdomen, difficulty breathing, restlessness';
      case 'healthy':
        return 'No symptoms observed';
      default:
        return 'Symptoms vary';
    }
  }

  String _getDiseaseTreatment(String diseaseName) {
    switch (diseaseName.toLowerCase()) {
      case 'foot and mouth disease':
        return 'Vaccination, isolation, supportive care, antibiotic treatment for secondary infections';
      case 'mastitis':
        return 'Antibiotic treatment, anti-inflammatory drugs, milking hygiene';
      case 'lumpy skin disease':
        return 'Supportive care, antibiotic treatment, vaccination';
      case 'blackleg':
        return 'Emergency vaccination, antibiotic treatment, surgical drainage';
      case 'anthrax':
        return 'Immediate veterinary attention, antibiotic treatment, isolation';
      case 'pneumonia':
        return 'Antibiotic treatment, anti-inflammatory drugs, good ventilation';
      case 'mange':
        return 'Acaricide treatment, environmental cleaning, isolation';
      case 'ringworm':
        return 'Antifungal treatment, topical medication, environmental cleaning';
      case 'bloat':
        return 'Emergency treatment, stomach tube, anti-foaming agents';
      case 'healthy':
        return 'Continue regular health monitoring';
      default:
        return 'Consult veterinarian for treatment';
    }
  }

  String _getDiseasePrevention(String diseaseName) {
    switch (diseaseName.toLowerCase()) {
      case 'foot and mouth disease':
        return 'Vaccination, biosecurity measures, avoid contact with infected animals';
      case 'mastitis':
        return 'Proper milking hygiene, clean bedding, regular udder health checks';
      case 'lumpy skin disease':
        return 'Vaccination, vector control, quarantine new animals';
      case 'blackleg':
        return 'Vaccination, avoid deep wounds, proper wound care';
      case 'anthrax':
        return 'Vaccination, avoid contaminated areas, proper carcass disposal';
      case 'pneumonia':
        return 'Good ventilation, proper nutrition, stress reduction, vaccination';
      case 'mange':
        return 'Regular health checks, quarantine new animals, clean environment';
      case 'ringworm':
        return 'Good hygiene, avoid contact with infected animals, clean environment';
      case 'bloat':
        return 'Proper feeding management, avoid sudden diet changes, monitor grazing';
      case 'healthy':
        return 'Continue current health management practices';
      default:
        return 'Maintain good biosecurity and health management';
    }
  }

  bool _isDiseaseContagious(String diseaseName) {
    switch (diseaseName.toLowerCase()) {
      case 'foot and mouth disease':
      case 'lumpy skin disease':
      case 'anthrax':
      case 'pneumonia':
      case 'mange':
      case 'ringworm':
        return true;
      case 'mastitis':
      case 'blackleg':
      case 'bloat':
      case 'healthy':
        return false;
      default:
        return false;
    }
  }

  String _getAffectedBodyParts(String diseaseName) {
    switch (diseaseName.toLowerCase()) {
      case 'foot and mouth disease':
        return 'Mouth, feet, udder';
      case 'mastitis':
        return 'Udder, mammary glands';
      case 'lumpy skin disease':
        return 'Skin, lymph nodes';
      case 'blackleg':
        return 'Muscles, particularly legs';
      case 'anthrax':
        return 'Multiple organs, blood';
      case 'pneumonia':
        return 'Lungs, respiratory system';
      case 'mange':
        return 'Skin, hair follicles';
      case 'ringworm':
        return 'Skin, hair';
      case 'bloat':
        return 'Stomach, digestive system';
      case 'healthy':
        return 'None';
      default:
        return 'Various';
    }
  }

  String _getMortalityRate(String diseaseName) {
    switch (diseaseName.toLowerCase()) {
      case 'anthrax':
      case 'blackleg':
        return 'High (80-100%)';
      case 'foot and mouth disease':
      case 'lumpy skin disease':
        return 'Low (1-5%)';
      case 'pneumonia':
        return 'Low to moderate (5-20%)';
      case 'bloat':
        return 'Moderate (20-50%)';
      case 'mastitis':
      case 'mange':
      case 'ringworm':
        return 'Very low';
      case 'healthy':
        return 'None';
      default:
        return 'Unknown';
    }
  }

  String _getSeasonality(String diseaseName) {
    switch (diseaseName.toLowerCase()) {
      case 'foot and mouth disease':
        return 'All year, peaks in dry season';
      case 'lumpy skin disease':
        return 'Peaks in rainy season';
      case 'pneumonia':
        return 'All year, peaks in cold season';
      case 'blackleg':
        return 'All year, peaks in wet season';
      case 'anthrax':
        return 'All year, peaks in dry season';
      default:
        return 'All year';
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
