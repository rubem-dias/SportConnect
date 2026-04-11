import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _stepOneKey = GlobalKey<FormState>();
  final _stepTwoKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  Timer? _emailDebounce;
  Timer? _usernameDebounce;

  int _currentStep = 0;
  bool _isCheckingEmail = false;
  bool _isCheckingUsername = false;
  bool? _isEmailAvailable;
  bool? _isUsernameAvailable;

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    _usernameDebounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim();
    _emailDebounce?.cancel();

    if (!_emailRegex.hasMatch(email)) {
      if (_isEmailAvailable != null || _isCheckingEmail) {
        setState(() {
          _isCheckingEmail = false;
          _isEmailAvailable = null;
        });
      }
      return;
    }

    _emailDebounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isCheckingEmail = true;
        _isEmailAvailable = null;
      });

      final available = await _checkAvailability(
        endpoint: ApiEndpoints.usersCheckEmail,
        key: 'email',
        value: email,
      );

      if (!mounted) return;
      setState(() {
        _isCheckingEmail = false;
        _isEmailAvailable = available;
      });
    });
  }

  void _onUsernameChanged() {
    final username = _usernameController.text.trim();
    _usernameDebounce?.cancel();

    if (!_usernameRegex.hasMatch(username)) {
      if (_isUsernameAvailable != null || _isCheckingUsername) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = null;
        });
      }
      return;
    }

    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isCheckingUsername = true;
        _isUsernameAvailable = null;
      });

      final available = await _checkAvailability(
        endpoint: ApiEndpoints.usersCheckUsername,
        key: 'username',
        value: username,
      );

      if (!mounted) return;
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = available;
      });
    });
  }

  Future<bool?> _checkAvailability({
    required String endpoint,
    required String key,
    required String value,
  }) async {
    final client = ref.read(apiClientProvider).dio;

    bool? parseAvailability(Map<String, dynamic> json) {
      final available = json['available'];
      if (available is bool) return available;

      final isAvailable = json['isAvailable'];
      if (isAvailable is bool) return isAvailable;

      final exists = json['exists'];
      if (exists is bool) return !exists;

      return null;
    }

    try {
      final response = await client.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {key: value},
      );
      return parseAvailability(response.data ?? <String, dynamic>{});
    } on DioException catch (e) {
      if (e.response?.statusCode != 405) return null;
      try {
        final response = await client.post<Map<String, dynamic>>(
          endpoint,
          data: {key: value},
        );
        return parseAvailability(response.data ?? <String, dynamic>{});
      } on DioException {
        return null;
      }
    }
  }

  String? _passwordValidator(String? value) {
    final l10n = context.l10n;
    if (value == null || value.isEmpty) return l10n.loginPasswordHint;
    if (value.length < 8) return l10n.registerPasswordMin;
    if (!RegExp(r'[A-Z]').hasMatch(value)) return l10n.registerPasswordUppercase;
    if (!RegExp(r'[a-z]').hasMatch(value)) return l10n.registerPasswordLowercase;
    if (!RegExp(r'[0-9]').hasMatch(value)) return l10n.registerPasswordNumber;
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) return l10n.registerPasswordSpecial;
    return null;
  }

  Future<void> _goToStepTwo() async {
    if (!_stepOneKey.currentState!.validate()) return;

    if (_isCheckingEmail) {
      AppSnackbar.info(context, context.l10n.registerAwaitEmailValidation);
      return;
    }

    if (_isEmailAvailable == false) {
      AppSnackbar.error(context, context.l10n.registerEmailTaken);
      return;
    }

    setState(() => _currentStep = 1);
  }

  Future<void> _submit() async {
    if (!_stepTwoKey.currentState!.validate()) return;

    if (_isCheckingUsername) {
      AppSnackbar.info(context, context.l10n.registerAwaitUsernameValidation);
      return;
    }

    if (_isUsernameAvailable == false) {
      AppSnackbar.error(context, context.l10n.registerUsernameTaken);
      return;
    }

    await ref.read(authStateProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(authStateProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && (previous?.isLoading ?? false)) {
            context.go(AppRoutes.onboarding);
          }
        },
        error: (error, _) => AppSnackbar.error(context, error.toString()),
      );
    });

    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.registerStep(_currentStep + 1, 2)),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(value: (_currentStep + 1) / 2),
              const SizedBox(height: AppSpacing.xl),

              if (_currentStep == 0)
                Form(
                  key: _stepOneKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: l10n.registerNameLabel,
                        textCapitalization: TextCapitalization.words,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.registerNameHint;
                          }
                          if (v.trim().length < 2) return l10n.registerNameTooShort;
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _emailController,
                        label: l10n.registerEmailLabel,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        helperText: _isCheckingEmail
                            ? l10n.registerEmailChecking
                            : _isEmailAvailable == true
                                ? l10n.registerEmailAvailable
                                : null,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.registerEmailHint;
                          }
                          if (!_emailRegex.hasMatch(v.trim())) {
                            return l10n.registerEmailInvalid;
                          }
                          if (_isEmailAvailable == false) {
                            return l10n.registerEmailTaken;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _passwordController,
                        label: l10n.registerPasswordLabel,
                        isPassword: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        validator: _passwordValidator,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: l10n.registerConfirmPassword,
                        isPassword: true,
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.registerConfirmPasswordHint;
                          }
                          if (v != _passwordController.text) {
                            return l10n.registerPasswordMismatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: l10n.registerNext,
                        onPressed: isLoading ? null : _goToStepTwo,
                      ),
                    ],
                  ),
                )
              else
                Form(
                  key: _stepTwoKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 38,
                              child: Icon(Icons.person, size: 42),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: () {
                                AppSnackbar.info(
                                  context,
                                  'Upload de foto será habilitado na próxima task.',
                                );
                              },
                              child: Text(l10n.registerAddPhoto),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _usernameController,
                        label: l10n.registerUsernameLabel,
                        prefixIcon: const Icon(Icons.alternate_email),
                        helperText: _isCheckingUsername
                            ? l10n.registerUsernameChecking
                            : _isUsernameAvailable == true
                                ? l10n.registerUsernameAvailable
                                : l10n.registerUsernameHelper,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.registerUsernameHint;
                          }
                          if (!_usernameRegex.hasMatch(v.trim())) {
                            return l10n.registerUsernameInvalid;
                          }
                          if (_isUsernameAvailable == false) {
                            return l10n.registerUsernameTaken;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: l10n.registerBack,
                              variant: AppButtonVariant.secondary,
                              onPressed: isLoading
                                  ? null
                                  : () => setState(() => _currentStep = 0),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: l10n.registerSubmit,
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _submit,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.registerAlreadyHaveAccount),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(l10n.registerSignIn),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
