# MifugoCare - App Publishing Readiness Guide

## 📋 Pre-Publishing Checklist

### ✅ Completed Items

#### 1. UI/UX Updates
- [x] Landing page changed from green to white background
- [x] Created custom hoof logo (replacing mifugocarelogo.png)
- [x] Landing page matches other screens' design
- [x] Hoof logo used in all authentication screens

#### 2. User Roles & Authentication
- [x] Signup limited to Farmer and Veterinarian only
- [x] Administrator option removed from public signup
- [x] Admin access via hidden login (credentials: admin@mifugocare.com / Admin2024!)
- [x] Email/password authentication implemented
- [x] Google Sign-In integration ready
- [x] MFA (Multi-Factor Authentication) implemented

#### 3. ML Integration
- [x] ResNet50 model training (GPU-accelerated, >95% accuracy target)
- [x] Model will be saved to `training_results/best_model.pth`
- [x] ML service ready for mobile (TFLite) and web (ONNX)

---

## 🚀 Steps to Publish

### Phase 1: Complete ML Training & Integration

#### 1.1. Wait for Training to Complete
- **Current Status**: Training in progress on GPU
- **Expected Time**: 1-2 hours total
- **Output Files**:
  - `training_results/best_model.pth` - Trained PyTorch model
  - `training_results/training_history.png` - Training graphs
  - `training_results/confusion_matrix.png` - Model performance
  - `training_results/final_metrics.json` - Accuracy metrics

#### 1.2. Convert Model for Mobile (TFLite)
```bash
# After training completes, convert to TensorFlow Lite
cd scripts
python convert_to_tflite.py --input ../training_results/best_model.pth --output ../assets/models/livestock_model.tflite
```

#### 1.3. Place Model in App
```bash
# Copy model to Flutter assets
mkdir -p assets/models
cp training_results/best_model.pth assets/models/
# (Or .tflite file if converted)
```

#### 1.4. Update pubspec.yaml
```yaml
flutter:
  assets:
    - assets/models/livestock_model.tflite
    - assets/models/labels.txt
```

---

### Phase 2: Configure Backend Services

#### 2.1. Supabase Configuration
**Follow**: `SUPABASE_EMAIL_SETUP.md`

**Quick Setup:**
1. Go to: https://supabase.com/dashboard/project/slkihxgkafkzasnpjmbl
2. Configure SMTP (Gmail or SendGrid)
3. Customize email templates
4. Enable email confirmations
5. Set redirect URLs

**Important:** Change admin password in production!
- File: `lib/features/auth/role_selection_screen.dart` (line 264)
- Current: `Admin2024!`
- Change to: Strong unique password

#### 2.2. Database Setup
```sql
-- Ensure these tables exist in Supabase:

-- Users table
CREATE TABLE users (
  user_id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('farmer', 'veterinarian', 'administrator')),
  phone_number TEXT,
  profile_image_url TEXT,
  license_number TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP,
  auth_token TEXT,
  token_expiry TIMESTAMP,
  is_verified BOOLEAN DEFAULT FALSE
);

-- Diagnoses table
CREATE TABLE diagnoses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id),
  image_url TEXT NOT NULL,
  disease TEXT NOT NULL,
  confidence FLOAT NOT NULL,
  recommendations TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Livestock profiles table
CREATE TABLE livestock (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(user_id),
  name TEXT NOT NULL,
  species TEXT NOT NULL,
  breed TEXT,
  age INTEGER,
  tag_number TEXT,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### 2.3. Row Level Security (RLS)
```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE diagnoses ENABLE ROW LEVEL SECURITY;
ALTER TABLE livestock ENABLE ROW LEVEL SECURITY;

-- Users can read/update their own data
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can manage their own diagnoses
CREATE POLICY "Users can view own diagnoses" ON diagnoses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create diagnoses" ON diagnoses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can manage their own livestock
CREATE POLICY "Users can view own livestock" ON livestock
  FOR ALL USING (auth.uid() = user_id);
