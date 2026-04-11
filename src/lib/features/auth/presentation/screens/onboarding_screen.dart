import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/app_routes.dart';
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

  // Resolve chave interna → label traduzido
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

  Future<void> _nextStep() async {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }
    await _finish();
  }

  Future<void> _skipStep() async {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    setState(() => _isSaving = true);
    final payload = <String, dynamic>{
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
    context.go(AppRoutes.feed);
  }

  Widget _buildStepContent(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0:
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

      case 1:
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
                groupValue: _selectedLevelKey,
                onChanged: (value) => setState(() => _selectedLevelKey = value),
              ),
            ),
          ],
        );

      case 2:
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
                groupValue: _selectedGoalKey,
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
            Text('${l10n.onboardingLocationSubtitle} ${l10n.onboardingLocationNote}'),
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.registerStep(_currentStep + 1, 4)),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(value: (_currentStep + 1) / 4),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(l10n),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: _currentStep == 3
                          ? l10n.onboardingFinishLater
                          : l10n.onboardingSkip,
                      variant: AppButtonVariant.secondary,
                      onPressed: _isSaving ? null : _skipStep,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: _currentStep == 3
                          ? l10n.onboardingComplete
                          : l10n.onboardingContinue,
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _nextStep,
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
