enum AccountStatus { active, inactive, pending, suspended }

class StudentInfo {
  final String studentId;
  final String program;
  final String yearLevel;
  final String section;
  final String enrollmentStatus;

  const StudentInfo({
    required this.studentId,
    required this.program,
    required this.yearLevel,
    required this.section,
    required this.enrollmentStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'program': program,
      'yearLevel': yearLevel,
      'section': section,
      'enrollmentStatus': enrollmentStatus,
    };
  }

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      studentId: json['studentId'] as String,
      program: json['program'] as String,
      yearLevel: json['yearLevel'] as String,
      section: json['section'] as String,
      enrollmentStatus: json['enrollmentStatus'] as String,
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
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      accountStatus: accountStatus,
      studentInfo: studentInfo,
      medicalInfo: medicalInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
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
