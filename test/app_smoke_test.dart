import 'package:flutter_test/flutter_test.dart';
import 'package:mais_fisio/src/models/clinical_record.dart';
import 'package:mais_fisio/src/models/patient.dart';

void main() {
  test('patient serializes locally', () {
    final patient = Patient(name: 'Paciente Teste', createdAt: DateTime(2026, 9, 15));
    expect(patient.toMap()['name'], 'Paciente Teste');
  });

  test('all five clinical record categories are available', () {
    expect(RecordType.values.length, 5);
    expect(RecordType.values, contains(RecordType.goniometry));
    expect(RecordType.values, contains(RecordType.functionalTest));
  });
}
