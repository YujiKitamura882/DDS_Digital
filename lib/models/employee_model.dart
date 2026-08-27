class Employee {
  final String id;
  final String name;
  final String registration;
  final String role;
  final DateTime admissionDate;

  Employee({
    required this.id,
    required this.name,
    required this.registration,
    required this.role,
    required this.admissionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'registration': registration,
      'role': role,
      'admissionDate': admissionDate.toIso8601String(),
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      registration: json['registration'],
      role: json['role'],
      admissionDate: json['admissionDate'] != null
          ? DateTime.parse(json['admissionDate'])
          : DateTime.now(),
    );
  }
}