import 'package:flutter/material.dart';

import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../utils/date_helpers.dart';
import '../attendance/attendance_history.dart';
import 'dashboard_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final today = DateTime.now();
    final week = isoWeekNumber(today);

    final todaySessions = state.sessionsOnDay(today);
    final dueSoon = state.assignmentsDueWithinDays(7);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          formatShortDate(today),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Academic week $week',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AluColors.textSecondary),
        ),
        const SizedBox(height: 16),
        AttendanceSummaryCard(
          percentage: state.attendancePercentage,
          isBelowThreshold: state.isAttendanceBelowThreshold,
          recordedCount: state.recordedAttendanceCount,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        PendingAssignmentsCard(count: state.pendingAssignmentsCount),
        const SizedBox(height: 12),
        TodaySessionsCard(sessions: todaySessions),
        const SizedBox(height: 12),
        DueSoonCard(assignments: dueSoon),
        const SizedBox(height: 24),
        Text(
          'Tip: Tap an item to edit it.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AluColors.textSecondary),
        ),
      ],
    );
  }
}
