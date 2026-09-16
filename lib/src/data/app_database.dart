import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../models/clinical_record.dart';
import '../models/patient.dart';

class AppDatabase {
  AppDatabase._(); static final instance=AppDatabase._();
  static const _storage=FlutterSecureStorage(); static const _keyName='database_encryption_key_v1';
  Database? _database;
  Future<Database> get database async=>_database??=await _open();
  Future<String> get databasePath async=>join(await getDatabasesPath(),'mais_fisio_secure.db');
  static Future<String> encryptionKey()async{var key=await _storage.read(key:_keyName);if(key!=null&&key.length>=32)return key;final random=Random.secure();key=List<int>.generate(48,(_)=>random.nextInt(256)).map((b)=>b.toRadixString(16).padLeft(2,'0')).join();await _storage.write(key:_keyName,value:key);return key;}
  Future<Database> _open()async{final key=await encryptionKey();return openDatabase(await databasePath,password:key,version:3,onConfigure:(db)=>db.execute('PRAGMA foreign_keys = ON'),onCreate:(db,version)async{await db.execute('CREATE TABLE patients(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,birth_date TEXT,phone TEXT,email TEXT,sex TEXT,weight_kg REAL,height_cm REAL,medical_diagnosis TEXT,chief_complaint TEXT,comorbidities TEXT,medications TEXT,allergies TEXT,surgeries TEXT,precautions TEXT,referring_professional TEXT,notes TEXT,created_at TEXT NOT NULL)');await db.execute('CREATE TABLE clinical_records(id INTEGER PRIMARY KEY AUTOINCREMENT,patient_id INTEGER NOT NULL,type TEXT NOT NULL,title TEXT NOT NULL,value TEXT NOT NULL,unit TEXT,notes TEXT,body_region TEXT,movement TEXT,side TEXT,pain_score INTEGER,protocol TEXT,recorded_at TEXT NOT NULL,FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE CASCADE)');},onUpgrade:(db,oldVersion,newVersion)async{if(oldVersion<2){for(final sql in ['ALTER TABLE clinical_records ADD COLUMN body_region TEXT','ALTER TABLE clinical_records ADD COLUMN movement TEXT','ALTER TABLE clinical_records ADD COLUMN side TEXT','ALTER TABLE clinical_records ADD COLUMN pain_score INTEGER','ALTER TABLE clinical_records ADD COLUMN protocol TEXT']){await db.execute(sql);}}if(oldVersion<3){for(final sql in ['ALTER TABLE patients ADD COLUMN sex TEXT','ALTER TABLE patients ADD COLUMN weight_kg REAL','ALTER TABLE patients ADD COLUMN height_cm REAL','ALTER TABLE patients ADD COLUMN medical_diagnosis TEXT','ALTER TABLE patients ADD COLUMN chief_complaint TEXT','ALTER TABLE patients ADD COLUMN comorbidities TEXT','ALTER TABLE patients ADD COLUMN medications TEXT','ALTER TABLE patients ADD COLUMN allergies TEXT','ALTER TABLE patients ADD COLUMN surgeries TEXT','ALTER TABLE patients ADD COLUMN precautions TEXT','ALTER TABLE patients ADD COLUMN referring_professional TEXT']){await db.execute(sql);}}});}
  Future<void> close()async{final db=_database;if(db!=null){await db.close();_database=null;}}
  Future<int> addPatient(Patient patient)async{final db=await database;final data=patient.toMap()..remove('id');return db.insert('patients',data);}
  Future<int> updatePatient(Patient patient)async{if(patient.id==null)throw ArgumentError('Paciente sem id.');final db=await database;final data=patient.toMap()..remove('id');return db.update('patients',data,where:'id = ?',whereArgs:[patient.id]);}
  Future<Patient?> patientById(int id)async{final db=await database;final rows=await db.query('patients',where:'id = ?',whereArgs:[id],limit:1);return rows.isEmpty?null:Patient.fromMap(rows.first);}
  Future<List<Patient>> patients()async{final db=await database;final rows=await db.query('patients',orderBy:'name COLLATE NOCASE');return rows.map(Patient.fromMap).toList();}
  Future<int> deletePatient(int id)async{final db=await database;return db.delete('patients',where:'id = ?',whereArgs:[id]);}
  Future<int> addRecord(ClinicalRecord record)async{final db=await database;final data=record.toMap()..remove('id');return db.insert('clinical_records',data);}
  Future<List<ClinicalRecord>> recordsFor(int patientId)async{final db=await database;final rows=await db.query('clinical_records',where:'patient_id = ?',whereArgs:[patientId],orderBy:'recorded_at DESC');return rows.map(ClinicalRecord.fromMap).toList();}
  Future<int> deleteRecord(int id)async{final db=await database;return db.delete('clinical_records',where:'id = ?',whereArgs:[id]);}
  Future<int> patientCount()async{final db=await database;final result=await db.rawQuery('SELECT COUNT(*) AS total FROM patients');return Sqflite.firstIntValue(result)??0;}
}
