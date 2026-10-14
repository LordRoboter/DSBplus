import 'package:material_ui/material_ui.dart';

class NoRelevantEntriesView extends StatelessWidget {
  final String title;
  final String message;
  const NoRelevantEntriesView({
    super.key,
    this.title = "You're all caught up!",
    this.message =
        "Nothing relevant for you right now. — Come back later to see new entries.",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: colors.secondaryContainer.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              child: Text(
                '( ˶ᵔ ᵕ ᵔ˶ )',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
