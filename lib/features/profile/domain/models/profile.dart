enum AccountStatus { active, inactive, pending, suspended }

class StudentInfo {
  final String studentId;
  final String program;
  final String yearLevel;
  final String block;
  final String enrollmentStatus;

  String get section => block;

  const StudentInfo({
    required this.studentId,
    required this.program,
    required this.yearLevel,
    required this.block,
    required this.enrollmentStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'program': program,
      'yearLevel': yearLevel,
      'block': block,
      'section': block,
      'enrollmentStatus': enrollmentStatus,
    };
  }

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      studentId: (json['studentId'] ?? '').toString(),
      program: (json['program'] ?? '').toString(),
      yearLevel: (json['yearLevel'] ?? '').toString(),
      block: (json['block'] ?? json['section'] ?? 'Block 1').toString(),
      enrollmentStatus: (json['enrollmentStatus'] ?? 'Enrolled').toString(),
    );
  }
}

class MedicalInfo {
  final String bloodType;
  final String? allergies;
  final String? conditions;
  final String? medications;
  final String? emergencyContact;
  final String? emergencyContactNumber;

  const MedicalInfo({
    required this.bloodType,
    this.allergies,
    this.conditions,
    this.medications,
    this.emergencyContact,
    this.emergencyContactNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'bloodType': bloodType,
      'allergies': allergies,
      'conditions': conditions,
      'medications': medications,
      'emergencyContact': emergencyContact,
      'emergencyContactNumber': emergencyContactNumber,
    };
  }

  factory MedicalInfo.fromJson(Map<String, dynamic> json) {
    return MedicalInfo(
      bloodType: json['bloodType'] as String,
      allergies: json['allergies'] as String?,
      conditions: json['conditions'] as String?,
      medications: json['medications'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyContactNumber: json['emergencyContactNumber'] as String?,
    );
  }
}

class Profile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? telephone;
  final String? address;
  final DateTime dateOfBirth;
  final String? gender;
  final AccountStatus accountStatus;
  final StudentInfo? studentInfo;
  final MedicalInfo? medicalInfo;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.telephone,
    this.address,
    required this.dateOfBirth,
    this.gender,
    required this.accountStatus,
    this.studentInfo,
    this.medicalInfo,
  });

  Profile copyWith({
    String? name,
    String? email,
    String? phone,
    String? telephone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    AccountStatus? accountStatus,
    StudentInfo? studentInfo,
    MedicalInfo? medicalInfo,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      telephone: telephone ?? this.telephone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      accountStatus: accountStatus ?? this.accountStatus,
      studentInfo: studentInfo ?? this.studentInfo,
      medicalInfo: medicalInfo ?? this.medicalInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'telephone': telephone,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'accountStatus': accountStatus.name,
      'studentInfo': studentInfo?.toJson(),
      'medicalInfo': medicalInfo?.toJson(),
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      telephone: (json['telephone'] ?? json['telephoneNumber'] ?? json['landline']) as String?,
      address: json['address'] as String?,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String?,
      accountStatus: AccountStatus.values.firstWhere(
        (e) => e.name == json['accountStatus'],
        orElse: () => AccountStatus.active,
      ),
      studentInfo: json['studentInfo'] != null
          ? StudentInfo.fromJson(json['studentInfo'] as Map<String, dynamic>)
          : null,
      medicalInfo: json['medicalInfo'] != null
          ? MedicalInfo.fromJson(json['medicalInfo'] as Map<String, dynamic>)
          : null,
    );
  }
}
