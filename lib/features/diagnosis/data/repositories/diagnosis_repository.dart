import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/diagnosis.dart';

class DiagnosisRepository {
  Future<Database> get _database => DatabaseHelper.database;

  Future<int> insertDiagnosis(Diagnosis diagnosis) async {
    final db = await _database;
    return await db.insert('diagnoses', diagnosis.toMap());
  }

  Future<List<Diagnosis>> getAllDiagnoses() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diagnoses',
      orderBy: 'diagnosisDate DESC',
    );
    return List.generate(maps.length, (i) => Diagnosis.fromMap(maps[i]));
  }

  Future<List<Diagnosis>> getDiagnosesByLivestock(int livestockId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diagnoses',
      where: 'livestockId = ?',
      whereArgs: [livestockId],
      orderBy: 'diagnosisDate DESC',
    );
    return List.generate(maps.length, (i) => Diagnosis.fromMap(maps[i]));
  }

  Future<Diagnosis?> getDiagnosisById(int diagnosisId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diagnoses',
      where: 'diagnosisId = ?',
      whereArgs: [diagnosisId],
    );
    if (maps.isNotEmpty) {
      return Diagnosis.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDiagnosis(Diagnosis diagnosis) async {
    final db = await _database;
    return await db.update(
      'diagnoses',
      diagnosis.toMap(),
      where: 'diagnosisId = ?',
      whereArgs: [diagnosis.diagnosisId],
    );
  }

  Future<int> deleteDiagnosis(int diagnosisId) async {
    final db = await _database;
    return await db.delete(
      'diagnoses',
      where: 'diagnosisId = ?',
      whereArgs: [diagnosisId],
    );
  }

  Future<List<Diagnosis>> getDiagnosesByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diagnoses',
      where: 'diagnosisDate BETWEEN ? AND ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'diagnosisDate DESC',
    );
    return List.generate(maps.length, (i) => Diagnosis.fromMap(maps[i]));
  }

  Future<List<Diagnosis>> getDiagnosesByStatus(String status) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diagnoses',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'diagnosisDate DESC',
    );
    return List.generate(maps.length, (i) => Diagnosis.fromMap(maps[i]));
  }

  Future<int> getDiagnosisCount() async {
    final db = await _database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM diagnoses');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
