import 'package:flutter/material.dart';

import '../../shared/services/reminder_service.dart';
import '../../shared/state/app_state_scope.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/info_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final reminderService = ReminderServiceScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InfoCard(
          title: 'Reminders',
          value: reminderService.enabled ? 'On' : 'Off',
          icon: Icons.notifications_active,
          accent: reminderService.enabled ? AluColors.secondary : AluColors.disco,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: reminderService.enabled,
          onChanged: (v) => reminderService.setEnabled(v),
          title: const Text('Enable in-app reminders'),
          subtitle: const Text(
            'Shows a popup when an assignment reminder time is reached (while the app is open).',
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Attendance warning threshold'),
            subtitle: const Text('Fixed at 75% (per requirements)'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AluColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '75%',
                style: TextStyle(
                  color: AluColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Session-only mode'),
            subtitle: const Text(
              'Data is kept for the current session only (no storage yet).',
            ),
            trailing: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () {
            state.clearAll();
            reminderService.resetSeen();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cleared all in-memory data.')),
            );
          },
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Clear demo data'),
        ),
      ],
    );
  }
}

