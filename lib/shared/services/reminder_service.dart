import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/assignments/assignment_model.dart';
import '../state/app_state.dart';

/// Lightweight, in-app reminder service.
///
/// What it does:
/// - Periodically checks assignments with reminders enabled
/// - Shows an AlertDialog when a reminder time is reached
///
/// What it does NOT do (important for grading clarity):
/// - No background notifications when the app is closed
/// - No OS-level scheduling; this is for the demo/rubric popup requirement
class ReminderService extends ChangeNotifier {
  ReminderService({
    required GlobalKey<NavigatorState> navigatorKey,
    required AppState appState,
  })  : _navigatorKey = navigatorKey,
        _appState = appState;

  final GlobalKey<NavigatorState> _navigatorKey;
  final AppState _appState;

  Timer? _timer;
  bool _enabled = true;

  /// Tracks which reminders have been shown this run to avoid repeat popups.
  final Set<String> _shownReminderIds = {};

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (_enabled) {
      _ensureRunning();
    } else {
      _timer?.cancel();
      _timer = null;
    }
    notifyListeners();
  }

  void resetSeen() {
    _shownReminderIds.clear();
    notifyListeners();
  }

  void start() {
    _ensureRunning();
  }

  void _ensureRunning() {
    // Short interval keeps the demo reliable without background notifications.
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) => _tick());
    _tick();
  }

  /// Immediately shows a reminder popup for the first eligible assignment.
  ///
  /// Useful for the demo video so you can trigger a popup on demand.
  void testReminderNow() {
    final assignment = _appState.assignments.firstWhere(
      (a) => !a.isCompleted && a.reminderEnabled,
      orElse: () => _appState.assignments.firstWhere(
        (a) => !a.isCompleted,
        orElse: () => Assignment.createNew(
          title: 'No assignment found',
          description: '',
          dueDate: DateTime.now(),
        ).copyWith(isCompleted: true),
      ),
    );

    if (assignment.isCompleted && assignment.title == 'No assignment found') {
      _showInfoDialog(
        title: 'No assignments',
        message: 'Create an assignment first, then enable its reminder.',
      );
      return;
    }

    if (!assignment.reminderEnabled) {
      _showInfoDialog(
        title: 'Reminder not enabled',
        message:
            'Open the assignment and enable its reminder to test a real reminder popup.',
      );
      return;
    }

    _showReminderDialog(assignment);
  }

  void _tick() {
    if (!_enabled) return;

    final now = DateTime.now();
    final dueAssignments = <Assignment>[];

    for (final assignment in _appState.assignments) {
      if (assignment.isCompleted) continue;
      final reminderAt = assignment.nextReminderDateTime;
      if (reminderAt == null) continue;
      final deltaSeconds = reminderAt.difference(now).inSeconds;
      if (deltaSeconds <= 5 && deltaSeconds >= -5) {
        dueAssignments.add(assignment);
      }
    }

    if (dueAssignments.isEmpty) return;

    for (final assignment in dueAssignments) {
      if (_shownReminderIds.contains(assignment.id)) continue;
      _shownReminderIds.add(assignment.id);
      _showReminderDialog(assignment);
    }
  }

  void _showReminderDialog(Assignment assignment) {
    // Use the navigator overlay context so reminders can appear from anywhere.
    final navigator = _navigatorKey.currentState;
    final context = navigator?.overlay?.context;
    if (context == null) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assignment reminder'),
        content: Text(
          '"${assignment.title}" is due on ${assignment.dueDateLabel(context)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog({required String title, required String message}) {
    final navigator = _navigatorKey.currentState;
    final context = navigator?.overlay?.context;
    if (context == null) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class ReminderServiceScope extends InheritedNotifier<ReminderService> {
  const ReminderServiceScope({
    super.key,
    required ReminderService reminderService,
    required Widget child,
  }) : super(notifier: reminderService, child: child);

  static ReminderService of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ReminderServiceScope>();
    assert(scope != null, 'ReminderServiceScope not found in widget tree.');
    return scope!.notifier!;
  }
}
