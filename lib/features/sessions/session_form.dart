// lib/features/sessions/session_form.dart
import 'package:flutter/material.dart';

import '../../shared/theme/colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/date_time_picker.dart';
import '../../utils/date_helpers.dart';
import 'session_model.dart';

class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({super.key, this.initial});

  final AcademicSession? initial;

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _locationController;

  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  SessionType _type = SessionType.classSession;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _locationController = TextEditingController(
      text: widget.initial?.location ?? '',
    );
    _date = widget.initial?.date;
    _start = widget.initial?.startTime;
    _end = widget.initial?.endTime;
    _type = widget.initial?.type ?? SessionType.classSession;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateTimeRange() {
    if (_start == null || _end == null) return null;
    final startMinutes = _start!.hour * 60 + _start!.minute;
    final endMinutes = _end!.hour * 60 + _end!.minute;
    if (endMinutes <= startMinutes) {
      return 'End time must be after start time.';
    }
    return null;
  }

  void _submit() {
    final timeError = _validateTimeRange();
    if (timeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(timeError)),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time.')),
      );
      return;
    }

    final newSession = AcademicSession(
      id: widget.initial?.id ?? AcademicSession.generateId(),
      title: _titleController.text.trim(),
      date: startOfDay(_date!),
      startTime: _start!,
      endTime: _end!,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      type: _type,
      attendance: widget.initial?.attendance,
    );

    Navigator.of(context).pop(newSession);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Session' : 'New Session'),
        backgroundColor: AluColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Session Title *',
                      hintText: 'e.g., Data Structures Lecture',
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Title is required.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DatePickerField(
                    label: 'Date *',
                    value: _date,
                    onChanged: (dt) => setState(() => _date = dt),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TimePickerField(
                          label: 'Start Time *',
                          value: _start,
                          onChanged: (t) => setState(() => _start = t),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TimePickerField(
                          label: 'End Time *',
                          value: _end,
                          onChanged: (t) => setState(() => _end = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<SessionType>(
                    initialValue: _type,
                    decoration: const InputDecoration(
                      labelText: 'Session Type *',
                    ),
                    items: SessionType.values
                        .map(
                          (t) =>
                          DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                        .toList(),
                    onChanged: (t) => setState(() => _type = t ?? _type),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (Optional)',
                      hintText: 'e.g., Room 2B or Online',
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: isEdit ? 'Save Changes' : 'Create Session',
                    onPressed: _submit,
                    icon: isEdit ? Icons.save : Icons.add, // ADD THIS LINE
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Attendance is edited from the schedule list.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AluColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}