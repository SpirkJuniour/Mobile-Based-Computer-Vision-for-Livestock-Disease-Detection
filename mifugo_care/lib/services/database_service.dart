import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/livestock_model.dart';
import '../models/diagnosis_model.dart';
import '../models/vet_case_model.dart';
import '../core/constants/app_constants.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> addLivestock(LivestockModel livestock) async {
    final payload = livestock.toMap();

    Future<String> insertPayload(Map<String, dynamic> body) async {
      final data = await _supabase
          .from(AppConstants.livestockCollection)
          .insert(body)
          .select('id')
          .single();
      return data['id'] as String;
    }

    try {
      return await insertPayload(payload);
    } on PostgrestException catch (e) {
      // Handle missing columns gracefully - use minimal payload
      // Only keep essential fields: farmer_id, created_at
      final minimalPayload = <String, dynamic>{
        'farmer_id': payload['farmer_id'],
        'created_at': payload['created_at'],
      };
      
      if (payload.containsKey('updated_at') && payload['updated_at'] != null) {
        minimalPayload['updated_at'] = payload['updated_at'];
      }
      
      debugPrint('[DatabaseService] Column error detected, using minimal payload: ${e.message}');
      return await insertPayload(minimalPayload);
    }
  }

  Future<List<LivestockModel>> getLivestockByFarmer(String farmerId) async {
    // Use select() without specifying columns - let database return what exists
    // We'll handle missing columns in fromMap()
    final rows = await _supabase
        .from(AppConstants.livestockCollection)
        .select()
        .eq('farmer_id', farmerId)
        .order('created_at', ascending: false);

    return rows
        .map<LivestockModel>((r) {
          final map = r;
          final id = map['id'] as String;
          return LivestockModel.fromMap(map, id);
        })
        .toList();
  }

  Stream<List<LivestockModel>> streamLivestockByFarmer(String farmerId) {
    return Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => getLivestockByFarmer(farmerId));
  }

  Future<void> updateLivestock(String id, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _supabase
        .from(AppConstants.livestockCollection)
        .update(updates)
        .eq('id', id);
  }

  Future<String> addDiagnosis(DiagnosisModel diagnosis) async {
    final data = await _supabase
        .from(AppConstants.diagnosesCollection)
        .insert(diagnosis.toMap())
        .select('id')
        .single();
    return data['id'] as String;
  }

  Future<List<DiagnosisModel>> getDiagnosesByFarmer(String farmerId) async {
    final rows = await _supabase
        .from(AppConstants.diagnosesCollection)
        .select()
        .eq('farmer_id', farmerId)
        .order('created_at', ascending: false);

    return rows
        .map<DiagnosisModel>((r) {
          final map = r;
          final id = map['id'] as String;
          return DiagnosisModel.fromMap(map, id);
        })
        .toList();
  }

  Stream<List<DiagnosisModel>> streamDiagnosesByFarmer(String farmerId) {
    return Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => getDiagnosesByFarmer(farmerId));
  }

  Future<List<DiagnosisModel>> getPendingDiagnoses() async {
    final rows = await _supabase
        .from(AppConstants.diagnosesCollection)
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return rows
        .map<DiagnosisModel>((r) {
          final map = r;
          final id = map['id'] as String;
          return DiagnosisModel.fromMap(map, id);
        })
        .toList();
  }

  Stream<List<DiagnosisModel>> streamPendingDiagnoses() {
    return Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => getPendingDiagnoses());
  }

  Future<void> updateDiagnosis(String id, Map<String, dynamic> updates) async {
    await _supabase
        .from(AppConstants.diagnosesCollection)
        .update(updates)
        .eq('id', id);
  }

  Future<String> addVetCase(VetCaseModel vetCase) async {
    final data = await _supabase
        .from(AppConstants.casesCollection)
        .insert(vetCase.toMap())
        .select('id')
        .single();
    return data['id'] as String;
  }

  Future<List<VetCaseModel>> getVetCasesByVet(String vetId) async {
    final rows = await _supabase
        .from(AppConstants.casesCollection)
        .select()
        .eq('vet_id', vetId)
        .order('created_at', ascending: false);

    return rows
        .map<VetCaseModel>((r) {
          final map = r;
          final id = map['id'] as String;
          return VetCaseModel.fromMap(map, id);
        })
        .toList();
  }

  Stream<List<VetCaseModel>> streamVetCasesByVet(String vetId) {
    return Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => getVetCasesByVet(vetId));
  }

  Future<List<VetCaseModel>> getPendingVetCases() async {
    final rows = await _supabase
        .from(AppConstants.casesCollection)
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return rows
        .map<VetCaseModel>((r) {
          final map = r;
          final id = map['id'] as String;
          return VetCaseModel.fromMap(map, id);
        })
        .toList();
  }

  Future<List<VetCaseModel>> getVetCasesByFarmer(String farmerId) async {
    final rows = await _supabase
        .from(AppConstants.casesCollection)
        .select()
        .eq('farmer_id', farmerId)
        .order('created_at', ascending: false);

    return rows
        .map<VetCaseModel>((r) {
          final map = r;
          final id = map['id'] as String;
          return VetCaseModel.fromMap(map, id);
        })
        .toList();
  }

  Stream<List<VetCaseModel>> streamVetCasesByFarmer(String farmerId) {
    return Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => getVetCasesByFarmer(farmerId));
  }

  Future<void> updateVetCase(String id, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _supabase
        .from(AppConstants.casesCollection)
        .update(updates)
        .eq('id', id);
  }
}


