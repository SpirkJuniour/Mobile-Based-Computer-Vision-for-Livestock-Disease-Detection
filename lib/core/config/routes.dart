import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/password_reset_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/camera/camera_screen.dart';
import '../../features/diagnosis/diagnosis_result_screen.dart';
import '../../features/diagnosis/diagnosis_history_screen.dart';
import '../../features/livestock/livestock_screen.dart';
import '../../features/livestock/livestock_profile_screen.dart';
import '../../features/disease/disease_info_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/profile_screen.dart';
import '../../features/settings/change_password_screen.dart';
import '../../features/health/health_tips_screen.dart';
import '../../features/health/vaccination_info_screen.dart';
import '../../features/farming/beef_farming_screen.dart';
import '../../features/farming/goat_farming_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/search/search_results_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/promotional/promotional_offer_screen.dart';
import '../../features/location/location_picker_screen.dart';
import '../../features/contact/contact_info_screen.dart';
import '../../features/firm/firm_detail_screen.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Onboarding
      GoRoute(
        path: '/',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return SignupScreen(selectedRole: role);
        },
      ),
      GoRoute(
        path: '/password-reset',
        name: 'password-reset',
        builder: (context, state) => const PasswordResetScreen(),
      ),

      // Main App
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeDashboardScreen(),
      ),

      // Camera & Diagnosis
      GoRoute(
        path: '/camera',
        name: 'camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/diagnosis-result',
        name: 'diagnosis-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DiagnosisResultScreen(
            diagnosisData: extra ?? {},
          );
        },
      ),
      GoRoute(
        path: '/diagnosis-history',
        name: 'diagnosis-history',
        builder: (context, state) => const DiagnosisHistoryScreen(),
      ),

      // Livestock
      GoRoute(
        path: '/livestock',
        name: 'livestock',
        builder: (context, state) => const LivestockScreen(),
      ),
      GoRoute(
        path: '/livestock/:id',
        name: 'livestock-profile',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LivestockProfileScreen(livestockId: id);
        },
      ),

      // Disease Info
      GoRoute(
        path: '/disease-info/:name',
        name: 'disease-info',
        builder: (context, state) {
          final name = state.pathParameters['name']!;
          return DiseaseInfoScreen(diseaseName: name);
        },
      ),

      // Settings & Profile
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Health & Information
      GoRoute(
        path: '/health-tips',
        name: 'health-tips',
        builder: (context, state) => const HealthTipsScreen(),
      ),
      GoRoute(
        path: '/vaccination-info',
        name: 'vaccination-info',
        builder: (context, state) => const VaccinationInfoScreen(),
      ),

      // Farming
      GoRoute(
        path: '/beef-farming',
        name: 'beef-farming',
        builder: (context, state) => const BeefFarmingScreen(),
      ),
      GoRoute(
        path: '/goat-farming',
        name: 'goat-farming',
        builder: (context, state) => const GoatFarmingScreen(),
      ),

      // Chat
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),

      // Search
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchResultsScreen(query: query);
        },
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Promotional
      GoRoute(
        path: '/promotional-offer',
        name: 'promotional-offer',
        builder: (context, state) => const PromotionalOfferScreen(),
      ),

      // Location
      GoRoute(
        path: '/location-picker',
        name: 'location-picker',
        builder: (context, state) => const LocationPickerScreen(),
      ),

      // Contact
      GoRoute(
        path: '/contact-info',
        name: 'contact-info',
        builder: (context, state) => const ContactInfoScreen(),
      ),

      // Firm Detail
      GoRoute(
        path: '/firm-detail',
        name: 'firm-detail',
        builder: (context, state) => const FirmDetailScreen(),
      ),
    ],

    // Redirect logic
    redirect: (context, state) {
      // Skip authentication checks on web for now
      if (kIsWeb) {
        return null;
      }

      try {
        final authService = AuthService.instance;
        final isLoggedIn = authService.isLoggedIn;
        final isOnAuthPage = state.matchedLocation.startsWith('/login') ||
            state.matchedLocation.startsWith('/signup') ||
            state.matchedLocation.startsWith('/role-selection') ||
            state.matchedLocation.startsWith('/password-reset') ||
            state.matchedLocation == '/';

        // If not logged in and not on auth page, redirect to onboarding
        if (!isLoggedIn && !isOnAuthPage) {
          return '/';
        }

        // If logged in and on auth page, redirect to home
        if (isLoggedIn && isOnAuthPage) {
          return '/home';
        }

        // No redirect needed
        return null;
      } catch (e) {
        // If auth service fails, allow navigation
        return null;
      }
    },
  );
});
