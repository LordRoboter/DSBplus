import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/features/dsb/resources/model/resource.dart';
import 'package:planner/features/dsb/resources/presentation/widgets/resource_image_screen.dart';
import 'package:planner/features/dsb/resources/provider/dsb_resources_provider.dart';
import 'package:planner/l10n/l10extension.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DsbResourcesScreen extends ConsumerWidget {
  const DsbResourcesScreen({super.key, this.showAppBar = false});
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(dsbResourcesProvider);

    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(context.l10n.resources)) : null,
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

class _ResourceBundleSection extends StatefulWidget {
  final ResourceBundle bundle;

  const _ResourceBundleSection({required this.bundle});

  @override
  State<_ResourceBundleSection> createState() => _ResourceBundleSectionState();
}

class _ResourceBundleSectionState extends State<_ResourceBundleSection> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resources = widget.bundle.resources;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.bundle.title != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                widget.bundle.title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

          SizedBox(
            height: 320,
            child: PageView.builder(
              controller: _pageController,
              itemCount: resources.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _ResourceCard(
                    resource: resources[index],
                    resources: resources,
                    index: index,
                  ),
                );
              },
            ),
          ),

          if (resources.length > 1) ...[
            const SizedBox(height: 12),
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: resources.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 7,
                  dotWidth: 7,
                  expansionFactor: 2.5,
                  spacing: 5,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final Resource resource;
  final List<Resource> resources;
  final int index;

  const _ResourceCard({
    required this.resource,
    required this.resources,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ResourceImageScreen(
                resources: resources,
                initialIndex: index,
              ),
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
