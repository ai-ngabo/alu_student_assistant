// data management for the assignments
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'assignment_model.dart';

class AssignmentRepository {
  static const String _assignmentsKey = 'assignments';

  Future<List<Assignment>> getAssignment() async {
    // implementing shared_preferences
    final prefs = await SharedPreferences.getInstance();
    final assignmentJson = prefs.getStringList(_assignmentsKey) ?? [];

    return assignmentJson.map((json) {
      final data = Map<String, dynamic>.from(jsonDecode(json));
      return Assignment(
        id: data['id'],
        title: data['title'],
        dueDate: data['dueDate'],
        course: data['course'],
        priority: data['priority'] ?? '',
        isCompleted: data['isCompleted'] ?? false,
      );
    }).toList();
  }

  // method for saving ana assignment
  Future<void> saveAssignments(List<Assignment> assignments) async {
    final prefs = await SharedPreferences.getInstance();
    final assignmentsJson = assignments.map((assignment) {
      return jsonEncode({
        'id': assignment.id,
        'title': assignment.title,
        'dueDate': assignment.dueDate.toIso8601String(),
        'course': assignment.course,
        'priority': assignment.priority,
        'isCompleted': assignment.isCompleted,
      });
    }).toList();

    await prefs.setStringList(_assignmentsKey, assignmentsJson);
  }

  // method for add an assignment to dictionary and save it
  Future<void> addAssignment(Assignment assignment) async {
    final assignments = await getAssignment();
    assignments.add(assignment);
    await saveAssignments(assignments);
  }

  // Editing the assignment
  Future<void> updateAssignment(Assignment updatedAssignment) async {
    final assignments = await getAssignment();
    final index = assignments.indexWhere((a) => a.id == updatedAssignment.id);
    if (index != -1) {
      assignments[index] = updatedAssignment;
      await saveAssignments(assignments);
    }
  }

  // method to delete assignment
  Future<void> deleteAssignment(String id) async {
    final assignments = await getAssignment();
    assignments.removeWhere((a) => a.id == id);
    await saveAssignments(assignments);
  }
}
