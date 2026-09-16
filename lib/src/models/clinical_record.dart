enum RecordType { goniometry, strength, assessment, evolution, functionalTest }

class ClinicalRecord {
  const ClinicalRecord({
    this.id, required this.patientId, required this.type, required this.title,
    required this.value, this.unit, this.notes, this.bodyRegion, this.movement,
    this.side, this.painScore, this.protocol, required this.recordedAt,
  });

  final int? id;
  final int patientId;
  final RecordType type;
  final String title;
  final String value;
  final String? unit;
  final String? notes;
  final String? bodyRegion;
  final String? movement;
  final String? side;
  final int? painScore;
  final String? protocol;
  final DateTime recordedAt;

  Map<String, Object?> toMap() => {
    'id': id, 'patient_id': patientId, 'type': type.name, 'title': title,
    'value': value, 'unit': unit, 'notes': notes, 'body_region': bodyRegion,
    'movement': movement, 'side': side, 'pain_score': painScore,
    'protocol': protocol, 'recorded_at': recordedAt.toIso8601String(),
  };

  factory ClinicalRecord.fromMap(Map<String, Object?> map) => ClinicalRecord(
    id: map['id'] as int?, patientId: map['patient_id'] as int,
    type: RecordType.values.byName(map['type'] as String),
    title: map['title'] as String, value: map['value'] as String,
    unit: map['unit'] as String?, notes: map['notes'] as String?,
    bodyRegion: map['body_region'] as String?, movement: map['movement'] as String?,
    side: map['side'] as String?, painScore: map['pain_score'] as int?,
    protocol: map['protocol'] as String?,
    recordedAt: DateTime.parse(map['recorded_at'] as String),
  );
}
