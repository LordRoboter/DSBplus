import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:planner/core/util/date.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';
import 'package:planner/core/util/translations.dart';
import 'package:planner/l10n/l10extension.dart';

class PlanDetailsSheet extends StatelessWidget {
  final Timetable timetable;

  const PlanDetailsSheet({super.key, required this.timetable});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.planDetails,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 16),

                _MetadataRow(
                  icon: Icons.calendar_today,
                  label: context.l10n.dateP,
                  value: timetable.date != null
                      ? DateFormat.yMd(locale).format(timetable.date!)
                      : context.l10n.unknown,
                ),

                _MetadataRow(
                  icon: Icons.event,
                  label: context.l10n.day,
                  value: timetable.day != null
                      ? localizedWeekday(context.l10n, timetable.day)
                      : context.l10n.unknown,
                ),

                _MetadataRow(
                  icon: Icons.update,
                  label: context.l10n.updatedP,
                  value: timetable.updated != null
                      ? getRelativeDayString(
                          timetable.updated!,
                          context,
                          timePattern: "Hm",
                        )
                      : context.l10n.unknown,
                ),

                _MetadataRow(
                  icon: Icons.download,
                  label: context.l10n.fetchedAt,
                  value: timetable.firstFetched != null
                      ? getRelativeDayString(
                          timetable.firstFetched!,
                          context,
                          timePattern: "Hms",
                        )
                      : context.l10n.unknown,
                ),

                _MetadataRow(
                  icon: Icons.sync,
                  label: context.l10n.lastFetchedAt,
                  value: timetable.lastFetched != null
                      ? getRelativeDayString(
                          timetable.lastFetched!,
                          context,
                          timePattern: "Hms",
                        )
                      : context.l10n.unknown,
                ),

                // Extra information
                if (timetable.extraInfos?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 12),

                  Text(
                    context.l10n.additionalInformation,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  ...timetable.extraInfos!.entries.map(
                    (entry) => _MetadataRow(
                      icon: Icons.info_outline,
                      label: entry.key,
                      value: entry.value,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value),
    );
  }
}
