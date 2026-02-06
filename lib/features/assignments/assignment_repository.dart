// lib/features/assignments/assignment_repository.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assignment_model.dart';

class AssignmentRepository {
  static const String _storageKey = 'assignments';

  // Get shared preferences instance
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Load all assignments from storage
  Future<List<Assignment>> loadAssignments() async {
    try {
      final prefs = await _prefs;
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Assignment.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading assignments: $e');
      return [];
    }
  }

  // Save all assignments to storage
  Future<void> saveAssignments(List<Assignment> assignments) async {
    try {
      final prefs = await _prefs;
      final jsonList = assignments.map((a) => a.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving assignments: $e');
    }
  }

  // Add a new assignment
  Future<void> addAssignment(Assignment assignment) async {
    final assignments = await loadAssignments();
    assignments.add(assignment);
    await saveAssignments(assignments);
  }

  // Update an existing assignment
  Future<void> updateAssignment(Assignment assignment) async {
    final assignments = await loadAssignments();
    final index = assignments.indexWhere((a) => a.id == assignment.id);

    if (index != -1) {
      assignments[index] = assignment;
      await saveAssignments(assignments);
    }
  }

  // Delete an assignment
  Future<void> deleteAssignment(String id) async {
    final assignments = await loadAssignments();
    assignments.removeWhere((a) => a.id == id);
    await saveAssignments(assignments);
  }

  // Toggle completion status
  Future<void> toggleCompletion(String id) async {
    final assignments = await loadAssignments();
    final index = assignments.indexWhere((a) => a.id == id);

    if (index != -1) {
      final assignment = assignments[index];
      assignments[index] = assignment.copyWith(
        isCompleted: !assignment.isCompleted,
      );
      await saveAssignments(assignments);
    }
  }

  // Get assignments due in next 7 days (for dashboard)
  Future<List<Assignment>> getUpcomingAssignments() async {
    final assignments = await loadAssignments();
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return assignments
        .where((a) => !a.isCompleted && a.dueDate.isAfter(now) && a.dueDate.isBefore(weekFromNow))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get pending assignments count (for dashboard)
  Future<int> getPendingCount() async {
    final assignments = await loadAssignments();
    return assignments.where((a) => !a.isCompleted).length;
  }
}