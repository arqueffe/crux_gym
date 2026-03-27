import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/auth_html_input.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _usernameError;
  String? _passwordError;

  bool _validateFields(AppLocalizations l10n) {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _usernameError =
          username.isEmpty ? l10n.pleaseEnterUsernameOrEmail : null;
      _passwordError = password.isEmpty ? l10n.pleaseEnterPassword : null;
    });

    return _usernameError == null && _passwordError == null;
  }

  String _buildLoginErrorMessage(AppLocalizations l10n, String? rawError) {
    if (rawError == null || rawError.trim().isEmpty) {
      return l10n.loginFailed;
    }

    final normalized = rawError.toLowerCase();

    // Map common backend/network patterns to clearer client-side messages.
    if (normalized.contains('invalid') ||
        normalized.contains('incorrect') ||
        normalized.contains('wrong') ||
        normalized.contains('credential') ||
        normalized.contains('unauthorized') ||
        normalized.contains('401')) {
      return '${l10n.loginFailed}: ${l10n.usernameOrEmail} / ${l10n.password}';
    }

    if (normalized.contains('network') ||
        normalized.contains('timeout') ||
        normalized.contains('socket') ||
        normalized.contains('connection')) {
      return '${l10n.loginFailed}. ${l10n.retry}';
    }

    return '${l10n.loginFailed}: $rawError';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context);
    if (!_validateFields(l10n)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Inform the platform that authentication data can be saved.
        TextInput.finishAutofillContext(shouldSave: true);
        // Navigation will happen automatically via AuthWrapper
      } else {
        final l10n = AppLocalizations.of(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _buildLoginErrorMessage(l10n, authProvider.errorMessage),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language selector
                Align(
                  alignment: Alignment.topRight,
                  child: DropdownButton<Locale>(
                    value: localeProvider.locale,
                    underline: Container(),
                    icon: const Icon(Icons.language),
                    items: LocaleProvider.supportedLocales.map((locale) {
                      return DropdownMenuItem(
                        value: locale,
                        child: Text(
                          LocaleProvider.languageNames[locale.languageCode] ??
                              locale.languageCode,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (locale) {
                      if (locale != null) {
                        localeProvider.setLocale(locale);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Logo
                Image.asset(
                  'assets/logo/logo_black.png',
                  height: 120,
                ),
                const SizedBox(height: 48),

                // Title
                Text(
                  l10n.welcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signInToContinue,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Username field
                AuthHtmlInput(
                  controller: _usernameController,
                  labelText: l10n.usernameOrEmail,
                  hintText: l10n.usernameOrEmail,
                  prefixIcon: Icons.person,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocomplete: 'username',
                  fieldName: 'username',
                  errorText: _usernameError,
                  enabled: !_isLoading,
                  onChanged: (_) {
                    if (_usernameError != null) {
                      setState(() {
                        _usernameError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                AuthHtmlInput(
                  controller: _passwordController,
                  labelText: l10n.password,
                  hintText: l10n.password,
                  prefixIcon: Icons.lock,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  autocomplete: 'current-password',
                  fieldName: 'password',
                  errorText: _passwordError,
                  enabled: !_isLoading,
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() {
                        _passwordError = null;
                      });
                    }
                  },
                  onSubmitted: _handleLogin,
                ),
                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          l10n.loginButton,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                      child: Text(l10n.registerLink),
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
