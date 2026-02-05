// lib/features/assignments/assignment_model.dart
class Assignment {
  final String title;
  final DateTime dueDate;
  final String course;
  final String priority;

  Assignment({
    required this.title,
    required this.dueDate,
    required this.course,
    this.priority = 'Medium',
  });
}