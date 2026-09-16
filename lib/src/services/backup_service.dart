import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class BackupService {
  static const databaseName='mais_fisio.db';

  static Future<File> _dbFile() async => File(p.join(await getDatabasesPath(),databaseName));

  static Future<void> shareBackup() async {
    final db=await _dbFile();
    if(!await db.exists()) throw Exception('Banco de dados não encontrado.');
    final dir=await getTemporaryDirectory();
    final stamp=DateTime.now().toIso8601String().replaceAll(':','-').split('.').first;
    final copy=await db.copy(p.join(dir.path,'mais_fisio_backup_$stamp.mfbackup'));
    final digest=sha256.convert(await copy.readAsBytes()).toString();
    final manifest=File('${copy.path}.sha256');
    await manifest.writeAsString(jsonEncode({'app':'+Fisio','version':1,'sha256':digest,'createdAt':DateTime.now().toIso8601String()}));
    await Share.shareXFiles([XFile(copy.path),XFile(manifest.path)],subject:'+Fisio - Backup local',text:'Backup do +Fisio. Este arquivo pode conter dados sensíveis de saúde. Guarde-o em local seguro.');
  }

  static Future<bool> restoreBackup() async {
    final result=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['mfbackup']);
    final path=result?.files.single.path;
    if(path==null)return false;
    final source=File(path);
    if(!await source.exists())throw Exception('Arquivo de backup inválido.');
    final bytes=await source.readAsBytes();
    if(bytes.length<100)throw Exception('Arquivo de backup inválido ou vazio.');
    final header=utf8.decode(bytes.take(16).toList(),allowMalformed:true);
    if(!header.startsWith('SQLite format 3'))throw Exception('O arquivo selecionado não é um backup válido do banco +Fisio.');
    final destination=await _dbFile();
    final safety=File('${destination.path}.before_restore');
    if(await destination.exists())await destination.copy(safety.path);
    try{await source.copy(destination.path);return true;}catch(e){if(await safety.exists())await safety.copy(destination.path);rethrow;}
  }
}
