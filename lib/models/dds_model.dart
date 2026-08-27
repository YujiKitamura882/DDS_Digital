class DdsTopic {
  final String id;
  final DateTime date;
  String title;
  final String category;
  String content;
  String? description;
  bool isCompleted;
  List<AttendanceRecord> signatures;

  DdsTopic({
    required this.id,
    required this.date,
    required this.title,
    required this.category,
    required this.content,
    this.description,
    this.isCompleted = false,
    List<AttendanceRecord>? signatures,
  }) : signatures = signatures ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'category': category,
      'content': content,
      'description': description,
      'isCompleted': isCompleted,
      'signatures': signatures.map((s) => s.toJson()).toList(),
    };
  }

  factory DdsTopic.fromJson(Map<String, dynamic> json) {
    return DdsTopic(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      category: json['category'] ?? 'Geral',
      content: json['content'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      signatures: (json['signatures'] as List<dynamic>?)
              ?.map((item) => AttendanceRecord.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class AttendanceRecord {
  final String id;
  final String name;
  final String role;
  final String signatureBase64;
  final DateTime signedAt;
  final String? pointsJson;

  AttendanceRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.signatureBase64,
    required this.signedAt,
    this.pointsJson,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'signatureBase64': signatureBase64,
      'signedAt': signedAt.toIso8601String(),
      'pointsJson': pointsJson,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      signatureBase64: json['signatureBase64'] ?? '',
      signedAt: json['signedAt'] != null
          ? DateTime.parse(json['signedAt'])
          : DateTime.now(),
      pointsJson: json['pointsJson'],
    );
  }
}