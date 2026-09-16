import 'package:flutter/material.dart';
import 'data/app_database.dart';
import 'screens/home_screen.dart';
import 'services/security_service.dart';

class MaisFisioApp extends StatelessWidget {
  const MaisFisioApp({super.key});
  @override Widget build(BuildContext context)=>MaterialApp(title:'+Fisio',debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorSchemeSeed:const Color(0xFF197A73),scaffoldBackgroundColor:const Color(0xFFF6F8F7),inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder())),home:HomeScreen(database:AppDatabase.instance),builder:(context,child)=>AppLockGate(child:child??const SizedBox.shrink()));
}

class AppLockGate extends StatefulWidget{const AppLockGate({super.key,required this.child});final Widget child;@override State<AppLockGate> createState()=>_AppLockGateState();}
class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver{
 bool _checking=true,_locked=false,_authRunning=false;DateTime? _backgroundedAt;
 @override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);_checkLock();}
 @override void dispose(){WidgetsBinding.instance.removeObserver(this);super.dispose();}
 Future<void> _checkLock()async{final enabled=await SecurityService.isLockEnabled();if(!mounted)return;setState((){_locked=enabled;_checking=false;});if(enabled)await _unlock();}
 Future<void> _unlock()async{if(_authRunning)return;_authRunning=true;final ok=await SecurityService.authenticate();_authRunning=false;if(mounted)setState(()=>_locked=!ok);}
 @override void didChangeAppLifecycleState(AppLifecycleState state){if(state==AppLifecycleState.paused||state==AppLifecycleState.inactive){_backgroundedAt??=DateTime.now();}else if(state==AppLifecycleState.resumed){final since=_backgroundedAt;_backgroundedAt=null;if(since!=null&&DateTime.now().difference(since)>const Duration(seconds:10)){SecurityService.isLockEnabled().then((enabled){if(enabled&&mounted){setState(()=>_locked=true);_unlock();}});}}}
 @override Widget build(BuildContext context){if(_checking)return const Material(color:Colors.white,child:Center(child:CircularProgressIndicator()));if(!_locked)return widget.child;return Material(color:Theme.of(context).colorScheme.surface,child:SafeArea(child:Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.lock_outline,size:72,color:Theme.of(context).colorScheme.primary),const SizedBox(height:18),Text('+Fisio bloqueado',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Autentique-se para acessar os prontuários armazenados neste aparelho.',textAlign:TextAlign.center),const SizedBox(height:22),FilledButton.icon(onPressed:_unlock,icon:const Icon(Icons.fingerprint),label:const Text('Desbloquear'))]))));}
}
