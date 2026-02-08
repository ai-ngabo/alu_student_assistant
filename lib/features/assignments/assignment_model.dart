// lib/features/assignments/assignment_model.dart
import 'package:flutter/material.dart';

import '../../utils/date_helpers.dart';

/// Assignment entity used throughout the app.
///
/// Includes:
/// - Core fields (title/description/due date/course/priority)
/// - Completion state
/// - Optional in-app reminder configuration (for rubric popup)
class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String course;
  final String priority; // Optional: High/Medium/Low (or empty when not set)
  final bool isCompleted;
  final DateTime createdAt;

  /// Reminder (in-app only; no background notifications when app is closed).
  final bool reminderEnabled;
  final int reminderDaysBefore; // 0 = same day, 1 = one day before, etc.
  final TimeOfDay reminderTime;

  const Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.course,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.reminderEnabled,
    required this.reminderDaysBefore,
    required this.reminderTime,
  });

  Assignment copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? course,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    TimeOfDay? reminderTime,
  }) {
    return Assignment(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      course: course ?? this.course,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'course': course,
    'priority': priority,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'reminderEnabled': reminderEnabled,
    'reminderDaysBefore': reminderDaysBefore,
    'reminderTimeHour': reminderTime.hour,
    'reminderTimeMinute': reminderTime.minute,
  };

  static Assignment fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      course: json['course'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 0,
      reminderTime: TimeOfDay(
        hour: json['reminderTimeHour'] as int? ?? 9,
        minute: json['reminderTimeMinute'] as int? ?? 0,
      ),
    );
  }

  // Helper methods
  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
  bool get isDueSoon {
    if (isCompleted) return false;
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;
    return daysUntilDue <= 3 && daysUntilDue >= 0;
  }
  bool get isHighPriority => priority == 'High' && !isCompleted;

  DateTime? get nextReminderDateTime {
    if (!reminderEnabled) return null;
    // Reminder is scheduled relative to the assignment's due date.
    final reminderDate = startOfDay(dueDate).subtract(
      Duration(days: reminderDaysBefore),
    );
    return DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      reminderTime.hour,
      reminderTime.minute,
    );
  }

  String dueDateLabel(BuildContext context) => formatShortDate(dueDate);

  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  static Assignment createNew({
    required String title,
    String description = '',
    required DateTime dueDate,
    String course = '',
    String priority = '',
    bool reminderEnabled = false,
    int reminderDaysBefore = 0,
    TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0),
  }) {
    return Assignment(
      id: generateId(),
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      course: course.trim(),
      priority: priority,
      isCompleted: false,
      createdAt: DateTime.now(),
      reminderEnabled: reminderEnabled,
      reminderDaysBefore: reminderDaysBefore,
      reminderTime: reminderTime,
    );
  }
}
