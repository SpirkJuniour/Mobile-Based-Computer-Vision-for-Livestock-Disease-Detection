import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Current user provider
final currentUserProvider = StateProvider<UserModel?>((ref) {
  return AuthService.instance.currentUser;
});

/// Auth state provider
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return Stream.value(AuthService.instance.currentUser);
});

/// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  return AuthService.instance.isLoggedIn;
});

/// Is offline mode provider
final isOfflineModeProvider = Provider<bool>((ref) {
  return AuthService.instance.isOfflineMode;
});

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

