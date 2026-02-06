// lib/features/assignments/assignment_repository.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assignment_model.dart';

class AssignmentRepository {
  static const String _storageKey = 'alu_student_assignments';

  // Singleton instance
  static AssignmentRepository? _instance;
  factory AssignmentRepository() => _instance ??= AssignmentRepository._internal();
  AssignmentRepository._internal();

  // Get shared preferences instance
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Load all assignments from storage with error handling
  Future<List<Assignment>> loadAssignments() async {
    try {
      final prefs = await _prefs;
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => Assignment.fromJson(json))
          .where((assignment) => assignment.id.isNotEmpty && assignment.title.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error loading assignments: $e');
      // If data is corrupted, needs to be cleared
      await clearAll();
      return [];
    }
  }

  // Save all assignments to storage
  Future<bool> saveAssignments(List<Assignment> assignments) async {
    try {
      final prefs = await _prefs;
      final validAssignments = assignments
          .where((a) => a.id.isNotEmpty && a.title.isNotEmpty)
          .toList();

      final jsonList = validAssignments.map((a) => a.toJson()).toList();
      return await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving assignments: $e');
      return false;
    }
  }

  // Add a new assignment
  Future<bool> addAssignment(Assignment assignment) async {
    final assignments = await loadAssignments();
    assignments.add(assignment);
    return await saveAssignments(assignments);
  }

  // Update an existing assignment
  Future<bool> updateAssignment(Assignment assignment) async {
    final assignments = await loadAssignments();
    final index = assignments.indexWhere((a) => a.id == assignment.id);

    if (index != -1) {
      assignments[index] = assignment;
      return await saveAssignments(assignments);
    }
    return false;
  }

  // Delete an assignment
  Future<bool> deleteAssignment(String id) async {
    final assignments = await loadAssignments();
    assignments.removeWhere((a) => a.id == id);
    return await saveAssignments(assignments);
  }

  // Toggle completion status
  Future<bool> toggleCompletion(String id) async {
    final assignments = await loadAssignments();
    final index = assignments.indexWhere((a) => a.id == id);

    if (index != -1) {
      final assignment = assignments[index];
      assignments[index] = assignment.copyWith(
        isCompleted: !assignment.isCompleted,
      );
      return await saveAssignments(assignments);
    }
    return false;
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

  // Get overdue assignments
  Future<List<Assignment>> getOverdueAssignments() async {
    final assignments = await loadAssignments();
    final now = DateTime.now();

    return assignments
        .where((a) => !a.isCompleted && a.dueDate.isBefore(now))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get high priority assignments
  Future<List<Assignment>> getHighPriorityAssignments() async {
    final assignments = await loadAssignments();

    return assignments
        .where((a) => !a.isCompleted && a.priority == 'High')
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get pending assignments count (for dashboard)
  Future<int> getPendingCount() async {
    final assignments = await loadAssignments();
    return assignments.where((a) => !a.isCompleted).length;
  }

  // Clear all assignments (for debugging/reset)
  Future<bool> clearAll() async {
    final prefs = await _prefs;
    return await prefs.remove(_storageKey);
  }
}