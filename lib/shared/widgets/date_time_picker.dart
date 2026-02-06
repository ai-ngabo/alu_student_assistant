// lib/shared/widgets/date_time_picker.dart
import 'package:flutter/material.dart';

import '../../utils/date_helpers.dart';

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.validator, // ADD THIS
  });

  final String label;
  final DateTime? value;
  final void Function(DateTime? date) onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(DateTime?)? validator; // ADD THIS

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: firstDate ?? DateTime(now.year - 1),
          lastDate: lastDate ?? DateTime(now.year + 5),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: validator?.call(value), // ADD THIS for validation
        ),
        child: Text(value == null ? 'Select date' : formatShortDate(value!)),
      ),
    );
  }
}

class TimePickerField extends StatelessWidget {
  const TimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.validator, // ADD THIS
  });

  final String label;
  final TimeOfDay? value;
  final void Function(TimeOfDay time) onChanged;
  final String? Function(TimeOfDay?)? validator; // ADD THIS

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: validator?.call(value), // ADD THIS for validation
        ),
        child: Text(value == null ? 'Select time' : value!.format(context)),
      ),
    );
  }
}