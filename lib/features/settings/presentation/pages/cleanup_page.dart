import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';

class CleanupSettingsPage extends ConsumerWidget {
  const CleanupSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        final notifier = ref.read(settingsProvider.notifier);

        return SettingsPageScaffold(
          title: context.l10n.cleanup,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSwitchCard(
                title: context.l10n.simplifyEntries,
                subtitle: context.l10n.simplifyEntriesSub,
                value: settings.simplify,
                onChanged: notifier.setSimplify,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(context.l10n.cleanupEntries),
                      subtitle: Text(context.l10n.cleanupEntriesSub),
                      value: settings.clean,
                      onChanged: notifier.setClean,
                    ),
                    const Divider(height: 1),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: settings.clean ? 1 : 0.5,
                      child: IgnorePointer(
                        ignoring: !settings.clean,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(context.l10n.cleanupOptions),
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.simplifyClassNames),
                              value: settings.cleanClassNames,
                              onChanged: settings.clean
                                  ? notifier.setCleanClassNames
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.collapseClassNames),
                              value: settings.collapse,
                              onChanged: settings.clean
                                  ? notifier.setCollapse
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.simplifyLessonStatus),
                              value: settings.remapTypes,
                              onChanged: settings.clean
                                  ? notifier.setRemapTypes
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.simplifyCourses),
                              value: settings.cleanupCourses,
                              onChanged: settings.clean
                                  ? notifier.setCleanupCourses
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.mergeTutorCourses),
                              value: settings.disposeTut,
                              onChanged: settings.clean
                                  ? notifier.setDisposeTut
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.renameSubjects),
                              value: settings.mapCourses,
                              onChanged:
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'de' &&
                                      settings.clean
                                  ? notifier.setMapCourses
                                  : null,
                            ),
                            SwitchListTile(
                              title: Text(context.l10n.removeCourseNumbers),
                              value: settings.disposeCourseNumbers,
                              onChanged: settings.clean
                                  ? notifier.setDisposeCourseNumbers
                                  : null,
                            ),
                          ],
                        ),
                      ),
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
