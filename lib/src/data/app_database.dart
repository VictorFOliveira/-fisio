import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/clinical_record.dart';
import '../models/patient.dart';

class AppDatabase {
  AppDatabase._();
  static final instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    return openDatabase(
      join(root, 'mais_fisio.db'),
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE patients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            birth_date TEXT,
            phone TEXT,
            email TEXT,
            notes TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE clinical_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            value TEXT NOT NULL,
            unit TEXT,
            notes TEXT,
            recorded_at TEXT NOT NULL,
            FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<int> addPatient(Patient patient) async {
    final db = await database;
    final data = patient.toMap()..remove('id');
    return db.insert('patients', data);
  }

  Future<List<Patient>> patients() async {
    final db = await database;
    final rows = await db.query('patients', orderBy: 'name COLLATE NOCASE');
    return rows.map(Patient.fromMap).toList();
  }

  Future<int> addRecord(ClinicalRecord record) async {
    final db = await database;
    final data = record.toMap()..remove('id');
    return db.insert('clinical_records', data);
  }

  Future<List<ClinicalRecord>> recordsFor(int patientId) async {
    final db = await database;
    final rows = await db.query(
      'clinical_records',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'recorded_at DESC',
    );
    return rows.map(ClinicalRecord.fromMap).toList();
  }

  Future<int> patientCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM patients');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
