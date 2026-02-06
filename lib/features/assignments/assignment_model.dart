class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String course;
  final String priority; // High/Medium/Low
  final bool isCompleted;

  const Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.course,
    required this.priority,
    required this.isCompleted,
  });

  Assignment copyWith({
    String? title,
    DateTime? dueDate,
    String? course,
    String? priority,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      course: course ?? this.course,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dueDate': dueDate.toIso8601String(),
        'course': course,
        'priority': priority,
        'isCompleted': isCompleted,
      };

  static Assignment fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      course: json['course'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Low',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}
