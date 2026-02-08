import 'package:flutter/material.dart';

import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../utils/date_helpers.dart';
import '../../shared/widgets/info_card.dart';
import 'session_form.dart';
import 'session_model.dart';

class SessionScheduleScreen extends StatefulWidget {
  const SessionScheduleScreen({super.key});

  @override
  State<SessionScheduleScreen> createState() => _SessionScheduleScreenState();
}

class _SessionScheduleScreenState extends State<SessionScheduleScreen> {
  DateTime _weekAnchor = DateTime.now();

  DateTime get _weekStart => startOfWeek(_weekAnchor);

  void _shiftWeek(int deltaWeeks) {
    setState(
      () => _weekAnchor = _weekAnchor.add(Duration(days: deltaWeeks * 7)),
    );
  }

  Future<void> _editSession(AcademicSession session) async {
    final updated = await Navigator.of(context).push<AcademicSession>(
      MaterialPageRoute(builder: (_) => SessionFormScreen(initial: session)),
    );
    if (!mounted || updated == null) return;
    AppStateScope.of(context).updateSession(updated);
  }

  void _deleteSession(AcademicSession session) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove session?'),
        content: Text('Delete "${session.title}" from your schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AppStateScope.of(context).removeSession(session.id);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AluColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final weekStart = _weekStart;
    final weekEnd = endOfWeek(_weekAnchor);
    final weekLabel =
        '${formatShortDate(weekStart)} - ${formatShortDate(weekEnd)}';

    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final today = DateTime.now();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: 'Week',
                value: weekLabel,
                icon: Icons.date_range,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              tooltip: 'Previous week',
              onPressed: () => _shiftWeek(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Next week',
              onPressed: () => _shiftWeek(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // "Calendar linkage" (rubric): show a weekly strip that highlights days
        // with scheduled sessions and/or assignments due.
        _WeekStrip(
          weekDays: weekDays,
          today: today,
          sessionCountForDay: (day) => state.sessionsOnDay(day).length,
          assignmentCountForDay: (day) => state.assignmentsDueOnDay(day).length,
        ),
        const SizedBox(height: 12),
        ...weekDays.map((day) {
          final sessions = state.sessionsOnDay(day);
          return _DaySection(
            day: day,
            sessions: sessions,
            onEdit: _editSession,
            onDelete: _deleteSession,
            onAttendanceChanged: (id, status) =>
                state.setSessionAttendance(id, status),
          );
        }),
        const SizedBox(height: 24),
        Text(
          'Add sessions from the + button in the top-right.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AluColors.textSecondary),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.weekDays,
    required this.today,
    required this.sessionCountForDay,
    required this.assignmentCountForDay,
  });

  final List<DateTime> weekDays;
  final DateTime today;
  final int Function(DateTime day) sessionCountForDay;
  final int Function(DateTime day) assignmentCountForDay;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: weekDays.map((day) {
            final isToday = isSameDay(day, today);
            final sessions = sessionCountForDay(day);
            final assignments = assignmentCountForDay(day);
            final hasItems = sessions > 0 || assignments > 0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isToday
                        ? AluColors.secondary.withOpacity(0.12)
                        : Colors.transparent,
                    border: Border.all(
                      color: isToday
                          ? AluColors.secondary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday - 1],
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: isToday
                                  ? AluColors.secondary
                                  : AluColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AluColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 6),
                      if (!hasItems)
                        const SizedBox(height: 6)
                      else
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          children: [
                            if (sessions > 0)
                              _CountDot(
                                color: AluColors.primary,
                                label: '$sessions',
                                tooltip: '$sessions session(s)',
                              ),
                            if (assignments > 0)
                              _CountDot(
                                color: AluColors.disco,
                                label: '$assignments',
                                tooltip: '$assignments assignment(s) due',
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CountDot extends StatelessWidget {
  const _CountDot({
    required this.color,
    required this.label,
    required this.tooltip,
  });

  final Color color;
  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.sessions,
    required this.onEdit,
    required this.onDelete,
    required this.onAttendanceChanged,
  });

  final DateTime day;
  final List<AcademicSession> sessions;
  final void Function(AcademicSession session) onEdit;
  final void Function(AcademicSession session) onDelete;
  final void Function(String sessionId, AttendanceStatus? status)
  onAttendanceChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDayLabel(day),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (sessions.isEmpty)
                Text(
                  'No sessions scheduled.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AluColors.textSecondary,
                  ),
                )
              else
                ...sessions.map(
                  (s) => _SessionTile(
                    session: s,
                    onTap: () => onEdit(s),
                    onDelete: () => onDelete(s),
                    onAttendanceChanged: (status) =>
                        onAttendanceChanged(s.id, status),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.onTap,
    required this.onDelete,
    required this.onAttendanceChanged,
  });

  final AcademicSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final void Function(AttendanceStatus? status) onAttendanceChanged;

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        '${session.startTime.format(context)} - ${session.endTime.format(context)}';
    final subtitleParts = <String>[
      session.type.label,
      if ((session.location ?? '').trim().isNotEmpty) session.location!.trim(),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.event_note, color: AluColors.primary),
        title: Text(session.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$timeLabel • ${subtitleParts.join(' • ')}'),
            const SizedBox(height: 6),
            _AttendanceToggle(
              value: session.attendance,
              onChanged: onAttendanceChanged,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Session actions',
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onTap();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (ctx) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Remove')),
          ],
        ),
      ),
    );
  }
}

class _AttendanceToggle extends StatelessWidget {
  const _AttendanceToggle({required this.value, required this.onChanged});

  final AttendanceStatus? value;
  final void Function(AttendanceStatus? status) onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AttendanceStatus>(
      showSelectedIcon: false,
      emptySelectionAllowed: true,
      segments: const [
        ButtonSegment(
          value: AttendanceStatus.present,
          label: Text('Present'),
          icon: Icon(Icons.check, size: 16),
        ),
        ButtonSegment(
          value: AttendanceStatus.absent,
          label: Text('Absent'),
          icon: Icon(Icons.close, size: 16),
        ),
      ],
      selected: value == null ? <AttendanceStatus>{} : {value!},
      onSelectionChanged: (set) => onChanged(set.isEmpty ? null : set.first),
    );
  }
}
