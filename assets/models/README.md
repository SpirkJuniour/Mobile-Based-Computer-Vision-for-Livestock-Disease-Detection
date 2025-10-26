# ML Models Directory

This directory should contain the TensorFlow Lite model for livestock disease detection.

## Expected Files

Place your trained model files here:
- `livestock_disease_model.tflite` - The main TensorFlow Lite model file
- `model_metadata.json` - Metadata about the model (classes, input shape, etc.)

## Model Information

The model should be trained to detect the following livestock diseases:
1. Bovine Respiratory Disease (BRD)
2. Bovine Disease (General)
3. Contagious Dermatitis
4. Dermatitis
5. Disease (Unspecified)
6. Contagious Ecthyma (Orf)
7. Respiratory Disease
8. Unlabeled
9. Healthy - No Disease
10. Lumpy Skin Disease
11. Skin Disease

## Training

For training instructions, see:
- `colab_training/README.md` - Google Colab training setup
- `README_TRAINING.md` - Detailed training documentation
- `USE_GOOGLE_COLAB.md` - Google Colab usage guide

## Current Status

The app currently uses `MLServiceAlternatives` which provides image analysis-based disease detection without requiring a TFLite model. Once you have a trained model, place it here and update the app to use `MLService` instead.

