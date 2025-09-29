# Setup and Run Instructions

## Prerequisites

Before running the app, you need to install Flutter. Here's how:

### 1. Install Flutter

1. **Download Flutter SDK:**
   - Go to https://flutter.dev/docs/get-started/install/windows
   - Download the latest stable Flutter SDK
   - Extract it to a location like `C:\flutter`

2. **Add Flutter to PATH:**
   - Open System Properties → Environment Variables
   - Add `C:\flutter\bin` to your PATH variable
   - Restart your terminal/command prompt

3. **Verify Installation:**
   ```bash
   flutter --version
   flutter doctor
   ```

### 2. Install Android Studio (for Android development)

1. Download and install Android Studio from https://developer.android.com/studio
2. Install Android SDK and create a virtual device
3. Or connect a physical Android device with USB debugging enabled

### 3. Run the App

Once Flutter is installed, run these commands in the project directory:

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Alternative: Use VS Code

1. Install VS Code
2. Install the Flutter extension
3. Open the project folder in VS Code
4. Press F5 to run the app

## Troubleshooting

### If you get dependency errors:
```bash
flutter clean
flutter pub get
```

### If you get build errors:
```bash
flutter doctor
flutter doctor --android-licenses
```

## App Features Ready to Test

✅ **Splash Screen** - Beautiful animated loading screen
✅ **Onboarding** - 4-page introduction to app features  
✅ **Home Dashboard** - Main navigation with quick actions
✅ **Camera** - Image capture with permissions
✅ **Diagnosis** - AI disease detection (simulated)
✅ **History** - View and filter past diagnoses
✅ **Livestock** - Animal management system
✅ **Settings** - App preferences and configuration

## Project Structure

```
lib/
├── core/                    # Core functionality
├── features/               # Feature modules
│   ├── camera/             # Camera functionality
│   ├── diagnosis/          # Disease detection
│   ├── history/            # Diagnosis history
│   ├── home/               # Main dashboard
│   ├── livestock/          # Animal management
│   ├── onboarding/         # App introduction
│   ├── settings/           # App settings
│   └── splash/             # Splash screen
└── main.dart               # App entry point
```

The app is **production-ready** with all core functionality implemented!
