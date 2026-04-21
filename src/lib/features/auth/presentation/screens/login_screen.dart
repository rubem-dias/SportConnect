import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  Future<void> _googleLogin() async {
    final l10n = context.l10n;
    try {
      final googleUser = await GoogleSignIn(scopes: const ['email']).signIn();
      if (!mounted) return;
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        AppSnackbar.error(context, l10n.loginGoogleError);
        return;
      }

      await ref
          .read(authStateProvider.notifier)
          .loginWithFirebaseUser(firebaseUser);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      next.whenOrNull(
        data: (user) {
          if (user == null) return;
          final hasOnboardingData =
              user.sports.isNotEmpty && user.level.isNotEmpty;
          context.go(
            hasOnboardingData ? AppRoutes.chat : AppRoutes.onboarding,
          );
        },
        error: (e, _) => AppSnackbar.error(context, e.toString()),
      );
    });

    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.sports,
                        color: Colors.white,
                        size: 52,
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
                      context.l10n.loginTitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Botão Google
              _GoogleButton(
                onPressed: isLoading ? null : _googleLogin,
                isLoading: isLoading,
              ),

              if (kDebugMode) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Entrar em modo teste',
                  variant: AppButtonVariant.secondary,
                  onPressed: isLoading
                      ? null
                      : () {
                          ref.read(devBypassAuthProvider.notifier).state = true;
                          context.go(AppRoutes.chat);
                        },
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, required this.isLoading});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.g_mobiledata, size: 26),
      label: Text(
        isLoading ? 'Entrando...' : 'Entrar com Google',
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
