import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/app/navigator.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/app/startup/startup_screen.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, stackTrace) {
        return Center(child: Text('Error: $error'));
      },

      data: (settingsState) {
        if (!settingsState.startupComplete) {
          return const StartupPage();
        }

        return const NavigatorScreen();
      },
    );
  }
}
