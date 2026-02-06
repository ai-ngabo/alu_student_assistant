import 'package:flutter/material.dart';

import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../utils/date_helpers.dart';
import '../sessions/session_model.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    // Sessions that can be marked (e.g. today or all sessions)
    final sessions = state.sessions
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: SafeArea(
        child: sessions.isEmpty
            ? const Center(child: Text('No sessions available.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  return _AttendanceCard(session: sessions[index]);
                },
              ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.session});

  final AcademicSession session;

  @override
  Widget build(BuildContext context) {
    final status = session.attendance;

    Color indicatorColor;
    if (status == AttendanceStatus.present) {
      indicatorColor = AluColors.success;
    } else if (status == AttendanceStatus.absent) {
      indicatorColor = AluColors.danger;
    } else {
      indicatorColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${formatShortDate(session.date)} • ${session.type.label}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SegmentedButton<AttendanceStatus>(
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
              selected:
                  status == null ? <AttendanceStatus>{} : {status},
              onSelectionChanged: (set) {
                AppStateScope.of(context).setSessionAttendance(
                  session.id,
                  set.isEmpty ? null : set.first,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
