import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/features/dsb/resources/model/resource.dart';
import 'package:planner/features/dsb/resources/presentation/widgets/resource_image_screen.dart';
import 'package:planner/features/dsb/resources/provider/dsb_resources_provider.dart';
import 'package:planner/l10n/l10extension.dart';

class DsbResourcesScreen extends ConsumerWidget {
  const DsbResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(dsbResourcesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.resources)),
      body: resources.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _ErrorView(onRetry: () => ref.invalidate(dsbResourcesProvider)),
        data: (bundles) {
          if (bundles.isEmpty) {
            return Center(child: Text(context.l10n.noResourcesAvailable));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(dsbResourcesProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bundles.length,
              itemBuilder: (context, index) {
                return _ResourceBundleSection(bundle: bundles[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ResourceBundleSection extends StatelessWidget {
  final ResourceBundle bundle;

  const _ResourceBundleSection({required this.bundle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bundle.title != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                bundle.title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ...bundle.resources.map(
            (resource) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ResourceCard(resource: resource),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final Resource resource;

  const _ResourceCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ResourceImageScreen(imageUrl: resource.url),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resource.previewUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: resource.previewUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorWidget: (context, url, error) {
                    return const Center(
                      child: Icon(Icons.broken_image_outlined),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (resource.title != null)
                    Text(
                      resource.title!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                  if (resource.date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(resource.date!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              context.l10n.couldNotLoadResources,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
