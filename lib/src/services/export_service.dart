import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/clinical_record.dart';
import '../models/patient.dart';

class ExportService {
  static String _type(RecordType t)=>switch(t){RecordType.goniometry=>'Goniometria',RecordType.strength=>'Força muscular',RecordType.assessment=>'Avaliação',RecordType.evolution=>'Evolução',RecordType.functionalTest=>'Teste funcional'};
  static String _safe(String value)=>value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'),'_');

  static Future<void> shareCsv(Patient patient,List<ClinicalRecord> records)async{
    final rows=<List<dynamic>>[['Data','Tipo','Título','Região','Movimento/Músculo','Lado','Resultado','Unidade','Dor EVA','Protocolo','Observações']];
    final ordered=[...records]..sort((a,b)=>a.recordedAt.compareTo(b.recordedAt));
    for(final r in ordered){rows.add([DateFormat('dd/MM/yyyy HH:mm').format(r.recordedAt),_type(r.type),r.title,r.bodyRegion??'',r.movement??'',r.side??'',r.value,r.unit??'',r.painScore??'',r.protocol??'',r.notes??'']);}
    final csv='\uFEFF${const ListToCsvConverter(fieldDelimiter:';',textDelimiter:'"',eol:'\r\n').convert(rows)}';
    final dir=await getTemporaryDirectory(); final file=File('${dir.path}/mais_fisio_${_safe(patient.name)}.csv'); await file.writeAsString(csv,flush:true);
    await Share.shareXFiles([XFile(file.path,mimeType:'text/csv')],subject:'+Fisio - ${patient.name}',text:'Exportação do prontuário do +Fisio. O arquivo contém dados de saúde e deve ser compartilhado com cuidado.');
  }

  static Future<void> sharePdf(Patient patient,List<ClinicalRecord> records)async{
    final doc=pw.Document(title:'+Fisio - ${patient.name}',author:'+Fisio'); final ordered=[...records]..sort((a,b)=>a.recordedAt.compareTo(b.recordedAt));
    doc.addPage(pw.MultiPage(pageFormat:PdfPageFormat.a4,margin:const pw.EdgeInsets.all(32),header:(c)=>pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[pw.Text('+Fisio',style:pw.TextStyle(fontSize:20,fontWeight:pw.FontWeight.bold)),pw.Text('Relatório de evolução fisioterapêutica')]),footer:(c)=>pw.Align(alignment:pw.Alignment.centerRight,child:pw.Text('Página ${c.pageNumber}/${c.pagesCount}',style:const pw.TextStyle(fontSize:9))),build:(c)=>[
      pw.SizedBox(height:16),pw.Text(patient.name,style:pw.TextStyle(fontSize:22,fontWeight:pw.FontWeight.bold)),
      if(patient.birthDate!=null)pw.Text('Nascimento: ${DateFormat('dd/MM/yyyy').format(patient.birthDate!)}'),if(patient.phone!=null)pw.Text('Telefone: ${patient.phone}'),if(patient.email!=null)pw.Text('E-mail: ${patient.email}'),if(patient.notes!=null)pw.Padding(padding:const pw.EdgeInsets.only(top:6),child:pw.Text('Observações cadastrais: ${patient.notes}')),
      pw.SizedBox(height:18),pw.Text('Histórico clínico',style:pw.TextStyle(fontSize:16,fontWeight:pw.FontWeight.bold)),pw.SizedBox(height:8),
      if(ordered.isEmpty)pw.Text('Nenhum registro clínico cadastrado.'),
      ...ordered.map((r)=>pw.Container(margin:const pw.EdgeInsets.only(bottom:8),padding:const pw.EdgeInsets.all(10),decoration:pw.BoxDecoration(border:pw.Border.all(color:PdfColors.grey300),borderRadius:pw.BorderRadius.circular(4)),child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[pw.Expanded(child:pw.Text(r.title,style:pw.TextStyle(fontWeight:pw.FontWeight.bold))),pw.Text('${r.value}${r.unit??''}',style:pw.TextStyle(fontWeight:pw.FontWeight.bold))]),pw.Text('${_type(r.type)} • ${DateFormat('dd/MM/yyyy HH:mm').format(r.recordedAt)}'),if(r.bodyRegion!=null||r.movement!=null||r.side!=null)pw.Text([r.bodyRegion,r.movement,r.side].whereType<String>().join(' • ')),if(r.painScore!=null)pw.Text('Dor (EVA): ${r.painScore}/10'),if(r.protocol!=null)pw.Text('Protocolo/referência: ${r.protocol}'),if(r.notes!=null)pw.Text('Observações: ${r.notes}')]))),
      pw.SizedBox(height:12),pw.Divider(),pw.Text('Documento gerado a partir de registros inseridos pelo profissional no +Fisio. Não constitui diagnóstico automatizado.',style:const pw.TextStyle(fontSize:9)),pw.Text('Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',style:const pw.TextStyle(fontSize:9)),
    ]));
    final bytes=await doc.save(); await Printing.sharePdf(bytes:bytes,filename:'mais_fisio_${_safe(patient.name)}.pdf');
  }
}
