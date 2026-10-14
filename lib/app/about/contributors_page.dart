import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class ContributorsPage extends StatefulWidget {
  const ContributorsPage({super.key});

  @override
  State<ContributorsPage> createState() => _ContributorsPageState();
}

class _ContributorsPageState extends State<ContributorsPage> {
  static const String owner = 'LordRoboter';
  static const String repo = 'DSBplus';

  late Future<List<dynamic>> contributors;

  @override
  void initState() {
    super.initState();
    contributors = fetchContributors();
  }

  Future<List<dynamic>> fetchContributors() async {
    final uri = Uri.https(
      'api.github.com',
      '/repos/$owner/$repo/contributors',
      {'per_page': '100'},
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/vnd.github+json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Could not load contributors (${response.statusCode})');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<void> openProfile(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open GitHub profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contributors')),
      body: FutureBuilder<List<dynamic>>(
        future: contributors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load contributors.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        contributors = fetchContributors();
                      });
                    },
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          final people = snapshot.data ?? [];

          if (people.isEmpty) {
            return const Center(child: Text('No contributors found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: people.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final person = people[index] as Map<String, dynamic>;
              final username = person['login'] ?? 'Unknown';
              final avatar = person['avatar_url'] as String?;
              final profile = person['html_url'] as String?;
              final count = person['contributions'] ?? 0;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: avatar != null
                        ? NetworkImage(avatar)
                        : null,
                    child: avatar == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(
                    username.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('$count contributions'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: profile == null ? null : () => openProfile(profile),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
