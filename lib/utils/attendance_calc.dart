import '../features/sessions/session_model.dart';

class AttendanceStats {
  final int recorded;
  final int present;

  const AttendanceStats({required this.recorded, required this.present});

  double get percentage => recorded == 0 ? 100 : (present / recorded) * 100;
}

AttendanceStats calculateAttendanceStats(Iterable<AcademicSession> sessions) {
  final recorded = sessions.where((s) => s.attendance != null).toList();
  final present = recorded
      .where((s) => s.attendance == AttendanceStatus.present)
      .length;
  return AttendanceStats(recorded: recorded.length, present: present);
}
