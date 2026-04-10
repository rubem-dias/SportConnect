import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

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

  static const _sports = <String>[
    'Musculacao',
    'Corrida',
    'Ciclismo',
    'Crossfit',
    'Natacao',
    'Futebol',
    'Yoga',
    'Calistenia',
  ];

  static const _levels = <String>[
    'Iniciante',
    'Intermediario',
    'Avancado',
  ];

  static const _objectives = <String>[
    'Hipertrofia',
    'Emagrecimento',
    'Performance',
    'Saude',
  ];

  final Set<String> _selectedSports = <String>{};

  int _currentStep = 0;
  String? _selectedLevel;
  String? _selectedObjective;
  bool _locationOptIn = false;
  bool _isSaving = false;

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
      'sports': _selectedSports.toList(),
      'level': _selectedLevel,
      'objective': _selectedObjective,
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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quais esportes te interessam?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Selecione quantos quiser para personalizar seu feed.',
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _sports.map((sport) {
                final selected = _selectedSports.contains(sport);
                return FilterChip(
                  label: Text(sport),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedSports.remove(sport);
                      } else {
                        _selectedSports.add(sport);
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
            const Text(
              'Qual seu nivel atual?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text('Isso ajuda a sugerir desafios no ritmo certo.'),
            const SizedBox(height: AppSpacing.lg),
            ..._levels.map(
              (level) => RadioListTile<String>(
                title: Text(level),
                value: level,
                groupValue: _selectedLevel,
                onChanged: (value) => setState(() => _selectedLevel = value),
              ),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Qual seu objetivo principal?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text('Seu objetivo define metas e recomendações iniciais.'),
            const SizedBox(height: AppSpacing.lg),
            ..._objectives.map(
              (objective) => RadioListTile<String>(
                title: Text(objective),
                value: objective,
                groupValue: _selectedObjective,
                onChanged: (value) =>
                    setState(() => _selectedObjective = value),
              ),
            ),
          ],
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ativar localizacao para o Nearby?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Com isso, voce encontra pessoas e locais de treino perto de voce. '
              'Essa permissao pode ser alterada depois nas configuracoes.',
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Quero usar o Nearby'),
              value: _locationOptIn,
              onChanged: (value) => setState(() => _locationOptIn = value),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Etapa ${_currentStep + 1} de 4'),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(value: (_currentStep + 1) / 4),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: _currentStep == 3 ? 'Finalizar depois' : 'Pular',
                      variant: AppButtonVariant.secondary,
                      onPressed: _isSaving ? null : _skipStep,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: _currentStep == 3 ? 'Concluir' : 'Continuar',
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
