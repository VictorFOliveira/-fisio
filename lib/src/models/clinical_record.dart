enum RecordType {
  goniometry,
  strength,
  assessment,
  evolution,
  functionalTest,
}

class ClinicalRecord {
  const ClinicalRecord({
    this.id,
    required this.patientId,
    required this.type,
    required this.title,
    required this.value,
    this.unit,
    this.notes,
    required this.recordedAt,
  });

  final int? id;
  final int patientId;
  final RecordType type;
  final String title;
  final String value;
  final String? unit;
  final String? notes;
  final DateTime recordedAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'patient_id': patientId,
        'type': type.name,
        'title': title,
        'value': value,
        'unit': unit,
        'notes': notes,
        'recorded_at': recordedAt.toIso8601String(),
      };

  factory ClinicalRecord.fromMap(Map<String, Object?> map) => ClinicalRecord(
        id: map['id'] as int?,
        patientId: map['patient_id'] as int,
        type: RecordType.values.byName(map['type'] as String),
        title: map['title'] as String,
        value: map['value'] as String,
        unit: map['unit'] as String?,
        notes: map['notes'] as String?,
        recordedAt: DateTime.parse(map['recorded_at'] as String),
      );
}
