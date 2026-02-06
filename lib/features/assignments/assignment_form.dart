import 'package:flutter/material.dart';

import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/date_time_picker.dart';
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date.')),
      );
      return;
    }

    final assignment = Assignment(
      id: widget.initial?.id ?? Assignment.generateId(),
      title: _titleController.text.trim(),
      dueDate: startOfDay(_dueDate!),
      course: _courseController.text.trim(),
      priority: _priority,
      isCompleted: widget.initial?.isCompleted ?? false,
    );

    Navigator.of(context).pop(assignment);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Assignment' : 'New Assignment'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Title *',
                      hintText: 'e.g., Reflection Essay',
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Title is required.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DatePickerField(
                    label: 'Due Date *',
                    value: _dueDate,
                    onChanged: (dt) => setState(() => _dueDate = dt),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _courseController,
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                      hintText: 'e.g., Foundations of Leadership',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: const [
                      DropdownMenuItem(value: 'High', child: Text('High')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                    ],
                    onChanged: (v) => setState(() => _priority = v ?? 'Low'),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: isEdit ? 'Save Changes' : 'Create Assignment',
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
