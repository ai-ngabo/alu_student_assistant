import 'package:flutter/material.dart';

import '../../shared/theme/colors.dart';
import '../../shared/widgets/info_card.dart';
import '../../utils/date_helpers.dart';
import '../assignments/assignment_model.dart';
import '../sessions/session_model.dart';

class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({
    super.key,
    required this.percentage,
    required this.isBelowThreshold,
    required this.recordedCount,
    required this.onTap,
  });

  final double percentage;
  final bool isBelowThreshold;
  final int recordedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pctText = '${percentage.toStringAsFixed(0)}%';
    final color = isBelowThreshold ? AluColors.danger : AluColors.success;
    final warning = isBelowThreshold ? ' (below 75%)' : '';
    final value = '$pctText$warning • $recordedCount recorded';

    return InfoCard(
      title: 'Attendance',
      value: value,
      icon: Icons.how_to_reg,
      accent: color,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class PendingAssignmentsCard extends StatelessWidget {
  const PendingAssignmentsCard({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Pending assignments',
      value: '$count',
      icon: Icons.pending_actions,
      accent: AluColors.primary,
    );
  }
}

class TodaySessionsCard extends StatelessWidget {
  const TodaySessionsCard({super.key, required this.sessions});

  final List<AcademicSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: AluColors.primary),
                const SizedBox(width: 8),
                Text(
                  "Today's sessions",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (sessions.isEmpty)
              Text(
                'No sessions today.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AluColors.textSecondary,
                ),
              )
            else
              ...sessions
                  .take(4)
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.startTime.format(context),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AluColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class DueSoonCard extends StatelessWidget {
  const DueSoonCard({super.key, required this.assignments});

  final List<Assignment> assignments;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: AluColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Due in 7 days',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (assignments.isEmpty)
              Text(
                'No upcoming deadlines.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AluColors.textSecondary,
                ),
              )
            else
              ...assignments
                  .take(4)
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatShortDate(a.dueDate),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AluColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
