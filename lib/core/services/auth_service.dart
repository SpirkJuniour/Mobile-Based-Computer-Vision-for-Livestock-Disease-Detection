import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'database_service.dart';

/// Authentication Service supporting online (Supabase) and offline modes
class AuthService {
  static final AuthService instance = AuthService._init();

  SupabaseClient? _supabase;
  GoogleSignIn? _googleSignIn;

  UserModel? _currentUser;
  bool _isOfflineMode = false;

  AuthService._init() {
    // Initialize Supabase client - will be set during app initialization
    try {
      _supabase = Supabase.instance.client;
      if (!kIsWeb) {
        _googleSignIn = GoogleSignIn();
      }
    } catch (e) {
      // Supabase not initialized yet, will be set later
      print('Supabase client not available yet: $e');
    }
  }

  // ==================== Getters ====================

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isOfflineMode => _isOfflineMode;
  User? get supabaseUser => _supabase?.auth.currentUser;

  // ==================== Initialization ====================

  /// Initialize auth service and check for cached user
  Future<void> initialize() async {
    // Skip initialization on web for now
    if (kIsWeb) {
      return;
    }

    try {
      _supabase = Supabase.instance.client;

      // Listen to auth state changes
      _supabase?.auth.onAuthStateChange.listen((data) {
        final user = data.session?.user;
        if (user != null) {
          _loadUserData(user.id);
        } else {
          _currentUser = null;
        }
      });

      // Check for cached offline user
      await _loadCachedUser();
    } catch (e) {
      print('Auth service initialization error: $e');
      _isOfflineMode = true;
    }
  }

  /// Load cached user from local storage
  Future<void> _loadCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    _isOfflineMode = prefs.getBool('offline_mode') ?? false;

    if (userId != null) {
      final user = await DatabaseService.instance.getUser(userId);
      if (user != null && user.isTokenValid) {
        _currentUser = user;
      } else {
        // Token expired, clear cache
        await _clearCachedUser();
      }
    }
  }

  /// Load user data from Supabase
  Future<void> _loadUserData(String userId) async {
    if (_supabase == null) {
      await _loadUserFromLocal(userId);
      return;
    }

    try {
      final response = await _supabase!
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      _currentUser = UserModel.fromSupabase(response);

      // Update last login
      _currentUser = _currentUser!.copyWith(lastLogin: DateTime.now());

      // Generate offline token
      _generateOfflineToken();

      // Save to local database
      await DatabaseService.instance.insertUser(_currentUser!);
      await _saveCachedUser(userId);

      // Update Supabase
      await _supabase!.from('users').update({
        'last_login': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      print('Error loading user data: $e');
      // Try loading from local database
      await _loadUserFromLocal(userId);
    }
  }

  /// Load user from local database (offline mode)
  Future<void> _loadUserFromLocal(String userId) async {
    final user = await DatabaseService.instance.getUser(userId);
    if (user != null && user.isTokenValid) {
      _currentUser = user;
      _isOfflineMode = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('offline_mode', true);
    }
  }

  /// Save cached user ID
  Future<void> _saveCachedUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
    await prefs.setBool('offline_mode', false);
  }

  /// Clear cached user
  Future<void> _clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await prefs.remove('offline_mode');
  }

  /// Generate offline authentication token (30-day validity)
  void _generateOfflineToken() {
    if (_currentUser == null) return;

    final token = const Uuid().v4();
    final expiry = DateTime.now().add(const Duration(days: 30));

    _currentUser = _currentUser!.copyWith(
      authToken: token,
      tokenExpiry: expiry,
    );
  }

  // ==================== Sign In Methods ====================

  /// Sign in with email and password
  Future<UserModel> signInWithEmail(String email, String password) async {
    if (_supabase == null) {
      throw Exception('Authentication not available');
    }

    try {
      final response = await _supabase!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }

      await _loadUserData(response.user!.id);
      return _currentUser!;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? licenseNumber,
  }) async {
    if (_supabase == null) {
      throw Exception('Authentication not available');
    }

    try {
      final response = await _supabase!.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.name,
        },
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      // Create user profile in database
      final user = UserModel(
        userId: response.user!.id,
        email: email,
        fullName: fullName,
        role: role,
        licenseNumber: licenseNumber,
        createdAt: DateTime.now(),
        isVerified: false,
      );

      // Save to Supabase database
      await _supabase!.from('users').insert(user.toSupabase());

      // Save locally
      _currentUser = user;
      _generateOfflineToken();
      await DatabaseService.instance.insertUser(_currentUser!);
      await _saveCachedUser(user.userId);

      return user;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    if (_supabase == null || _googleSignIn == null) {
      throw Exception('Authentication not available');
    }

    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // Sign in to Supabase with Google
      final response = await _supabase!.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user == null) {
        throw Exception('Google sign in failed');
      }

      // Check if user exists in database
      try {
        await _supabase!
            .from('users')
            .select()
            .eq('user_id', response.user!.id)
            .single();

        await _loadUserData(response.user!.id);
      } catch (e) {
        // User doesn't exist, create new profile
        final user = UserModel(
          userId: response.user!.id,
          email: response.user!.email!,
          fullName: response.user!.userMetadata?['full_name'] ??
              response.user!.userMetadata?['name'] ??
              'User',
          role: UserRole.farmer, // Default role
          profileImageUrl: response.user!.userMetadata?['avatar_url'] ??
              response.user!.userMetadata?['picture'],
          createdAt: DateTime.now(),
          isVerified: true,
        );

        await _supabase!.from('users').insert(user.toSupabase());
        await _loadUserData(response.user!.id);
      }

      return _currentUser!;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // ==================== Password Management ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (_supabase == null) {
      throw Exception('Authentication not available');
    }

    try {
      await _supabase!.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  /// Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    if (_supabase == null) {
      throw Exception('Authentication not available');
    }

    try {
      final user = _supabase!.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Supabase doesn't require re-authentication for password update
      // The user must be logged in with a valid session
      await _supabase!.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // ==================== Sign Out ====================

  /// Sign out
  Future<void> signOut() async {
    if (_supabase != null) {
      await _supabase!.auth.signOut();
    }
    if (_googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
    _currentUser = null;
    _isOfflineMode = false;
    await _clearCachedUser();
  }

  // ==================== User Profile Management ====================

  /// Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      // Update in Supabase if available
      if (_supabase != null) {
        await _supabase!
            .from('users')
            .update(user.toSupabase())
            .eq('user_id', user.userId);
      }

      // Update locally
      await DatabaseService.instance.updateUser(user);

      if (_currentUser?.userId == user.userId) {
        _currentUser = user;
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Sync user data when coming online
  Future<void> syncUserData() async {
    if (_currentUser == null || _supabase == null) return;

    try {
      final response = await _supabase!
          .from('users')
          .select()
          .eq('user_id', _currentUser!.userId)
          .single();

      _currentUser = UserModel.fromSupabase(response);
      _generateOfflineToken();
      await DatabaseService.instance.insertUser(_currentUser!);
      _isOfflineMode = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('offline_mode', false);
    } catch (e) {
      print('Error syncing user data: $e');
    }
  }

  // ==================== Helper Methods ====================

  /// Handle Supabase auth exceptions
  String _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('Invalid login credentials')) {
          return 'Invalid email or password';
        }
        return 'Invalid request: ${e.message}';
      case '422':
        if (e.message.contains('email')) {
          return 'Invalid email address';
        }
        if (e.message.contains('password')) {
          return 'Password must be at least 6 characters';
        }
        return 'Validation error: ${e.message}';
      case '429':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
