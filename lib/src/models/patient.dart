class Patient {
  const Patient({
    this.id,
    required this.name,
    this.birthDate,
    this.phone,
    this.email,
    this.sex,
    this.weightKg,
    this.heightCm,
    this.medicalDiagnosis,
    this.chiefComplaint,
    this.comorbidities,
    this.medications,
    this.allergies,
    this.surgeries,
    this.precautions,
    this.referringProfessional,
    this.notes,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final DateTime? birthDate;
  final String? phone;
  final String? email;
  final String? sex;
  final double? weightKg;
  final double? heightCm;
  final String? medicalDiagnosis;
  final String? chiefComplaint;
  final String? comorbidities;
  final String? medications;
  final String? allergies;
  final String? surgeries;
  final String? precautions;
  final String? referringProfessional;
  final String? notes;
  final DateTime createdAt;

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) years--;
    return years;
  }

  double? get bmi {
    if (weightKg == null || heightCm == null || heightCm! <= 0) return null;
    final meters = heightCm! / 100;
    return weightKg! / (meters * meters);
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'birth_date': birthDate?.toIso8601String(),
        'phone': phone,
        'email': email,
        'sex': sex,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'medical_diagnosis': medicalDiagnosis,
        'chief_complaint': chiefComplaint,
        'comorbidities': comorbidities,
        'medications': medications,
        'allergies': allergies,
        'surgeries': surgeries,
        'precautions': precautions,
        'referring_professional': referringProfessional,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory Patient.fromMap(Map<String, Object?> map) => Patient(
        id: map['id'] as int?,
        name: map['name'] as String,
        birthDate: map['birth_date'] == null ? null : DateTime.parse(map['birth_date'] as String),
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        sex: map['sex'] as String?,
        weightKg: (map['weight_kg'] as num?)?.toDouble(),
        heightCm: (map['height_cm'] as num?)?.toDouble(),
        medicalDiagnosis: map['medical_diagnosis'] as String?,
        chiefComplaint: map['chief_complaint'] as String?,
        comorbidities: map['comorbidities'] as String?,
        medications: map['medications'] as String?,
        allergies: map['allergies'] as String?,
        surgeries: map['surgeries'] as String?,
        precautions: map['precautions'] as String?,
        referringProfessional: map['referring_professional'] as String?,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
