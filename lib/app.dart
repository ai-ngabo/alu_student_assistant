import 'package:flutter/material.dart';

import 'features/assignments/assignment_form.dart';
import 'features/assignments/assignment_list.dart';
import 'features/attendance/attendance_history.dart';
import 'features/attendance/attendance_summary.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/sessions/session_form.dart';
import 'features/sessions/session_model.dart';
import 'features/sessions/session_schedule.dart';
import 'features/settings/settings_screen.dart';
import 'shared/services/reminder_service.dart';
import 'shared/state/app_state.dart';
import 'shared/state/app_state_scope.dart';
import 'shared/theme/colors.dart';
import 'shared/theme/text_styles.dart';



/// Root widget that wires together:
/// - Theme (ALU colors)
/// - Global app state (`AppStateScope`)
/// - In-app reminders (`ReminderServiceScope`)
/// - Bottom navigation shell
class AluStudentAssistantApp extends StatefulWidget {
  const AluStudentAssistantApp({super.key});

  @override
  State<AluStudentAssistantApp> createState() => _AluStudentAssistantAppState();
}

class _AluStudentAssistantAppState extends State<AluStudentAssistantApp> {
  final AppState _appState = AppState();

  // Used by ReminderService to display dialogs from anywhere in the app.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final ReminderService _reminderService =
      ReminderService(navigatorKey: _navigatorKey, appState: _appState);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reminderService.start();
    });
  }

  @override
  void dispose() {
    _reminderService.dispose();
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AluColors.primary,
        primary: AluColors.primary,
        secondary: AluColors.secondary,
        error: AluColors.danger,
        surface: AluColors.surface,
      ),
      scaffoldBackgroundColor: AluColors.background,
      textTheme: AluTextStyles.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AluColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AluColors.secondary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AluColors.border),
        ),
      ),
    );

    return AppStateScope(
      appState: _appState,
      child: ReminderServiceScope(
        reminderService: _reminderService,
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'ALU Student Assistant',
          theme: theme,
          home: const _HomeShell(),
        ),
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  Future<void> _handleAddPressed() async {
    final state = AppStateScope.of(context);
    if (_index == 1) {
      final created = await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AssignmentFormScreen()),
      );
      if (!mounted || created == null) return;
      await state.addAssignment(created);
    } else if (_index == 2) {
      final created = await Navigator.of(context).push<AcademicSession>(
        MaterialPageRoute(builder: (_) => const SessionFormScreen()),
      );
      if (!mounted || created == null) return;
      await state.addSession(created);
    }
  }

  Future<void> _openMore(String value) async {
    switch (value) {
      case 'attendance':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AttendanceSummaryScreen()),
        );
        break;
      case 'attendance_history':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
        );
        break;
      case 'settings':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const DashboardScreen(),
      const AssignmentListScreen(),
      const SessionScheduleScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_index) {
          0 => 'Dashboard',
          1 => 'Assignments',
          _ => 'Schedule',
        }),
        actions: [
          if (_index == 1 || _index == 2)
            IconButton(
              tooltip: _index == 1 ? 'Add assignment' : 'Add session',
              onPressed: _handleAddPressed,
              icon: const Icon(Icons.add),
            ),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: _openMore,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'attendance',
                child: ListTile(
                  leading: Icon(Icons.fact_check),
                  title: Text('Attendance'),
                ),
              ),
              PopupMenuItem(
                value: 'attendance_history',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Attendance history'),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
            ],
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 18, color: AluColors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _index, children: screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (idx) => setState(() => _index = idx),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AluColors.secondary,
        unselectedItemColor: AluColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
