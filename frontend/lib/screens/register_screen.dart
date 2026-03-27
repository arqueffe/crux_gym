import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_semantic_colors.dart';
import '../widgets/auth_html_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _validateFields(AppLocalizations l10n) {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      if (email.isEmpty) {
        _emailError = l10n.pleaseEnterEmail;
      } else if (!email.contains('@') || !email.contains('.')) {
        _emailError = l10n.emailInvalid;
      } else {
        _emailError = null;
      }

      if (username.isEmpty) {
        _usernameError = l10n.pleaseEnterUsername;
      } else if (username.length < 3) {
        _usernameError = l10n.usernameMinLength;
      } else {
        _usernameError = null;
      }

      if (password.isEmpty) {
        _passwordError = l10n.pleaseEnterPassword;
      } else if (password.length < 6) {
        _passwordError = l10n.passwordMinLength;
      } else {
        _passwordError = null;
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError = l10n.pleaseConfirmPassword;
      } else if (confirmPassword != password) {
        _confirmPasswordError = l10n.passwordsDoNotMatch;
      } else {
        _confirmPasswordError = null;
      }
    });

    return _emailError == null &&
        _usernameError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context);
    if (!_validateFields(l10n)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Show success message and go back to login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).registrationSuccessful,
                style:
                    TextStyle(color: context.semanticColors.onSuccessContainer),
              ),
              backgroundColor: context.semanticColors.successContainer,
            ),
          );
        }
        // Navigation will happen automatically via AuthWrapper
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).registrationFailed,
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
      appBar: AppBar(
        title: Text(l10n.registerTitle),
        actions: [
          // Language selector
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
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
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Image.asset(
                  'assets/logo/logo_black.png',
                  height: 100,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.joinCruxClimbingGym,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.createAccountToGetStarted,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Email field
                AuthHtmlInput(
                  controller: _emailController,
                  labelText: l10n.email,
                  hintText: l10n.email,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocomplete: 'email',
                  fieldName: 'email',
                  errorText: _emailError,
                  enabled: !_isLoading,
                  onChanged: (_) {
                    if (_emailError != null) {
                      setState(() {
                        _emailError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Username field
                AuthHtmlInput(
                  controller: _usernameController,
                  labelText: l10n.username,
                  hintText: l10n.username,
                  prefixIcon: Icons.person,
                  textInputAction: TextInputAction.next,
                  helperText: l10n.atLeastThreeCharacters,
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
                  textInputAction: TextInputAction.next,
                  helperText: l10n.atLeastSixCharacters,
                  autocomplete: 'new-password',
                  fieldName: 'new-password',
                  errorText: _passwordError,
                  enabled: !_isLoading,
                  onChanged: (_) {
                    if (_passwordError != null ||
                        _confirmPasswordError != null) {
                      setState(() {
                        _passwordError = null;
                        _confirmPasswordError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password field
                AuthHtmlInput(
                  controller: _confirmPasswordController,
                  labelText: l10n.confirmPassword,
                  hintText: l10n.confirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  autocomplete: 'new-password',
                  fieldName: 'confirm-password',
                  errorText: _confirmPasswordError,
                  enabled: !_isLoading,
                  onChanged: (_) {
                    if (_confirmPasswordError != null) {
                      setState(() {
                        _confirmPasswordError = null;
                      });
                    }
                  },
                  onSubmitted: _handleRegister,
                ),
                const SizedBox(height: 24),

                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                          l10n.createAccountButton,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // Back to login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: Text(l10n.loginLink),
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
