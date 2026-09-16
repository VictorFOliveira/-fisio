import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_database.dart';
import '../models/clinical_record.dart';
import '../models/patient.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key, required this.database, required this.patient, this.initialRecordType});
  final AppDatabase database;
  final Patient patient;
  final RecordType? initialRecordType;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Future<List<ClinicalRecord>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
    if (widget.initialRecordType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _addRecord(widget.initialRecordType!));
    }
  }

  void _reload() => _future = widget.database.recordsFor(widget.patient.id!);

  String _label(RecordType type) => switch (type) {
    RecordType.goniometry => 'Goniometria',
    RecordType.strength => 'Força muscular',
    RecordType.assessment => 'Avaliação',
    RecordType.evolution => 'Evolução',
    RecordType.functionalTest => 'Teste funcional',
  };

  Future<void> _addRecord(RecordType type) async {
    final title = TextEditingController();
    final value = TextEditingController();
    final unit = TextEditingController(text: type == RecordType.goniometry ? '°' : '');
    final notes = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(_label(type)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Medição / teste / título *')),
        const SizedBox(height: 10),
        TextField(controller: value, decoration: const InputDecoration(labelText: 'Resultado / registro *')),
        const SizedBox(height: 10),
        TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unidade (opcional)')),
        const SizedBox(height: 10),
        TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Observações')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
      ],
    ));
    if (ok != true || title.text.trim().isEmpty || value.text.trim().isEmpty) return;
    await widget.database.addRecord(ClinicalRecord(
      patientId: widget.patient.id!, type: type, title: title.text.trim(), value: value.text.trim(),
      unit: unit.text.trim().isEmpty ? null : unit.text.trim(), notes: notes.text.trim().isEmpty ? null : notes.text.trim(), recordedAt: DateTime.now(),
    ));
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.patient.name)),
      body: FutureBuilder<List<ClinicalRecord>>(
        future: _future,
        builder: (context, snapshot) {
          final records = snapshot.data ?? [];
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.patient.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              if (widget.patient.phone != null) Text(widget.patient.phone!),
              if (widget.patient.notes != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(widget.patient.notes!)),
            ]))),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: RecordType.values.map((t) => ActionChip(label: Text('+ ${_label(t)}'), onPressed: () => _addRecord(t))).toList()),
            const SizedBox(height: 20),
            Text('Linha do tempo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (snapshot.connectionState == ConnectionState.waiting) const Center(child: CircularProgressIndicator()),
            if (snapshot.connectionState != ConnectionState.waiting && records.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Sem registros clínicos.'))),
            ...records.map((r) => Card(child: ListTile(
              title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${_label(r.type)} • ${DateFormat('dd/MM/yyyy HH:mm').format(r.recordedAt)}${r.notes == null ? '' : '\n${r.notes}'}'),
              trailing: Text('${r.value}${r.unit ?? ''}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ))),
          ]);
        },
      ),
    );
  }
}
