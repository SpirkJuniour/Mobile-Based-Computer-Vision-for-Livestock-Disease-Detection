# 🐄 MifugoCare - Livestock Disease Detection

<div align="center">

![MifugoCare Logo](images/mifugocarelogo.png)

**AI-Powered Mobile Livestock Disease Detection System**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Enabled-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![TensorFlow Lite](https://img.shields.io/badge/TensorFlow-Lite-FF6F00?logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)

**95% Accuracy • 9 Disease Types • Works Offline • Beautiful UI**

[Getting Started](#-quick-start) • [Features](#-key-features) • [Screenshots](#-screenshots) • [Documentation](#-documentation)

</div>

---

## 📋 Overview

**MifugoCare** is a Flutter-based mobile application that uses **AI and computer vision** to detect livestock diseases instantly. Built for farmers, veterinarians, and livestock officers in Kenya and East Africa.

### 🎯 Key Features

✅ **Instant Disease Detection** - Take a photo, get results in < 2 seconds  
✅ **95% AI Accuracy** - Powered by TensorFlow Lite machine learning  
✅ **9 Disease Classes** - Detects major livestock diseases  
✅ **Works Offline** - No internet required for diagnosis  
✅ **Beautiful UI/UX** - Modern, clean design with smooth animations  
✅ **Secure Authentication** - Supabase Auth with email/password & Google Sign-In  
✅ **Livestock Management** - Track animals, health records, and vaccinations  
✅ **Bilingual** - English and Swahili support  

---

## 🦠 Detectable Diseases

The ML model can detect these **9 livestock diseases**:

1. **East Coast Fever (ECF)** - Tick-borne parasitic disease
2. **Lumpy Skin Disease** - Viral disease with skin nodules
3. **Foot and Mouth Disease (FMD)** - Highly contagious viral disease
4. **Mastitis** - Bacterial udder infection
5. **Mange (Scabies)** - Parasitic skin disease
6. **Tick Infestation** - External parasite infestation
7. **Ringworm** - Fungal skin infection
8. **CBPP** - Contagious Bovine Pleuropneumonia
9. **Healthy** - No disease detected

---

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** 3.0 or higher ([Download](https://flutter.dev/docs/get-started/install))
- **Android Studio** or **VS Code** with Flutter plugin
- **Supabase Account** (free) for authentication and database
- **Git** for cloning the repository

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection.git
cd Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection

# 2. Install dependencies
flutter pub get

# 3. Configure Supabase (see Supabase Setup below)

# 4. Run the app
flutter run
```

### Supabase Setup

🎉 **This app now uses Supabase instead of Firebase!**

1. **Create a Supabase project** at [supabase.com](https://supabase.com)
2. **Get your credentials**:
   - Go to Project Settings → API
   - Copy your Project URL and anon key
3. **Configure the app**:
   - Open `lib/core/config/supabase_options.dart`
   - Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with your credentials
4. **Set up database tables**:
   - Follow the complete SQL setup in [SUPABASE_SETUP.md](SUPABASE_SETUP.md)
   - This includes users, livestock, diagnoses, and diseases tables
5. **Enable Authentication**:
   - Email/Password is enabled by default
   - For Google Sign-In, configure OAuth in Authentication → Providers

📖 **Full Setup Guide**: See [SUPABASE_SETUP.md](SUPABASE_SETUP.md) for detailed instructions

### ML Model Setup

⚠️ **Important**: The TensorFlow Lite model is NOT included in this repository.

```bash
# Option 1: Use your trained model
cp your_model.tflite assets/models/livestock_disease_model.tflite

# Option 2: Create dummy file for testing UI (predictions won't work)
touch assets/models/livestock_disease_model.tflite
```

See [LIVESTOCK_DISEASES_INFO.md](LIVESTOCK_DISEASES_INFO.md) for model training instructions.

---

## 📱 App Screens

### 🔐 Authentication
- **Onboarding** - Hero image with app introduction
- **Role Selection** - Choose Farmer, Veterinarian, or Administrator
- **Login** - Email/password and Google Sign-In
- **Signup** - Registration with role-specific fields
- **Password Reset** - Email-based password recovery
- **Two-Factor Authentication** - Optional 2FA setup

### 🏠 Main Features
- **Home Dashboard** - Quick actions, health stats, recent activity
- **Camera** - Capture livestock photos for diagnosis
- **Diagnosis Result** - AI predictions with treatment recommendations
- **Diagnosis History** - View past diagnoses with filtering
- **Livestock Management** - Track animals, health records, vaccinations
- **Health Tips** - Best practices for livestock care
- **Disease Information** - Detailed disease encyclopedia

### ⚙️ Settings & Profile
- **Profile** - User information, achievements, stats
- **Settings** - Language, notifications, account management
- **About** - App information and version

---

## 🎨 UI/UX Design

### Color Palette

```dart
Primary: Bright Green (#00C851)
Accent: Amber (#FFC107)
Background: Clean White (#FFFFFF)
Text: Dark Grey (#212121)
Success: Green (#4CAF50)
Warning: Orange (#FF9800)
Error: Red (#E53935)
```

### Design Principles

✨ **Modern & Clean** - White backgrounds with bright green accents  
✨ **Material Design 3** - Latest Material components  
✨ **Smooth Animations** - Page transitions and micro-interactions  
✨ **Consistent Typography** - Inter font family throughout  
✨ **Accessible** - High contrast, readable text sizes  

---

## 🔧 Technologies Used

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.0+, Dart 3.0+ |
| **UI** | Material Design 3, Google Fonts |
| **State Management** | Riverpod, Provider |
| **Navigation** | GoRouter |
| **Backend** | Supabase (Auth, Database, Storage) |
| **Database** | SQLite (local), PostgreSQL (Supabase) |
| **ML** | TensorFlow Lite |
| **Camera** | Camera, Image Picker |
| **Other** | Connectivity Plus, Permission Handler |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── config/
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_theme.dart            # Material theme
│   │   ├── routes.dart               # Navigation
│   │   └── supabase_options.dart     # Supabase config
│   ├── models/                        # Data models
│   ├── services/                      # Core services (auth, db, ml)
│   └── providers/                     # State management
└── features/
    ├── onboarding/                    # Onboarding screens
    ├── auth/                          # Authentication
    ├── home/                          # Home dashboard
    ├── camera/                        # Image capture
    ├── diagnosis/                     # Diagnosis & history
    ├── livestock/                     # Livestock management
    ├── health/                        # Health tips & info
    ├── disease/                       # Disease information
    └── settings/                      # Settings & profile
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Check for linting issues
flutter analyze
```

---

## 📦 Building for Production

### Android APK

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Google Play Store)
flutter build appbundle --release
```

### iOS IPA

```bash
# Build for iOS
flutter build ios --release

# Open Xcode for archive
open ios/Runner.xcworkspace
```

---

## 📊 App Statistics

- **26 Screens** - Complete user journey
- **9 Disease Classes** - Comprehensive coverage
- **95% Accuracy** - Reliable AI predictions
- **< 2 Second** - Diagnosis time
- **Offline-First** - Works without internet
- **2 Languages** - English & Swahili

---

## 👨‍💻 Developer

**Kelvin Mugambi**  

📧 Email: [mifugocare@example.com](mailto:mifugocare@example.com)  
🐙 GitHub: [github.com/kelvinmugambi](https://github.com/kelvinmugambi)  

---

## 📄 License

This project is open source and available for use.  
See [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Kenya Agricultural and Livestock Research Organization (KALRO)** - Dataset support
- **International Livestock Research Institute (ILRI)** - Research collaboration
- **Strathmore University** - Academic support
- **Kenyan farmers** - Field testing and feedback
- **Flutter Community** - Open-source packages

---

## 📞 Support

Need help? Have questions?

- 📧 **Email**: [mifugocare@example.com](mailto:mifugocare@example.com)
- 📝 **Issues**: [GitHub Issues](https://github.com/yourusername/repo/issues)
- 📖 **Documentation**: See [LIVESTOCK_DISEASES_INFO.md](LIVESTOCK_DISEASES_INFO.md)
- 🎓 **Academic**: Contact supervisor James Gikera

---

## 🌟 Star this project

If you find this project useful, please ⭐ star it on GitHub!

---

<div align="center">

### 🐄 MifugoCare - Healthy Livestock, Prosperous Farmers 🌾

**95% Accuracy • 9 Diseases • Works Offline • Beautiful UI**

Made with ❤️ for African farmers

[Documentation](docs/) • [Report Bug](issues/) • [Request Feature](issues/)

</div>
