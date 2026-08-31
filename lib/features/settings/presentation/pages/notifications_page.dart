import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';

class NotificationsSettingsPage extends ConsumerWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        final notifier = ref.read(settingsProvider.notifier);

        return SettingsPageScaffold(
          title: context.l10n.notifications,
          child: Column(
            children: [
              SettingsSwitchCard(
                title: context.l10n.notifications,
                value: settings.notifications,
                onChanged: notifier.setNotifications,
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(context.l10n.firebase),
                      subtitle: Text(context.l10n.firebaseDesc),
                      value: settings.firebase,
                      onChanged: notifier.setFirebase,
                    ),
                    SwitchListTile(
                      title: Text(context.l10n.workManager),
                      subtitle: Text(context.l10n.workManagerDesc),
                      value: settings.workManager,
                      onChanged: notifier.setWorkManager,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
