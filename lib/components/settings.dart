import 'package:flutter/material.dart';

enum SettingsCategoryTilePosition { single, top, middle, bottom }

class SettingsSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SettingsSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }
}

class SettingsCategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final SettingsCategoryTilePosition position;

  const SettingsCategoryTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.position = SettingsCategoryTilePosition.single,
  });

  @override
  Widget build(BuildContext context) {
    final shape = switch (position) {
      SettingsCategoryTilePosition.single => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      SettingsCategoryTilePosition.top => const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      SettingsCategoryTilePosition.middle => const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      SettingsCategoryTilePosition.bottom => const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
    };

    return Card(
      margin: EdgeInsets.zero,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class SettingsPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsPageScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(padding: const EdgeInsets.all(16), children: [child]),
      ),
    );
  }
}

class SettingsSwitchCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsSwitchCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(title),
            subtitle: subtitle == null ? null : Text(subtitle!),
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const SettingsSectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class SettingsLabeledRow extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsLabeledRow({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        child,
      ],
    );
  }
}

class SettingsFilterTile extends StatelessWidget {
  final Map<String, String> filter;
  final Map<String, String> labels;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SettingsFilterTile({
    super.key,
    required this.filter,
    required this.labels,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          filter.entries
              .map((e) => "${labels[e.key] ?? e.key}: ${e.value}")
              .join(" • "),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: IconButton(
                icon: const Icon(Icons.edit),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEdit,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 20,
              height: 20,
              child: IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
