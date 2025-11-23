class AppConstants {
  // App Info
  static const String appName = 'Mifugo Care';
  static const String appVersion = '1.0.0';

  // User Roles
  static const String roleFarmer = 'farmer';
  static const String roleVeterinarian = 'veterinarian';

  // Database Tables
  static const String usersCollection = 'users';
  static const String livestockCollection = 'livestock';
  static const String diagnosesCollection = 'diagnoses';
  static const String casesCollection = 'vet_cases';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String livestockImagesPath = 'livestock_images';
  static const String diagnosisImagesPath = 'diagnosis_images';

  // Disease Detection
  static const double minConfidenceThreshold = 0.5;
  
  // Notification Types
  static const String notificationTypeDisease = 'disease_detected';
  static const String notificationTypeVetResponse = 'vet_response';
  static const String notificationTypeCheckup = 'scheduled_checkup';
}

