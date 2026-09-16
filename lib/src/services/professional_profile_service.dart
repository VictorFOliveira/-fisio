import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/professional_profile.dart';

class ProfessionalProfileService {
  ProfessionalProfileService._();
  static final instance = ProfessionalProfileService._();
  static const _storage = FlutterSecureStorage();
  static const _name = 'professional_name_v1';
  static const _registration = 'professional_registration_v1';
  static const _email = 'professional_email_v1';
  static const _phone = 'professional_phone_v1';

  Future<ProfessionalProfile?> load() async {
    final name = await _storage.read(key: _name) ?? '';
    final registration = await _storage.read(key: _registration) ?? '';
    if (name.trim().isEmpty || registration.trim().isEmpty) return null;
    return ProfessionalProfile(
      name: name,
      registration: registration,
      email: await _storage.read(key: _email) ?? '',
      phone: await _storage.read(key: _phone) ?? '',
    );
  }

  Future<void> save(ProfessionalProfile profile) async {
    if (!profile.isValid) throw ArgumentError('Nome e registro profissional são obrigatórios.');
    await _storage.write(key: _name, value: profile.name.trim());
    await _storage.write(key: _registration, value: profile.registration.trim());
    await _storage.write(key: _email, value: profile.email.trim());
    await _storage.write(key: _phone, value: profile.phone.trim());
  }
}
