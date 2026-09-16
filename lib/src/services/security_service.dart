import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  static const _storage=FlutterSecureStorage();
  static final _auth=LocalAuthentication();
  static const _lockKey='app_lock_enabled';

  static Future<bool> isLockEnabled()async=>(await _storage.read(key:_lockKey))=='true';
  static Future<void> setLockEnabled(bool enabled)async=>_storage.write(key:_lockKey,value:enabled.toString());

  static Future<bool> canAuthenticate()async{
    try{return await _auth.isDeviceSupported()&&(await _auth.canCheckBiometrics);}catch(_){return false;}
  }

  static Future<bool> authenticate()async{
    try{return await _auth.authenticate(localizedReason:'Desbloqueie o +Fisio para acessar dados de pacientes',options:const AuthenticationOptions(biometricOnly:false,stickyAuth:true));}catch(_){return false;}
  }
}
