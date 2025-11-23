# How to View Logs from Android APK

When running your app via APK on an Android device, you can view the debug logs using Android Debug Bridge (adb). The `debugPrint()` statements in your code will appear in these logs.

## Prerequisites

1. **Enable USB Debugging** on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

2. **Install ADB** (Android Debug Bridge):
   - ADB comes with Android SDK Platform Tools
   - Download from: https://developer.android.com/studio/releases/platform-tools
   - Or install via Android Studio (it's included)

3. **Connect your device** via USB cable

## Quick Start

### Option 1: Use the Provided Scripts (Windows)

I've created batch files for you:

1. **`check_logs.bat`** - View filtered logs (disease detection only)
2. **`check_logs_detailed.bat`** - View all Flutter logs
3. **`check_logs_save.bat`** - Save logs to a file

Just double-click any of these scripts while your device is connected.

### Option 2: Manual Commands

#### View All Flutter Logs
```bash
adb logcat | grep -i flutter
```

#### View Only Disease Detection Logs
```bash
adb logcat | grep -i "disease_detection_service"
```

#### View Model Outputs and Probabilities
```bash
adb logcat | grep -i "model\|probability\|confidence\|classification"
```

#### Clear Log Buffer and Start Fresh
```bash
adb logcat -c
adb logcat | grep -i flutter
```

#### Save Logs to File
```bash
adb logcat | grep -i flutter > flutter_logs.txt
```

## What to Look For

When testing disease detection, look for these log messages:

### Model Initialization
```
✅ ONNX Runtime initialized
✅ Classification model loaded successfully
Model Status - Classification: true, Detection: false
```

### Image Processing
```
Image decoded: 1920x1080
Using classification model
```

### Model Outputs
```
Model output shape: 11 classes
Raw model outputs: 2.345, -1.234, 0.567...
=== All Class Probabilities ===
  0: (BRD) -> Bovine Respiratory Disease = 5.23%
  1: Bovine -> Bovine (General) = 2.15%
  ...
  8: healthy -> Healthy = 45.67%
  9: lumpy -> Lumpy Skin Disease = 12.34%
  10: skin -> Lumpy Skin Disease = 8.90%
================================
```

### Final Results
```
Classification result: Healthy (confidence: 45.7%)
Selected index: 8 (dataset class: healthy)
```

### Combination Logic
```
Combining lumpy and skin: top1=45.2%, top2=32.1%
```
or
```
Not combining: top1=12.3%, top2=8.9% (thresholds not met)
```

### Warnings
```
⚠️ Low confidence score: 35.2% - Model may need retraining
⚠️ Very low confidence score: 15.8% - Defaulting to Healthy
```

## Troubleshooting

### "adb: command not found"
- Make sure ADB is installed and in your PATH
- On Windows, you may need to add the platform-tools folder to your PATH
- Or use the full path: `C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools\adb.exe`

### "device not found"
- Make sure USB debugging is enabled
- Try: `adb devices` to see if your device is recognized
- You may need to authorize the computer on your device (a popup will appear)

### No logs appearing
- Make sure the app is running
- Try clearing the log buffer: `adb logcat -c`
- Check if logs are being filtered too strictly - try without grep/findstr

### View logs in real-time while testing
1. Connect device and run: `adb logcat | grep -i flutter`
2. Keep the terminal open
3. Use the app on your device
4. Watch the logs appear in real-time

## Alternative: Use Android Studio Logcat

If you have Android Studio installed:

1. Open Android Studio
2. Connect your device
3. Go to View → Tool Windows → Logcat
4. Filter by package name: `com.example.mifugo_care` (or your app's package name)
5. Filter by tag: `flutter` or `disease_detection_service`

## Understanding the Logs

The disease detection service logs will show:
- **Model loading status** - Whether models loaded successfully
- **Image preprocessing** - Image dimensions and preprocessing steps
- **Model inference** - Raw outputs and processed probabilities
- **Class probabilities** - Confidence for each disease class
- **Final prediction** - Selected disease and confidence score
- **Warnings** - Low confidence or model issues

This helps you debug why certain diseases are detected and verify the model is working correctly.

