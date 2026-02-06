import 'package:flutter/material.dart';

import 'features/assignments/assignment_form.dart';
import 'features/assignments/assignment_list.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/sessions/session_form.dart';
import 'features/sessions/session_model.dart';
import 'features/sessions/session_schedule.dart';
import 'shared/state/app_state.dart';
import 'shared/state/app_state_scope.dart';
import 'shared/theme/colors.dart';
import 'shared/theme/text_styles.dart';

class AluStudentAssistantApp extends StatefulWidget {
  const AluStudentAssistantApp({super.key});

  @override
  State<AluStudentAssistantApp> createState() => _AluStudentAssistantAppState();
}

class _AluStudentAssistantAppState extends State<AluStudentAssistantApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ALU Student Assistant',
        theme: theme,
        home: const _HomeShell(),
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
      state.addAssignment(created);
    } else if (_index == 2) {
      final created = await Navigator.of(context).push<AcademicSession>(
        MaterialPageRoute(builder: (_) => const SessionFormScreen()),
      );
      if (!mounted || created == null) return;
      state.addSession(created);
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
        title: Text(
          switch (_index) {
            0 => 'Dashboard',
            1 => 'Assignments',
            _ => 'Schedule',
          },
        ),
        actions: [
          if (_index == 1 || _index == 2)
            IconButton(
              tooltip: _index == 1 ? 'Add assignment' : 'Add session',
              onPressed: _handleAddPressed,
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: screens,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (idx) => setState(() => _index = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Assignments'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Schedule'),
        ],
      ),
    );
  }
}
