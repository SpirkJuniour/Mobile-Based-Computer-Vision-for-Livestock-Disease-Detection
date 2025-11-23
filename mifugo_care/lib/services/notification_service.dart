import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Initialize FCM
  Future<void> initialize() async {
    // Placeholder: configure push via a separate provider later.
  }

  // Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from(AppConstants.notificationsCollection).insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  // Send disease detection notification
  Future<void> notifyDiseaseDetected({
    required String farmerId,
    required String diseaseLabel,
    required String diagnosisId,
  }) async {
    await sendNotification(
      userId: farmerId,
      title: 'Disease Detected',
      body: 'Your livestock has been diagnosed with $diseaseLabel',
      type: AppConstants.notificationTypeDisease,
      data: {
        'diagnosisId': diagnosisId,
        'diseaseLabel': diseaseLabel,
      },
    );
  }

  // Send vet response notification
  Future<void> notifyVetResponse({
    required String farmerId,
    required String caseId,
    required String vetName,
  }) async {
    await sendNotification(
      userId: farmerId,
      title: 'Veterinarian Response',
      body: '$vetName has reviewed your case',
      type: AppConstants.notificationTypeVetResponse,
      data: {
        'caseId': caseId,
      },
    );
  }

  // Get user notifications
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return Stream.periodic(const Duration(seconds: 2)).asyncMap((_) async {
      final rows = await _supabase
          .from(AppConstants.notificationsCollection)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows.cast<Map<String, dynamic>>();
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from(AppConstants.notificationsCollection)
        .update({'read': true})
        .eq('id', notificationId);
  }
}

