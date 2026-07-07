import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FilterDialog extends StatefulWidget {
  final Map<String, String>? initialFilter;
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

  @override
  void initState() {
    super.initState();

    classController.text = widget.initialFilter?["class"] ?? "";
    lessonController.text = widget.initialFilter?["lesson"] ?? "";
    teacherController.text = widget.initialFilter?["teacher"] ?? "";
    subjectController.text = widget.initialFilter?["subject"] ?? "";
    dayController.text = widget.initialFilter?["day"] ?? "";
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter hinzufügen"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: classController,
              decoration: const InputDecoration(labelText: "Klasse"),
            ),
            TextField(
              controller: lessonController,
              decoration: const InputDecoration(labelText: "Stunde"),
            ),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: "Fach"),
            ),
            TextField(
              controller: teacherController,
              decoration: const InputDecoration(labelText: "Lehrerkürzel"),
            ),
            TextField(
              controller: dayController,
              decoration: const InputDecoration(labelText: "Tag"),
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
            final filter = <String, String>{};

            void add(String key, TextEditingController controller) {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                filter[key] = text;
              }
            }

            add("class", classController);
            add("lesson", lessonController);
            add("subject", subjectController);
            add("teacher", teacherController);
            add("day", dayController);

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
