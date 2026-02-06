// lib/features/assignments/assignment_form.dart
import 'package:flutter/material.dart';

import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/date_time_picker.dart';
import '../../shared/theme/colors.dart';
import '../../utils/date_helpers.dart';
import 'assignment_model.dart';

class AssignmentFormScreen extends StatefulWidget {
  const AssignmentFormScreen({super.key, this.initial});

  final Assignment? initial;

  @override
  State<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _courseController;
  DateTime? _dueDate;
  String _priority = 'Low';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _courseController = TextEditingController(
      text: widget.initial?.course ?? '',
    );
    _dueDate = widget.initial?.dueDate;
    _priority = (widget.initial?.priority.trim().isEmpty ?? true)
        ? 'Low'
        : widget.initial!.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Prevent double submission
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // If editing, preserve the original ID and creation date
      final finalAssignment = widget.initial != null
          ? Assignment(
        id: widget.initial!.id,
        title: _titleController.text.trim(),
        dueDate: startOfDay(_dueDate!),
        course: _courseController.text.trim(),
        priority: _priority,
        isCompleted: widget.initial!.isCompleted,
        createdAt: widget.initial!.createdAt,
      )
          : Assignment.createNew(
        title: _titleController.text.trim(),
        dueDate: startOfDay(_dueDate!),
        course: _courseController.text.trim(),
        priority: _priority,
      );

      Navigator.of(context).pop(finalAssignment);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AluColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Assignment title is required';
    if (trimmed.length < 3) return 'Title must be at least 3 characters';
    if (trimmed.length > 100) return 'Title is too long (max 100 characters)';
    return null;
  }

  String? _validateCourse(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > 50) return 'Course name is too long (max 50 characters)';
    return null;
  }

  String? _validateDueDate(DateTime? date) {
    if (date == null) return 'Due date is required';
    if (date.isBefore(DateTime.now())) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  Color _getDueDateColor() {
    if (_dueDate == null) return AluColors.primary;
    final daysLeft = _dueDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 3) return AluColors.warning;
    return AluColors.success;
  }

  IconData _getDueDateIcon() {
    if (_dueDate == null) return Icons.calendar_today;
    final daysLeft = _dueDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 3) return Icons.warning;
    return Icons.calendar_today;
  }

  String _getDueDateMessage() {
    if (_dueDate == null) return 'Select a due date';
    final daysLeft = _dueDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 3) {
      return 'Due soon! $daysLeft day${daysLeft == 1 ? '' : 's'} remaining';
    }
    return 'Due in $daysLeft day${daysLeft == 1 ? '' : 's'}';
  }

  Color _getDueDateContainerColor() {
    final color = _getDueDateColor();
    return Color.alphaBlend(color.withAlpha(25), Colors.transparent);
  }

  Color _getDueDateBorderColor() {
    final color = _getDueDateColor();
    return Color.alphaBlend(color.withAlpha(75), Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Assignment' : 'New Assignment'),
        backgroundColor: AluColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  isEdit ? 'Update assignment details' : 'Create a new assignment',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Color.alphaBlend(
                      colorScheme.onSurface.withAlpha(178),
                      colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Assignment Title *',
                    hintText: 'e.g., Reflection Essay',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                  maxLength: 100,
                  validator: _validateTitle,
                  autofocus: !isEdit,
                ),
                const SizedBox(height: 16),

                // Due date field
                DatePickerField(
                  label: 'Due Date *',
                  value: _dueDate,
                  onChanged: (dt) => setState(() => _dueDate = dt),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  validator: _validateDueDate,
                ),
                const SizedBox(height: 16),

                // Course field
                TextFormField(
                  controller: _courseController,
                  decoration: InputDecoration(
                    labelText: 'Course Name',
                    hintText: 'e.g., Foundations of Leadership',
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                  maxLength: 50,
                  validator: _validateCourse,
                ),
                const SizedBox(height: 16),

                // Priority field
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: const Icon(Icons.flag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'High',
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: AluColors.danger, size: 20),
                          SizedBox(width: 8),
                          Text('High Priority'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Medium',
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: AluColors.warning, size: 20),
                          SizedBox(width: 8),
                          Text('Medium Priority'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Low',
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: AluColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Low Priority'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _priority = v ?? 'Low'),
                ),
                const SizedBox(height: 32),

                // Due date warning
                if (_dueDate != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getDueDateContainerColor(),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getDueDateBorderColor(),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getDueDateIcon(),
                          color: _getDueDateColor(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getDueDateMessage(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _getDueDateColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Submit button
                CustomButton(
                  text: isEdit ? 'Save Changes' : 'Create Assignment',
                  onPressed: _isSubmitting ? null : _submit,
                  isLoading: _isSubmitting,
                  icon: isEdit ? Icons.save : Icons.add,
                ),

                // Cancel button for edit mode
                if (isEdit) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}