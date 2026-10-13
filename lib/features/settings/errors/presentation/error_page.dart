import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/core/providers/http_overrides_provider.dart';
import 'package:planner/features/settings/errors/providers/error_provider.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';
import 'package:planner/l10n/l10extension.dart';

class ErrorSettingsPage extends ConsumerWidget {
  const ErrorSettingsPage({super.key});

  Future<void> _trustCertificate(
    BuildContext context,
    WidgetRef ref,
    String fingerprint,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.verified_user_outlined),
        title: Text(context.l10n.trustCertificateTitle),
        content: Text(context.l10n.trustCertificateWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.verified_user),
            label: Text(context.l10n.trust),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final errorNotifier = ref.read(errorProvider.notifier);
      final overrides = ref.read(httpOverridesProvider);

      await errorNotifier.trustFingerprint(fingerprint);
      overrides.updateTrustedFingerprint(fingerprint);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.certificateTrusted)));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.failedToTrustCertificate(error.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _setAutoTrust(WidgetRef ref, bool enabled) async {
    final errorNotifier = ref.read(errorProvider.notifier);
    final overrides = ref.read(httpOverridesProvider);

    await errorNotifier.setAutoTrustCertificates(enabled);
    overrides.autoTrustCertificates = enabled;
  }

  Future<void> _removeTrustedCertificate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final errorNotifier = ref.read(errorProvider.notifier);
      final overrides = ref.read(httpOverridesProvider);

      await errorNotifier.clearTrustedFingerprint();
      overrides.updateTrustedFingerprint(null);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.trustedCertificateRemoved)),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.failedToRemoveTrust(error.toString())),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final errorState = ref.watch(errorProvider);

    return errorState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.l10n.errorLoadingCertificateSettings(error.toString()),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (errors) {
        final failedFingerprint = errors.lastFailedFingerprint;
        final trustedFingerprint = errors.trustedFingerprint;
        final isTrusted = errors.lastFailedIsTrusted;

        return SettingsPageScaffold(
          title: context.l10n.certificateTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Security setting
              SettingsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security_outlined, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.l10n.certificateSecurityTitle,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.autoTrustCertificates),
                      subtitle: Text(
                        context.l10n.autoTrustCertificatesDescription,
                      ),
                      value: errors.autoTrustCertificates,
                      onChanged: (enabled) async {
                        try {
                          await _setAutoTrust(ref, enabled);
                        } catch (error) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.failedToUpdateAutoTrust(
                                  error.toString(),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Most recent certificate validation failure
              SettingsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.policy_outlined, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.l10n.lastFailedCertificate,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (!errors.hasFailedFingerprint)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: colors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(context.l10n.noFailedCertificate),
                          ),
                        ],
                      )
                    else ...[
                      Text(context.l10n.certificateFailedValidation),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: SelectableText(
                          failedFingerprint!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (isTrusted)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.verified, color: colors.primary),
                          title: Text(context.l10n.certificateIsTrusted),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _trustCertificate(
                              context,
                              ref,
                              failedFingerprint,
                            ),
                            icon: const Icon(Icons.verified_user),
                            label: Text(context.l10n.trustCertificate),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              // Previously trusted certificate
              if (errors.hasTrustedFingerprint) ...[
                const SizedBox(height: 16),
                SettingsSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.l10n.trustedCertificate,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SelectableText(
                          trustedFingerprint!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _removeTrustedCertificate(context, ref),
                          icon: const Icon(Icons.delete_outline),
                          label: Text(context.l10n.removeTrust),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Compatibility disclaimer at the bottom
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: colors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.androidCertificateCompatibilityTitle,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context
                                .l10n
                                .androidCertificateCompatibilityDisclaimer,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
