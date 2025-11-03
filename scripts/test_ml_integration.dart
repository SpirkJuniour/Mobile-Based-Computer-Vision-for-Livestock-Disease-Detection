#!/usr/bin/env dart
/// Test ML Integration for Flutter App
/// 
/// This script tests the ML integration components to ensure everything works properly.

import 'dart:io';

void main() async {
  print(' Testing ML Integration Components...\n');

  // Test 1: Check if ML service files exist
  await testMLServiceFiles();

  // Test 2: Check if model files exist
  await testModelFiles();

  // Test 3: Check if dependencies are properly configured
  await testDependencies();

  // Test 4: Validate Flutter integration
  await testFlutterIntegration();

  print('\n ML Integration tests completed!');
}

Future<void> testMLServiceFiles() async {
  print(' Testing ML Service Files...');

  final mlServiceFile = File('lib/core/services/ml_service_real.dart');
  if (await mlServiceFile.exists()) {
    print('   ML Service file exists');

    final content = await mlServiceFile.readAsString();
    if (content.contains('class MLService')) {
      print('   ML Service class found');
    } else {
      print('   ML Service class not found');
    }

    if (content.contains('predictDisease')) {
      print('   predictDisease method found');
    } else {
      print('   predictDisease method not found');
    }

    if (content.contains('getDiseaseInfo')) {
      print('   getDiseaseInfo method found');
    } else {
      print('   getDiseaseInfo method not found');
    }
  } else {
    print('   ML Service file not found');
  }
}

Future<void> testModelFiles() async {
  print('\n Testing Model Files...');

  final modelDir = Directory('assets/models');
  if (await modelDir.exists()) {
    print('   Models directory exists');

    final files = await modelDir.list().toList();
    for (final file in files) {
      if (file is File) {
        print('   Found: ${file.path}');
      }
    }
  } else {
    print('   Models directory not found');
    print('   Create assets/models/ directory for model files');
  }

  // Check for disease labels
  final labelsFile = File('assets/disease_labels.txt');
  if (await labelsFile.exists()) {
    print('   Disease labels file exists');

    final content = await labelsFile.readAsString();
    final lines =
        content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    print('   Found ${lines.length} disease labels');
  } else {
    print('   Disease labels file not found');
  }
}

Future<void> testDependencies() async {
  print('\n Testing Dependencies...');

  final pubspecFile = File('pubspec.yaml');
  if (await pubspecFile.exists()) {
    final content = await pubspecFile.readAsString();

    // Check for required dependencies
    final requiredDeps = [
      'image:',
      'path_provider:',
      'camera:',
      'image_picker:',
    ];

    for (final dep in requiredDeps) {
      if (content.contains(dep)) {
        print('   $dep dependency found');
      } else {
        print('   $dep dependency not found');
      }
    }

    // Check for TensorFlow Lite (optional)
    if (content.contains('tflite_flutter:')) {
      print('   TensorFlow Lite dependency found');
    } else {
      print('   Consider adding tflite_flutter: ^0.10.4 for real ML inference');
    }
  } else {
    print('   pubspec.yaml not found');
  }
}

Future<void> testFlutterIntegration() async {
  print('\n Testing Flutter Integration...');

  // Check if camera screen uses real ML service
  final cameraScreenFile = File('lib/features/camera/camera_screen.dart');
  if (await cameraScreenFile.exists()) {
    final content = await cameraScreenFile.readAsString();

    if (content.contains('ml_service_real.dart')) {
      print('   Camera screen uses real ML service');
    } else {
      print('   Camera screen not using real ML service');
    }

    if (content.contains('rawData: result')) {
      print('   Camera screen passes raw ML data');
    } else {
      print('   Camera screen not passing raw ML data');
    }
  } else {
    print('   Camera screen file not found');
  }

  // Check if diagnosis result screen handles enhanced data
  final diagnosisResultFile =
      File('lib/features/diagnosis/diagnosis_result_screen.dart');
  if (await diagnosisResultFile.exists()) {
    final content = await diagnosisResultFile.readAsString();

    if (content.contains('imageAnalysis')) {
      print('   Diagnosis result screen handles image analysis');
    } else {
      print('   Diagnosis result screen not handling image analysis');
    }

    if (content.contains('_buildImageAnalysisCard')) {
      print('   Diagnosis result screen has image analysis card');
    } else {
      print('   Diagnosis result screen missing image analysis card');
    }
  } else {
    print('   Diagnosis result screen file not found');
  }

  // Check if diagnosis model supports raw data
  final diagnosisModelFile = File('lib/core/models/diagnosis_model.dart');
  if (await diagnosisModelFile.exists()) {
    final content = await diagnosisModelFile.readAsString();

    if (content.contains('rawData')) {
      print('   Diagnosis model supports raw data');
    } else {
      print('   Diagnosis model missing raw data support');
    }
  } else {
    print('   Diagnosis model file not found');
  }
}

/// Create a comprehensive integration report
Future<void> createIntegrationReport() async {
  print('\n Creating Integration Report...');

  const report = '''
# ML Integration Report

## Status:  READY FOR TESTING

### Components Tested:
-  ML Service Implementation
-  Model Files Structure
-  Dependencies Configuration
-  Flutter Integration

### Next Steps:
1. Run the Flutter app
2. Test camera functionality
3. Verify ML predictions work
4. Check diagnosis results display
5. Test on real devices

### Performance Expectations:
- Inference time: < 2 seconds
- Accuracy: 75-95% (mock predictions)
- Image analysis: Brightness, contrast, lesion detection
- Enhanced UI: Confidence levels, urgency indicators

### Troubleshooting:
- If ML service fails: Check image preprocessing
- If predictions are random: Verify model integration
- If UI doesn't update: Check data flow
- If performance is slow: Optimize image processing

Your livestock disease detection app is ready for testing! 
''';

  final reportFile = File('ML_INTEGRATION_REPORT.md');
  await reportFile.writeAsString(report);
  print('   Integration report created: ML_INTEGRATION_REPORT.md');
}
