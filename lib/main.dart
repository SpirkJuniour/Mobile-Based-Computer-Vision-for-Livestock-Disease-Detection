import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/supabase_options.dart';
import 'core/config/app_theme.dart';
import 'core/config/routes.dart';
import 'core/services/database_service.dart';
import 'core/services/ml_service.dart';
import 'core/services/auth_service.dart';

void main() async {
  // Catch any errors during startup
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint('🚀 MifugoCare starting...');

    // Initialize Supabase
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: SupabaseConfig.debugMode,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      debugPrint('✓ Supabase initialized');
    } catch (e) {
      debugPrint('⚠️ Supabase initialization failed: $e');
      debugPrint(
          '   Make sure to update SupabaseConfig with your project credentials');
    }

    // Initialize Hive for local storage (skip on web)
    try {
      if (!kIsWeb) {
        await Hive.initFlutter();
        debugPrint('✓ Hive initialized');
      }
    } catch (e) {
      debugPrint('⚠️ Hive initialization failed: $e');
    }

    // Initialize local database (skip on web - SQLite doesn't work on web)
    try {
      if (!kIsWeb) {
        await DatabaseService.instance.initialize();
        debugPrint('✓ Database initialized');
      }
    } catch (e) {
      debugPrint('⚠️ Database initialization failed: $e');
    }

    // Initialize ML model
    try {
      await MLService.instance.initialize();
      debugPrint('✓ ML Service initialized');
    } catch (e) {
      debugPrint('⚠️ ML Service initialization failed: $e');
    }

    // Initialize Auth Service
    try {
      await AuthService.instance.initialize();
      debugPrint('✓ Auth Service initialized');
    } catch (e) {
      debugPrint('⚠️ Auth Service initialization failed: $e');
    }

    // Set system UI overlay style
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
      debugPrint('✓ System UI configured');
    } catch (e) {
      debugPrint('⚠️ System UI configuration failed: $e');
    }

    // Lock orientation to portrait
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      debugPrint('✓ Orientation locked');
    } catch (e) {
      debugPrint('⚠️ Orientation lock failed: $e');
    }

    debugPrint('✓ MifugoCare initialization complete - launching app!');

    runApp(
      const ProviderScope(
        child: MifugoCareApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('❌ Fatal error during startup: $error');
    debugPrint('Stack trace: $stack');
    // Still try to run the app even if there's an error
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
                'Error starting app: $error\nPlease check internet connection'),
          ),
        ),
      ),
    );
  });
}

class MifugoCareApp extends ConsumerWidget {
  const MifugoCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final router = ref.watch(routerProvider);

      return MaterialApp.router(
        title: 'MifugoCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: router,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error building app: $e');
      debugPrint('Stack trace: $stackTrace');

      // Return error screen
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'App Build Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
