import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../data/app_database.dart';

class BackupService {
 static const databaseName='mais_fisio_secure.db';
 static Future<File> _dbFile()async=>File(p.join(await getDatabasesPath(),databaseName));
 static Future<void> shareBackup()async{await AppDatabase.instance.close();final db=await _dbFile();if(!await db.exists())throw Exception('Banco de dados não encontrado.');final dir=await getTemporaryDirectory();final stamp=DateTime.now().toIso8601String().replaceAll(':','-').split('.').first;final copy=await db.copy(p.join(dir.path,'mais_fisio_backup_$stamp.mfbackup'));final digest=sha256.convert(await copy.readAsBytes()).toString();final checksum=File('${copy.path}.sha256');await checksum.writeAsString(digest);await Share.shareXFiles([XFile(copy.path),XFile(checksum.path)],subject:'+Fisio - Backup criptografado',text:'Backup criptografado do +Fisio. Guarde o arquivo em local seguro. A restauração depende da chave protegida deste aparelho.');}
 static Future<bool> restoreBackup()async{final result=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['mfbackup']);final path=result?.files.single.path;if(path==null)return false;final source=File(path);if(!await source.exists()||await source.length()<100)throw Exception('Arquivo de backup inválido.');await AppDatabase.instance.close();final key=await AppDatabase.encryptionKey();Database? test;try{test=await openDatabase(source.path,password:key,readOnly:true);await test.rawQuery('SELECT name FROM sqlite_master LIMIT 1');}catch(_){throw Exception('Este backup não pode ser aberto com a chave segura deste aparelho.');}finally{await test?.close();}final destination=await _dbFile();final safety=File('${destination.path}.before_restore');if(await destination.exists())await destination.copy(safety.path);try{await source.copy(destination.path);return true;}catch(e){if(await safety.exists())await safety.copy(destination.path);rethrow;}}
}
