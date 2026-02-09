import 'package:flutter/material.dart';

import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/info_card.dart';
import '../../shared/widgets/attendance_indicator.dart';
import 'attendance_history.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    final percentage = state.attendancePercentage;
    final presentCount = state.presentAttendanceCount;
    final recordedCount = state.recordedAttendanceCount;
    final absentCount = recordedCount - presentCount;
    final hasData = state.hasRecordedAttendance;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: AttendanceIndicator(
                percentage: percentage,
                hasRecordedAttendance: hasData,
              ),
            ),
            const SizedBox(height: 16),
            if (!hasData) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No attendance recorded yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Go to Schedule and mark sessions as Present or Absent to see your attendance percentage.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            InfoCard(
              title: 'Total sessions recorded',
              value: hasData ? recordedCount.toString() : 'None yet',
              icon: Icons.event_available,
              accent: AluColors.primary,
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'Sessions attended',
              value: hasData ? presentCount.toString() : 'None yet',
              icon: Icons.check_circle,
              accent: AluColors.success,
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'Sessions missed',
              value: hasData ? absentCount.toString() : 'None yet',
              icon: Icons.cancel,
              accent: AluColors.danger,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AttendanceHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('View attendance history'),
            ),
            const SizedBox(height: 16),
            if (hasData && percentage < 75)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AluColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: AluColors.danger),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your attendance is below the required threshold. '
                        'Please attend more sessions to avoid penalties.',
                      ),
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
