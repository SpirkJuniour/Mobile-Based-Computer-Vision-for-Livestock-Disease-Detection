import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // Upload livestock image
  Future<String> uploadLivestockImage(File imageFile) async {
    try {
      String fileName = '${_uuid.v4()}.jpg';
      final path = fileName;
      await _supabase.storage
          .from(AppConstants.livestockImagesPath)
          .upload(path, imageFile);
      final publicUrl = _supabase.storage
          .from(AppConstants.livestockImagesPath)
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload diagnosis image
  Future<String> uploadDiagnosisImage(File imageFile) async {
    try {
      String fileName = '${_uuid.v4()}.jpg';
      final path = fileName;
      await _supabase.storage
          .from(AppConstants.diagnosisImagesPath)
          .upload(path, imageFile);
      final publicUrl = _supabase.storage
          .from(AppConstants.diagnosisImagesPath)
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Supabase SDK does not delete by URL directly; expect path, so this is a no-op placeholder.
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}

