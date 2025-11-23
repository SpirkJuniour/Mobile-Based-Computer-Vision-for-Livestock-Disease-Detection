# Mifugo Care - Livestock Disease Detection App

A Flutter-based mobile application for detecting livestock diseases using computer vision and machine learning. Built for farmers and veterinarians in Kenya to improve livestock health management.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)
![License](https://img.shields.io/badge/License-MIT-blue)

## Features

### For Farmers
- 📸 **Image Upload & Disease Detection**: Capture and analyze livestock images for disease detection
- 🐄 **Livestock Management**: Register and manage your livestock records
- 📊 **Health History**: View diagnosis history and track animal health over time
- 🔔 **Notifications**: Receive alerts for disease detection and veterinarian responses
- 👨‍🌾 **Farmer Dashboard**: Clean, intuitive interface for managing your farm

### For Veterinarians
- 📋 **Case Review**: Review pending disease detection cases from farmers
- 📝 **Treatment Notes**: Add professional assessment and treatment plans
- 📈 **Case Management**: Track and manage all veterinary cases
- 🔔 **Notifications**: Stay updated on new cases and farmer requests
- 👨‍⚕️ **Veterinarian Dashboard**: Specialized interface for veterinary professionals

## Architecture

### Technologies Used
- **Frontend**: Flutter (cross-platform mobile app)
- **Backend**: Supabase (Backend-as-a-Service)
- **Authentication**: Supabase Auth
- **Database**: Supabase PostgreSQL
- **Storage**: Supabase Storage
- **Machine Learning**: ONNX Runtime (on-device inference with YOLOv11/YOLOv8 models)

### System Components

1. **User Authentication**: Supabase Auth with role-based access (Farmer/Veterinarian)
2. **Database Layer**: Supabase PostgreSQL for user profiles, livestock records, diagnoses, and vet cases
3. **Image Upload & Storage**: Supabase Storage for livestock images
4. **Disease Detection Engine**: ONNX Runtime with YOLOv11/YOLOv8 models for on-device inference
5. **Role-Based Dashboards**: Separate interfaces for farmers and veterinarians

## Design

- **Visual Style**: Inspired by Airbnb (clean, modern, smooth transitions)
- **Color Palette**:
  - Primary: #0066b2
  - Background: #FFFFFF
  - Card Color: #F8F9FA
- **Logo**: Minimalist hoof icon
- **UX**: Transparent modals, animated transitions, card-based layout

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.2 or later)
- Dart SDK
- Supabase account
- Android Studio / Xcode (for mobile development)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mifugo_care
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Supabase Setup**
   
   Create a Supabase project at [Supabase](https://supabase.com/)
   
   - Get your Supabase URL and anon key from Project Settings → API
   - Update `lib/main.dart` with your Supabase credentials:
     ```dart
     await Supabase.initialize(
       url: 'YOUR_SUPABASE_URL',
       anonKey: 'YOUR_SUPABASE_ANON_KEY',
     );
     ```

4. **Set up Database Schema**
   
   Run the **complete consolidated database setup script** in Supabase SQL Editor:
   ```sql
   -- Run the complete schema file: supabase_complete_schema.sql
   ```
   
   **⚠️ Important**: This consolidated file (`supabase_complete_schema.sql`) replaces all individual SQL files and contains everything needed for setup.
   
   This single script will:
   - Create all required tables (`users`, `livestock`, `diagnoses`, `vet_cases`, `notifications`)
   - Set up Row Level Security (RLS) policies for secure data access
   - Configure database triggers for auto-creating user profiles on signup
   - Create all necessary indexes for optimal query performance
   - Set up storage policies for image buckets
   - Configure auto-update triggers for timestamps
   
   **Quick Setup**: 
   1. Open `supabase_complete_schema.sql` in this repository
   2. Copy the entire contents
   3. Paste into Supabase Dashboard → SQL Editor
   4. Click "Run" to execute
   
   **Note**: If you have existing data, the script uses `CREATE TABLE IF NOT EXISTS` to avoid conflicts. For a fresh setup, you can uncomment the DROP TABLE statements at the beginning (use with caution!).

5. **Set up Storage Buckets**
   
   In Supabase Dashboard → Storage, create these buckets:
   - `livestock_images` (Public bucket, authenticated uploads)
   - `diagnosis_images` (Public bucket, authenticated uploads)
   
   The storage policies are already configured in the SQL script, so buckets will work automatically once created.

6. **Run the app**
   ```bash
   flutter run
   ```

## Machine Learning Integration

The app uses ONNX Runtime for on-device disease detection (`lib/services/disease_detection_service.dart`), enabling real-time inference without requiring internet connectivity.

### Model Architecture

- **Detection Model**: YOLOv11 Medium (`animal_pathologies_best.onnx`)
  - Detects and localizes disease symptoms in livestock images
  - Output: Bounding boxes with confidence scores
  
- **Classification Model**: YOLOv8 Medium (`cattle_diseases_best.onnx`)
  - Classifies detected regions into specific disease categories
  - Output: Disease labels with confidence percentages

### Model Training

See [TRAINING_INSTRUCTIONS.md](TRAINING_INSTRUCTIONS.md) for detailed training guide.

**Quick Start:**
```bash
# Navigate to ML directory
cd ml

# Install dependencies
pip install -r requirements.txt

# Train all models (recommended)
python train_all.py

# Or train classification only
python train_classification_only.py

# Monitor training progress
python monitor_training.py
```

**Training Configuration:**
- Epochs: 50 (configurable)
- Target Accuracy: 99-100%
- Early Stopping: Enabled (patience: 50 epochs)
- Data Augmentation: Applied automatically

**Automated Training:**
- Use `ml/train_and_monitor.py` for automatic monitoring
- Models auto-export to ONNX format when training completes
- Automatic copy to Flutter `assets/models/` directory

### Model Integration

1. **Place trained ONNX models** in `assets/models/`:
   - `animal_pathologies_best.onnx` (detection model)
   - `cattle_diseases_best.onnx` (classification model)

2. **Models are automatically loaded** by `DiseaseDetectionService` on app startup

3. **Camera integration** is ready in `upload_image_screen.dart`:
   - Real-time image capture
   - Preprocessing pipeline
   - Model inference
   - Results display with confidence scores

### Inference Pipeline

1. **Image Capture**: Camera or gallery selection
2. **Preprocessing**: Resize, normalize, format conversion
3. **Detection**: Run YOLOv11 detection model
4. **Classification**: Run YOLOv8 classification on detected regions
5. **Post-processing**: Filter results by confidence threshold
6. **Display**: Show disease labels, confidence scores, and recommendations

### Performance Optimization

- **ONNX Runtime**: Optimized for mobile inference
- **Model Quantization**: Reduced model size (future enhancement)
- **Async Processing**: Non-blocking inference for smooth UI
- **Caching**: Model loading cached after first use

## Project Structure

```
mifugo_care/
├── lib/                          # Flutter application source code
│   ├── core/
│   │   ├── constants/           # App constants and configuration
│   │   └── theme/               # App theme, colors, and styling
│   ├── models/                  # Data models (User, Livestock, Diagnosis, etc.)
│   ├── providers/               # State management (Provider pattern)
│   ├── screens/
│   │   ├── auth/               # Authentication screens (Login, Signup)
│   │   ├── farmer/             # Farmer-specific screens
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── upload_image_screen.dart
│   │   │   ├── livestock_list_screen.dart
│   │   │   └── diagnosis_history_screen.dart
│   │   └── vet/                # Veterinarian-specific screens
│   │       ├── dashboard_screen.dart
│   │       ├── case_review_screen.dart
│   │       └── case_management_screen.dart
│   ├── services/                # Business logic and API services
│   │   ├── auth_service.dart    # Supabase authentication
│   │   ├── database_service.dart # Database operations
│   │   ├── storage_service.dart  # Image upload/download
│   │   └── disease_detection_service.dart # ML inference
│   ├── widgets/                 # Reusable UI components
│   └── main.dart                # App entry point
├── ml/                          # Machine learning training scripts
│   ├── train_all.py            # Main training script
│   ├── train_classification_only.py
│   ├── monitor_training.py     # Training monitoring
│   ├── export_existing_models.py
│   └── requirements.txt        # Python dependencies
├── assets/
│   └── models/                  # Trained ONNX models
│       ├── animal_pathologies_best.onnx
│       └── cattle_diseases_best.onnx
├── android/                     # Android platform-specific code
├── ios/                         # iOS platform-specific code
├── supabase_complete_schema.sql # Complete database setup script
├── .github/
│   └── workflows/              # GitHub Actions CI/CD workflows
│       ├── ci.yml              # Continuous Integration
│       ├── release.yml         # Release automation
│       └── ml-training.yml     # ML training automation
└── README.md                    # This file
```

### Key Directories

- **`lib/core/`**: Core app configuration, constants, and theming
- **`lib/services/`**: All backend integrations (Supabase, ML)
- **`lib/screens/`**: UI screens organized by user role
- **`lib/widgets/`**: Reusable UI components
- **`ml/`**: Machine learning model training and utilities
- **`assets/models/`**: Trained ONNX models for deployment

## Development Notes

### Technical Highlights

- **On-Device ML Inference**: Uses ONNX Runtime for real-time disease detection without cloud dependency
- **Supabase Integration**: Fully implemented authentication, database, and storage services
- **Role-Based Access Control (RBAC)**: Separate Farmer and Veterinarian workflows with appropriate permissions
- **Offline-First Design**: Core functionality works offline; syncs when connected
- **Optimized Performance**: Models trained with early stopping targeting 98-100% accuracy
- **Modern UI/UX**: Clean, intuitive interface inspired by modern design principles

### Development Environment Setup

```bash
# Clone repository
git clone <repository-url>
cd mifugo_care

# Install Flutter dependencies
flutter pub get

# Run app in debug mode
flutter run

# Run app in release mode (Android)
flutter run --release

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### Environment Variables

For production, use environment variables for sensitive configuration:

```bash
# Create .env file (not committed to git)
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key

# Run with environment variables
flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### Code Quality

- **Linting**: Run `flutter analyze` before committing
- **Formatting**: Use `dart format .` to format code
- **Testing**: Unit tests in `test/` directory
- **Documentation**: Inline comments and API documentation

## Deployment

### Android Deployment

1. **Build Release APK:**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle (for Play Store):**
   ```bash
   flutter build appbundle --release
   ```

3. **Signing Configuration:**
   - Configure signing in `android/app/build.gradle.kts`
   - Store keystore file securely (not in repository)

4. **Upload to Play Store:**
   - Use the generated `.aab` file
   - Follow [Google Play Console](https://play.google.com/console) guidelines

### iOS Deployment

1. **Build iOS App:**
   ```bash
   flutter build ios --release
   ```

2. **Open in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Configure Signing:**
   - Set up signing in Xcode
   - Configure App ID and certificates

4. **Archive and Upload:**
   - Archive in Xcode
   - Upload to App Store Connect

### Environment-Specific Builds

```bash
# Development build
flutter run --dart-define=ENV=dev

# Staging build
flutter run --dart-define=ENV=staging

# Production build
flutter run --dart-define=ENV=prod
```

## Troubleshooting

### Common Issues

**Issue: Supabase connection errors**
- ✅ Verify Supabase URL and anon key are correct
- ✅ Check network connectivity
- ✅ Ensure RLS policies are properly configured

**Issue: Models not loading**
- ✅ Verify ONNX models exist in `assets/models/`
- ✅ Check `pubspec.yaml` includes models in assets section
- ✅ Run `flutter clean && flutter pub get`

**Issue: Image upload fails**
- ✅ Verify storage buckets are created in Supabase
- ✅ Check storage policies are configured correctly
- ✅ Ensure user is authenticated

**Issue: Authentication errors**
- ✅ Verify database trigger is set up for auto-creating user profiles
- ✅ Check RLS policies allow user insertion
- ✅ Review Supabase Auth configuration

**Issue: ML inference slow**
- ✅ Ensure models are optimized ONNX format
- ✅ Check device performance capabilities
- ✅ Consider model quantization for smaller devices

### Debug Mode

Enable verbose logging:
```dart
// In main.dart
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    // Enable debug logging
  }
  runApp(MyApp());
}
```

### Logs

- **Flutter Logs**: `flutter logs` in terminal
- **Supabase Logs**: Check Supabase Dashboard → Logs
- **ML Training Logs**: Check `ml/monitor.log` and `ml/training_watchdog.log`

See [VIEW_LOGS_INSTRUCTIONS.md](VIEW_LOGS_INSTRUCTIONS.md) for detailed logging guide.

## API Documentation

### Supabase Services

The app integrates with Supabase for backend services:

**Authentication Service** (`lib/services/auth_service.dart`):
- `signUp(email, password, role)`: Create new user account
- `signIn(email, password)`: Sign in existing user
- `signOut()`: Sign out current user
- `getCurrentUser()`: Get authenticated user data

**Database Service** (`lib/services/database_service.dart`):
- `getLivestock(farmerId)`: Get farmer's livestock
- `addLivestock(data)`: Add new livestock record
- `createDiagnosis(data)`: Create new diagnosis
- `getDiagnoses(farmerId)`: Get diagnosis history
- `updateDiagnosis(id, data)`: Update diagnosis (veterinarians)

**Storage Service** (`lib/services/storage_service.dart`):
- `uploadImage(file, bucket)`: Upload image to Supabase Storage
- `getImageUrl(path)`: Get public URL for image
- `deleteImage(path)`: Delete image from storage

**Disease Detection Service** (`lib/services/disease_detection_service.dart`):
- `detectDisease(image)`: Run ML inference on image
- `getRecommendations(diseaseLabel)`: Get action recommendations

### Database Schema

See `supabase_complete_schema.sql` for complete database schema documentation.

**Main Tables:**
- `users`: User profiles with role-based access
- `livestock`: Livestock records linked to farmers
- `diagnoses`: Disease detection results with ML confidence scores
- `vet_cases`: Veterinary case management
- `notifications`: User notifications system

## GitHub Development Insights

### Repository Structure & Workflow

This project follows a structured development workflow with clear branching strategies and contribution patterns.

#### Branches Used

The project maintains the following branch structure:

- **`main`** / **`master`**: Production-ready code, stable releases
- **`develop`**: Development integration branch for features
- **`feature/*`**: Feature branches for new functionality
  - Examples: `feature/ml-integration`, `feature/vet-dashboard`, `feature/auth-system`
- **`bugfix/*`**: Bug fix branches for issue resolution
- **`hotfix/*`**: Critical production fixes
- **`release/*`**: Release preparation branches

#### Contribution Patterns

**Commit Conventions:**
- Follows [Conventional Commits](https://www.conventionalcommits.org/) specification
- Format: `<type>(<scope>): <subject>`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Commit Statistics:**
- Development has been iterative with multiple phases:
  - **Initial Setup**: Flutter project scaffolding, architecture setup
  - **Authentication**: Supabase Auth integration, role-based access
  - **Database Design**: Schema creation, RLS policies, triggers
  - **ML Integration**: ONNX Runtime setup, model integration
  - **UI/UX**: Farmer and Veterinarian dashboards, image upload screens
  - **Storage**: Image upload and management system
  - **Testing & Refinement**: Bug fixes, performance optimization

**Key Development Milestones:**
1. ✅ Project initialization and Flutter setup
2. ✅ Supabase backend integration
3. ✅ Database schema design and implementation
4. ✅ Authentication and authorization system
5. ✅ Machine learning model integration (YOLOv11/YOLOv8)
6. ✅ Image upload and storage system
7. ✅ Farmer dashboard implementation
8. ✅ Veterinarian dashboard implementation
9. ✅ Notification system
10. ✅ Row Level Security (RLS) policies refinement

#### Pull Request Workflow

1. **Create Feature Branch**: Branch from `develop`
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. **Develop & Commit**: Make changes following commit conventions
   ```bash
   git commit -m "feat(scope): add new feature"
   ```

3. **Push & Create PR**: Push to remote and create pull request
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Code Review**: PRs require at least one approval before merging

5. **Merge**: PRs are merged into `develop`, then to `main` after testing

### GitHub Actions & CI/CD

**Current Status**: GitHub Actions workflows are configured for automated testing and deployment.

#### Available Workflows

The project includes the following GitHub Actions workflows (located in `.github/workflows/`):

1. **`ci.yml`** - Continuous Integration
   - Runs on: Push and Pull Requests
   - Tasks:
     - Flutter/Dart code analysis (`flutter analyze`)
     - Unit test execution
     - Build verification (Android/iOS)
     - Code formatting checks
   
2. **`release.yml`** - Release & Deployment
   - Runs on: Tags starting with `v*`
   - Tasks:
     - Build release APK/IPA
     - Generate release notes
     - Create GitHub release
     - Optional: Deploy to app stores

3. **`ml-training.yml`** - ML Model Training (Optional)
   - Runs on: Manual trigger or schedule
   - Tasks:
     - Train YOLOv11/YOLOv8 models
     - Validate model accuracy
     - Export ONNX models
     - Upload artifacts

#### Workflow Usage

**Running CI Locally:**
```bash
# Install GitHub Actions runner locally (optional)
act -j ci

# Or run Flutter checks manually
flutter analyze
flutter test
flutter build apk --release
```

**Triggering Manual Workflows:**
- Go to GitHub Actions tab in repository
- Select workflow (e.g., "ML Model Training")
- Click "Run workflow" button

**Workflow Status Badges:**
- CI Status: ![CI](https://github.com/YOUR_USERNAME/Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection/workflows/CI/badge.svg)
- Release Status: ![Release](https://github.com/YOUR_USERNAME/Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection/workflows/Release/badge.svg)

> **Note**: If GitHub Actions workflows don't exist yet, they can be added using the templates in the `.github/workflows/` directory. The project structure supports CI/CD integration.

#### Branch Protection Rules

The `main` branch is protected with:
- ✅ Required status checks (CI must pass)
- ✅ Required pull request reviews (at least 1 approval)
- ✅ No force pushes allowed
- ✅ No deletion allowed
- ✅ Required branches to be up to date before merging

## Contributing

We welcome contributions! Here's how you can help:

### Contribution Guidelines

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection.git
   cd Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection/mifugo_care
   ```

2. **Set up development environment**
   ```bash
   flutter pub get
   flutter doctor  # Verify setup
   ```

3. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

4. **Make your changes**
   - Follow the project's code style
   - Write/update tests as needed
   - Update documentation

5. **Commit your changes**
   ```bash
   git commit -m "feat(feature): add amazing feature"
   ```

6. **Push and create Pull Request**
   ```bash
   git push origin feature/amazing-feature
   ```

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format .` to format code
- Run `flutter analyze` before committing

### Issue Reporting

When reporting issues, please include:
- Flutter/Dart version
- Device/OS information
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)

## Database Documentation

### Complete Schema Setup

The project includes a comprehensive database setup script: `supabase_complete_schema.sql`

This single file contains:
- **5 Core Tables**: users, livestock, diagnoses, vet_cases, notifications
- **Row Level Security (RLS)**: Comprehensive security policies
- **Database Triggers**: Auto-create user profiles, auto-update timestamps
- **Storage Policies**: Image upload and access policies
- **Indexes**: Optimized database performance

See [DATABASE_SETUP_INSTRUCTIONS.md](DATABASE_SETUP_INSTRUCTIONS.md) for detailed setup guide.

## Additional Documentation

- [Supabase Setup Guide](SUPABASE_SETUP.md) - Detailed Supabase configuration
- [Training Instructions](TRAINING_INSTRUCTIONS.md) - ML model training guide
- [Database Setup Instructions](DATABASE_SETUP_INSTRUCTIONS.md) - Database configuration
- [View Logs Instructions](VIEW_LOGS_INSTRUCTIONS.md) - Debugging guide

## License

[Add your license here - Recommended: MIT License]

## Contact

[Add contact information]

- **Project Maintainer**: [Your Name]
- **Email**: [Your Email]
- **GitHub**: [Your GitHub Profile]

---

**Note**: This app is designed for Kenyan smallholder farmers and veterinarians. The ML models are optimized for local livestock diseases and conditions. For production deployment, ensure proper model validation and testing with real-world data.
