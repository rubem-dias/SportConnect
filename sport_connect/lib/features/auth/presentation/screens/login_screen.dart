import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) context.go(AppRoutes.feed);
        },
      );
    });

    final isLoading =
        ref.watch(authStateProvider).isLoading;

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
                        'Conecte-se com sua comunidade esportiva',
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
                  label: 'E-mail',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o e-mail';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Senha
                AppTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.sm),

                // Esqueci senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Esqueci minha senha'),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Botão entrar
                AppButton(
                  label: 'Entrar',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
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
                        'ou continue com',
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
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _SocialButton(
                        label: 'Apple',
                        icon: Icons.apple,
                        onPressed: () {},
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
                      'Não tem conta? ',
                      style: AppTypography.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: const Text('Criar conta'),
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
  final VoidCallback onPressed;

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
