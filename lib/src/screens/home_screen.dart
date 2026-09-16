import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/clinical_record.dart';
import '../services/pro_service.dart';
import 'patients_screen.dart';
import 'pro_screen.dart';
import 'security_backup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.database});
  final AppDatabase database;
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _patients = 0;
  final pro = ProService.instance;

  @override void initState(){super.initState();_refresh();pro.addListener(_proChanged);pro.initialize();}
  @override void dispose(){pro.removeListener(_proChanged);super.dispose();}
  void _proChanged(){if(mounted)setState((){});}
  Future<void> _refresh()async{final count=await widget.database.patientCount();if(mounted)setState(()=>_patients=count);}
  Future<void> _openPatients([RecordType? initialType])async{await Navigator.of(context).push(MaterialPageRoute(builder:(_)=>PatientsScreen(database:widget.database,initialRecordType:initialType)));await _refresh();}
  void _openPro()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const ProScreen()));

  @override
  Widget build(BuildContext context) {
    final modules=[
      ('Goniometria','Amplitude de movimento',Icons.straighten,RecordType.goniometry),
      ('Força muscular','Escalas e evolução',Icons.fitness_center,RecordType.strength),
      ('Avaliação','Avaliação fisioterapêutica',Icons.assignment_outlined,RecordType.assessment),
      ('Evoluções','Histórico de atendimentos',Icons.monitor_heart_outlined,RecordType.evolution),
      ('Testes','Testes funcionais',Icons.timer_outlined,RecordType.functionalTest),
    ];
    return Scaffold(
      appBar:AppBar(
        toolbarHeight:72,
        title:Row(children:[
          Container(width:44,height:44,decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary,borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.add_rounded,color:Colors.white,size:32)),
          const SizedBox(width:10),
          const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('+Fisio',style:TextStyle(fontWeight:FontWeight.w900,fontSize:22)),Text('Fisioterapia inteligente e simples',style:TextStyle(fontSize:11,fontWeight:FontWeight.normal))]),
        ]),
        actions:[
          IconButton(tooltip:'Segurança e backup',onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SecurityBackupScreen())),icon:const Icon(Icons.shield_outlined)),
          IconButton(tooltip:pro.isPro?'PRO ativado':'+Fisio PRO',onPressed:_openPro,icon:Icon(pro.isPro?Icons.verified:Icons.workspace_premium_outlined,color:pro.isPro?Theme.of(context).colorScheme.primary:null)),
        ],
      ),
      body:RefreshIndicator(
        onRefresh:_refresh,
        child:ListView(
          padding:const EdgeInsets.fromLTRB(18,8,18,30),
          children:[
            Container(
              padding:const EdgeInsets.all(22),
              decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary,borderRadius:BorderRadius.circular(24)),
              child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                const Icon(Icons.health_and_safety_outlined,color:Colors.white,size:34),
                const SizedBox(height:14),
                const Text('Seu consultório no seu celular',style:TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.w800)),
                const SizedBox(height:6),
                const Text('Avalie, acompanhe a evolução e organize seus pacientes com segurança.',style:TextStyle(color:Colors.white70,height:1.35)),
                const SizedBox(height:18),
                FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:Colors.white,foregroundColor:Theme.of(context).colorScheme.primary),onPressed:()=>_openPatients(),icon:const Icon(Icons.people_alt_outlined),label:Text('Ver $_patients pacientes')),
              ]),
            ),
            if(!pro.isPro)...[
              const SizedBox(height:12),
              Card(child:ListTile(onTap:_openPro,leading:Icon(Icons.workspace_premium,color:Theme.of(context).colorScheme.primary),title:const Text('Conheça o +Fisio PRO',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:const Text('Pagamento único • sem assinatura'),trailing:const Icon(Icons.chevron_right))),
            ],
            const SizedBox(height:22),
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Ferramentas clínicas',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),TextButton(onPressed:()=>_openPatients(),child:const Text('Pacientes'))]),
            const SizedBox(height:8),
            GridView.builder(
              shrinkWrap:true,
              physics:const NeverScrollableScrollPhysics(),
              itemCount:modules.length,
              gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.18),
              itemBuilder:(context,i){final m=modules[i];return InkWell(borderRadius:BorderRadius.circular(20),onTap:()=>_openPatients(m.$4),child:Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:42,height:42,decoration:BoxDecoration(color:Theme.of(context).colorScheme.primaryContainer,borderRadius:BorderRadius.circular(12)),child:Icon(m.$3,color:Theme.of(context).colorScheme.primary)),const Spacer(),Text(m.$1,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15)),const SizedBox(height:2),Text(m.$2,maxLines:2,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.bodySmall)]))));},
            ),
            const SizedBox(height:18),
            Card(child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:18,vertical:8),leading:Container(width:44,height:44,decoration:BoxDecoration(color:Theme.of(context).colorScheme.secondaryContainer,borderRadius:BorderRadius.circular(13)),child:Icon(Icons.cloud_done_outlined,color:Theme.of(context).colorScheme.secondary)),title:const Text('Seus dados, protegidos',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:const Text('Banco criptografado, bloqueio do app e backup local ou Google Drive.'),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SecurityBackupScreen())))),
          ],
        ),
      ),
    );
  }
}
