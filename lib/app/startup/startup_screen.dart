import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/app/startup/page_overview.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/settings/presentation/pages/language_page.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';

enum LanguageOption { system, english, german }

class StartupPage extends ConsumerStatefulWidget {
  const StartupPage({super.key});

  @override
  ConsumerState<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends ConsumerState<StartupPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  bool _showPassword = false;
  bool _saving = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final credentials = ref.read(authRepositoryProvider);

      await credentials.saveCredentials(username: username, password: password);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StartupSetupPage(
            onComplete: () async {
              await ref
                  .read(settingsProvider.notifier)
                  .setStartupComplete(true);

              if (!mounted) return;

              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _loadCredentials() async {
    final repository = ref.read(authRepositoryProvider);

    final usernameFuture = repository.getUsername();
    final passwordFuture = repository.getPassword();

    final username = await usernameFuture;
    final password = await passwordFuture;

    if (!mounted) return;

    usernameController.text = username ?? '';
    passwordController.text = password ?? '';

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;

    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App icon
                      Align(
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                                color: Colors.black.withValues(alpha: 0.12),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset('assets/bg.png', fit: BoxFit.cover),
                                Image.asset(
                                  'assets/fg.png',
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        context.l10n.welcome,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        context.l10n.welcomeDesc,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 40),

                      TextField(
                        controller: usernameController,
                        focusNode: usernameFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.username],

                        decoration: InputDecoration(
                          labelText: context.l10n.username,
                          hintText: context.l10n.usernameHint,
                          prefixIcon: Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) {
                          passwordFocusNode.requestFocus();
                        },
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: passwordController,
                        focusNode: passwordFocusNode,
                        obscureText: !_showPassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: context.l10n.password,
                          hintText: context.l10n.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _showPassword
                                ? context.l10n.hidePassword
                                : context.l10n.showPassword,
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _continue(),
                      ),

                      const SizedBox(height: 24),

                      /*Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your credentials are stored securely on your device.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),*/
                      FilledButton(
                        onPressed: _saving ? null : _continue,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                context.l10n.getStarted,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),

                      PopupMenuButton<LanguageOption>(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        tooltip: context.l10n.language,
                        child: TextButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.language_rounded, size: 20),
                          label: Text(context.l10n.language),
                        ),
                        onSelected: (option) {
                          final locale = switch (option) {
                            LanguageOption.system => null,
                            LanguageOption.english => const Locale('en'),
                            LanguageOption.german => const Locale('de'),
                          };

                          ref.read(settingsProvider.notifier).setLocale(locale);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: LanguageOption.system,
                            child: Text(
                              "${context.l10n.systemDefault} (${nativeLanguageNames[systemLocale.languageCode] ?? 'English'})",
                            ),
                          ),
                          PopupMenuItem(
                            value: LanguageOption.english,
                            child: Text(
                              context.l10n.english == 'English'
                                  ? 'English'
                                  : '${context.l10n.english} (English)',
                            ),
                          ),
                          PopupMenuItem(
                            value: LanguageOption.german,
                            child: Text(
                              context.l10n.german == 'Deutsch'
                                  ? 'Deutsch'
                                  : '${context.l10n.german} (Deutsch)',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
