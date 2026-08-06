import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:planner/core/models/filter.dart';
import 'package:planner/core/models/timetable.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FilterDialog extends StatefulWidget {
  final TimetableFilter? initialFilter;
  const FilterDialog({super.key, this.initialFilter});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final classController = TextEditingController();
  final lessonController = TextEditingController();
  final teacherController = TextEditingController();
  final subjectController = TextEditingController();
  final dayController = TextEditingController();

  late Set<String> classes;
  late Set<String> teachers;
  late Set<String> subjects;
  late Set<Weekday> days;

  @override
  void initState() {
    super.initState();

    classes = Set.from(widget.initialFilter?.classes ?? {});
    teachers = Set.from(widget.initialFilter?.teachers ?? {});
    subjects = Set.from(widget.initialFilter?.subjects ?? {});
    days = Set.from(widget.initialFilter?.days ?? {});
  }

  @override
  void dispose() {
    classController.dispose();
    lessonController.dispose();
    teacherController.dispose();
    subjectController.dispose();
    dayController.dispose();
    super.dispose();
  }

  void _addToSet(TextEditingController controller, Set<String> set) {
    if (controller.text.isNotEmpty) {
      setState(() {
        set.add(controller.text.trim());
        controller.clear();
      });
    }
  }

  void _removeFromSet(String value, Set<String> set) {
    setState(() {
      set.remove(value);
    });
  }

  Widget _buildChipSection(
    String label,
    Set<String> items,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addToSet(controller, items),
                  )
                : null,
          ),
          onSubmitted: (_) => _addToSet(controller, items),
          onChanged: (value) => setState(() {}),
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...items.map((item) {
                return Chip(
                  label: Text(item),
                  onDeleted: () => _removeFromSet(item, items),
                  deleteIcon: const Icon(Icons.close),
                );
              }),
            ],
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter hinzufügen"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChipSection("Klasse", classes, classController),
            _buildChipSection("Fach", subjects, subjectController),
            _buildChipSection("Lehrerkürzel", teachers, teacherController),
            // TextField for lesson (keeping as simple text for now)
            TextField(
              controller: lessonController,
              decoration: const InputDecoration(
                labelText: "Stunde",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Day selection as chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...Weekday.values.map((weekday) {
                  final isSelected = days.contains(weekday);
                  return FilterChip(
                    label: Text(weekday.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          days.add(weekday);
                        } else {
                          days.remove(weekday);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Abbrechen"),
        ),
        FilledButton(
          onPressed: () {
            final filter = TimetableFilter(
              classes: classes,
              subjects: subjects,
              teachers: teachers,
              days: days,
            );
            Navigator.pop(context, filter);
          },
          child: const Text("Hinzufügen"),
        ),
      ],
    );
  }
}

class HelpDialog extends StatefulWidget {
  const HelpDialog({super.key});

  @override
  State<HelpDialog> createState() => _HelpDialogState();
}

class _HelpDialogState extends State<HelpDialog> {
  final controller = PageController();
  int page = 0;

  final pages = const [
    Center(
      child: Text(
        "Die erweiterten Filter bieten die Möglichkeit, Einträge nach spezifischen Kriterien zu suchen.\n\nDies ist besonders nützlich, wenn man nur Einträge für spezifische Kurse sehen will.",
        textAlign: TextAlign.center,
      ),
    ),
    Center(
      child: Text(
        "Es ist möglich nach verschiedenen Feldern zu filtern. Falls man nicht die genaue Kursbezeichnung mit Nummer kennt, lässt sich zum Beispiel nach Lehrer, Stunde und Klasse filtern.\n\nKennt man die Genaue Kursbezeichnung (z.B. E2M_VLK01) kann man diese unter \"Fach\" eintragen.",
        textAlign: TextAlign.center,
      ),
    ),
    Center(
      child: Text(
        "Ist bereits ein Klassenfilter oben eingegeben werden alle Klassenfilter die hier angegeben ignoriert.",
        textAlign: TextAlign.center,
      ),
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 420,
          height: 320,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    Expanded(
                      child: PageView(
                        controller: controller,
                        onPageChanged: (i) => {setState(() => page = i)},
                        children: pages,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SmoothPageIndicator(
                      controller: controller,
                      count: pages.length,
                      effect: const WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 8,
                      ),
                      onDotClicked: (index) => {setState(() => page = index)},
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: "Schließen",
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
