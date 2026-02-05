// Creating the assignment model
class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String course;
  final String priority; // It can be high, medium or low
  bool isCompleted;


  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.course,
    this.priority = '',
    this.isCompleted = false // current state until done
  });

  // helper method for unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}