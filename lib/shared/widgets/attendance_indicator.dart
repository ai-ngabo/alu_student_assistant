import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AttendanceIndicator extends StatelessWidget {
  const AttendanceIndicator({
    super.key,
    required this.percentage,
  });

  final double percentage;

  @override
  Widget build(BuildContext context) {
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