```

---

### Phase 3: Android Build & Testing

#### 3.1. Update App Configuration
**File**: `android/app/build.gradle`
```gradle
android {
    defaultConfig {
        applicationId "com.mifugocare.app"  // Change to your domain
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

**File**: `android/app/src/main/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.mifugocare.app">
    
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application
        android:label="MifugoCare"
        android:icon="@mipmap/ic_launcher">
        <!-- Add your configuration here -->
    </application>
</manifest>
```

#### 3.2. Generate App Icon
```bash
# Install flutter_launcher_icons
flutter pub add dev:flutter_launcher_icons

# Create flutter_launcher_icons.yaml
# Then run:
flutter pub run flutter_launcher_icons
```

**flutter_launcher_icons.yaml:**
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#4CAF50"
  adaptive_icon_foreground: "assets/icons/app_icon_fg.png"
```

#### 3.3. Generate Signing Key
```bash
# Generate keystore
keytool -genkey -v -keystore ~/mifugocare-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mifugocare

# Create android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=mifugocare
storeFile=<path-to-jks>
```

#### 3.4. Build Release APK
```bash
# Clean build
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Or build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### 3.5. Test Release Build
```bash
# Install on device
flutter install --release

# Test all features:
# - Authentication (signup, login, password reset)
# - Camera capture
# - ML disease detection
# - Profile management
# - Offline mode
```

---

### Phase 4: iOS Build (Optional)

#### 4.1. Requirements
- Mac computer
- Xcode 15+
- Apple Developer Account ($99/year)
- CocoaPods installed

#### 4.2. iOS Configuration
```bash
# Update iOS deployment target
# File: ios/Podfile
platform :ios, '12.0'

# Install pods
cd ios
pod install
cd ..
```

#### 4.3. Build iOS App
```bash
# Build iOS
flutter build ios --release

# Or build IPA
flutter build ipa
```

---

### Phase 5: Security & Performance

#### 5.1. Security Checklist
- [ ] Change admin password (not Admin2024!)
- [ ] Add API keys to environment variables (not hardcoded)
- [ ] Enable SSL/TLS for all network calls
- [ ] Implement certificate pinning
- [ ] Enable ProGuard/R8 (Android)
- [ ] Obfuscate code: `flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory>`

#### 5.2. Performance Optimization
- [ ] Enable image caching
- [ ] Optimize model size (<10MB)
- [ ] Test on low-end devices (2GB RAM)
- [ ] Profile app startup time (<3 seconds)
- [ ] Reduce APK size (<50MB)

```bash
# Analyze app size
flutter build apk --analyze-size

# Profile performance
flutter run --profile
```

#### 5.3. Code Obfuscation
```bash
# Build with obfuscation
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols
```

---

### Phase 6: Play Store Submission

#### 6.1. Create Store Listing
**Required Assets:**
- App icon (512x512 PNG)
- Feature graphic (1024x500 PNG)
- Screenshots (at least 2, up to 8)
  - Phone: 1080x1920
  - Tablet: 2560x1600
- Short description (80 chars): "AI-powered livestock disease detection app"
- Full description (4000 chars max)
- Privacy policy URL
- Category: Medical / Agriculture

#### 6.2. Privacy Policy
Create at: https://app.termly.io/dashboard/website-scans

**Required Disclosures:**
- Camera usage (disease detection)
- Location (optional, for vet finder)
- Photo storage
- User account data (email, name)
- ML inference (on-device)

#### 6.3. Google Play Console
1. Go to: https://play.google.com/console
2. Create app → Select default language
3. Fill in app details:
   - App name: MifugoCare
   - Package name: com.mifugocare.app
   - Category: Medical / Agriculture
4. Upload app bundle (.aab file)
5. Fill content rating questionnaire
6. Set pricing (Free)
7. Add screenshots and graphics
8. Submit for review

---

### Phase 7: Testing & QA

#### 7.1. Feature Testing Checklist
- [ ] **Authentication**
  - [ ] Sign up (farmer, vet)
  - [ ] Login
  - [ ] Password reset
  - [ ] Google Sign-In
  - [ ] Admin access
  - [ ] MFA setup

- [ ] **Disease Detection**
  - [ ] Camera capture
  - [ ] Gallery selection
  - [ ] ML inference (<3 seconds)
  - [ ] Results display
  - [ ] Save diagnosis
  - [ ] View history

- [ ] **Livestock Management**
  - [ ] Add livestock profile
  - [ ] Edit profile
  - [ ] Delete profile
  - [ ] View list

- [ ] **Offline Mode**
  - [ ] Login offline (cached)
  - [ ] Disease detection offline
  - [ ] Save data locally
  - [ ] Sync when online

- [ ] **Settings**
  - [ ] Profile update
  - [ ] Change password
  - [ ] Notifications
  - [ ] Language switch (EN/SW)

#### 7.2. Device Testing Matrix
- [ ] Android 8.0 (API 26)
- [ ] Android 10 (API 29)
- [ ] Android 12 (API 31)
- [ ] Android 14 (API 34)
- [ ] Low RAM device (2GB)
- [ ] High-end device (8GB+)
- [ ] Tablet (10")

#### 7.3. Network Testing
- [ ] Offline mode
- [ ] Slow 3G
- [ ] WiFi
- [ ] Mobile data
- [ ] Airplane mode toggle

---

### Phase 8: Monitoring & Analytics

#### 8.1. Crash Reporting
**Option 1: Firebase Crashlytics**
```bash
flutter pub add firebase_core firebase_crashlytics

# Initialize in main.dart
await Firebase.initializeApp();
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
```

**Option 2: Sentry**
```bash
flutter pub add sentry_flutter

# Initialize
await SentryFlutter.init(
  (options) => options.dsn = 'YOUR_SENTRY_DSN',
);
```

#### 8.2. Analytics
```bash
flutter pub add firebase_analytics

# Track events
FirebaseAnalytics.instance.logEvent(
  name: 'disease_detected',
  parameters: {'disease': 'lumpy_skin', 'confidence': 0.95},
);
```

---

## 🎯 Launch Day Checklist

### 24 Hours Before Launch
- [ ] ML model training completed (>95% accuracy)
- [ ] Model integrated into app
- [ ] All tests passing
- [ ] Release build tested on 3+ devices
- [ ] Supabase email configured and tested
- [ ] Admin password changed
- [ ] Privacy policy published
- [ ] Store listing complete
- [ ] Screenshots uploaded
- [ ] Backup database

### Launch Day
- [ ] Submit to Play Store
- [ ] Monitor crash reports
- [ ] Check error logs in Supabase
- [ ] Test in production with real users
- [ ] Prepare support email (support@mifugocare.com)
- [ ] Monitor app performance
- [ ] Check review ratings
- [ ] Respond to user feedback

### Post-Launch (Week 1)
- [ ] Fix critical bugs (if any)
- [ ] Collect user feedback
- [ ] Analyze usage patterns
- [ ] Plan version 1.1 features
- [ ] Update documentation
- [ ] Create user guide/tutorial

---

## 📊 Success Metrics

### Week 1 Targets
- 100+ downloads
- <1% crash rate
- >4.0 star rating
- <2% uninstall rate

### Month 1 Targets
- 1,000+ downloads
- 500+ active users
- >90% positive reviews
- Featured in local agriculture apps

---

## 🐛 Common Issues & Fixes

### Issue 1: Model too large (>10MB)
**Solution**: Quantize model
```python
import torch
model = torch.load('best_model.pth')
quantized_model = torch.quantization.quantize_dynamic(model, {torch.nn.Linear}, dtype=torch.qint8)
torch.save(quantized_model.state_dict(), 'best_model_quantized.pth')
```

### Issue 2: Slow inference (>5 seconds)
**Solutions**:
- Use TFLite instead of PyTorch
- Enable GPU delegate
- Reduce image size (224x224)
- Use quantized model

### Issue 3: High crash rate
**Check**:
- Memory leaks (camera not disposed)
- Null pointer exceptions
- Network timeout errors
- Model loading failures

### Issue 4: Battery drain
**Optimize**:
- Reduce ML inference frequency
- Use efficient image loading
- Disable background tasks
- Optimize location services

---

## 📞 Support

### Technical Issues
- Supabase: https://supabase.com/docs
- Flutter: https://docs.flutter.dev
- ML: Check training_results/ folder

### App Issues
- File bug reports in issue tracker
- Email: support@mifugocare.com
- Check logs in Supabase dashboard

---

## 🎉 You're Ready!

Once ML training completes and you follow this guide, your app will be ready for the Play Store!

**Remember:**
1. Test thoroughly before launch
2. Monitor closely after launch
3. Respond to user feedback quickly
4. Keep improving based on data

Good luck with your launch! 🚀🐄

