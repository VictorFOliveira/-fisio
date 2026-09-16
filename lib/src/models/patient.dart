class Patient {
  const Patient({
    this.id,
    required this.name,
    this.birthDate,
    this.phone,
    this.email,
    this.notes,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final DateTime? birthDate;
  final String? phone;
  final String? email;
  final String? notes;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'birth_date': birthDate?.toIso8601String(),
        'phone': phone,
        'email': email,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory Patient.fromMap(Map<String, Object?> map) => Patient(
        id: map['id'] as int?,
        name: map['name'] as String,
        birthDate: map['birth_date'] == null
            ? null
            : DateTime.parse(map['birth_date'] as String),
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
