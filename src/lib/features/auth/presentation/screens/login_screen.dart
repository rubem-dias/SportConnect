import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSocialFlow = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _isSocialFlow = false;

    await ref.read(authStateProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    authState.whenOrNull(
      error: (e, _) => AppSnackbar.error(context, e.toString()),
    );
  }

  Future<void> _googleLogin() async {
    try {
      _isSocialFlow = true;
      final account = await GoogleSignIn(scopes: const ['email']).signIn();
      if (!mounted) return;
      if (account == null) return;

      final auth = await account.authentication;
      if (!mounted) return;
      final token = auth.idToken ?? auth.accessToken;
      if (token == null || token.isEmpty) {
        AppSnackbar.error(context, context.l10n.loginGoogleError);
        return;
      }

      await ref
          .read(authStateProvider.notifier)
          .socialLogin(provider: 'google', token: token);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.toString());
    }
  }

  Future<void> _appleLogin() async {
    final isAvailable = await SignInWithApple.isAvailable();
    if (!mounted) return;
    if (!isAvailable) {
      AppSnackbar.info(context, context.l10n.loginAppleUnavailable);
      return;
    }

    try {
      _isSocialFlow = true;
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (!mounted) return;

      final token = credential.identityToken;
      if (token == null || token.isEmpty) {
        AppSnackbar.error(context, context.l10n.loginAppleError);
        return;
      }

      await ref
          .read(authStateProvider.notifier)
          .socialLogin(provider: 'apple', token: token);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(authStateProvider, (_, next) {
      next.whenOrNull(
        data: (user) {
          if (user == null) return;

          if (_isSocialFlow) {
            final hasOnboardingData =
                user.sports.isNotEmpty && user.level.isNotEmpty;
            context.go(hasOnboardingData ? AppRoutes.feed : AppRoutes.onboarding);
            _isSocialFlow = false;
            return;
          }

          context.go(AppRoutes.feed);
        },
      );
    });

    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),

                // Logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.sports,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'SportConnect',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.loginTitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Email
                AppTextField(
                  controller: _emailController,
                  label: l10n.loginEmailLabel,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.loginEmailHint;
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return l10n.loginEmailInvalid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Senha
                AppTextField(
                  controller: _passwordController,
                  label: l10n.loginPasswordLabel,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.loginPasswordHint;
                    if (v.length < 6) return l10n.loginPasswordMin;
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.sm),

                // Esqueci senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(l10n.loginForgotPassword),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Botão entrar
                AppButton(
                  label: l10n.loginButton,
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                ),

                const SizedBox(height: AppSpacing.sm),

                AppButton(
                  label: 'Entrar em modo teste',
                  variant: AppButtonVariant.secondary,
                  onPressed: isLoading
                      ? null
                      : () {
                          ref.read(devBypassAuthProvider.notifier).state = true;
                          context.go(AppRoutes.feed);
                        },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Divisor
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        l10n.loginOr,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Social login buttons
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        label: 'Google',
                        icon: Icons.g_mobiledata,
                        onPressed: isLoading ? null : _googleLogin,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _SocialButton(
                        label: 'Apple',
                        icon: Icons.apple,
                        onPressed: isLoading ? null : _appleLogin,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Criar conta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.loginNoAccount,
                      style: AppTypography.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: Text(l10n.loginCreateAccount),
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
      ),
    );
  }
}
