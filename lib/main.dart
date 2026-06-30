import 'package:flutter/material.dart';
import 'dsb_api.dart';
import 'settings.dart';
import 'sorter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

/// Root of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vertretungsplan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

/// Home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<Map<String, dynamic>>> entries = {};
  Map<String, Map<String, List<Map<String, dynamic>>>> groupedEntries = {};
  bool loading = true;
  String? error;
  String? selectedDay;
  List<String> availableDays = [];
  bool ssimplify = true;
  bool ggroup = true;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    await loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final simplify = prefs.getBool("simplify") ?? true;
      final group = prefs.getBool("group") ?? true;
      final clean = prefs.getBool("clean") ?? true;

      final api = DSBApi(
        "REMOVED",
        "REMOVED",
        tableMapper: ['type', 'lesson', 'teacher', 'subject', 'room', 'text'],
      );

      var result = await api.fetchEntries();
      var dayResult = groupEntriesByDay(result);

      final days = result.map((e) => e["day"] as String).toSet().toList();
      final Map<String, Map<String, List<Map<String, dynamic>>>> groupedByDay =
          {};

      for (final entry in dayResult.entries) {
        var res = entry.value;

        if (clean) {
          res = cleanupEntries(res);
        }

        if (simplify) {
          res = simplifyEntries(res);
        }

        groupedByDay[entry.key] = groupEntries(res);
      }

      setState(() {
        entries = dayResult;
        groupedEntries = groupedByDay;
        availableDays = days;

        selectedDay ??= days.isNotEmpty ? days.first : null;

        ssimplify = simplify;
        ggroup = group;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );

    // Reload data when returning from settings
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final visibleGroups = groupedEntries[selectedDay] ?? {};
    final visibleEntries = entries[selectedDay] ?? <Map<String, dynamic>>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vertretungsplan"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: openSettings),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ggroup && groupedEntries.isNotEmpty
          ? Column(
              children: [
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: availableDays.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final day = availableDays[index];

                      return ChoiceChip(
                        label: Text(day),
                        selected: selectedDay == day,
                        onSelected: (_) {
                          setState(() {
                            selectedDay = day;
                          });
                        },
                      );
                    },
                  ),
                ),

                Expanded(
                  child: ListView(
                    children: visibleGroups.entries.map((group) {
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.key,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(),

                              ...group.value.asMap().entries.map((item) {
                                final entry = item.value;

                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${entry['lesson']} • ${entry['subject']}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(entry["teacher"] ?? ""),

                                              if ((entry["text"] ?? "")
                                                  .toString()
                                                  .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    entry["text"],
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Chip(
                                              label: Text(entry["type"] ?? ""),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            Text(entry["room"] ?? ""),
                                          ],
                                        ),
                                      ],
                                    ),

                                    if (item.key != group.value.length - 1)
                                      const Divider(height: 24),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: availableDays.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final day = availableDays[index];

                      return ChoiceChip(
                        label: Text(day),
                        selected: selectedDay == day,
                        onSelected: (_) {
                          setState(() {
                            selectedDay = day;
                          });
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: visibleEntries.length,
                    itemBuilder: (context, index) {
                      final entry = visibleEntries[index];

                      return ListTile(
                        title: Text("${entry['lesson']} - ${entry['subject']}"),
                        subtitle: Text("${entry['class']} • ${entry['room']}"),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_month),
            label: "Plan",
          ),
        ],
      ),
    );
  }
}
