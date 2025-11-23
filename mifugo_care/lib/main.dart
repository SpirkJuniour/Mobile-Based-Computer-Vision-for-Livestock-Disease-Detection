import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mifugo_care/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/farmer/farmer_dashboard.dart';
import 'screens/vet/vet_dashboard.dart';
import 'screens/splash_screen.dart';
import 'core/constants/app_constants.dart';
import 'services/disease_detection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://vwmdllaypvwvtwdnlpiy.supabase.co'),
    anonKey: String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3bWRsbGF5cHZ3dnR3ZG5scGl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyOTA3MjQsImV4cCI6MjA3ODg2NjcyNH0.zQoak8fxQL4VtcQiiaCzrvp4WSS1HtzJYcPffkPqwHw'),
  );
  
  // Initialize ML service in background
  final mlService = DiseaseDetectionService();
  mlService.initialize().catchError((e) {
    debugPrint('ML service initialization error: $e');
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('sw'), // Kiswahili
            ],
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show splash while checking auth state
    if (authProvider.isLoading && authProvider.currentUser == null) {
      return const SplashScreen();
    }

    // Show login if not authenticated
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Show appropriate dashboard based on role
    if (authProvider.isFarmer) {
      return const FarmerDashboard();
    } else if (authProvider.isVeterinarian) {
      return const VetDashboard();
    }

    // Default to login if role is unknown
    return const LoginScreen();
  }
}
