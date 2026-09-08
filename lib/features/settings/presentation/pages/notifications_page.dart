import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/core/model/weekday.dart';
import 'package:planner/core/util/translations.dart';
import 'package:planner/features/notifications/model/interval.dart';
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

              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: settings.workManager ? 1 : 0.5,
                child: IgnorePointer(
                  ignoring: !settings.workManager,
                  child: _BackgroundScheduleCard(
                    schedule: settings.backgroundSchedule,
                    onChanged: notifier.setBackgroundSchedule,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackgroundScheduleCard extends StatelessWidget {
  const _BackgroundScheduleCard({
    required this.schedule,
    required this.onChanged,
  });

  final BackgroundCheckSchedule schedule;
  final ValueChanged<BackgroundCheckSchedule> onChanged;

  void _update({
    Set<Weekday>? days,
    int? startTime,
    int? endTime,
    Duration? interval,
  }) {
    onChanged(
      BackgroundCheckSchedule(
        days: days ?? schedule.days,
        startTime: startTime ?? schedule.startTime,
        endTime: endTime ?? schedule.endTime,
        interval: interval ?? schedule.interval,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.backgroundCheckSchedule,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 20),

            _WeekdaySelector(
              value: schedule.days,
              onChanged: (days) => _update(days: days),
            ),

            const SizedBox(height: 24),

            _ScheduleTimeRange(
              startTime: schedule.startTime,
              endTime: schedule.endTime,
              onChanged: (start, end) {
                onChanged(
                  BackgroundCheckSchedule(
                    days: schedule.days,
                    startTime: start,
                    endTime: end,
                    interval: schedule.interval,
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            _IntervalSelector(
              value: schedule.interval,
              onChanged: (interval) => _update(interval: interval),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({required this.value, required this.onChanged});

  final Set<Weekday> value;
  final ValueChanged<Set<Weekday>> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.days, style: theme.textTheme.titleSmall),

        const SizedBox(height: 10),

        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: Weekday.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final day = Weekday.values[index];
              final selected = value.contains(day);

              return _DayButton(
                label: _weekdayLabel(context, day),
                selected: selected,
                onTap: () {
                  final days = {...value};

                  if (selected) {
                    days.remove(day);
                  } else {
                    days.add(day);
                  }

                  onChanged(days);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _weekdayLabel(BuildContext context, Weekday day) {
    return switch (day) {
      Weekday.monday => context.l10n.monday,
      Weekday.tuesday => context.l10n.tuesday,
      Weekday.wednesday => context.l10n.wednesday,
      Weekday.thursday => context.l10n.thursday,
      Weekday.friday => context.l10n.friday,
      Weekday.saturday => context.l10n.saturday,
      Weekday.sunday => context.l10n.sunday,
    };
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              label.substring(0, 2),
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleTimeRange extends StatelessWidget {
  const _ScheduleTimeRange({
    required this.startTime,
    required this.endTime,
    required this.onChanged,
  });

  final int startTime;
  final int endTime;
  final void Function(int start, int end) onChanged;

  static const int minMinutes = 0;
  static const int maxMinutes = 1440;
  static const int stepMinutes = 15;

  String _formatTime(BuildContext context, int minutes) {
    if (minutes == 1440) {
      return '24:00';
    }

    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

    return time.format(context);
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: startTime ~/ 60, minute: startTime % 60),
    );

    if (result != null) {
      final minutes = result.hour * 60 + result.minute;

      if (minutes < endTime) {
        onChanged(minutes, endTime);
      }
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: endTime ~/ 60, minute: endTime % 60),
    );

    if (result != null) {
      final minutes = result.hour * 60 + result.minute;

      if (minutes > startTime) {
        onChanged(startTime, minutes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.startTime, style: theme.textTheme.titleSmall),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TimePill(
              time: _formatTime(context, startTime),
              onTap: () => _pickStartTime(context),
            ),
            Icon(
              Icons.arrow_forward,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            _TimePill(
              time: _formatTime(context, endTime),
              onTap: () => _pickEndTime(context),
            ),
          ],
        ),

        const SizedBox(height: 8),

        RangeSlider(
          min: minMinutes.toDouble(),
          max: maxMinutes.toDouble(),
          divisions: maxMinutes ~/ stepMinutes,
          values: RangeValues(startTime.toDouble(), endTime.toDouble()),
          labels: RangeLabels(
            _formatTime(context, startTime),
            _formatTime(context, endTime),
          ),
          onChanged: (values) {
            onChanged(values.start.round(), values.end.round());
          },
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00'),
              Text('06:00'),
              Text('12:00'),
              Text('18:00'),
              Text('24:00'),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.time, required this.onTap});

  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: 18,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 7),
              Text(
                time,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntervalSelector extends StatelessWidget {
  const _IntervalSelector({required this.value, required this.onChanged});

  final Duration value;
  final ValueChanged<Duration> onChanged;

  static const intervals = [
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(minutes: 60),
    Duration(minutes: 120),
    Duration(minutes: 360),
    Duration(minutes: 720),
    Duration(minutes: 1440),
  ];

  int _indexFor(Duration duration) {
    final index = intervals.indexOf(duration);

    if (index >= 0) {
      return index;
    }

    var closestIndex = 0;
    var closestDistance = (duration - intervals.first).abs().inMinutes;

    for (var i = 1; i < intervals.length; i++) {
      final distance = (duration - intervals[i]).abs().inMinutes;

      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _indexFor(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.interval, style: theme.textTheme.titleSmall),
            Text(
              _formatDuration(context, intervals[selectedIndex]),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            min: 0,
            max: (intervals.length - 1).toDouble(),
            divisions: intervals.length - 1,
            value: selectedIndex.toDouble(),
            label: _formatDuration(context, intervals[selectedIndex]),
            onChanged: (index) {
              onChanged(intervals[index.round()]);
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: intervals.map((duration) {
              return Text(
                _formatShortDuration(duration),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _formatShortDuration(Duration duration) {
    if (duration.inHours >= 1) {
      return '${duration.inHours}h';
    }

    return '${duration.inMinutes}m';
  }

  String _formatDuration(BuildContext context, Duration duration) {
    if (duration.inHours >= 1) {
      final hours = duration.inHours;

      return localizedHours(context, hours);
    }

    final minutes = duration.inMinutes;

    return localizedMinutes(context, minutes);
  }
}
