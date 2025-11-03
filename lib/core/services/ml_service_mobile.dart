import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// ML Service for disease classification using TensorFlow Lite
class MLService {
  static final MLService instance = MLService._init();

  Interpreter? _interpreter;
  List<String>? _labels;

  static const String modelPath =
      'assets/models/livestock_disease_model.tflite';
  static const String labelsPath = 'assets/disease_labels.txt';

  // Model input/output shapes
  static const int inputSize = 224;
  static const int numClasses = 11;

  bool get isInitialized => _interpreter != null && _labels != null;

  MLService._init();

  /// Initialize the ML model
  Future<void> initialize() async {
    try {
      print('🔄 Loading TFLite model from $modelPath...');

      // Check if model file exists in assets
      try {
        await rootBundle.load(modelPath);
        print('✅ Model file found in assets');
      } catch (e) {
        print('❌ Model file NOT found in assets: $modelPath');
        throw Exception(
            'Model file not found in assets. Please ensure $modelPath exists and is properly included in pubspec.yaml');
      }

      // Load the TFLite model with proper options
      try {
        _interpreter = await Interpreter.fromAsset(
          modelPath,
          options: InterpreterOptions()..threads = 4,
        );
        print('✅ Interpreter created successfully');
      } catch (e) {
        print('❌ Failed to create interpreter: $e');
        print('   This error usually means:');
        print('   1. TFLite native libraries are not loaded properly');
        print('   2. Model file format is incompatible');
        print('   3. Android build configuration is missing TFLite settings');
        print('   Solution: Rebuild the app after gradle sync');
        throw Exception(
            'Failed to create TFLite interpreter: $e. Please rebuild the app.');
      }

      // Get input and output tensor info
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      print('✅ Model loaded successfully');
      print('   Input shape: ${inputTensor.shape}');
      print('   Input type: ${inputTensor.type}');
      print('   Output shape: ${outputTensor.shape}');
      print('   Output type: ${outputTensor.type}');

      // Load labels
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();

      print('✅ ML Service initialized with ${_labels!.length} disease labels');

      // Print labels for verification
      for (int i = 0; i < _labels!.length; i++) {
        print('   [$i] ${_labels![i]}');
      }
    } catch (e) {
      print('❌ Error initializing ML Service: $e');
      rethrow;
    }
  }

  /// Predict disease from image using real TFLite model
  Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    if (!isInitialized) {
      throw Exception('ML Service not initialized. Call initialize() first.');
    }

    try {
      print('🔄 Processing image for disease prediction...');

      // Read and decode image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Preprocess image
      final input = _preprocessImage(image);

      // Prepare output buffer [batch_size, num_classes]
      final output = List.generate(1, (_) => List.filled(numClasses, 0.0));

      // Run inference
      final startTime = DateTime.now();
      _interpreter!.run(input, output);
      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;

      print('✅ Inference completed in ${inferenceTime}ms');

      // Process results
      final probabilities = output[0].cast<double>();

      // Find prediction with highest confidence
      double maxConfidence = probabilities[0];
      int maxIndex = 0;
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          maxIndex = i;
        }
      }

      final rawLabel = _labels![maxIndex];
      final diseaseName = _interpretDiseaseLabel(rawLabel);
      final confidence = maxConfidence * 100; // Convert to percentage

      print('✅ Prediction: $diseaseName (${confidence.toStringAsFixed(1)}%)');

      return {
        'disease': diseaseName,
        'confidence': confidence,
        'diseaseIndex': maxIndex,
        'rawLabel': rawLabel,
        'probabilities': probabilities,
        'allLabels': _labels,
        'inferenceTimeMs': inferenceTime,
        'modelType': 'tflite',
      };
    } catch (e) {
      print('❌ Error during prediction: $e');
      rethrow;
    }
  }

  /// Preprocess image for model input
  /// Returns a properly shaped input tensor [1, 224, 224, 3]
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize image to model input size (224x224)
    final resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.cubic,
    );

    // Create properly shaped input: [batch, height, width, channels]
    List<List<List<List<double>>>> input = List.generate(
      1, // batch size
      (_) => List.generate(
        inputSize, // height
        (y) => List.generate(
          inputSize, // width
          (x) {
            final pixel = resizedImage.getPixel(x, y);

            // Extract RGB values and normalize to [0, 1]
            final r = ((pixel >> 16) & 0xFF) / 255.0;
            final g = ((pixel >> 8) & 0xFF) / 255.0;
            final b = (pixel & 0xFF) / 255.0;

            return [r, g, b]; // channels
          },
        ),
      ),
    );

    return input;
  }

  /// Interpret ML model labels to user-friendly disease names
  String _interpretDiseaseLabel(String label) {
    final cleanLabel = label.trim();

    switch (cleanLabel) {
      case '(BRD)':
        return 'Bovine Respiratory Disease (BRD)';
      case 'healthy':
        return 'Healthy - No Disease Detected';
      case 'lumpy':
      case 'skin':
        return 'Lumpy Skin Disease';
      case 'Contagious':
      case 'Dermatitis':
        return 'Contagious Dermatitis';
      case 'Ecthym':
        return 'Contagious Ecthyma (Orf)';
      case 'Respiratory':
        return 'Respiratory Disease';
      case 'Bovine':
        return 'Bovine Disease (General)';
      case 'Disease':
        return 'Disease Detected (Unspecified)';
      case 'Unlabeled':
        return 'Unknown Condition';
      default:
        return cleanLabel;
    }
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
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
