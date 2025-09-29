# Mifugo Care - Flutter

A mobile application for livestock disease detection using computer vision and machine learning. This Flutter app helps farmers and veterinarians identify diseases in livestock through image analysis.

## Features

- **AI-Powered Disease Detection**: Uses TensorFlow Lite for real-time disease identification
- **Camera Integration**: Capture and analyze livestock images
- **Disease Database**: Comprehensive information about various livestock diseases
- **Diagnosis History**: Track and manage diagnosis records
- **Livestock Management**: Keep records of your animals
- **Multi-language Support**: English and Swahili localization
- **Offline Capability**: Works without internet connection

## Supported Diseases

The app can detect the following livestock diseases:

1. **Foot and Mouth Disease** - High severity, contagious
2. **Mastitis** - Medium severity, affects dairy cattle
3. **Lumpy Skin Disease** - High severity, contagious
4. **Blackleg** - Critical severity, high mortality
5. **Anthrax** - Critical severity, highly contagious
6. **Pneumonia** - Medium severity, respiratory infection
7. **Mange** - Low severity, skin condition
8. **Ringworm** - Low severity, fungal infection
9. **Bloat** - Medium severity, digestive issue
10. **Healthy** - Normal physiological state

## Technology Stack

- **Framework**: Flutter 3.10+
- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **Machine Learning**: TensorFlow Lite
- **Camera**: camera plugin
- **Image Processing**: image package
- **Navigation**: go_router
- **Localization**: flutter_localizations

## Project Structure

```
lib/
├── core/
│   ├── database/
│   │   └── database_helper.dart
│   ├── localization/
│   │   └── app_localizations.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── camera/
│   │   └── presentation/
│   │       └── pages/
│   │           └── camera_page.dart
│   ├── diagnosis/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── diagnosis_repository.dart
│   │   │   └── services/
│   │   │       └── tensorflow_service.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── diagnosis.dart
│   │   │       └── diagnosis_result.dart
│   │   └── presentation/
│   │       └── pages/
│   │           └── diagnosis_page.dart
│   ├── disease/
│   │   └── domain/
│   │       └── entities/
│   │           └── disease.dart
│   ├── history/
│   │   └── presentation/
│   │       └── pages/
│   │           └── history_page.dart
│   ├── home/
│   │   └── presentation/
│   │       └── pages/
│   │           └── home_page.dart
│   ├── livestock/
│   │   └── domain/
│   │       └── entities/
│   │           └── livestock.dart
│   ├── onboarding/
│   │   └── presentation/
│   │       └── pages/
│   │           └── onboarding_page.dart
│   ├── settings/
│   │   └── presentation/
│   │       └── pages/
│   │           └── settings_page.dart
│   └── splash/
│       └── presentation/
│           └── pages/
│               └── splash_page.dart
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

## Usage

1. **First Launch**: The app will show an onboarding screen for new users
2. **Camera Access**: Grant camera permission when prompted
3. **Capture Image**: Use the camera to take a photo of livestock
4. **Analysis**: The app will analyze the image using AI
5. **Results**: View detailed diagnosis results with treatment recommendations
6. **History**: Access previous diagnoses from the history tab

## Model Information

- **Input Size**: 224x224 pixels
- **Number of Classes**: 10 diseases + healthy
- **Confidence Threshold**: 70%
- **Model Format**: TensorFlow Lite (.tflite)

## Database Schema

The app uses SQLite with the following main tables:

- **diseases**: Disease information and metadata
- **livestock**: Animal records and details
- **diagnoses**: Diagnosis history and results

## Localization

The app supports multiple languages:
- English (en)
- Swahili (sw)

## Permissions

The app requires the following permissions:
- Camera access for image capture
- Storage access for saving images
- Network access for potential future features

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

## Roadmap

- [ ] Add more disease types
- [ ] Implement cloud sync
- [ ] Add veterinary consultation features
- [ ] Improve model accuracy
- [ ] Add batch processing
- [ ] Implement notifications
- [ ] Add data export features

## Acknowledgments

- TensorFlow Lite team for the ML framework
- Flutter team for the cross-platform framework
- Agricultural research institutions for disease data
- Open source community for various packages used