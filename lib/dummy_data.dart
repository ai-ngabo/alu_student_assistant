// dummy_data.dart
// Temporary dummy data - will be replaced with real data from other pages later

import 'models.dart';

class DummyData {
  // Dummy Assignments
  static List<Assignment> getDummyAssignments() {
    return [
      Assignment(
        id: '1',
        title: 'Mobile Dev Project 1',
        dueDate: DateTime.now().add(Duration(days: 2)),
        course: 'Mobile Development',
        priority: 'High',
      ),
      Assignment(
        id: '2',
        title: 'Data Structures Essay',
        dueDate: DateTime.now().add(Duration(days: 5)),
        course: 'Computer Science',
        priority: 'Medium',
      ),
      Assignment(
        id: '3',
        title: 'Leadership Reflection',
        dueDate: DateTime.now().add(Duration(days: 3)),
        course: 'Leadership',
        priority: 'Low',
      ),
      Assignment(
        id: '4',
        title: 'Algorithm Problem Set',
        dueDate: DateTime.now().add(Duration(days: 6)),
        course: 'Algorithms',
        priority: 'High',
      ),
      Assignment(
        id: '5',
        title: 'Group Presentation Prep',
        dueDate: DateTime.now().add(Duration(days: 1)),
        course: 'Communication',
        priority: 'Medium',
      ),
    ];
  }

  // Dummy Sessions
  static List<Session> getDummySessions() {
    final today = DateTime.now();
    final tomorrow = today.add(Duration(days: 1));
    
    return [
      Session(
        id: '1',
        title: 'Mobile Development Class',
        date: today,
        startTime: '9:00 AM',
        endTime: '11:00 AM',
        location: 'Lab 2',
        type: 'Class',
        isPresent: true,
      ),
      Session(
        id: '2',
        title: 'Algorithms Lecture',
        date: today,
        startTime: '2:00 PM',
        endTime: '4:00 PM',
        location: 'Room 305',
        type: 'Class',
        isPresent: true,
      ),
      Session(
        id: '3',
        title: 'Study Group - Data Structures',
        date: today,
        startTime: '5:00 PM',
        endTime: '6:30 PM',
        location: 'Library',
        type: 'Study Group',
        isPresent: false,
      ),
      Session(
        id: '4',
        title: 'Leadership Mastery Session',
        date: tomorrow,
        startTime: '10:00 AM',
        endTime: '12:00 PM',
        location: 'Hall A',
        type: 'Mastery Session',
        isPresent: false,
      ),
      Session(
        id: '5',
        title: 'PSL Meeting',
        date: tomorrow,
        startTime: '3:00 PM',
        endTime: '4:00 PM',
        location: 'Conference Room',
        type: 'PSL Meeting',
        isPresent: false,
      ),
    ];
  }

  // Calculate attendance percentage
  static double calculateAttendance(List<Session> sessions) {
    if (sessions.isEmpty) return 0.0;
    
    int totalSessions = sessions.length;
    int attendedSessions = sessions.where((s) => s.isPresent).length;
    
    return (attendedSessions / totalSessions) * 100;
  }

  // Get assignments due in next 7 days
  static List<Assignment> getUpcomingAssignments(List<Assignment> assignments) {
    final now = DateTime.now();
    final weekFromNow = now.add(Duration(days: 7));
    
    return assignments.where((assignment) {
      return !assignment.isCompleted &&
             assignment.dueDate.isAfter(now) &&
             assignment.dueDate.isBefore(weekFromNow);
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get today's sessions
  static List<Session> getTodaySessions(List<Session> sessions) {
    return sessions.where((session) => session.isToday).toList();
  }

  // Get current academic week (dummy calculation)
  static int getCurrentWeek() {
    // Simple calculation: assume semester started Jan 13, 2026
    final semesterStart = DateTime(2026, 1, 13);
    final now = DateTime.now();
    final difference = now.difference(semesterStart).inDays;
    return (difference / 7).floor() + 1;
  }
}
