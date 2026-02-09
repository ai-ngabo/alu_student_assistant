import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AttendanceIndicator extends StatelessWidget {
  const AttendanceIndicator({
    super.key,
    required this.percentage,
    this.hasRecordedAttendance = true,
  });

  final double percentage;
  final bool hasRecordedAttendance;

  @override
  Widget build(BuildContext context) {
    if (!hasRecordedAttendance) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: AluColors.primary),
          const SizedBox(width: 8),
          Text(
            'N/A',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AluColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      );
    }

    final isLow = percentage < 75;
    final color = isLow ? AluColors.danger : AluColors.success;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isLow ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
