import 'package:flutter/foundation.dart';

import '../../features/assignments/assignment_model.dart';
import '../../features/sessions/session_model.dart';
import '../../utils/date_helpers.dart';

class AppState extends ChangeNotifier {
  final List<Assignment> _assignments = [];
  final List<AcademicSession> _sessions = [];

  List<Assignment> get assignments => List.unmodifiable(_assignments);
  List<AcademicSession> get sessions => List.unmodifiable(_sessions);

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

  void addAssignment(Assignment assignment) {
    _assignments.add(assignment);
    notifyListeners();
  }

  void updateAssignment(Assignment updated) {
    final index = _assignments.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;
    _assignments[index] = updated;
    notifyListeners();
  }

  void removeAssignment(String id) {
    _assignments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleAssignmentCompleted(String id) {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final current = _assignments[index];
    _assignments[index] = current.copyWith(isCompleted: !current.isCompleted);
    notifyListeners();
  }

  void addSession(AcademicSession session) {
    _sessions.add(session);
    notifyListeners();
  }

  void updateSession(AcademicSession updated) {
    final index = _sessions.indexWhere((s) => s.id == updated.id);
    if (index == -1) return;
    _sessions[index] = updated;
    notifyListeners();
  }

  void removeSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void setSessionAttendance(String sessionId, AttendanceStatus? status) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;
    _sessions[index] = _sessions[index].copyWith(attendance: status);
    notifyListeners();
  }
}
