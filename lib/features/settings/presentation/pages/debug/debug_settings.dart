import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/background_tasks.dart';
import 'package:planner/core/database/database.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';
import 'package:planner/features/settings/providers/background_settings.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/features/timetables/data/timetable_repository.dart';
import 'package:planner/features/timetables/providers/timetable_provider.dart';
import 'package:restart_app/restart_app.dart';

class DebugSettingsPage extends ConsumerWidget {
  const DebugSettingsPage({super.key});

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider.notifier);

    return SettingsPageScaffold(
      title: 'Debug',
      child: SettingsSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.settings_backup_restore_rounded),
              title: const Text('Clear settings'),
              subtitle: const Text('Remove all stored application settings.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _confirm(
                context,
                title: 'Clear settings?',
                message:
                    'This will remove all stored settings from the device.',
                onConfirm: () async {
                  await settings.clear();
                  await Restart.restartApp();
                },
              ),
            ),

            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_sweep_rounded),
              title: const Text('Clear timetables'),
              subtitle: const Text('Remove all cached timetable data.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _confirm(
                context,
                title: 'Clear timetables?',
                message: 'This will remove all locally stored timetable data.',
                onConfirm: () async {
                  await ref.read(timetableRepositoryProvider).clear();

                  ref.invalidate(timetableProvider);
                },
              ),
            ),

            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.sync),
              title: const Text('Trigger background check'),
              subtitle: const Text('Check the background service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                runTimetableBackgroundCheck();
              },
            ),
          ],
        ),
      ),
    );
  }
}
