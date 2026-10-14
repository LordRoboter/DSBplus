import 'package:material_ui/material_ui.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_rounded,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.onSecondaryAction,
    this.secondaryLabel,
    this.footer,
    this.compact = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryLabel;
  final Widget? footer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: compact ? 88 : 120,
                        height: compact ? 88 : 120,
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: compact ? 42 : 56,
                          color: colors.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      if (onRetry != null) ...[
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(retryLabel),
                          ),
                        ),
                      ],
                      if (onSecondaryAction != null &&
                          secondaryLabel != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: onSecondaryAction,
                            child: Text(secondaryLabel!),
                          ),
                        ),
                      ],
                      if (footer != null) ...[
                        const SizedBox(height: 32),
                        footer!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
