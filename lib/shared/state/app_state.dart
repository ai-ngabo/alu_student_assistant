// lib/shared/state/app_state.dart
import 'package:flutter/foundation.dart';

import '../../features/assignments/assignment_model.dart';
import '../../features/assignments/assignment_repository.dart';
import '../../features/sessions/session_model.dart';
import '../../features/sessions/session_repository.dart';
import '../../utils/date_helpers.dart';

/// Central in-memory state for the app.
///
/// This class is the single source of truth for UI screens:
/// - Dashboard reads summaries (today’s sessions, due soon, attendance %).
/// - Assignments and Calendar mutate and observe the same lists.
///
/// Persistence note:
/// - Assignments are currently persisted via [AssignmentRepository].
/// - Sessions (including attendance) are persisted via [SessionRepository].
class AppState extends ChangeNotifier {
  final List<Assignment> _assignments = [];
  final List<AcademicSession> _sessions = [];

  /// Simple persistence layer for assignments (SharedPreferences JSON).
  ///
  /// Kept behind a repository so we can swap it later (e.g., SQLite).
  final AssignmentRepository _assignmentRepo = AssignmentRepository();

  /// Persistence layer for sessions (SharedPreferences JSON).
  /// Sessions include attendance, so this also persists attendance.
  final SessionRepository _sessionRepo = SessionRepository();

  /// True while loading persisted data at startup.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Assignment> get assignments => List.unmodifiable(_assignments);
  List<AcademicSession> get sessions => List.unmodifiable(_sessions);

  /// Clears in-memory lists (used for demos).
  ///
  /// Note: this does not clear persisted assignments.
  void clearAll() {
    _assignments.clear();
    _sessions.clear();
    notifyListeners();
  }

  /// Clears demo data in a way that matches what the user sees.
  ///
  /// - Clears persisted assignments + sessions
  /// - Clears in-memory copies
  Future<void> resetDemoData() async {
    _sessions.clear();
    _assignments.clear();
    await _assignmentRepo.clearAll();
    await _sessionRepo.clearAll();
    notifyListeners();
  }

  AppState() {
    // Load persisted assignments on app start.
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load assignments from repository.
      final loadedAssignments = await _assignmentRepo.loadAssignments();
      _assignments.clear();
      _assignments.addAll(loadedAssignments);

      // Load sessions (includes attendance).
      final loadedSessions = await _sessionRepo.loadSessions();
      _sessions.clear();
      _sessions.addAll(loadedSessions);

    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Count of assignments not marked completed.
  int get pendingAssignmentsCount =>
      _assignments.where((a) => !a.isCompleted).length;

  /// Returns assignments due within [days] days (inclusive), sorted by due date.
  ///
  /// Used by the Dashboard “due within next 7 days” list.
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

  /// Returns sessions scheduled on a given calendar day, sorted by start time.
  List<AcademicSession> sessionsOnDay(DateTime day) {
    final items = _sessions.where((s) => isSameDay(s.date, day)).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return items;
  }

  /// Count of sessions where attendance is explicitly recorded.
  int get recordedAttendanceCount =>
      _sessions.where((s) => s.attendance != null).length;

  /// Count of sessions recorded as Present.
  int get presentAttendanceCount =>
      _sessions.where((s) => s.attendance == AttendanceStatus.present).length;

  /// True once at least one session has Present/Absent set.
  bool get hasRecordedAttendance => recordedAttendanceCount > 0;

  /// Attendance percentage computed from recorded sessions only.
  ///
  /// UI shows “N/A” until at least one session is recorded.
  double get attendancePercentage {
    final recorded = recordedAttendanceCount;
    if (recorded == 0) return 100;
    return (presentAttendanceCount / recorded) * 100;
  }

  /// Assignments due on a specific day (used by Calendar day highlighting).
  List<Assignment> assignmentsDueOnDay(DateTime day) {
    final items = _assignments
        .where((a) => !a.isCompleted)
        .where((a) => isSameDay(a.dueDate, day))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }

  /// Dashboard warning flag (only valid when attendance has been recorded).
  bool get isAttendanceBelowThreshold =>
      hasRecordedAttendance && attendancePercentage < 75;

  // Assignment methods with persistence
  /// Adds an assignment and persists the full list.
  Future<void> addAssignment(Assignment assignment) async {
    _assignments.add(assignment);
    await _assignmentRepo.saveAssignments(_assignments);
    notifyListeners();
  }

  /// Updates an assignment and persists the full list.
  Future<void> updateAssignment(Assignment updated) async {
    final index = _assignments.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;
    _assignments[index] = updated;
    await _assignmentRepo.saveAssignments(_assignments);
    notifyListeners();
  }

  /// Removes an assignment and persists the full list.
  Future<void> removeAssignment(String id) async {
    _assignments.removeWhere((a) => a.id == id);
    await _assignmentRepo.saveAssignments(_assignments);
    notifyListeners();
  }

  /// Toggles completion status and persists the full list.
  Future<void> toggleAssignmentCompleted(String id) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final current = _assignments[index];
    _assignments[index] = current.copyWith(isCompleted: !current.isCompleted);
    await _assignmentRepo.saveAssignments(_assignments);
    notifyListeners();
  }

  // Session methods with persistence
  /// Adds a session and persists the full list.
  Future<void> addSession(AcademicSession session) async {
    _sessions.add(session);
    await _sessionRepo.saveSessions(_sessions);
    notifyListeners();
  }

  /// Updates a session and persists the full list.
  Future<void> updateSession(AcademicSession updated) async {
    final index = _sessions.indexWhere((s) => s.id == updated.id);
    if (index == -1) return;
    _sessions[index] = updated;
    await _sessionRepo.saveSessions(_sessions);
    notifyListeners();
  }

  /// Removes a session and persists the full list.
  Future<void> removeSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await _sessionRepo.saveSessions(_sessions);
    notifyListeners();
  }

  /// Records attendance for a session (Present/Absent/Not set).
  Future<void> setSessionAttendance(
    String sessionId,
    AttendanceStatus? status,
  ) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;
    _sessions[index] = _sessions[index].copyWith(attendance: status);
    await _sessionRepo.saveSessions(_sessions);
    notifyListeners();
  }
}
