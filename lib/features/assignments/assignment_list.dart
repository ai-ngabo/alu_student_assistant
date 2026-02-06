// lib/features/assignments/assignment_list.dart
import 'package:flutter/material.dart';

import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../utils/date_helpers.dart';
import 'assignment_form.dart';
import 'assignment_model.dart';

class AssignmentListScreen extends StatelessWidget {
  const AssignmentListScreen({super.key});

  Future<void> _createAssignment(BuildContext context) async {
    final created = await Navigator.of(context).push<Assignment>(
      MaterialPageRoute(builder: (_) => const AssignmentFormScreen()),
    );
    if (created == null || !context.mounted) return;
    AppStateScope.of(context).addAssignment(created);
  }

  Future<void> _editAssignment(BuildContext context, Assignment assignment) async {
    final updated = await Navigator.of(context).push<Assignment>(
      MaterialPageRoute(
        builder: (_) => AssignmentFormScreen(initial: assignment),
      ),
    );
    if (updated == null || !context.mounted) return;
    AppStateScope.of(context).updateAssignment(updated);
  }

  void _deleteAssignment(BuildContext context, Assignment assignment) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove assignment?'),
        content: Text('Delete "${assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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

  void _toggleCompletion(BuildContext context, Assignment assignment) {
    AppStateScope.of(context).toggleAssignmentCompleted(assignment.id);
  }

  Color _getAssignmentColor(Assignment assignment) {
    if (assignment.isCompleted) return AluColors.success;
    switch (assignment.priority) {
      case 'High':
        return AluColors.danger;
      case 'Medium':
        return AluColors.warning;
      case 'Low':
        return AluColors.primary;
      default:
        return AluColors.primary;
    }
  }

  Color _getAssignmentBackgroundColor(Color color) {
    return Color.alphaBlend(color.withAlpha(30), Colors.transparent);
  }

  Color _getSubtitleColor(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Color.alphaBlend(onSurface.withAlpha(178), Colors.transparent);
  }

  Color _getOutlineColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
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
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: _getOutlineColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                'No assignments yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first assignment to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _getOutlineColor(context),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _createAssignment(context),
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
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final assignment = items[index];
        final dueLabel = formatShortDate(assignment.dueDate);
        final color = _getAssignmentColor(assignment);
        final backgroundColor = _getAssignmentBackgroundColor(color);
        final subtitleColor = _getSubtitleColor(context);
        final outlineColor = _getOutlineColor(context);

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Checkbox(
              value: assignment.isCompleted,
              onChanged: (_) => _toggleCompletion(context, assignment),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(
              assignment.title,
              style: TextStyle(
                decoration: assignment.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (assignment.description.trim().isNotEmpty) ...[
                  Text(
                    assignment.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (assignment.course.trim().isNotEmpty) ...[
                  Text(
                    assignment.course,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: outlineColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due $dueLabel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: outlineColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PriorityChip(
                  label: assignment.priority,
                  color: color,
                  backgroundColor: backgroundColor,
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Assignment actions',
                  icon: Icon(
                    Icons.more_vert,
                    color: outlineColor,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editAssignment(context, assignment);
                        break;
                      case 'delete':
                        _deleteAssignment(context, assignment);
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AluColors.danger, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Remove',
                            style: TextStyle(color: AluColors.danger),
                          ),
                        ],
                      ),
                    ),
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
  const _PriorityChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final text = label.trim().isEmpty ? 'Not set' : label.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
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
