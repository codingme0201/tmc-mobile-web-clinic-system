import 'package:meta/meta.dart';

@immutable
class MedicalRecord {
  final String id;
  final String patientId;
  final String name;
  final int age;
  final String sex;
  final String type;
  final String courseDept;
  final String contact;
  final String emergencyContact;
  final String status;
  final String lastUpdated;
  final List<MedicalHistory> medicalHistory;
  final List<Condition> conditions;
  final List<Allergy> allergies;
  final List<Medication> medications;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    required this.name,
    required this.age,
    required this.sex,
    required this.type,
    required this.courseDept,
    required this.contact,
    required this.emergencyContact,
    required this.status,
    required this.lastUpdated,
    required this.medicalHistory,
    required this.conditions,
    required this.allergies,
    required this.medications,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    int parsedAge = 0;
    if (json['age'] is int) {
      parsedAge = json['age'];
    } else if (json['age'] != null) {
      parsedAge = int.tryParse(json['age'].toString()) ?? 0;
    }

    final historyRaw = json['medicalHistory'] as List? ?? [];
    final conditionsRaw = json['conditions'] as List? ?? [];
    final allergiesRaw = json['allergies'] as List? ?? [];
    final medicationsRaw = json['medications'] as List? ?? [];

    return MedicalRecord(
      id: json['id']?.toString() ?? '',
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      age: parsedAge,
      sex: (json['sex'] ?? 'Unknown').toString(),
      type: (json['type'] ?? 'Student').toString(),
      courseDept: (json['courseDept'] ?? json['course_dept'] ?? '').toString(),
      contact: (json['contact'] ?? '').toString(),
      emergencyContact: (json['emergencyContact'] ?? json['emergency_contact'] ?? '').toString(),
      status: (json['status'] ?? 'Active').toString(),
      lastUpdated: (json['lastUpdated'] ?? json['last_updated'] ?? '').toString(),
      medicalHistory: historyRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => MedicalHistory.fromJson(e))
          .toList(),
      conditions: conditionsRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => Condition.fromJson(e))
          .toList(),
      allergies: allergiesRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => Allergy.fromJson(e))
          .toList(),
      medications: medicationsRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => Medication.fromJson(e))
          .toList(),
    );
  }
}

@immutable
class MedicalHistory {
  final String id;
  final String date;
  final String condition;
  final String notes;

  const MedicalHistory({
    required this.id,
    required this.date,
    required this.condition,
    required this.notes,
  });

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
      id: json['id']?.toString() ?? '',
      date: (json['date'] ?? '').toString(),
      condition: (json['condition'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }
}

@immutable
class Condition {
  final String id;
  final String name;
  final String status;
  final String diagnosedDate;
  final String notes;

  const Condition({
    required this.id,
    required this.name,
    required this.status,
    required this.diagnosedDate,
    required this.notes,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? '').toString(),
      status: (json['status'] ?? 'Active').toString(),
      diagnosedDate: (json['diagnosedDate'] ?? json['diagnosed_date'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }
}

@immutable
class Allergy {
  final String id;
  final String allergen;
  final String reaction;
  final String severity;
  final String dateRecorded;
  final String notes;

  const Allergy({
    required this.id,
    required this.allergen,
    required this.reaction,
    required this.severity,
    required this.dateRecorded,
    required this.notes,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      id: json['id']?.toString() ?? '',
      allergen: (json['allergen'] ?? '').toString(),
      reaction: (json['reaction'] ?? '').toString(),
      severity: (json['severity'] ?? 'Mild').toString(),
      dateRecorded: (json['dateRecorded'] ?? json['date_recorded'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }
}

@immutable
class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String route;
  final String prescribedBy;
  final String prescribedDate;
  final String startDate;
  final String endDate;
  final String status;
  final String instructions;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.prescribedBy,
    required this.prescribedDate,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.instructions,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? json['medicine_name'] ?? '').toString(),
      dosage: (json['dosage'] ?? '').toString(),
      frequency: (json['frequency'] ?? '').toString(),
      route: (json['route'] ?? '').toString(),
      prescribedBy: (json['prescribedBy'] ?? json['prescribed_by'] ?? '').toString(),
      prescribedDate: (json['prescribedDate'] ?? json['prescribed_date'] ?? '').toString(),
      startDate: (json['startDate'] ?? json['start_date'] ?? '').toString(),
      endDate: (json['endDate'] ?? json['end_date'] ?? '').toString(),
      status: (json['status'] ?? 'Active').toString(),
      instructions: (json['instructions'] ?? '').toString(),
    );
  }
}
