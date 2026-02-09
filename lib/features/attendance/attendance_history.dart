import 'package:flutter/material.dart';

import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/info_card.dart';
import '../../utils/date_helpers.dart';
import '../sessions/session_model.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final recorded = state.sessions.where((s) => s.attendance != null).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final hasData = state.hasRecordedAttendance;
    final pct = hasData ? state.attendancePercentage.toStringAsFixed(0) : 'N/A';
    final color = hasData
        ? (state.isAttendanceBelowThreshold
            ? AluColors.danger
            : AluColors.success)
        : AluColors.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InfoCard(
              title: 'Overall attendance',
              value:
                  hasData
                      ? '$pct% • ${state.presentAttendanceCount}/${state.recordedAttendanceCount} sessions'
                      : 'No attendance recorded yet',
              icon: Icons.analytics,
              accent: color,
            ),
            const SizedBox(height: 12),
            if (recorded.isEmpty)
              const Center(child: Text('No attendance recorded yet.'))
            else
              ...recorded.map((s) => _AttendanceTile(session: s)),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.session});

  final AcademicSession session;

  @override
  Widget build(BuildContext context) {
    final status = session.attendance;
    final color = status == AttendanceStatus.present
        ? AluColors.success
        : AluColors.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          title: Text(session.title),
          subtitle: Text(
            '${formatShortDate(session.date)} • ${session.type.label}',
          ),
          trailing: SegmentedButton<AttendanceStatus>(
            showSelectedIcon: false,
            emptySelectionAllowed: true,
            segments: const [
              ButtonSegment(
                value: AttendanceStatus.present,
                label: Text('Present'),
              ),
              ButtonSegment(
                value: AttendanceStatus.absent,
                label: Text('Absent'),
              ),
            ],
            selected: status == null ? <AttendanceStatus>{} : {status},
            onSelectionChanged: (set) => AppStateScope.of(
              context,
            ).setSessionAttendance(session.id, set.isEmpty ? null : set.first),
          ),
          leading: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
