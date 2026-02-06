import 'package:flutter/material.dart';
import 'assignment_model.dart';
import 'assignment_repository.dart';

class AssignmentForm extends StatefulWidget {
  final Assignment? existingAssignment;

  const AssignmentForm({Key? key, this.existingAssignment}) : super(key: key);

  @override
  _AssignmentFormState createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String _priority = 'Medium';

  final AssignmentRepository _repository = AssignmentRepository();

  @override
  void initState() {
    super.initState();
    if (widget.existingAssignment != null) {
      _titleController.text = widget.existingAssignment!.title;
      _courseController.text = widget.existingAssignment!.course;
      _dueDate = widget.existingAssignment!.dueDate;
      _priority = widget.existingAssignment!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingAssignment == null
              ? 'Create New Assignment'
              : 'Edit Assignment',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter assignment title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Due Date Picker
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _dueDate = selectedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Course Name Field
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Priority Dropdown
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority Level',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'High', child: Text('High')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value ?? 'Medium';
                  });
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _saveAssignment,
                child: const Text('Save Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAssignment() async {
    if (_formKey.currentState!.validate()) {
      final assignment = Assignment(
        id: widget.existingAssignment?.id ?? Assignment.generateId(),
        title: _titleController.text,
        dueDate: _dueDate,
        course: _courseController.text,
        priority: _priority,
        isCompleted: widget.existingAssignment?.isCompleted ?? false,
      );

      if (widget.existingAssignment == null) {
        await _repository.addAssignment(assignment);
      } else {
        await _repository.updateAssignment(assignment);
      }

      Navigator.pop(context, assignment);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }
}
