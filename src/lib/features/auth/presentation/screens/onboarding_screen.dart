import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _storage = FlutterSecureStorage();
  static const _kOnboardingPreferencesKey = 'onboarding_preferences';
  static const _kOnboardingCompletedKey = 'onboarding_completed';

  static const _totalSteps = 5;

  // Step 0 — username
  final _usernameController = TextEditingController();
  String? _usernameError;
  _UsernameStatus _usernameStatus = _UsernameStatus.idle;

  // Internal keys — display labels são resolvidos via l10n em build()
  static const _sportKeys = <String>[
    'musculacao', 'corrida', 'ciclismo', 'crossfit',
    'natacao', 'futebol', 'yoga', 'calistenia',
  ];

  static const _levelKeys = <String>[
    'beginner', 'intermediate', 'advanced',
  ];

  static const _goalKeys = <String>[
    'hypertrophy', 'weightLoss', 'performance', 'health',
  ];

  final Set<String> _selectedSportKeys = <String>{};
  int _currentStep = 0;
  String? _selectedLevelKey;
  String? _selectedGoalKey;
  bool _locationOptIn = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // ─── Username validation ──────────────────────────────────────────────────

  static final _usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');

  void _onUsernameChanged(String value) {
    setState(() {
      _usernameError = null;
      _usernameStatus =
          value.isEmpty ? _UsernameStatus.idle : _UsernameStatus.checking;
    });

    if (value.isEmpty) return;

    // Simula verificação de disponibilidade com debounce
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (_usernameController.text != value) return;

      if (!_usernameRegex.hasMatch(value)) {
        setState(() {
          _usernameError = 'Use apenas letras minúsculas, números e _';
          _usernameStatus = _UsernameStatus.unavailable;
        });
        return;
      }

      // Mock: usernames reservados
      const reserved = {'admin', 'sport', 'sportconnect'};
      if (reserved.contains(value)) {
        setState(() {
          _usernameError = '@$value já está em uso';
          _usernameStatus = _UsernameStatus.unavailable;
        });
        return;
      }

      setState(() => _usernameStatus = _UsernameStatus.available);
    });
  }

  bool get _canProceedFromUsername =>
      _usernameStatus == _UsernameStatus.available &&
      _usernameController.text.isNotEmpty;

  // ─── l10n helpers ─────────────────────────────────────────────────────────

  String _sportLabel(String key, AppLocalizations l10n) => switch (key) {
        'musculacao' => l10n.sportMusculacao,
        'corrida'    => l10n.sportCorrida,
        'ciclismo'   => l10n.sportCiclismo,
        'crossfit'   => l10n.sportCrossfit,
        'natacao'    => l10n.sportNatacao,
        'futebol'    => l10n.sportFutebol,
        'yoga'       => l10n.sportYoga,
        'calistenia' => l10n.sportCalistenia,
        _            => key,
      };

  String _levelLabel(String key, AppLocalizations l10n) => switch (key) {
        'beginner'     => l10n.levelBeginner,
        'intermediate' => l10n.levelIntermediate,
        'advanced'     => l10n.levelAdvanced,
        _              => key,
      };

  String _goalLabel(String key, AppLocalizations l10n) => switch (key) {
        'hypertrophy' => l10n.goalHypertrophy,
        'weightLoss'  => l10n.goalWeightLoss,
        'performance' => l10n.goalPerformance,
        'health'      => l10n.goalHealth,
        _             => key,
      };

  // ─── Navigation ───────────────────────────────────────────────────────────

  Future<void> _nextStep() async {
    if (_currentStep == 0 && !_canProceedFromUsername) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      return;
    }
    await _finish();
  }

  Future<void> _skipStep() async {
    if (_currentStep == 0) return; // username é obrigatório
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    setState(() => _isSaving = true);
    final payload = <String, dynamic>{
      'username': _usernameController.text.trim(),
      'sports': _selectedSportKeys.toList(),
      'level': _selectedLevelKey,
      'objective': _selectedGoalKey,
      'locationOptIn': _locationOptIn,
      'savedAt': DateTime.now().toIso8601String(),
    };

    await Future.wait([
      _storage.write(
        key: _kOnboardingPreferencesKey,
        value: jsonEncode(payload),
      ),
      _storage.write(key: _kOnboardingCompletedKey, value: 'true'),
    ]);

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(AppRoutes.chat);
    });
  }

  // ─── Step content ─────────────────────────────────────────────────────────

  Widget _buildStepContent(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0:
        return _UsernameStep(
          controller: _usernameController,
          status: _usernameStatus,
          error: _usernameError,
          onChanged: _onUsernameChanged,
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.onboardingSportsTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.onboardingSportsSubtitle),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _sportKeys.map((key) {
                final selected = _selectedSportKeys.contains(key);
                return FilterChip(
                  label: Text(_sportLabel(key, l10n)),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedSportKeys.remove(key);
                      } else {
                        _selectedSportKeys.add(key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.onboardingLevelTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.onboardingLevelSubtitle),
            const SizedBox(height: AppSpacing.lg),
            ..._levelKeys.map(
              (key) => RadioListTile<String>(
                title: Text(_levelLabel(key, l10n)),
                value: key,
                // ignore: deprecated_member_use
                groupValue: _selectedLevelKey,
                // ignore: deprecated_member_use
                onChanged: (value) =>
                    setState(() => _selectedLevelKey = value),
              ),
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.onboardingGoalTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.onboardingGoalSubtitle),
            const SizedBox(height: AppSpacing.lg),
            ..._goalKeys.map(
              (key) => RadioListTile<String>(
                title: Text(_goalLabel(key, l10n)),
                value: key,
                // ignore: deprecated_member_use
                groupValue: _selectedGoalKey,
                // ignore: deprecated_member_use
                onChanged: (value) =>
                    setState(() => _selectedGoalKey = value),
              ),
            ),
          ],
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.onboardingLocationTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${l10n.onboardingLocationSubtitle} ${l10n.onboardingLocationNote}',
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.onboardingLocationEnable),
              value: _locationOptIn,
              onChanged: (value) => setState(() => _locationOptIn = value),
            ),
          ],
        );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLastStep = _currentStep == _totalSteps - 1;
    final isUsernameStep = _currentStep == 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.registerStep(_currentStep + 1, _totalSteps)),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(l10n),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (!isUsernameStep) ...[
                    Expanded(
                      child: AppButton(
                        label: isLastStep
                            ? l10n.onboardingFinishLater
                            : l10n.onboardingSkip,
                        variant: AppButtonVariant.secondary,
                        onPressed: _isSaving ? null : _skipStep,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: AppButton(
                      label: isLastStep
                          ? l10n.onboardingComplete
                          : l10n.onboardingContinue,
                      isLoading: _isSaving,
                      onPressed: _isSaving
                          ? null
                          : (isUsernameStep && !_canProceedFromUsername
                              ? null
                              : _nextStep),
                    ),
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

// ─── Username step ──────────────────────────────────────────────────────────

enum _UsernameStatus { idle, checking, available, unavailable }

class _UsernameStep extends StatelessWidget {
  const _UsernameStep({
    required this.controller,
    required this.status,
    required this.error,
    required this.onChanged,
  });

  final TextEditingController controller;
  final _UsernameStatus status;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha seu @username',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Seu username é como as pessoas te encontram no SportConnect. Você pode mudá-lo depois.',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: controller,
          onChanged: onChanged,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_]')),
            LengthLimitingTextInputFormatter(20),
          ],
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            prefixText: '@',
            prefixStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            hintText: 'seuusername',
            errorText: error,
            suffixIcon: _StatusIcon(status: status),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
        if (status == _UsernameStatus.available) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '@${controller.text} está disponível!',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          '• Entre 3 e 20 caracteres\n'
          '• Apenas letras minúsculas, números e _\n'
          '• Sem espaços ou caracteres especiais',
          style: TextStyle(
            fontSize: 13,
            height: 1.7,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final _UsernameStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      _UsernameStatus.checking => const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      _UsernameStatus.available => const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
        ),
      _UsernameStatus.unavailable => const Icon(
          Icons.cancel_rounded,
          color: AppColors.error,
        ),
      _UsernameStatus.idle => const SizedBox.shrink(),
    };
  }
}
