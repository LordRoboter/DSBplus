import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/features/dsb/resources/model/resource.dart';

class ResourceImageScreen extends StatefulWidget {
  final List<Resource> resources;
  final int initialIndex;

  const ResourceImageScreen({
    super.key,
    required this.resources,
    required this.initialIndex,
  });

  @override
  State<ResourceImageScreen> createState() => _ResourceImageScreenState();
}

class _ResourceImageScreenState extends State<ResourceImageScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.resources.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final resource = widget.resources[index];

              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                constrained: true,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: resource.url,
                    fit: BoxFit.contain,
                    placeholder: (context, url) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    },
                    errorWidget: (context, url, error) {
                      return const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 48,
                      );
                    },
                  ),
                ),
              );
            },
          ),

          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              color: Colors.white,
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),

          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            right: 16,
            child: Text(
              '${_currentIndex + 1} / ${widget.resources.length}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
