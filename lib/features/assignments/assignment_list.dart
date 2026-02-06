import 'package:flutter/material.dart';

import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../utils/date_helpers.dart';
import 'assignment_form.dart';
import 'assignment_model.dart';

class AssignmentListScreen extends StatelessWidget {
  const AssignmentListScreen({super.key});

  Future<void> _create(BuildContext context) async {
    final created = await Navigator.of(context).push<Assignment>(
      MaterialPageRoute(builder: (_) => const AssignmentFormScreen()),
    );
    if (created == null || !context.mounted) return;
    AppStateScope.of(context).addAssignment(created);
  }

  Future<void> _edit(BuildContext context, Assignment assignment) async {
    final updated = await Navigator.of(context).push<Assignment>(
      MaterialPageRoute(builder: (_) => AssignmentFormScreen(initial: assignment)),
    );
    if (updated == null || !context.mounted) return;
    AppStateScope.of(context).updateAssignment(updated);
  }

  void _delete(BuildContext context, Assignment assignment) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove assignment?'),
        content: Text('Delete "${assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AppStateScope.of(context).removeAssignment(assignment.id);
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
    final items = state.assignments.toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No assignments yet.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _create(context),
                icon: const Icon(Icons.add),
                label: const Text('Add assignment'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, index) {
        final a = items[index];
        final dueLabel = formatShortDate(a.dueDate);
        final color = a.isCompleted
            ? AluColors.success
            : (a.priority == 'High'
                ? AluColors.danger
                : (a.priority == 'Medium'
                    ? AluColors.warning
                    : AluColors.primary));
        return Card(
          child: ListTile(
            title: Text(
              a.title,
              style: TextStyle(
                decoration: a.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              a.course.trim().isEmpty
                  ? 'Due $dueLabel'
                  : '${a.course} • Due $dueLabel',
            ),
            leading: Checkbox(
              value: a.isCompleted,
              onChanged: (_) =>
                  AppStateScope.of(context).toggleAssignmentCompleted(a.id),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PriorityChip(label: a.priority, color: color),
                const SizedBox(width: 6),
                PopupMenuButton<String>(
                  tooltip: 'Assignment actions',
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _edit(context, a);
                        break;
                      case 'delete':
                        _delete(context, a);
                        break;
                    }
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Remove')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = label.trim().isEmpty ? 'Low' : label.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
