import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

class ResourceImageScreen extends StatelessWidget {
  final String imageUrl;
  const ResourceImageScreen({super.key, required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            constrained: true,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) {
                  return const CircularProgressIndicator(color: Colors.white);
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
        ],
      ),
    );
  }
}
