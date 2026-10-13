import 'package:material_ui/material_ui.dart';
import 'package:planner/l10n/l10extension.dart';

class NoEffect extends StatelessWidget {
  const NoEffect({super.key, required this.face, required this.onKaomojiTap});
  final String face;
  final VoidCallback onKaomojiTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onKaomojiTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(face, style: Theme.of(context).textTheme.headlineMedium),

            const SizedBox(height: 12),
            Text(
              context.l10n.noEntries,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
