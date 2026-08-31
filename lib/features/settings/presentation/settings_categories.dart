import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/settings/presentation/pages/appearance_page.dart';
import 'package:planner/features/settings/presentation/pages/auth_page.dart';
import 'package:planner/features/settings/presentation/pages/cleanup_page.dart';
import 'package:planner/features/settings/presentation/pages/debug/debug_settings.dart';
import 'package:planner/features/settings/presentation/pages/filter_page.dart';
import 'package:planner/features/settings/presentation/pages/language_page.dart';
import 'package:planner/features/settings/presentation/pages/notifications_page.dart';
import 'package:planner/features/timetables/model/filter.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:planner/theme.dart';
import 'package:planner/features/settings/presentation/widgets/dialogues.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';

class SettingsCategoriesPage extends StatelessWidget {
  const SettingsCategoriesPage({super.key});

  Widget _stackedCategories(List<SettingsCategoryTile> tiles) {
    final children = <Widget>[];

    for (var index = 0; index < tiles.length; index++) {
      children.add(tiles[index]);

      if (index != tiles.length - 1) {
        children.add(const SizedBox(height: 1));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _stackedCategories([
            SettingsCategoryTile(
              title: context.l10n.credentials,
              subtitle: context.l10n.credentialsExp,
              icon: Icons.account_circle,
              position: SettingsCategoryTilePosition.single,
              onTap: () => _open(context, const AuthSettingsPage()),
            ),
          ]),
          const SizedBox(height: 16),
          _stackedCategories([
            SettingsCategoryTile(
              title: context.l10n.language,
              subtitle: context.l10n.languageExp,
              icon: Icons.language_outlined,
              position: SettingsCategoryTilePosition.top,
              onTap: () => _open(context, const LanguageSettingsPage()),
            ),
            SettingsCategoryTile(
              title: context.l10n.appearance,
              subtitle: context.l10n.darkTheme,
              icon: Icons.palette_outlined,
              position: SettingsCategoryTilePosition.middle,
              onTap: () => _open(context, const AppearanceSettingsPage()),
            ),
            SettingsCategoryTile(
              title: context.l10n.notifications,
              subtitle: context.l10n.notificationsExp,
              icon: Icons.notifications_outlined,
              position: SettingsCategoryTilePosition.bottom,
              onTap: () => _open(context, const NotificationsSettingsPage()),
            ),
          ]),
          const SizedBox(height: 16),
          _stackedCategories([
            SettingsCategoryTile(
              title: context.l10n.cleanup,
              subtitle: context.l10n.enhanceEntries,
              icon: Icons.cleaning_services_outlined,
              position: SettingsCategoryTilePosition.top,
              onTap: () => _open(context, const CleanupSettingsPage()),
            ),
            SettingsCategoryTile(
              title: context.l10n.filters,
              subtitle: context.l10n.filtersExp,
              icon: Icons.filter_alt_outlined,
              position: SettingsCategoryTilePosition.bottom,
              onTap: () => _open(context, const FiltersSettingsPage()),
            ),
          ]),
          if (kDebugMode) ...[
            const SizedBox(height: 16),
            _stackedCategories([
              SettingsCategoryTile(
                title: 'Debug',
                subtitle: 'Developer settings',
                icon: Icons.bug_report_outlined,
                position: SettingsCategoryTilePosition.single,
                onTap: () => _open(context, const DebugSettingsPage()),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
