import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_database.dart';
import '../models/clinical_record.dart';
import '../models/patient.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key,required this.database,required this.patient,this.initialRecordType});
  final AppDatabase database; final Patient patient; final RecordType? initialRecordType;
  @override State<PatientDetailScreen> createState()=>_PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Future<List<ClinicalRecord>> _future;
  @override void initState(){super.initState();_reload();if(widget.initialRecordType!=null){WidgetsBinding.instance.addPostFrameCallback((_)=>_addRecord(widget.initialRecordType!));}}
  void _reload()=>_future=widget.database.recordsFor(widget.patient.id!);
  String _label(RecordType t)=>switch(t){RecordType.goniometry=>'Goniometria',RecordType.strength=>'Força muscular',RecordType.assessment=>'Avaliação',RecordType.evolution=>'Evolução',RecordType.functionalTest=>'Teste funcional'};

  Future<void> _addRecord(RecordType type) async {
    final title=TextEditingController(), value=TextEditingController(), notes=TextEditingController();
    final region=TextEditingController(), movement=TextEditingController(), protocol=TextEditingController();
    final unit=TextEditingController(text:type==RecordType.goniometry?'°':type==RecordType.strength?'/5':'');
    String side='Não se aplica'; double pain=0;
    final ok=await showDialog<bool>(context:context,builder:(context)=>StatefulBuilder(builder:(context,setLocal)=>AlertDialog(
      title:Text('Nova ${_label(type)}'),content:SizedBox(width:480,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:title,decoration:const InputDecoration(labelText:'Título / teste *')),
        if(type==RecordType.goniometry||type==RecordType.strength)...[
          const SizedBox(height:10),TextField(controller:region,decoration:const InputDecoration(labelText:'Região / articulação *')),
          const SizedBox(height:10),TextField(controller:movement,decoration:InputDecoration(labelText:type==RecordType.goniometry?'Movimento *':'Músculo / grupo muscular *')),
          const SizedBox(height:10),DropdownButtonFormField<String>(initialValue:side,decoration:const InputDecoration(labelText:'Lado'),items:['Direito','Esquerdo','Bilateral','Não se aplica'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setLocal(()=>side=v!)),
        ],
        const SizedBox(height:10),TextField(controller:value,keyboardType:type==RecordType.goniometry?TextInputType.number:TextInputType.text,decoration:const InputDecoration(labelText:'Resultado / registro *')),
        const SizedBox(height:10),TextField(controller:unit,decoration:const InputDecoration(labelText:'Unidade')),
        if(type==RecordType.assessment||type==RecordType.evolution)...[
          const SizedBox(height:14),Align(alignment:Alignment.centerLeft,child:Text('Dor (EVA): ${pain.round()}/10')),
          Slider(value:pain,min:0,max:10,divisions:10,label:pain.round().toString(),onChanged:(v)=>setLocal(()=>pain=v)),
        ],
        if(type==RecordType.functionalTest)...[const SizedBox(height:10),TextField(controller:protocol,decoration:const InputDecoration(labelText:'Protocolo / referência utilizada'))],
        const SizedBox(height:10),TextField(controller:notes,maxLines:4,decoration:const InputDecoration(labelText:'Observações clínicas')),
      ]))),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Salvar registro'))],
    )));
    if(ok!=true||title.text.trim().isEmpty||value.text.trim().isEmpty)return;
    if((type==RecordType.goniometry||type==RecordType.strength)&&(region.text.trim().isEmpty||movement.text.trim().isEmpty)){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Informe região e movimento/músculo.')));return;}
    await widget.database.addRecord(ClinicalRecord(patientId:widget.patient.id!,type:type,title:title.text.trim(),value:value.text.trim(),unit:unit.text.trim().isEmpty?null:unit.text.trim(),notes:notes.text.trim().isEmpty?null:notes.text.trim(),bodyRegion:region.text.trim().isEmpty?null:region.text.trim(),movement:movement.text.trim().isEmpty?null:movement.text.trim(),side:side=='Não se aplica'?null:side,painScore:(type==RecordType.assessment||type==RecordType.evolution)?pain.round():null,protocol:protocol.text.trim().isEmpty?null:protocol.text.trim(),recordedAt:DateTime.now()));
    if(mounted)setState(_reload);
  }

  Future<void> _delete(ClinicalRecord r) async { if(r.id==null)return; final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Excluir registro?'),content:const Text('Esta ação remove o registro clínico deste aparelho.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Excluir'))]));if(yes==true){await widget.database.deleteRecord(r.id!);if(mounted)setState(_reload);}}

  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.patient.name)),body:FutureBuilder<List<ClinicalRecord>>(future:_future,builder:(context,snapshot){final records=snapshot.data??[];return ListView(padding:const EdgeInsets.all(16),children:[
    Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.patient.name,style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),if(widget.patient.birthDate!=null)Text('Nascimento: ${DateFormat('dd/MM/yyyy').format(widget.patient.birthDate!)}'),if(widget.patient.phone!=null)Text('Telefone: ${widget.patient.phone}'),if(widget.patient.email!=null)Text('E-mail: ${widget.patient.email}'),if(widget.patient.notes!=null)Padding(padding:const EdgeInsets.only(top:8),child:Text(widget.patient.notes!))]))),
    const SizedBox(height:12),Text('Novo registro',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),const SizedBox(height:8),Wrap(spacing:8,runSpacing:8,children:RecordType.values.map((t)=>ActionChip(label:Text('+ ${_label(t)}'),onPressed:()=>_addRecord(t))).toList()),
    const SizedBox(height:20),Text('Prontuário • ${records.length} registros',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),const SizedBox(height:8),
    if(snapshot.connectionState==ConnectionState.waiting)const Center(child:CircularProgressIndicator()),if(snapshot.connectionState!=ConnectionState.waiting&&records.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('Sem registros clínicos. Inicie uma avaliação.'))),
    ...records.map((r)=>Card(child:ListTile(onLongPress:()=>_delete(r),title:Text(r.title,style:const TextStyle(fontWeight:FontWeight.w600)),subtitle:Text([_label(r.type),DateFormat('dd/MM/yyyy HH:mm').format(r.recordedAt),if(r.bodyRegion!=null)r.bodyRegion!,if(r.movement!=null)r.movement!,if(r.side!=null)r.side!,if(r.painScore!=null)'EVA ${r.painScore}/10',if(r.protocol!=null)'Protocolo: ${r.protocol}',if(r.notes!=null)r.notes!].join(' • ')),trailing:Text('${r.value}${r.unit??''}',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold))))),
    const SizedBox(height:16),const Text('Os registros são inseridos pelo profissional e não substituem julgamento clínico ou protocolos validados.',textAlign:TextAlign.center),
  ]);}));
}
