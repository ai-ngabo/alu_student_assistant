// dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'dummy_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // TODO: Replace with real data from other pages later
  late List<Assignment> assignments;
  late List<Session> sessions;
  late double attendancePercentage;
  late int currentWeek;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Using dummy data for now - will integrate real data later
    assignments = DummyData.getDummyAssignments();
    sessions = DummyData.getDummySessions();
    attendancePercentage = DummyData.calculateAttendance(sessions);
    currentWeek = DummyData.getCurrentWeek();
  }

  @override
  Widget build(BuildContext context) {
    final todaySessions = DummyData.getTodaySessions(sessions);
    final upcomingAssignments = DummyData.getUpcomingAssignments(assignments);
    final pendingAssignments = assignments.where((a) => !a.isCompleted).length;

    return Scaffold(
      backgroundColor: Color(0xFF0A1128), // Dark navy background
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1128),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.dashboard, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ALU User greeting section
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'ALU User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Attendance Warning Card
            _buildAttendanceWarning(attendancePercentage),

            SizedBox(height: 16),

            // Assignment Stats Row
            _buildAssignmentStats(pendingAssignments),

            SizedBox(height: 20),

            // Today's Classes Section
            _buildTodayClassesSection(todaySessions),

            SizedBox(height: 20),

            // Assignments Section
            _buildAssignmentsSection(upcomingAssignments),

            SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceWarning(double percentage) {
    final bool isLow = percentage < 75;

    if (!isLow) {
      // If attendance is good, show a success message instead
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2D5F3F), // Dark green
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATTENDANCE GOOD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You\'re at ${percentage.toStringAsFixed(0)}% - Keep it up!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFD32F2F), // Red background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATTENDANCE WARNING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You\'re at ${percentage.toStringAsFixed(0)}% - Must be above 75%',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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

  Widget _buildAssignmentStats(int pendingAssignments) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Pending Assignments
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    pendingAssignments.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),

          // Upcoming (due in next 7 days)
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    DummyData.getUpcomingAssignments(assignments)
                        .length
                        .toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Upcoming',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),

          // Completed
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    assignments.where((a) => a.isCompleted).length.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayClassesSection(List<Session> todaySessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Today\'s Classes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        if (todaySessions.isEmpty)
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No classes scheduled for today',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: todaySessions.length,
            itemBuilder: (context, index) {
              final session = todaySessions[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${session.startTime} - ${session.endTime}',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            if (session.location.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  session.location,
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAssignmentsSection(List<Assignment> upcomingAssignments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Assignments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        if (upcomingAssignments.isEmpty)
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No assignments due this week',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount:
                upcomingAssignments.length > 3 ? 3 : upcomingAssignments.length,
            itemBuilder: (context, index) {
              final assignment = upcomingAssignments[index];
              final daysUntilDue =
                  assignment.dueDate.difference(DateTime.now()).inDays;

              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              assignment.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(assignment.priority),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              assignment.priority,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.book_outlined,
                              size: 14, color: Colors.white54),
                          SizedBox(width: 4),
                          Text(
                            assignment.course,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.white54),
                          SizedBox(width: 4),
                          Text(
                            'Due in $daysUntilDue day${daysUntilDue == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: daysUntilDue <= 2
                                  ? Colors.orange
                                  : Colors.white54,
                              fontSize: 13,
                              fontWeight: daysUntilDue <= 2
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
