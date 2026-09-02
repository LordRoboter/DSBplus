import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/settings/presentation/widgets/settings.dart';
import 'package:planner/features/settings/providers/settings_provider.dart';
import 'package:planner/l10n/l10extension.dart';

class AuthSettingsPage extends ConsumerStatefulWidget {
  const AuthSettingsPage({super.key});

  @override
  ConsumerState<AuthSettingsPage> createState() => _AuthSettingsPageState();
}

class _AuthSettingsPageState extends ConsumerState<AuthSettingsPage> {
  final usernameController = TextEditingController();
  final usernameFocusNode = FocusNode();

  final passwordController = TextEditingController();
  final passwordFocusNode = FocusNode();

  bool _loadingCredentials = true;
  bool _saving = false;

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final credentials = ref.read(authRepositoryProvider);

    final username = await credentials.getUsername();
    final password = await credentials.getPassword();

    if (!mounted) return;

    usernameController.text = username ?? '';
    passwordController.text = password ?? '';

    setState(() {
      _loadingCredentials = false;
    });
  }

  Future<void> _saveCredentials() async {
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.credentialsSaved)));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    usernameFocusNode.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCredentials) {
      return const Center(child: CircularProgressIndicator());
    }

    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (settings) {
        return SettingsPageScaffold(
          title: context.l10n.credentials,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: usernameController,
                      focusNode: usernameFocusNode,
                      decoration: InputDecoration(
                        labelText: context.l10n.username,
                        hintText: context.l10n.usernameHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        passwordFocusNode.requestFocus();
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: context.l10n.password,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
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
                          tooltip: _showPassword
                              ? context.l10n.hidePassword
                              : context.l10n.showPassword,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    FilledButton(
                      onPressed: _saving ? null : _saveCredentials,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.l10n.save),
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
