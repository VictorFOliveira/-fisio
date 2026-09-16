import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/clinical_record.dart';
import '../models/patient.dart';
import 'patient_detail_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key, required this.database, this.initialRecordType});
  final AppDatabase database;
  final RecordType? initialRecordType;

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  late Future<List<Patient>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = widget.database.patients();

  Future<void> _addPatient() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final notes = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo paciente'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome *')),
            const SizedBox(height: 12),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Telefone')),
            const SizedBox(height: 12),
            TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Observações')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );
    if (saved != true || name.text.trim().isEmpty) return;
    await widget.database.addPatient(Patient(
      name: name.text.trim(),
      phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
      notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
      createdAt: DateTime.now(),
    ));
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addPatient, icon: const Icon(Icons.person_add_alt_1), label: const Text('Paciente')),
      body: FutureBuilder<List<Patient>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final patients = snapshot.data!;
          if (patients.isEmpty) return const Center(child: Text('Nenhum paciente cadastrado ainda.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = patients[index];
              return Card(child: ListTile(
                leading: CircleAvatar(child: Text(p.name.substring(0, 1).toUpperCase())),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(p.phone ?? 'Prontuário local'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PatientDetailScreen(database: widget.database, patient: p, initialRecordType: widget.initialRecordType),
                )),
              ));
            },
          );
        },
      ),
    );
  }
}
