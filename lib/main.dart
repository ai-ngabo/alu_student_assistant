// main.dart
import 'package:flutter/material.dart';
import 'dashboard_page.dart';

void main() {
  runApp(const AcademicPlannerApp());
}

class AcademicPlannerApp extends StatelessWidget {
  const AcademicPlannerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Planner',
      theme: ThemeData(
        primaryColor: Color(0xFF1B4965),
        scaffoldBackgroundColor: Color(0xFF0A1128),
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // TODO: Replace these placeholder pages with actual pages from teammates
  final List<Widget> _pages = [
    DashboardPage(),
    PlaceholderPage(title: 'Assignments', icon: Icons.assignment),
    PlaceholderPage(title: 'Schedule', icon: Icons.calendar_today),
    PlaceholderPage(title: 'More', icon: Icons.menu),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF0F1B2E), // Dark blue-grey background
          selectedItemColor:
              Color(0xFFFFB800), // Yellow/gold color for selected
          unselectedItemColor: Colors.white54,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              activeIcon: Icon(Icons.menu),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder page for pages not yet built by teammates
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderPage({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1128),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1128),
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              '$title Page',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This page will be built by a teammate',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
