import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/settings/presentation/widgets/dialogues.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/features/timetables/model/filter.dart';
import 'package:planner/l10n/l10extension.dart';

class FiltersSettingsPage extends ConsumerStatefulWidget {
  const FiltersSettingsPage({super.key});

  @override
  ConsumerState<FiltersSettingsPage> createState() =>
      _FiltersSettingsPageState();
}

class _FiltersSettingsPageState extends ConsumerState<FiltersSettingsPage> {
  final classController = TextEditingController();
  final classFocusNode = FocusNode();

  @override
  void dispose() {
    classController.dispose();
    classFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addClass() async {
    final className = classController.text.trim();

    if (className.isEmpty) {
      return;
    }

    final settings = ref.read(settingsProvider).requireValue;
    final notifier = ref.read(settingsProvider.notifier);

    final updatedClasses = {...settings.classFilter.classes, className};

    await notifier.setClassFilter(
      settings.classFilter.copyWith(classes: updatedClasses),
    );

    classController.clear();
  }

  Future<void> _removeClass(String className) async {
    final settings = ref.read(settingsProvider).requireValue;
    final notifier = ref.read(settingsProvider.notifier);

    final updatedClasses = {...settings.classFilter.classes}..remove(className);

    await notifier.setClassFilter(
      settings.classFilter.copyWith(classes: updatedClasses),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        return SettingsPageScaffold(
          title: context.l10n.filter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: classController,
                      focusNode: classFocusNode,
                      decoration: InputDecoration(
                        labelText: context.l10n.classFilter,
                        hintText: context.l10n.classFilterHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.class_),
                        suffixIcon: classController.text.trim().isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addClass,
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _addClass(),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    if (settings.classFilter.classes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: settings.classFilter.classes.map((className) {
                          return Chip(
                            label: Text(className),
                            onDeleted: () => _removeClass(className),
                            deleteIcon: const Icon(Icons.close),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SettingsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SettingsSectionHeader(
                        title: context.l10n.advancedFilters,
                        action: TextButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const HelpDialog(),
                          ),
                          icon: const Icon(Icons.help_outline),
                          label: Text(context.l10n.help),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...settings.filters.map(
                      (filter) => SettingsFilterTile(
                        filter: filter,
                        onEdit: () async {
                          final updatedFilter =
                              await showDialog<TimetableFilter>(
                                context: context,
                                builder: (_) =>
                                    FilterDialog(initialFilter: filter),
                              );

                          if (updatedFilter != null) {
                            await ref
                                .read(settingsProvider.notifier)
                                .updateFilter(filter, updatedFilter);
                          }
                        },
                        onDelete: () => ref
                            .read(settingsProvider.notifier)
                            .removeFilter(filter),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final filter = await showDialog<TimetableFilter>(
                          context: context,
                          builder: (_) => const FilterDialog(),
                        );

                        if (filter != null) {
                          await ref
                              .read(settingsProvider.notifier)
                              .addFilter(filter);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.addFilter),
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
