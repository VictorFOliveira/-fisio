import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_database.dart';
import '../models/clinical_record.dart';
import '../models/patient.dart';
import 'patient_detail_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key, required this.database, this.initialRecordType, this.openNewPatient = false});
  final AppDatabase database;
  final RecordType? initialRecordType;
  final bool openNewPatient;
  @override State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  late Future<List<Patient>> _future;
  @override void initState(){super.initState();_reload();if(widget.openNewPatient){WidgetsBinding.instance.addPostFrameCallback((_)=>_addPatient());}}
  void _reload()=>_future=widget.database.patients();
  String? _text(TextEditingController c){final v=c.text.trim();return v.isEmpty?null:v;}
  double? _number(TextEditingController c)=>double.tryParse(c.text.trim().replaceAll(',','.'));

  Future<void> _addPatient() async {
    final name=TextEditingController(), phone=TextEditingController(), email=TextEditingController();
    final weight=TextEditingController(), height=TextEditingController(), diagnosis=TextEditingController();
    final complaint=TextEditingController(), comorbidities=TextEditingController(), medications=TextEditingController();
    final allergies=TextEditingController(), surgeries=TextEditingController(), precautions=TextEditingController();
    final referring=TextEditingController(), notes=TextEditingController();
    DateTime? birthDate; String? sex;
    final patient=await showDialog<Patient>(context:context,builder:(dialogContext)=>StatefulBuilder(builder:(context,setDialogState)=>AlertDialog(
      insetPadding:const EdgeInsets.symmetric(horizontal:20,vertical:24),
      titlePadding:const EdgeInsets.fromLTRB(24,22,24,8),
      contentPadding:const EdgeInsets.fromLTRB(24,8,24,8),
      actionsPadding:const EdgeInsets.fromLTRB(16,8,16,16),
      title:const Row(children:[Icon(Icons.person_add_alt_1),SizedBox(width:10),Text('Novo paciente')]),
      content:SizedBox(width:520,child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
        Text('Identificação',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),
        TextField(controller:name,textCapitalization:TextCapitalization.words,decoration:const InputDecoration(labelText:'Nome completo *')),const SizedBox(height:14),
        InkWell(onTap:()async{final picked=await showDatePicker(context:context,firstDate:DateTime(1900),lastDate:DateTime.now(),initialDate:birthDate??DateTime(1990));if(picked!=null)setDialogState(()=>birthDate=picked);},child:InputDecorator(decoration:const InputDecoration(labelText:'Data de nascimento'),child:Padding(padding:const EdgeInsets.only(top:2),child:Text(birthDate==null?'Selecionar':'${birthDate!.day.toString().padLeft(2,'0')}/${birthDate!.month.toString().padLeft(2,'0')}/${birthDate!.year}')))),const SizedBox(height:14),
        DropdownButtonFormField<String>(initialValue:sex,decoration:const InputDecoration(labelText:'Sexo'),items:const ['Feminino','Masculino','Outro','Prefere não informar'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>setDialogState(()=>sex=v)),const SizedBox(height:14),
        TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'Telefone')),const SizedBox(height:14),
        TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'E-mail')),const SizedBox(height:24),
        Text('Dados físicos',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),
        Row(children:[Expanded(child:TextField(controller:weight,keyboardType:const TextInputType.numberWithOptions(decimal:true),inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],decoration:const InputDecoration(labelText:'Peso (kg)'))),const SizedBox(width:12),Expanded(child:TextField(controller:height,keyboardType:const TextInputType.numberWithOptions(decimal:true),inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],decoration:const InputDecoration(labelText:'Altura (cm)',hintText:'175')))]),const SizedBox(height:24),
        Text('Informações clínicas',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),
        TextField(controller:diagnosis,maxLines:2,decoration:const InputDecoration(labelText:'Diagnóstico médico informado',hintText:'Diagnóstico/hipótese do encaminhamento')),const SizedBox(height:14),
        TextField(controller:complaint,maxLines:2,decoration:const InputDecoration(labelText:'Queixa principal')),const SizedBox(height:14),
        TextField(controller:comorbidities,maxLines:2,decoration:const InputDecoration(labelText:'Comorbidades')),const SizedBox(height:14),
        TextField(controller:medications,maxLines:2,decoration:const InputDecoration(labelText:'Medicamentos em uso')),const SizedBox(height:14),
        TextField(controller:allergies,maxLines:2,decoration:const InputDecoration(labelText:'Alergias')),const SizedBox(height:14),
        TextField(controller:surgeries,maxLines:2,decoration:const InputDecoration(labelText:'Cirurgias / histórico relevante')),const SizedBox(height:14),
        TextField(controller:precautions,maxLines:2,decoration:const InputDecoration(labelText:'Restrições e precauções')),const SizedBox(height:14),
        TextField(controller:referring,decoration:const InputDecoration(labelText:'Profissional que encaminhou')),const SizedBox(height:14),
        TextField(controller:notes,maxLines:4,decoration:const InputDecoration(labelText:'Observações gerais')),const SizedBox(height:12),
        Text('Os dados são registrados para avaliação do profissional; o +Fisio não determina diagnóstico ou tratamento.',style:Theme.of(context).textTheme.bodySmall),
      ]))),
      actions:[TextButton(onPressed:()=>Navigator.pop(dialogContext),child:const Text('Cancelar')),FilledButton(onPressed:(){if(name.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Informe o nome do paciente.')));return;}Navigator.pop(dialogContext,Patient(name:name.text.trim(),birthDate:birthDate,phone:_text(phone),email:_text(email),sex:sex,weightKg:_number(weight),heightCm:_number(height),medicalDiagnosis:_text(diagnosis),chiefComplaint:_text(complaint),comorbidities:_text(comorbidities),medications:_text(medications),allergies:_text(allergies),surgeries:_text(surgeries),precautions:_text(precautions),referringProfessional:_text(referring),notes:_text(notes),createdAt:DateTime.now()));},child:const Text('Salvar paciente'))],
    )));
    if(patient==null)return;
    final id=await widget.database.addPatient(patient);
    final saved=await widget.database.patientById(id);
    if(!mounted||saved==null)return;
    setState(_reload);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${saved.name} cadastrado com sucesso.')));
    await Navigator.of(context).push(MaterialPageRoute(builder:(_)=>PatientDetailScreen(database:widget.database,patient:saved,initialRecordType:widget.initialRecordType)));
    if(mounted)setState(_reload);
  }

  Future<void> _deletePatient(Patient p)async{if(p.id==null)return;final confirmed=await showDialog<bool>(context:context,builder:(context)=>AlertDialog(title:const Text('Excluir paciente permanentemente?'),content:Text('Excluir ${p.name} também apagará todas as avaliações, evoluções, medições e testes vinculados. Esta ação não pode ser desfeita.'),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Cancelar')),FilledButton(style:FilledButton.styleFrom(backgroundColor:Theme.of(context).colorScheme.error),onPressed:()=>Navigator.pop(context,true),child:const Text('Excluir permanentemente'))]));if(confirmed==true){await widget.database.deletePatient(p.id!);if(mounted){setState(_reload);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${p.name} foi excluído.')));}}}

  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Pacientes')),floatingActionButton:FloatingActionButton.extended(onPressed:_addPatient,icon:const Icon(Icons.person_add_alt_1),label:const Text('Paciente')),body:FutureBuilder<List<Patient>>(future:_future,builder:(context,snapshot){if(!snapshot.hasData)return const Center(child:CircularProgressIndicator());final patients=snapshot.data!;if(patients.isEmpty)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.people_outline,size:56),const SizedBox(height:12),const Text('Nenhum paciente cadastrado ainda.'),const SizedBox(height:12),FilledButton.icon(onPressed:_addPatient,icon:const Icon(Icons.add),label:const Text('Cadastrar paciente'))]));return ListView.separated(padding:const EdgeInsets.all(16),itemCount:patients.length,separatorBuilder:(_,__)=>const SizedBox(height:8),itemBuilder:(context,index){final p=patients[index];final details=<String>[];if(p.age!=null)details.add('${p.age} anos');if(p.weightKg!=null)details.add('${p.weightKg!.toStringAsFixed(1)} kg');if(p.heightCm!=null)details.add('${p.heightCm!.toStringAsFixed(0)} cm');return Card(child:ListTile(leading:CircleAvatar(child:Text(p.name.substring(0,1).toUpperCase())),title:Text(p.name,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text([if(details.isNotEmpty)details.join(' • '),if(p.medicalDiagnosis?.isNotEmpty==true)p.medicalDiagnosis!,if(details.isEmpty&&p.medicalDiagnosis==null)p.phone??'Prontuário local'].join('\n'),maxLines:3,overflow:TextOverflow.ellipsis),isThreeLine:p.medicalDiagnosis?.isNotEmpty==true,trailing:PopupMenuButton<String>(onSelected:(v){if(v=='delete')_deletePatient(p);},itemBuilder:(_)=>const [PopupMenuItem(value:'delete',child:Row(children:[Icon(Icons.delete_outline),SizedBox(width:8),Text('Excluir paciente')]))]),onTap:()async{await Navigator.of(context).push(MaterialPageRoute(builder:(_)=>PatientDetailScreen(database:widget.database,patient:p,initialRecordType:widget.initialRecordType)));if(mounted)setState(_reload);},));});}));
}
