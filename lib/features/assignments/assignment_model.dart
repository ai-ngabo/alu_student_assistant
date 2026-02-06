// lib/features/assignments/assignment_model.dart
class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String course;
  final String priority; // High/Medium/Low
  final bool isCompleted;
  final DateTime createdAt;

  const Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.course,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
  });

  Assignment copyWith({
    String? title,
    DateTime? dueDate,
    String? course,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Assignment(
      id: id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      course: course ?? this.course,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'course': course,
    'priority': priority,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  static Assignment fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      course: json['course'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Low',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // Helper methods
  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
  bool get isDueSoon {
    if (isCompleted) return false;
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;
    return daysUntilDue <= 3 && daysUntilDue >= 0;
  }
  bool get isHighPriority => priority == 'High' && !isCompleted;

  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  static Assignment createNew({
    required String title,
    required DateTime dueDate,
    String course = '',
    String priority = 'Low',
  }) {
    return Assignment(
      id: generateId(),
      title: title.trim(),
      dueDate: dueDate,
      course: course.trim(),
      priority: priority,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }
}