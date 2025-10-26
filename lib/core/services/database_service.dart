import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/diagnosis_model.dart';
import '../models/livestock_model.dart';
import '../models/disease_model.dart';

/// Local SQLite database service for offline-first functionality
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mifugocare.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        userId $idType,
        email $textType,
        fullName $textType,
        role $textType,
        phoneNumber TEXT,
        profileImageUrl TEXT,
        licenseNumber TEXT,
        createdAt $textType,
        lastLogin TEXT,
        authToken TEXT,
        tokenExpiry TEXT,
        isVerified $boolType
      )
    ''');

    // Livestock table
    await db.execute('''
      CREATE TABLE livestock (
        id $idType,
        userId $textType,
        name $textType,
        type $textType,
        breed TEXT,
        tagNumber TEXT,
        dateOfBirth TEXT,
        gender TEXT,
        weight REAL,
        color TEXT,
        imageUrl TEXT,
        registeredDate $textType,
        notes TEXT,
        diagnosisHistory TEXT,
        isSynced $boolType
      )
    ''');

    // Diagnoses table
    await db.execute('''
      CREATE TABLE diagnoses (
        id $idType,
        userId $textType,
        livestockId TEXT,
        diseaseName $textType,
        confidence $doubleType,
        imagePath $textType,
        diagnosisDate $textType,
        symptoms TEXT,
        recommendedTreatments TEXT,
        preventionSteps TEXT,
        severityLevel $intType,
        notes TEXT,
        isSynced $boolType
      )
    ''');

    // Diseases table
    await db.execute('''
      CREATE TABLE diseases (
        id $idType,
        name $textType,
        description $textType,
        symptoms TEXT,
        causes TEXT,
        treatments TEXT,
        preventionMethods TEXT,
        severityLevel $intType,
        imageUrl TEXT,
        isContagious $boolType,
        affectedSpecies TEXT
      )
    ''');
  }

  /// Initialize with default data
  Future<void> initialize() async {
    await database;
    // Database is now ready
  }

  // ==================== User Operations ====================

  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      user.toJson(),
      where: 'userId = ?',
      whereArgs: [user.userId],
    );
  }

  Future<void> deleteUser(String userId) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // ==================== Livestock Operations ====================

  Future<void> insertLivestock(LivestockModel livestock) async {
    final db = await database;
    final map = livestock.toJson();
    map['diagnosisHistory'] = map['diagnosisHistory'].join(',');
    await db.insert(
      'livestock',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LivestockModel>> getUserLivestock(String userId) async {
    final db = await database;
    final maps = await db.query(
      'livestock',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'registeredDate DESC',
    );

    return maps.map((map) {
      final livestock = Map<String, dynamic>.from(map);
      if (livestock['diagnosisHistory'] is String) {
        livestock['diagnosisHistory'] =
            (livestock['diagnosisHistory'] as String).split(',');
      }
      return LivestockModel.fromJson(livestock);
    }).toList();
  }

  Future<LivestockModel?> getLivestock(String id) async {
    final db = await database;
    final maps = await db.query(
      'livestock',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final livestock = Map<String, dynamic>.from(maps.first);
      if (livestock['diagnosisHistory'] is String) {
        livestock['diagnosisHistory'] =
            (livestock['diagnosisHistory'] as String).split(',');
      }
      return LivestockModel.fromJson(livestock);
    }
    return null;
  }

  Future<void> updateLivestock(LivestockModel livestock) async {
    final db = await database;
    final map = livestock.toJson();
    map['diagnosisHistory'] = map['diagnosisHistory'].join(',');
    await db.update(
      'livestock',
      map,
      where: 'id = ?',
      whereArgs: [livestock.id],
    );
  }

  Future<void> deleteLivestock(String id) async {
    final db = await database;
    await db.delete(
      'livestock',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Diagnosis Operations ====================

  Future<void> insertDiagnosis(DiagnosisModel diagnosis) async {
    final db = await database;
    final map = diagnosis.toJson();
    map['symptoms'] = map['symptoms'].join('|||');
    map['recommendedTreatments'] = map['recommendedTreatments'].join('|||');
    map['preventionSteps'] = map['preventionSteps'].join('|||');
    await db.insert(
      'diagnoses',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiagnosisModel>> getUserDiagnoses(String userId) async {
    final db = await database;
    final maps = await db.query(
      'diagnoses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'diagnosisDate DESC',
    );

    return maps.map((map) {
      final diagnosis = Map<String, dynamic>.from(map);
      diagnosis['symptoms'] = (diagnosis['symptoms'] as String).split('|||');
      diagnosis['recommendedTreatments'] =
          (diagnosis['recommendedTreatments'] as String).split('|||');
      diagnosis['preventionSteps'] =
          (diagnosis['preventionSteps'] as String).split('|||');
      return DiagnosisModel.fromJson(diagnosis);
    }).toList();
  }

  Future<DiagnosisModel?> getDiagnosis(String id) async {
    final db = await database;
    final maps = await db.query(
      'diagnoses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final diagnosis = Map<String, dynamic>.from(maps.first);
      diagnosis['symptoms'] = (diagnosis['symptoms'] as String).split('|||');
      diagnosis['recommendedTreatments'] =
          (diagnosis['recommendedTreatments'] as String).split('|||');
      diagnosis['preventionSteps'] =
          (diagnosis['preventionSteps'] as String).split('|||');
      return DiagnosisModel.fromJson(diagnosis);
    }
    return null;
  }

  Future<void> deleteDiagnosis(String id) async {
    final db = await database;
    await db.delete(
      'diagnoses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Disease Operations ====================

  Future<void> insertDisease(DiseaseModel disease) async {
    final db = await database;
    final map = disease.toJson();
    map['symptoms'] = map['symptoms'].join('|||');
    map['causes'] = map['causes'].join('|||');
    map['treatments'] = map['treatments'].join('|||');
    map['preventionMethods'] = map['preventionMethods'].join('|||');
    map['affectedSpecies'] = map['affectedSpecies'].join('|||');
    await db.insert(
      'diseases',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiseaseModel>> getAllDiseases() async {
    final db = await database;
    final maps = await db.query('diseases', orderBy: 'name ASC');

    return maps.map((map) {
      final disease = Map<String, dynamic>.from(map);
      disease['symptoms'] = (disease['symptoms'] as String).split('|||');
      disease['causes'] = (disease['causes'] as String).split('|||');
      disease['treatments'] = (disease['treatments'] as String).split('|||');
      disease['preventionMethods'] =
          (disease['preventionMethods'] as String).split('|||');
      disease['affectedSpecies'] =
          (disease['affectedSpecies'] as String).split('|||');
      return DiseaseModel.fromJson(disease);
    }).toList();
  }

  Future<DiseaseModel?> getDiseaseByName(String name) async {
    final db = await database;
    final maps = await db.query(
      'diseases',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      final disease = Map<String, dynamic>.from(maps.first);
      disease['symptoms'] = (disease['symptoms'] as String).split('|||');
      disease['causes'] = (disease['causes'] as String).split('|||');
      disease['treatments'] = (disease['treatments'] as String).split('|||');
      disease['preventionMethods'] =
          (disease['preventionMethods'] as String).split('|||');
      disease['affectedSpecies'] =
          (disease['affectedSpecies'] as String).split('|||');
      return DiseaseModel.fromJson(disease);
    }
    return null;
  }

  // ==================== Utility ====================

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
