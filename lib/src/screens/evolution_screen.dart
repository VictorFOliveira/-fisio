import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/clinical_record.dart';
import '../models/patient.dart';

class EvolutionScreen extends StatefulWidget {
  const EvolutionScreen({super.key, required this.patient, required this.records});
  final Patient patient;
  final List<ClinicalRecord> records;
  @override State<EvolutionScreen> createState()=>_EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen> {
  RecordType type=RecordType.goniometry;
  List<ClinicalRecord> get numericRecords {
    final list=widget.records.where((r)=>r.type==type&&double.tryParse(r.value.replaceAll(',','.'))!=null).toList();
    list.sort((a,b)=>a.recordedAt.compareTo(b.recordedAt)); return list;
  }
  String label(RecordType t)=>switch(t){RecordType.goniometry=>'ADM',RecordType.strength=>'Força',RecordType.assessment=>'Avaliação',RecordType.evolution=>'Evolução',RecordType.functionalTest=>'Testes'};
  @override Widget build(BuildContext context){final data=numericRecords;final spots=<FlSpot>[];for(var i=0;i<data.length;i++){spots.add(FlSpot(i.toDouble(),double.parse(data[i].value.replaceAll(',','.'))));}
    return Scaffold(appBar:AppBar(title:const Text('Evolução clínica')),body:ListView(padding:const EdgeInsets.all(16),children:[
      Text(widget.patient.name,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),const Text('Acompanhe medidas registradas ao longo das sessões.'),const SizedBox(height:18),
      SegmentedButton<RecordType>(segments:[RecordType.goniometry,RecordType.strength,RecordType.functionalTest].map((e)=>ButtonSegment(value:e,label:Text(label(e)))).toList(),selected:{type},onSelectionChanged:(s)=>setState(()=>type=s.first)),const SizedBox(height:22),
      if(data.length<2)Card(child:Padding(padding:const EdgeInsets.all(24),child:Column(children:[const Icon(Icons.show_chart,size:44),const SizedBox(height:8),Text('Registre pelo menos 2 resultados numéricos de ${label(type)} para visualizar a evolução.',textAlign:TextAlign.center)]))) else ...[
        SizedBox(height:260,child:LineChart(LineChartData(gridData:const FlGridData(show:true),borderData:FlBorderData(show:false),titlesData:FlTitlesData(topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:42)),bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,interval:1,getTitlesWidget:(v,m){final i=v.toInt();if(i<0||i>=data.length)return const SizedBox.shrink();return Padding(padding:const EdgeInsets.only(top:8),child:Text(DateFormat('dd/MM').format(data[i].recordedAt),style:const TextStyle(fontSize:10)));}))),lineBarsData:[LineChartBarData(spots:spots,isCurved:true,barWidth:3,dotData:const FlDotData(show:true),belowBarData:BarAreaData(show:true))]))),
        const SizedBox(height:18),Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[_metric(context,'Inicial','${data.first.value}${data.first.unit??''}'),_metric(context,'Atual','${data.last.value}${data.last.unit??''}'),_metric(context,'Registros','${data.length}')]))),
        const SizedBox(height:12),...data.reversed.map((r)=>ListTile(leading:const Icon(Icons.timeline),title:Text('${r.title}: ${r.value}${r.unit??''}'),subtitle:Text('${DateFormat('dd/MM/yyyy').format(r.recordedAt)}${r.bodyRegion==null?'':' • ${r.bodyRegion}'}${r.side==null?'':' • ${r.side}'}'))),
      ],
    ]));
  }
  Widget _metric(BuildContext c,String name,String value)=>Column(children:[Text(value,style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),Text(name)]);
}
