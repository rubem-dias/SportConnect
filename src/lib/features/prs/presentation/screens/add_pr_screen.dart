import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/pr_model.dart';
import '../../data/repositories/pr_repository_impl.dart';
import '../providers/prs_provider.dart';

class AddPrScreen extends ConsumerStatefulWidget {
  const AddPrScreen({super.key, this.editPR});

  final PRModel? editPR;

  @override
  ConsumerState<AddPrScreen> createState() => _AddPrScreenState();
}

class _AddPrScreenState extends ConsumerState<AddPrScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _confettiCtrl = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  ExerciseModel? _selectedExercise;
  DateTime _date = DateTime.now();
  bool _shareToFeed = false;
  bool _isLoading = false;

  PRModel? _previousBestPR;

  @override
  void initState() {
    super.initState();
    if (widget.editPR != null) {
      final pr = widget.editPR!;
      _valueCtrl.text = pr.value.toString();
      if (pr.reps != null) _repsCtrl.text = pr.reps.toString();
      _notesCtrl.text = pr.notes ?? '';
      _date = pr.date;
      _shareToFeed = pr.isShared;
    }
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    _repsCtrl.dispose();
    _notesCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPreviousBest() async {
    if (_selectedExercise == null) return;
    _previousBestPR = await ref
        .read(prRepositoryProvider)
        .fetchBestPR(_selectedExercise!.id);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercise == null) {
      AppSnackbar.error(context, context.l10n.addPrNoExercise);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final value = double.parse(_valueCtrl.text.replaceAll(',', '.'));
      final reps = _repsCtrl.text.isNotEmpty
          ? int.tryParse(_repsCtrl.text)
          : null;

      final pr = await ref.read(prsProvider.notifier).addPR(
            exerciseId: _selectedExercise!.id,
            exerciseName: _selectedExercise!.name,
            value: value,
            unit: _selectedExercise!.unit,
            date: _date,
            muscleGroup: _selectedExercise!.muscleGroup,
            reps: reps,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
            shareToFeed: _shareToFeed,
          );

      final isBetter = _previousBestPR == null || pr.value > _previousBestPR!.value;

      if (!mounted) return;

      if (isBetter) {
        _confettiCtrl.play();
        HapticFeedback.heavyImpact();
        await _showCelebrationDialog(pr);
      } else {
        AppSnackbar.success(context, context.l10n.addPrSuccess);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, context.l10n.addPrError);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showCelebrationDialog(PRModel pr) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CelebrationDialog(
        pr: pr,
        previousBest: _previousBestPR,
        confettiCtrl: _confettiCtrl,
        onContinue: () {
          Navigator.of(context).pop(); // dialog
          Navigator.of(context).pop(); // add pr screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              widget.editPR != null ? context.l10n.editPrTitle : context.l10n.addPrTitle,
            ),
            actions: [
              if (widget.editPR != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.error,
                  onPressed: _confirmDelete,
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Exercise picker
                _SectionLabel(context.l10n.addPrExerciseSection),
                _ExercisePicker(
                  selected: _selectedExercise,
                  onSelect: (e) async {
                    setState(() => _selectedExercise = e);
                    await _loadPreviousBest();
                    setState(() {});
                  },
                ),
                if (_previousBestPR != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PreviousBestBanner(pr: _previousBestPR!),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Value + unit
                _SectionLabel(context.l10n.addPrResultSection),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _valueCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: '0',
                          filled: true,
                          fillColor: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariantLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.l10n.addPrValueRequired;
                          final n =
                              double.tryParse(v.replaceAll(',', '.'));
                          if (n == null || n <= 0) return context.l10n.addPrValueInvalid;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          _selectedExercise?.unit ?? 'kg',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Reps (optional)
                _SectionLabel(context.l10n.addPrRepsSection),
                TextFormField(
                  controller: _repsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: context.l10n.addPrRepsHint,
                    filled: true,
                    fillColor: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (int.tryParse(v) == null) return context.l10n.addPrRepsInvalid;
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Date
                _SectionLabel(context.l10n.addPrDateSection),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Notes
                _SectionLabel(context.l10n.addPrNotesSection),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: context.l10n.addPrNotesHint,
                    filled: true,
                    fillColor: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Share to feed toggle
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: SwitchListTile(
                    value: _shareToFeed,
                    onChanged: (v) => setState(() => _shareToFeed = v),
                    title: Text(context.l10n.addPrShareToggle),
                    subtitle: Text(context.l10n.addPrShareSubtitle),
                    secondary: const Icon(Icons.share_outlined),
                    activeThumbColor: AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                AppButton(
                  label: widget.editPR != null ? context.l10n.editPrSubmit : context.l10n.addPrSubmit,
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),

        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiCtrl,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 40,
            gravity: 0.1,
            colors: const [
              AppColors.primary,
              AppColors.prGold,
              AppColors.prGreen,
              AppColors.secondary,
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deletePrTitle),
        content: Text(context.l10n.deletePrConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancelButton)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l10n.deletePrButton),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref
          .read(prsProvider.notifier)
          .deletePR(widget.editPR!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PreviousBestBanner extends StatelessWidget {
  const _PreviousBestBanner({required this.pr});
  final PRModel pr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.info),
          const SizedBox(width: AppSpacing.xs),
          Text(
            context.l10n.addPrPreviousBest(pr.displayValue),
            style: AppTypography.labelSmall.copyWith(color: AppColors.info),
          ),
        ],
      ),
    );
  }
}

// ---- Exercise Picker ----

class _ExercisePicker extends ConsumerStatefulWidget {
  const _ExercisePicker({required this.selected, required this.onSelect});

  final ExerciseModel? selected;
  final void Function(ExerciseModel) onSelect;

  @override
  ConsumerState<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends ConsumerState<_ExercisePicker> {
  void _open() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseSearchSheet(onSelect: (e) {
        Navigator.pop(context);
        widget.onSelect(e);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = widget.selected;

    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected != null
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              Text(_muscleEmoji(selected.muscleGroup),
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  selected.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                selected.unit,
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.primary),
              ),
            ] else ...[
              const Icon(Icons.fitness_center_rounded,
                  size: 20, color: AppColors.textDisabledLight),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.addPrSelectExercise,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  String _muscleEmoji(String group) => switch (group) {
        'peito' => 'ðŸ«',
        'costas' => 'ðŸ”™',
        'pernas' => 'ðŸ¦µ',
        'ombros' || 'bÃ­ceps' || 'trÃ­ceps' => 'ðŸ’ª',
        'core' => 'ðŸŽ¯',
        'cardio' => 'ðŸƒ',
        'olÃ­mpico' => 'ðŸ‹ï¸',
        _ => 'âš¡',
      };
}

class _ExerciseSearchSheet extends ConsumerStatefulWidget {
  const _ExerciseSearchSheet({required this.onSelect});
  final void Function(ExerciseModel) onSelect;

  @override
  ConsumerState<_ExerciseSearchSheet> createState() =>
      _ExerciseSearchSheetState();
}

class _ExerciseSearchSheetState extends ConsumerState<_ExerciseSearchSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exercisesAsync = ref.watch(exerciseSearchProvider(_query));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  Text(context.l10n.addPrSelectExercise,
                      style: AppTypography.titleMedium),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _createCustom,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(context.l10n.exerciseCreateNew),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.l10n.exerciseSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariantLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: exercisesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                    child: Text(context.l10n.prsErrorMessage)),
                data: (exercises) => ListView.builder(
                  controller: scrollCtrl,
                  itemCount: exercises.length,
                  itemBuilder: (_, i) {
                    final e = exercises[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(_muscleEmoji(e.muscleGroup)),
                      ),
                      title: Text(e.name),
                      subtitle: Text('${e.muscleGroup} Â· ${e.unit}'),
                      trailing: e.isCustom
                          ? const Icon(Icons.person_outline_rounded,
                              size: 14, color: AppColors.primary)
                          : null,
                      onTap: () => widget.onSelect(e),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _muscleEmoji(String group) => switch (group) {
        'peito' => 'ðŸ«',
        'costas' => 'ðŸ”™',
        'pernas' => 'ðŸ¦µ',
        'ombros' || 'bÃ­ceps' || 'trÃ­ceps' => 'ðŸ’ª',
        'core' => 'ðŸŽ¯',
        'cardio' => 'ðŸƒ',
        'olÃ­mpico' => 'ðŸ‹ï¸',
        _ => 'âš¡',
      };

  void _createCustom() {
    showDialog<void>(
      context: context,
      builder: (_) => _CreateExerciseDialog(
        onCreated: (e) {
          Navigator.pop(context); // dialog
          widget.onSelect(e);
        },
      ),
    );
  }
}

class _CreateExerciseDialog extends ConsumerStatefulWidget {
  const _CreateExerciseDialog({required this.onCreated});
  final void Function(ExerciseModel) onCreated;

  @override
  ConsumerState<_CreateExerciseDialog> createState() =>
      _CreateExerciseDialogState();
}

class _CreateExerciseDialogState
    extends ConsumerState<_CreateExerciseDialog> {
  final _nameCtrl = TextEditingController();
  String _muscleGroup = 'outros';
  String _unit = 'kg';

  static const _muscleGroups = [
    'peito', 'costas', 'pernas', 'ombros', 'bÃ­ceps', 'trÃ­ceps',
    'core', 'cardio', 'olÃ­mpico', 'outros',
  ];
  static const _units = ['kg', 'lb', 'km', 'm', 'min', 'reps'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.exerciseCreateTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: context.l10n.exerciseNameLabel,
              hintText: context.l10n.exerciseNameHint,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _muscleGroup,
            decoration: InputDecoration(labelText: context.l10n.exerciseMuscleLabel),
            items: _muscleGroups
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setState(() => _muscleGroup = v ?? _muscleGroup),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _unit,
            decoration: InputDecoration(labelText: context.l10n.exerciseUnitLabel),
            items: _units
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (v) => setState(() => _unit = v ?? _unit),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () async {
            if (_nameCtrl.text.trim().isEmpty) return;
            final exercise = await ref
                .read(prRepositoryProvider)
                .createCustomExercise(
                  name: _nameCtrl.text.trim(),
                  muscleGroup: _muscleGroup,
                  unit: _unit,
                );
            if (context.mounted) {
              Navigator.pop(context);
              widget.onCreated(exercise);
            }
          },
          child: Text(context.l10n.exerciseCreateButton),
        ),
      ],
    );
  }
}

// ---- Celebration Dialog ----

class _CelebrationDialog extends StatelessWidget {
  const _CelebrationDialog({
    required this.pr,
    required this.previousBest,
    required this.confettiCtrl,
    required this.onContinue,
  });

  final PRModel pr;
  final PRModel? previousBest;
  final ConfettiController confettiCtrl;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final improvement = previousBest != null
        ? pr.value - previousBest!.value
        : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.95),
              AppColors.primaryDark.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ðŸ†', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.addPrCelebrationTitle,
              style: AppTypography.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              pr.exerciseName,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(
                pr.displayValue,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.prGold,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
              ),
            ),
            if (improvement != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.addPrCelebrationImprovement(
                  improvement.toStringAsFixed(1),
                  pr.unit,
                ),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.successLight,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(context.l10n.addPrCelebrationButton,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

