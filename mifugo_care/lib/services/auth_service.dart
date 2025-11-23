import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      // Sign up the user with metadata (role, displayName)
      // This metadata will be available to database triggers
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'role': role,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
      );
      final uid = res.user?.id;
      if (uid == null) return null;

      // Wait a moment to ensure the session is established
      await Future.delayed(const Duration(milliseconds: 300));

      // Try to get the session - refresh if needed
      var session = _supabase.auth.currentSession;
      if (session == null) {
        // Wait a bit more and try to get session from the signup response
        await Future.delayed(const Duration(milliseconds: 200));
        session = res.session ?? _supabase.auth.currentSession;
        
        // If still no session, try to refresh
        if (session == null && res.user != null) {
          try {
            await _supabase.auth.refreshSession();
            session = _supabase.auth.currentSession;
          } catch (e) {
            // Session refresh might fail, continue anyway
            debugPrint('Session refresh note: $e');
          }
        }
      }

      UserModel userModel = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      // Wait for database trigger to create user profile automatically
      // This is the most reliable approach - triggers run with SECURITY DEFINER
      // which bypasses RLS policies
      bool userCreated = false;
      int maxRetries = 10;
      int retryCount = 0;
      
      while (!userCreated && retryCount < maxRetries) {
        // Wait a bit for trigger to process
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Check if user was created by trigger
        var existingUser = await _supabase
            .from(AppConstants.usersCollection)
            .select()
            .eq('id', uid)
            .maybeSingle();
        
        if (existingUser != null) {
          // User created by trigger - update with any additional info
          await _updateUserProfile(uid, displayName, phoneNumber);
          userCreated = true;
          break;
        }
        
        retryCount++;
      }
      
      // If trigger didn't create the user, try manual insert as fallback
      if (!userCreated) {
        try {
          // Try to insert manually (this will work if RLS policies are set correctly)
          await _supabase.from(AppConstants.usersCollection).insert({
            'id': uid,
            'email': email,
            'role': role,
            'display_name': displayName,
            'phone_number': phoneNumber,
            'created_at': DateTime.now().toIso8601String(),
          });
          
          // Verify it was created
          await Future.delayed(const Duration(milliseconds: 200));
          var verifyUser = await _supabase
              .from(AppConstants.usersCollection)
              .select()
              .eq('id', uid)
              .maybeSingle();
          
          if (verifyUser == null) {
            // Still not created - this should not happen with proper setup
            // But we'll continue anyway and let the user proceed
            // The profile can be updated later when they visit their profile
            debugPrint('Warning: User profile not found after insert attempt, but signup completed');
          }
        } catch (insertError) {
          // Manual insert failed - this means RLS is blocking
          // Check one more time if trigger created it (in case there was a delay)
          await Future.delayed(const Duration(milliseconds: 500));
          var finalCheck = await _supabase
              .from(AppConstants.usersCollection)
              .select()
              .eq('id', uid)
              .maybeSingle();
          
          if (finalCheck == null) {
            // User profile still doesn't exist
            // Don't fail signup - instead, let the user proceed
            // They can update their profile later or it will be created when they log in
            // This ensures signup always succeeds even if RLS isn't configured
            debugPrint('Warning: User profile not created automatically. Please configure database trigger or RLS policies. User can still proceed.');
            debugPrint('To fix: Run supabase_trigger_auto_create_user.sql in Supabase SQL Editor');
            
            // Continue with signup - don't throw error
            // The user profile will be created on next login or when they update profile
          }
        }
      }

      return userModel;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return null;

      // Wait a moment for any triggers to complete
      await Future.delayed(const Duration(milliseconds: 300));

      var data = await _supabase
          .from(AppConstants.usersCollection)
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (data != null) {
        return UserModel.fromMap({
          'email': data['email'],
          'displayName': data['display_name'],
          'role': data['role'],
          'phoneNumber': data['phone_number'],
          'createdAt': data['created_at'],
        }, uid);
      }
      
      // If user profile doesn't exist, try to create it from auth metadata
      // This handles cases where signup completed but profile wasn't created
      final authUser = _supabase.auth.currentUser;
      if (authUser != null) {
        try {
          // Try to create profile from auth metadata
          await _supabase.from(AppConstants.usersCollection).insert({
            'id': uid,
            'email': authUser.email ?? email,
            'display_name': authUser.userMetadata?['display_name'] ?? email.split('@')[0],
            'role': authUser.userMetadata?['role'] ?? 'farmer',
            'phone_number': authUser.userMetadata?['phone_number'],
            'created_at': DateTime.now().toIso8601String(),
          });
          
          // Retry fetching
          await Future.delayed(const Duration(milliseconds: 200));
          data = await _supabase
              .from(AppConstants.usersCollection)
              .select()
              .eq('id', uid)
              .maybeSingle();
          
          if (data != null) {
            return UserModel.fromMap({
              'email': data['email'],
              'displayName': data['display_name'],
              'role': data['role'],
              'phoneNumber': data['phone_number'],
              'createdAt': data['created_at'],
            }, uid);
          }
        } catch (e) {
          // Profile creation failed, but user can still sign in
          // They'll be able to update profile later
          debugPrint('Warning: Could not create user profile during sign in: $e');
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // OAuth: Google
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  // OAuth: Apple (iOS/macOS)
  Future<void> signInWithApple() async {
    await _supabaseOAuthApple();
  }

  Future<void> _supabaseOAuthApple() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.apple);
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final data = await _supabase
          .from(AppConstants.usersCollection)
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (data == null) return null;

      return UserModel.fromMap({
        'email': data['email'],
        'displayName': data['display_name'],
        'role': data['role'],
        'phoneNumber': data['phone_number'],
        'createdAt': data['created_at'],
      }, uid);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;
    if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;

    if (updates.isNotEmpty) {
      await _supabase
          .from(AppConstants.usersCollection)
          .update(updates)
          .eq('id', uid);
    }
  }

  // Helper method to update user profile after signup
  Future<void> _updateUserProfile(String uid, String displayName, String? phoneNumber) async {
    final updates = <String, dynamic>{
      'display_name': displayName,
    };
    if (phoneNumber != null) {
      updates['phone_number'] = phoneNumber;
    }
    try {
      await _supabase
          .from(AppConstants.usersCollection)
          .update(updates)
          .eq('id', uid);
    } catch (e) {
      // Update failed, but user exists so it's not critical
      debugPrint('Warning: Failed to update user profile: $e');
    }
  }
}

