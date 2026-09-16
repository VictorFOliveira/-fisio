import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../data/app_database.dart';

class DriveBackupInfo{const DriveBackupInfo({required this.id,required this.name,this.modifiedTime,this.size});final String id,name;final DateTime? modifiedTime;final int? size;}

class GoogleDriveBackupService{
 static const _scope='https://www.googleapis.com/auth/drive.appdata';
 static const _keyName='drive_backup_key_v1';
 static const _storage=FlutterSecureStorage();
 static final _signIn=GoogleSignIn(scopes:[_scope]);
 static final _cipher=AesGcm.with256bits();

 static Future<GoogleSignInAccount?> connect()async=>await _signIn.signIn();
 static Future<GoogleSignInAccount?> currentUser()async=>_signIn.currentUser??await _signIn.signInSilently();
 static Future<void> disconnect()async=>_signIn.disconnect();

 static Future<drive.DriveApi> _api()async{final account=await currentUser()??await connect();if(account==null)throw Exception('Conta Google não conectada.');final client=await _signIn.authenticatedClient();if(client==null)throw Exception('Não foi possível autorizar o Google Drive.');return drive.DriveApi(client);}
 static Future<SecretKey> _backupKey()async{var encoded=await _storage.read(key:_keyName);if(encoded==null){final key=await _cipher.newSecretKey();encoded=base64Encode(await key.extractBytes());await _storage.write(key:_keyName,value:encoded);}return SecretKey(base64Decode(encoded));}

 static Future<File> _encryptedSnapshot()async{await AppDatabase.instance.close();final source=File(await AppDatabase.instance.databasePath);if(!await source.exists())throw Exception('Banco local não encontrado.');final bytes=await source.readAsBytes();final box=await _cipher.encrypt(bytes,secretKey:await _backupKey());final payload=jsonEncode({'format':'mais-fisio-drive-backup','version':1,'nonce':base64Encode(box.nonce),'mac':base64Encode(box.mac.bytes),'data':base64Encode(box.cipherText),'createdAt':DateTime.now().toUtc().toIso8601String()});final dir=await getTemporaryDirectory();final file=File(p.join(dir.path,'mais_fisio_${DateTime.now().millisecondsSinceEpoch}.mfdrive'));await file.writeAsString(payload,flush:true);return file;}

 static Future<void> upload()async{final api=await _api();final file=await _encryptedSnapshot();final metadata=drive.File()..name='mais_fisio_backup_${DateTime.now().toUtc().toIso8601String().replaceAll(':','-')}.mfdrive'..parents=['appDataFolder']..appProperties={'app':'mais_fisio','format':'1'};await api.files.create(metadata,uploadMedia:drive.Media(file.openRead(),await file.length()),$fields:'id,name,modifiedTime');}

 static Future<List<DriveBackupInfo>> listBackups()async{final api=await _api();final result=await api.files.list(spaces:'appDataFolder',q:"appProperties has { key='app' and value='mais_fisio' }",orderBy:'modifiedTime desc',$fields:'files(id,name,modifiedTime,size)');return(result.files??[]).where((f)=>f.id!=null&&f.name!=null).map((f)=>DriveBackupInfo(id:f.id!,name:f.name!,modifiedTime:f.modifiedTime,size:int.tryParse(f.size??''))).toList();}

 static Future<void> restore(DriveBackupInfo info)async{final api=await _api();final media=await api.files.get(info.id,downloadOptions:drive.DownloadOptions.fullMedia) as drive.Media;final chunks=<int>[];await for(final chunk in media.stream){chunks.addAll(chunk);}final map=jsonDecode(utf8.decode(chunks)) as Map<String,dynamic>;if(map['format']!='mais-fisio-drive-backup'||map['version']!=1)throw Exception('Backup do Drive incompatível.');final box=SecretBox(base64Decode(map['data'] as String),nonce:base64Decode(map['nonce'] as String),mac:Mac(base64Decode(map['mac'] as String)));final plain=await _cipher.decrypt(box,secretKey:await _backupKey());await AppDatabase.instance.close();final destination=File(await AppDatabase.instance.databasePath);if(await destination.exists())await destination.copy('${destination.path}.before_drive_restore');await destination.writeAsBytes(Uint8List.fromList(plain),flush:true);}
}
