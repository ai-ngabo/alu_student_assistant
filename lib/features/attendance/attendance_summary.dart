import 'package:flutter/material.dart';

import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/info_card.dart';
import '../../shared/widgets/attendance_indicator.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    final percentage = state.attendancePercentage;
    final presentCount = state.presentAttendanceCount;
    final recordedCount = state.recordedAttendanceCount;
    final absentCount = recordedCount - presentCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Summary')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: AttendanceIndicator(percentage: percentage),
              ),
              const SizedBox(height: 24),
              InfoCard(
                title: 'Total sessions recorded',
                value: recordedCount.toString(),
                icon: Icons.event_available,
                accent: AluColors.primary,
              ),
              const SizedBox(height: 12),
              InfoCard(
                title: 'Sessions attended',
                value: presentCount.toString(),
                icon: Icons.check_circle,
                accent: AluColors.success,
              ),
              const SizedBox(height: 12),
              InfoCard(
                title: 'Sessions missed',
                value: absentCount.toString(),
                icon: Icons.cancel,
                accent: AluColors.danger,
              ),
              const SizedBox(height: 24),
              if (percentage < 75)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AluColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
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
      ),
    );
  }
}
