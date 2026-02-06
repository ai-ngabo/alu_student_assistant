import 'package:flutter/material.dart';

import '../../shared/theme/colors.dart';

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
        Icon(isLow ? Icons.warning_amber : Icons.check_circle, color: color),
        const SizedBox(width: 6),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
