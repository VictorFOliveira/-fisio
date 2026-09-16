import 'package:flutter/material.dart';

import '../models/professional_profile.dart';
import '../services/professional_profile_service.dart';
import '../widgets/brand_logo.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  const ProfessionalProfileScreen({super.key, this.initial});
  final ProfessionalProfile? initial;

  @override
  State<ProfessionalProfileScreen> createState() => _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _registration;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _registration = TextEditingController(text: widget.initial?.registration ?? '');
    _email = TextEditingController(text: widget.initial?.email ?? '');
    _phone = TextEditingController(text: widget.initial?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose(); _registration.dispose(); _email.dispose(); _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final profile = ProfessionalProfile(name: _name.text, registration: _registration.text, email: _email.text, phone: _phone.text);
    await ProfessionalProfileService.instance.save(profile);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return Scaffold(
      appBar: editing ? AppBar(title: const Text('Meu perfil profissional')) : null,
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (!editing) ...[const Center(child: BrandLogo(size: 105)), const SizedBox(height: 22)],
        Text(editing ? 'Dados do profissional' : 'Bem-vindo ao +Fisio', textAlign: editing ? TextAlign.left : TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(editing ? 'Esses dados identificam o profissional responsável pelos atendimentos.' : 'Antes de começar, cadastre o profissional responsável. Nome e registro serão usados automaticamente nos relatórios.', textAlign: editing ? TextAlign.left : TextAlign.center),
        const SizedBox(height: 24),
        TextFormField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nome do profissional *', prefixIcon: Icon(Icons.person_outline)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome do profissional.' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _registration, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Registro profissional *', hintText: 'Ex.: CREFITO 123456-F', prefixIcon: Icon(Icons.badge_outlined)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o registro profissional.' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail (opcional)', prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: 12),
        TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone (opcional)', prefixIcon: Icon(Icons.phone_outlined))),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_circle_outline), label: Text(editing ? 'Salvar alterações' : 'Salvar e continuar')),
      ])))),
    );
  }
}
