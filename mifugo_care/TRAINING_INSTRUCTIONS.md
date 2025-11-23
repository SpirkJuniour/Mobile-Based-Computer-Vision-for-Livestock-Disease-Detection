# Model Training Instructions

## Overview
This document describes how to train the disease detection models with 50 epochs targeting 99-100% accuracy, and integrate them with the Flutter app.

## Quick Start

### Option 1: Run Training with Auto-Monitoring (Recommended)
```powershell
# Windows PowerShell
.\ml\run_training.ps1

# Or Windows Batch
.\ml\run_training.bat

# Or Python directly
python ml\train_and_monitor.py
```

This will:
- Start training with 50 epochs
- Monitor progress every 5 minutes
- Automatically copy models to Flutter assets when ready
- Target 99-100% accuracy

### Option 2: Run Training and Monitor Separately

1. **Start Training:**
```bash
python ml/train_all.py
```

2. **Monitor Progress (in another terminal):**
```bash
python ml/monitor_training_loop.py
```

## Training Configuration

- **Epochs:** 50
- **Target Accuracy:** 99-100%
- **Early Stopping:** Patience of 50 epochs
- **Models:**
  - Detection: YOLOv11 Medium (animal_pathologies)
  - Classification: YOLOv8 Medium (cattle diseases)

## Monitoring

The monitoring script checks every 5 minutes and will:
- Display current epoch and accuracy metrics
- Check if models have reached 99%+ accuracy
- Automatically copy models to `assets/models/` when ready
- Notify when training is complete

## Model Integration

Once training completes and models are copied:

1. **Update Flutter dependencies:**
```bash
flutter clean
flutter pub get
```

2. **Verify ONNX Runtime API:**
   - The ONNX Runtime integration in `lib/services/disease_detection_service.dart` may need API adjustments
   - Check the actual method names once models are available
   - The code includes fallback to mock detection until API is verified

3. **Test Camera Integration:**
   - The camera is already integrated in `lib/screens/farmer/upload_image_screen.dart`
   - Models will be automatically loaded when available in `assets/models/`

## Files Modified

- `ml/train_all.py` - Updated to 50 epochs, 99-100% accuracy target
- `ml/monitor_training.py` - Updated to check for 99%+ accuracy
- `ml/monitor_training_loop.py` - New: Monitors every 5 minutes
- `ml/train_and_monitor.py` - New: Runs training with auto-monitoring
- `lib/services/disease_detection_service.dart` - ONNX Runtime integration (may need API verification)

## Troubleshooting

### Models not reaching 99% accuracy
- Check dataset quality and size
- Verify data augmentation settings
- Consider adjusting learning rate or model size

### ONNX Runtime API errors
- The exact API method names may vary by package version
- Check `onnxruntime` package documentation
- The code includes try-catch fallbacks to mock detection

### Models not copying automatically
- Manually run: `python ml/copy_models_to_flutter.py`
- Check that models exist in `ml/runs/` directories
- Verify ONNX export completed successfully

