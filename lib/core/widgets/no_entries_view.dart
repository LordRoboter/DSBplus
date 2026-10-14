import 'package:material_ui/material_ui.dart';
import 'package:planner/l10n/l10extension.dart';

class NoEntriesView extends StatelessWidget {
  const NoEntriesView({
    super.key,
    this.title = 'No entries yet',
    this.message = 'Looks like there is nothing here right now.',
    this.onRetry,
    this.isLoading = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('(｡•́︿•̀｡)', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: isLoading ? null : onRetry,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  isLoading ? context.l10n.loading : context.l10n.tryAgain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
