# MifugoCare 🐄

**Mobile-Based Computer Vision for Livestock Disease Detection**

An AI-powered mobile application for livestock health monitoring and disease diagnosis designed for farmers in Kenya and East Africa. Built with Flutter and powered by machine learning, MifugoCare helps farmers detect livestock diseases early through image analysis.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey.svg)](https://github.com)

---

## 🌟 Features

### Core Functionality
- 📸 **AI Disease Detection** - Capture or upload livestock images for instant disease analysis
- 🤖 **ML-Powered Diagnosis** - Advanced computer vision model trained on 11 livestock disease classes
- 📊 **Health Dashboard** - Track livestock health history and diagnosis records
- 🐮 **Livestock Management** - Manage your livestock profiles and health records
- 📱 **Offline-First** - Works without internet using local SQLite database
- 🔐 **Secure Authentication** - Supabase-powered authentication with offline mode

### Disease Detection Classes
1. Bovine Respiratory Disease (BRD)
2. Lumpy Skin Disease
3. Contagious Dermatitis
4. Contagious Ecthyma (Orf)
5. Respiratory Disease
6. Bovine Disease (General)
7. Dermatitis
8. Healthy - No Disease
9. Unlabeled/Unknown
10. Disease (Unspecified)
11. Skin Disease

### Additional Features
- 🏥 Vaccination information and health tips
- 📖 Disease information library
- 🐂 Beef and goat farming guides
- 💬 Community chat support
- 📍 Location-based services
- 🔔 Notifications and alerts

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0 or higher
- Android Studio / Xcode for platform development
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection.git
   cd Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase** (Optional - works offline without it)
   - Copy `.env.example` to `.env`
   - Add your Supabase credentials
   - Or use environment variables:
   ```bash
   flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_KEY=your_key
   ```

4. **Run the app**
   ```bash
   # Android
   flutter run

   # iOS
   flutter run -d ios

   # Web
   flutter run -d chrome
   ```

---

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration (theme, routes, colors)
│   ├── models/          # Data models (User, Diagnosis, Livestock)
│   ├── services/        # Core services (Auth, Database, ML)
│   └── widgets/         # Reusable widgets
├── features/            # Feature modules
│   ├── auth/           # Authentication screens
│   ├── camera/         # Camera & image capture
│   ├── diagnosis/      # Disease diagnosis screens
│   ├── home/           # Dashboard
│   ├── livestock/      # Livestock management
│   └── ...             # Other features
└── main.dart           # App entry point

assets/
├── models/             # ML model files (.tflite)
├── disease_labels.txt  # Disease class labels
├── images/             # App images
└── icons/              # Icons and graphics

scripts/
├── train_simple_model.py  # Model training script
└── training_outputs/      # Trained models
```

---

## 🤖 Machine Learning Model

### Current Status
The app uses `MLServiceAlternatives` which provides image analysis-based disease detection. For production use, train and deploy a TensorFlow Lite model.

### Model Training

**Option 1: Google Colab (Recommended)**
1. Open `colab_training/livestock_disease_training.ipynb` in Google Colab
2. Follow the instructions in `USE_GOOGLE_COLAB.md`
3. Train the model on your dataset
4. Download the `.tflite` file
5. Place it in `assets/models/`

**Option 2: Local Training**
```bash
cd scripts
pip install -r requirements_tensorflow.txt
python train_simple_model.py
```

### Model Specifications
- **Architecture:** MobileNetV2 (Transfer Learning)
- **Input Size:** 224x224x3
- **Classes:** 11 livestock disease categories
- **Format:** TensorFlow Lite (.tflite)
- **Current Accuracy:** ~85% (based on training data)

See `assets/models/README.md` for detailed model information.

---

## 🔧 Configuration

### Android Setup
- **Min SDK:** 21 (Android 5.0)
- **Target SDK:** 33 (Android 13)
- **Permissions:** Camera, Internet, Storage (configured)

### iOS Setup
- **Min iOS Version:** 12.0
- **Permissions:** Camera, Photo Library (configured in Info.plist)

### Supabase Backend (Optional)
Create a project at [supabase.com](https://supabase.com) and configure:
- Authentication (Email, Google Sign-In)
- Database tables (users, livestock, diagnoses)
- Row Level Security policies

---

## 📱 Screenshots

| Dashboard | Camera | Diagnosis |
|-----------|--------|-----------|
| *Home screen with health overview* | *Capture livestock image* | *Disease detection results* |

---

## 🛠️ Development

### Run Tests
```bash
flutter test
```

### Analyze Code
```bash
flutter analyze
```

### Build Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📋 Roadmap

- [x] Core app structure with Flutter
- [x] Camera integration for image capture
- [x] ML service implementation (alternative)
- [x] Offline-first architecture
- [x] Authentication system
- [ ] Train production TFLite model
- [ ] Real-time veterinarian chat
- [ ] Multi-language support (Swahili, English)
- [ ] Weather integration for disease prediction
- [ ] Livestock marketplace
- [ ] iOS App Store release
- [ ] Google Play Store release

---

## 🐛 Known Issues

- TFLite model not yet integrated (using alternative ML service)
- Web version has limited camera support
- Some features require internet connectivity

See `PROJECT_HEALTH_CHECK_REPORT.md` for detailed project status.

---

## 📚 Documentation

- [Training Guide](USE_GOOGLE_COLAB.md) - How to train the ML model
- [ML Integration](ML_INTEGRATION_GUIDE.md) - Integrating TensorFlow Lite
- [Project Status](FINAL_PROJECT_STATUS.md) - Detailed project status
- [Health Check Report](PROJECT_HEALTH_CHECK_REPORT.md) - Latest project audit

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- TensorFlow team for ML tools
- Supabase for backend infrastructure
- Roboflow for dataset management
- The agricultural community in Kenya and East Africa

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

**MifugoCare Team**
- Your Name - *Initial work*

---

## 📞 Support

For support, email support@mifugocare.com or join our community chat.

---

## ⚡ Tech Stack

- **Frontend:** Flutter 3.0+, Dart
- **ML:** TensorFlow Lite, MobileNetV2
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Database:** SQLite (local), PostgreSQL (cloud)
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Camera:** camera plugin
- **Image Processing:** image package

---

**Made with ❤️ for Livestock Farmers in East Africa**
