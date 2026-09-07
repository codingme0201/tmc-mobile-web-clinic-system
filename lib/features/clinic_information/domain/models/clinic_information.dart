class ClinicInformation {
  final String name;
  final String description;
  final String address;
  final String contactNumber;
  final String email;
  final List<String> services;

  const ClinicInformation({
    required this.name,
    required this.description,
    required this.address,
    required this.contactNumber,
    required this.email,
    required this.services,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'contactNumber': contactNumber,
      'email': email,
      'services': services,
    };
  }

  factory ClinicInformation.fromJson(Map<String, dynamic> json) {
    return ClinicInformation(
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      contactNumber: json['contactNumber'] as String,
      email: json['email'] as String,
      services: (json['services'] as List).cast<String>(),
    );
  }
}
