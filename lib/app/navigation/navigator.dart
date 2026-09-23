import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/app/navigation/model/navigation_item.dart';
import 'package:planner/features/dsb/resources/presentation/dsb_resources_screen.dart';
import 'package:planner/features/dsb/timetables/model/timetable.dart';
import 'package:planner/features/dsb/timetables/presentation/home_screen.dart';
import 'package:planner/features/dsb/timetables/presentation/plan_screen.dart';
import 'package:planner/features/dsb/timetables/providers/timetable_provider.dart';
import 'package:planner/features/settings/presentation/settings_screen.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';

class NavigatorScreen extends ConsumerStatefulWidget {
  const NavigatorScreen({super.key});

  @override
  ConsumerState<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends ConsumerState<NavigatorScreen> {
  NavigationItem _currentItem = NavigationItem.home;

  late final PageController _pageController;
  List<NavigationItem> _previousItems = [];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    ref.listenManual<AsyncValue<List<Timetable>>>(timetableProvider, (
      previous,
      next,
    ) {
      final oldTimetables = previous?.value;
      final newTimetables = next.value;

      if (oldTimetables == null || newTimetables == null) {
        return;
      }

      const equality = DeepCollectionEquality();

      final oldJson = oldTimetables
          .map((timetable) => timetable.toComparableJson())
          .toList();

      final newJson = newTimetables
          .map((timetable) => timetable.toComparableJson())
          .toList();

      if (equality.equals(oldJson, newJson)) {
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.l10n.newEntries),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    });
  }

  Future<void> openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _navigateToPage(int index) {
    if (!_pageController.hasClients) {
      return;
    }

    final currentPage = _pageController.page?.round();

    if (currentPage == index) {
      return;
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _openFromDrawer(NavigationItem item) {
    final settings = ref.read(settingsProvider).value;
    if (settings == null) {
      return;
    }
    final bottomItems = settings.bottomNavigationItems
        .where((entry) => entry.visible)
        .toList();
    final bottomIndex = bottomItems.indexWhere((entry) => entry.item == item);
    if (bottomIndex != -1) {
      setState(() {
        _currentItem = item;
      });
      _navigateToPage(bottomIndex);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Material(child: _pageFor(item, standalone: true)),
      ),
    );
  }

  Widget _pageFor(NavigationItem item, {bool standalone = false}) {
    return switch (item) {
      NavigationItem.home => HomeScreen(showAppBar: standalone),
      NavigationItem.plan => PlanScreen(showAppBar: standalone),
      NavigationItem.resources => DsbResourcesScreen(showAppBar: standalone),
    };
  }

  IconData _iconFor(NavigationItem item) {
    return switch (item) {
      NavigationItem.home => Icons.home_outlined,
      NavigationItem.plan => Icons.calendar_month_outlined,
      NavigationItem.resources => Icons.article_outlined,
    };
  }

  IconData _selectedIconFor(NavigationItem item) {
    return switch (item) {
      NavigationItem.home => Icons.home,
      NavigationItem.plan => Icons.calendar_month,
      NavigationItem.resources => Icons.article,
    };
  }

  String _labelFor(BuildContext context, NavigationItem item) {
    return switch (item) {
      NavigationItem.home => context.l10n.home,
      NavigationItem.plan => context.l10n.plan,
      NavigationItem.resources => context.l10n.resources,
    };
  }

  void _syncPageController(List<NavigationItem> items) {
    if (items.length < 2) {
      return;
    }

    final targetIndex = items.indexOf(_currentItem);

    if (targetIndex == -1 || !_pageController.hasClients) {
      return;
    }

    final currentIndex = _pageController.page?.round();

    if (currentIndex == targetIndex) {
      return;
    }

    _pageController.jumpToPage(targetIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (settings) {
        final bottomItems = settings.bottomNavigationItems
            .where((item) => item.visible)
            .toList();

        if (bottomItems.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No navigation items enabled')),
          );
        }

        final currentItems = bottomItems.map((item) => item.item).toList();

        final itemsChanged = !const ListEquality<NavigationItem>().equals(
          _previousItems,
          currentItems,
        );

        if (itemsChanged) {
          _previousItems = List<NavigationItem>.from(currentItems);

          // The selected item may have moved to another index.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }

            _syncPageController(currentItems);
          });
        }

        // If the currently selected item is no longer visible,
        // fall back to the first available item.
        final currentIndex = bottomItems.indexWhere(
          (item) => item.item == _currentItem,
        );

        final selectedIndex = currentIndex >= 0 ? currentIndex : 0;

        if (currentIndex == -1) {
          _currentItem = bottomItems.first.item;
        }

        final pages = [
          for (final item in bottomItems)
            KeyedSubtree(key: ValueKey(item.item), child: _pageFor(item.item)),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.plan),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: openSettings,
              ),
            ],
          ),
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  DrawerHeader(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Planner',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: Text(context.l10n.home),
                    selected: _currentItem == NavigationItem.home,
                    onTap: () {
                      Navigator.of(context).pop();
                      _openFromDrawer(NavigationItem.home);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(context.l10n.plan),
                    selected: _currentItem == NavigationItem.plan,
                    onTap: () {
                      Navigator.of(context).pop();
                      _openFromDrawer(NavigationItem.plan);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article),
                    title: Text(context.l10n.resources),
                    selected: _currentItem == NavigationItem.resources,
                    onTap: () {
                      Navigator.of(context).pop();
                      _openFromDrawer(NavigationItem.resources);
                    },
                  ),
                  const Spacer(),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text(context.l10n.settings),
                    onTap: () {
                      Navigator.of(context).pop();
                      openSettings();
                    },
                  ),
                ],
              ),
            ),
          ),
          body: bottomItems.length >= 2
              ? PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (index >= bottomItems.length) {
                      return;
                    }

                    setState(() {
                      _currentItem = bottomItems[index].item;
                    });
                  },
                  children: pages,
                )
              : pages.first,
          bottomNavigationBar: bottomItems.length >= 2
              ? NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    if (index < 0 || index >= bottomItems.length) {
                      return;
                    }

                    setState(() {
                      _currentItem = bottomItems[index].item;
                    });

                    _navigateToPage(index);
                  },
                  destinations: [
                    for (final item in bottomItems)
                      NavigationDestination(
                        icon: Icon(_iconFor(item.item)),
                        selectedIcon: Icon(_selectedIconFor(item.item)),
                        label: _labelFor(context, item.item),
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
