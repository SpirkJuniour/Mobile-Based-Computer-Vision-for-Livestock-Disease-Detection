import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'mifugo_care.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create diseases table
    await db.execute('''
      CREATE TABLE diseases (
        diseaseId INTEGER PRIMARY KEY AUTOINCREMENT,
        diseaseName TEXT NOT NULL,
        scientificName TEXT,
        species TEXT,
        symptoms TEXT,
        causes TEXT,
        prevention TEXT,
        treatment TEXT,
        severity TEXT,
        contagious TEXT,
        mortalityRate TEXT,
        affectedBodyParts TEXT,
        seasonality TEXT,
        imageUrl TEXT,
        modelConfidence TEXT,
        dateAdded INTEGER NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    // Create livestock table
    await db.execute('''
      CREATE TABLE livestock (
        livestockId INTEGER PRIMARY KEY AUTOINCREMENT,
        tagNumber TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT,
        gender TEXT NOT NULL,
        dateOfBirth INTEGER NOT NULL,
        color TEXT,
        weight TEXT,
        healthStatus TEXT,
        vaccinationHistory TEXT,
        notes TEXT,
        imagePath TEXT,
        dateAdded INTEGER NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    // Create diagnoses table
    await db.execute('''
      CREATE TABLE diagnoses (
        diagnosisId INTEGER PRIMARY KEY AUTOINCREMENT,
        livestockId INTEGER NOT NULL,
        diseaseId INTEGER NOT NULL,
        imagePath TEXT NOT NULL,
        diagnosisResult TEXT NOT NULL,
        confidence REAL NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        veterinarianNotes TEXT,
        treatmentPrescribed TEXT,
        followUpDate TEXT,
        isTreated INTEGER NOT NULL DEFAULT 0,
        location TEXT,
        weatherConditions TEXT,
        diagnosisDate INTEGER NOT NULL,
        lastUpdated INTEGER NOT NULL,
        FOREIGN KEY (livestockId) REFERENCES livestock (livestockId) ON DELETE CASCADE,
        FOREIGN KEY (diseaseId) REFERENCES diseases (diseaseId) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_diagnoses_livestock_id ON diagnoses(livestockId)');
    await db.execute('CREATE INDEX idx_diagnoses_disease_id ON diagnoses(diseaseId)');
    await db.execute('CREATE INDEX idx_diagnoses_date ON diagnoses(diagnosisDate)');
    await db.execute('CREATE INDEX idx_livestock_tag ON livestock(tagNumber)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
