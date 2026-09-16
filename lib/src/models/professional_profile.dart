class ProfessionalProfile {
  const ProfessionalProfile({required this.name, required this.registration, this.email = '', this.phone = ''});

  final String name;
  final String registration;
  final String email;
  final String phone;

  bool get isValid => name.trim().isNotEmpty && registration.trim().isNotEmpty;
}
