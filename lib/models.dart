// models.dart
// Data models for the academic planner app

class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String course;
  final String priority; // High, Medium, Low
  bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.course,
    this.priority = 'Medium',
    this.isCompleted = false,
  });
}

class Session {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final String type; // Class, Mastery Session, Study Group, PSL Meeting
  bool isPresent;

  Session({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location = '',
    required this.type,
    this.isPresent = false,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
