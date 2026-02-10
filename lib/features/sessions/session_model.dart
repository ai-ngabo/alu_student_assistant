import 'package:flutter/material.dart';

enum SessionType { classSession, masterySession, studyGroup, pslMeeting }

extension SessionTypeLabel on SessionType {
  String get label => switch (this) {
    SessionType.classSession => 'Class',
    SessionType.masterySession => 'Mastery Session',
    SessionType.studyGroup => 'Study Group',
    SessionType.pslMeeting => 'PSL Meeting',
  };
}

enum AttendanceStatus { present, absent }

extension AttendanceStatusLabel on AttendanceStatus {
  String get label => switch (this) {
    AttendanceStatus.present => 'Present',
    AttendanceStatus.absent => 'Absent',
  };
}

class AcademicSession {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? location;
  final SessionType type;
  final AttendanceStatus? attendance;

  const AcademicSession({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.location,
    this.attendance,
  });

  int get startMinutes => startTime.hour * 60 + startTime.minute;
  int get endMinutes => endTime.hour * 60 + endTime.minute;

  AcademicSession copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    SessionType? type,
    AttendanceStatus? attendance,
    bool clearAttendance = false,
  }) {
    return AcademicSession(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      attendance: clearAttendance ? null : (attendance ?? this.attendance),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'startHour': startTime.hour,
    'startMinute': startTime.minute,
    'endHour': endTime.hour,
    'endMinute': endTime.minute,
    'location': location,
    'type': type.name,
    'attendance': attendance?.name,
  };

  static AcademicSession fromJson(Map<String, dynamic> json) {
    return AcademicSession(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: TimeOfDay(
        hour: json['startHour'] as int,
        minute: json['startMinute'] as int,
      ),
      endTime: TimeOfDay(
        hour: json['endHour'] as int,
        minute: json['endMinute'] as int,
      ),
      location: json['location'] as String?,
      type: SessionType.values.firstWhere((t) => t.name == json['type']),
      attendance: (json['attendance'] as String?) == null
          ? null
          : AttendanceStatus.values.firstWhere(
              (a) => a.name == (json['attendance'] as String),
            ),
    );
  }

  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}
