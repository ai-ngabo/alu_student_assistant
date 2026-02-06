// lib/shared/state/app_state.dart
import 'package:flutter/foundation.dart';

import '../../features/assignments/assignment_model.dart';
import '../../features/assignments/assignment_repository.dart';
import '../../features/sessions/session_model.dart';
import '../../utils/date_helpers.dart';

class AppState extends ChangeNotifier {
  final List<Assignment> _assignments = [];
  final List<AcademicSession> _sessions = [];

  // Add repository for assignments persistence
  final AssignmentRepository _assignmentRepo = AssignmentRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Assignment> get assignments => List.unmodifiable(_assignments);
  List<AcademicSession> get sessions => List.unmodifiable(_sessions);

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load assignments from repository
      final loadedAssignments = await _assignmentRepo.loadAssignments();
      _assignments.clear();
      _assignments.addAll(loadedAssignments);

      // Sessions will be loaded later when session repository is created
      // For now, sessions are empty or use dummy data

    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int get pendingAssignmentsCount =>
      _assignments.where((a) => !a.isCompleted).length;

  List<Assignment> assignmentsDueWithinDays(int days, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final end = current.add(Duration(days: days));
    final items =
    _assignments
        .where((a) => !a.isCompleted)
        .where((a) => !a.dueDate.isBefore(startOfDay(current)))
        .where((a) => !a.dueDate.isAfter(endOfDay(end)))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }

  List<AcademicSession> sessionsOnDay(DateTime day) {
    final items = _sessions.where((s) => isSameDay(s.date, day)).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return items;
  }

  int get recordedAttendanceCount =>
      _sessions.where((s) => s.attendance != null).length;

  int get presentAttendanceCount =>
      _sessions.where((s) => s.attendance == AttendanceStatus.present).length;

  double get attendancePercentage {
    final recorded = recordedAttendanceCount;
    if (recorded == 0) return 100;
    return (presentAttendanceCount / recorded) * 100;
  }

  bool get isAttendanceBelowThreshold => attendancePercentage < 75;

  // Assignment methods with persistence
  Future<void> addAssignment(Assignment assignment) async {
    _assignments.add(assignment);
    await _assignmentRepo.saveAssignments(_assignments);
    notifyListeners();
  }

  Future<void> updateAssignment(Assignment updated) async {
    final index = _assignments.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;
    _assignments[index] = updated;
    await _assignmentRepo.saveAssignments(_assignments);
    notifyListeners();
  }

  Future<void> removeAssignment(String id) async {
    _assignments.removeWhere((a) => a.id == id);
    await _assignmentRepo.saveAssignments(_assignments);
    notifyListeners();
  }

  Future<void> toggleAssignmentCompleted(String id) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final current = _assignments[index];
    _assignments[index] = current.copyWith(isCompleted: !current.isCompleted);
    await _assignmentRepo.saveAssignments(_assignments);
    notifyListeners();
  }

  // Session methods (without persistence for now - teammates will add repository)
  Future<void> addSession(AcademicSession session) async {
    _sessions.add(session);
    notifyListeners();
  }

  Future<void> updateSession(AcademicSession updated) async {
    final index = _sessions.indexWhere((s) => s.id == updated.id);
    if (index == -1) return;
    _sessions[index] = updated;
    notifyListeners();
  }

  Future<void> removeSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<void> setSessionAttendance(String sessionId, AttendanceStatus? status) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;
    _sessions[index] = _sessions[index].copyWith(attendance: status);
    notifyListeners();
  }
}