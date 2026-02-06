import 'package:flutter/material.dart';

import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../utils/date_helpers.dart';
import '../attendance/attendance_history.dart';
import 'dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final today = DateTime.now();
    final week = isoWeekNumber(today);

    final todaySessions = state.sessionsOnDay(today);
    final dueSoon = state.assignmentsDueWithinDays(7);

    // The dashboard is purely derived from AppState (no dummy data).
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderCard(
          dateText: formatShortDate(today),
          weekText: 'Academic week $week',
        ),
        const SizedBox(height: 12),
        if (state.isAttendanceBelowThreshold) ...[
          // Requirement: visible warning indicator when attendance < 75%.
          _WarningBanner(
            title: 'Attendance below 75%',
            message:
                'Record attendance for sessions and aim to stay above 75% to avoid penalties.',
          ),
          const SizedBox(height: 12),
        ],
        AttendanceSummaryCard(
          percentage: state.attendancePercentage,
          hasRecordedAttendance: state.hasRecordedAttendance,
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
          'Tip: Update attendance from Schedule to keep your dashboard accurate.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AluColors.textSecondary),
        ),
      ],
    );
  }
}


class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.dateText, required this.weekText});

  final String dateText;
  final String weekText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AluColors.primary, AluColors.disco],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  weekText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AluColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.warning_amber, color: AluColors.danger),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AluColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
