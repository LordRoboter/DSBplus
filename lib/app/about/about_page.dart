import 'package:crazy_kaomojis/crazy_kaomoji_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:planner/app/about/contributors_page.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static const appName = 'Planner';
  static const githubUrl = 'https://github.com/LordRoboter/DSBplus';

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not open $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int taps = 0;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.about)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),
          Align(
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/bg.png', fit: BoxFit.cover),
                    Image.asset('assets/fg.png', fit: BoxFit.contain),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AboutPage.appName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.projectDesc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              return Center(
                child: Chip(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  label: Text(
                    info == null
                        ? context.l10n.openSource
                        : '${context.l10n.version} ${info.version}'
                              ' (${info.buildNumber})',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: SvgPicture.asset(
                'assets/github.svg',
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onPrimaryContainer,
                  BlendMode.srcIn,
                ),
              ),
              title: Text(context.l10n.viewOnGitHub),
              subtitle: Text(context.l10n.gitHubDesc),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openLink(AboutPage.githubUrl),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(context.l10n.reportBug),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openLink('${AboutPage.githubUrl}/issues'),
                ),
                const Divider(height: 1),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: Text(context.l10n.featureRequest),
                    subtitle: Text(context.l10n.featureRequestDesc),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openLink('${AboutPage.githubUrl}/issues/new'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(context.l10n.contributors),
                  subtitle: Text(context.l10n.contributorsDesc),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContributorsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(context.l10n.license),
                  subtitle: Text(context.l10n.licenseName),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () =>
                      _openLink('${AboutPage.githubUrl}/blob/main/LICENSE'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            child: Text(
              context.l10n.madeWithFlutter,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            onTap: () async => {
              taps++,
              if (taps >= 3)
                {
                  taps = 0,
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(body: CrazyKaomojiPage()),
                    ),
                  ),
                },
            },
          ),
        ],
      ),
    );
  }
}
