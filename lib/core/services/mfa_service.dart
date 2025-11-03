import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MFA Service for managing multi-factor authentication
class MFAService {
  static final MFAService instance = MFAService._init();
  
  SupabaseClient? _supabase;
  
  MFAService._init() {
    try {
      _supabase = Supabase.instance.client;
    } catch (e) {
      print('Supabase client not available yet: $e');
    }
  }
  
  // ==================== MFA Enrollment ====================
  
  /// Enroll a new MFA factor (TOTP)
  /// Returns the QR code URI and secret for the user to scan
  Future<MFAEnrollResult> enrollTOTP({String friendlyName = 'Mifugo Care'}) async {
    if (_supabase == null) {
      throw Exception('Authentication not available');
    }
    
    try {
      final response = await _supabase!.auth.mfa.enroll(
        factorType: FactorType.totp,
        friendlyName: friendlyName,
      );
      
      return MFAEnrollResult(
        factorId: response.id,
        qrCodeUri: response.totp.qrCode,
        secret: response.totp.secret,
      );
    } on AuthException catch (e) {
      throw Exception('MFA enrollment failed: ${e.message}');
    } catch (e) {
      throw Exception('MFA enrollment failed: $e');
    }
  }
  
  /// Verify the MFA enrollment with a code from authenticator app
  Future<void> verifyEnrollment({
    required String factorId,
    required String code,
  }) async {
    if (_supabase == null) {
      throw Exception('Authentication not available');
    }
    
    try {
      final challenge = await _supabase!.auth.mfa.challenge(
        factorId: factorId,
      );
      
      await _supabase!.auth.mfa.verify(
        factorId: factorId,
        challengeId: challenge.id,
        code: code,
      );
      
      // Mark MFA as enrolled
      await _markMFAEnrolled();
    } on AuthException catch (e) {
      throw Exception('MFA verification failed: ${e.message}');
    } catch (e) {
      throw Exception('MFA verification failed: $e');
    }
  }
  
  // ==================== MFA Challenge ====================
  
  /// Create a challenge for MFA during login
  Future<String> createChallenge({required String factorId}) async {
    if (_supabase == null) {
      throw Exception('Authentication not available');
    }
    
    try {
      final challenge = await _supabase!.auth.mfa.challenge(
        factorId: factorId,
      );
      return challenge.id;
    } on AuthException catch (e) {
      throw Exception('MFA challenge failed: ${e.message}');
    } catch (e) {
      throw Exception('MFA challenge failed: $e');
    }
  }
  
  /// Verify MFA code during login
  Future<void> verifyChallenge({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    if (_supabase == null) {
      throw Exception('Authentication not available');
    }
    
    try {
      await _supabase!.auth.mfa.verify(
        factorId: factorId,
        challengeId: challengeId,
        code: code,
      );
    } on AuthException catch (e) {
      throw Exception('Invalid MFA code: ${e.message}');
    } catch (e) {
      throw Exception('MFA verification failed: $e');
    }
  }
  
  // ==================== MFA Status ====================
  
  /// Check if user has MFA enrolled
  Future<bool> hasMFAEnrolled() async {
    if (_supabase == null) return false;
    
    try {
      final factors = await _supabase!.auth.mfa.listFactors();
      return factors.totp.isNotEmpty;
    } catch (e) {
      print('Error checking MFA status: $e');
      return false;
    }
  }
  
  /// Get all enrolled MFA factors
  Future<List<Factor>> getEnrolledFactors() async {
    if (_supabase == null) return [];
    
    try {
      final factors = await _supabase!.auth.mfa.listFactors();
      return factors.totp;
    } catch (e) {
      print('Error getting MFA factors: $e');
      return [];
    }
  }
  
  /// Unenroll an MFA factor
  Future<void> unenrollFactor(String factorId) async {
    if (_supabase == null) {
      throw Exception('Authentication not available');
    }
    
    try {
      await _supabase!.auth.mfa.unenroll(factorId);
      
      // Check if any factors remain
      final factors = await getEnrolledFactors();
      if (factors.isEmpty) {
        await _markMFAUnenrolled();
      }
    } on AuthException catch (e) {
      throw Exception('Failed to remove MFA: ${e.message}');
    } catch (e) {
      throw Exception('Failed to remove MFA: $e');
    }
  }
  
  // ==================== Local Storage ====================
  
  /// Mark MFA as enrolled in local storage
  Future<void> _markMFAEnrolled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mfa_enrolled', true);
  }
  
  /// Mark MFA as unenrolled in local storage
  Future<void> _markMFAUnenrolled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mfa_enrolled', false);
  }
  
  /// Check if MFA is enrolled (from local cache)
  Future<bool> isMFAEnrolledLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('mfa_enrolled') ?? false;
  }
}

/// Result from MFA enrollment
class MFAEnrollResult {
  final String factorId;
  final String qrCodeUri;
  final String secret;
  
  MFAEnrollResult({
    required this.factorId,
    required this.qrCodeUri,
    required this.secret,
  });
}

