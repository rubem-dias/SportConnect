import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_empty_state.dart';
import '../../../../../shared/widgets/app_loading_skeleton.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../data/models/goal_model.dart';
import '../providers/goals_provider.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _onGoalCompleted() {
    _confettiCtrl.play();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalsAsync = ref.watch(goalsProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: goalsAsync.when(
            loading: () => const _GoalsSkeleton(),
            error: (_, __) => Center(
              child: TextButton.icon(
                onPressed: () => ref.read(goalsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ),
            data: (state) => _GoalsContent(
              state: state,
              tabCtrl: _tabCtrl,
              isDark: isDark,
              onGoalCompleted: _onGoalCompleted,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateGoalSheet(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_rounded),
          ),
        ),

        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiCtrl,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 50,
            gravity: 0.12,
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

  void _showCreateGoalSheet(BuildContext context) {
    AppBottomSheet.show<void>(
      context: context,
      child: _CreateGoalSheet(
        onCreated: (goal) {
          AppSnackbar.success(context, 'Meta criada!');
          ref.read(goalsProvider.notifier).refresh();
        },
      ),
    );
  }
}

// ---- Content ----

class _GoalsContent extends StatelessWidget {
  const _GoalsContent({
    required this.state,
    required this.tabCtrl,
    required this.isDark,
    required this.onGoalCompleted,
  });

  final GoalsState state;
  final TabController tabCtrl;
  final bool isDark;
  final VoidCallback onGoalCompleted;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (_, __) => [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text('Metas', style: AppTypography.titleLarge),
          bottom: TabBar(
            controller: tabCtrl,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                text: 'Em andamento${state.active.isNotEmpty ? ' (${state.active.length})' : ''}',
              ),
              Tab(
                text: 'Concluídas${state.completed.isNotEmpty ? ' (${state.completed.length})' : ''}',
              ),
              Tab(
                text: 'Expiradas${state.expired.isNotEmpty ? ' (${state.expired.length})' : ''}',
              ),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: tabCtrl,
        children: [
          _GoalsList(
            goals: state.active,
            emptyMessage: 'Nenhuma meta ativa.\nCrie uma meta para começar!',
            isDark: isDark,
            onGoalCompleted: onGoalCompleted,
          ),
          _GoalsList(
            goals: state.completed,
            emptyMessage: 'Nenhuma meta concluída ainda.',
            isDark: isDark,
          ),
          _GoalsList(
            goals: state.expired,
            emptyMessage: 'Nenhuma meta expirada.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ---- Goals list ----

class _GoalsList extends ConsumerWidget {
  const _GoalsList({
    required this.goals,
    required this.emptyMessage,
    required this.isDark,
    this.onGoalCompleted,
  });

  final List<GoalModel> goals;
  final String emptyMessage;
  final bool isDark;
  final VoidCallback? onGoalCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (goals.isEmpty) {
      return AppEmptyState(
        icon: Icons.flag_outlined,
        title: emptyMessage,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(goalsProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        itemCount: goals.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) => _GoalCard(
          goal: goals[i],
          isDark: isDark,
          onCompleted: onGoalCompleted,
        ),
      ),
    );
  }
}

// ---- Goal card ----

class _GoalCard extends ConsumerWidget {
  const _GoalCard({
    required this.goal,
    required this.isDark,
    this.onCompleted,
  });

  final GoalModel goal;
  final bool isDark;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = goal.status == GoalStatus.active;
    final isCompleted = goal.status == GoalStatus.completed;

    return Dismissible(
      key: ValueKey(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.archive_outlined, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        await ref.read(goalsProvider.notifier).archiveGoal(goal.id);
        return false; // handled by notifier
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isCompleted
                ? AppColors.prGold.withOpacity(0.4)
                : isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(_goalEmoji(goal.type), style: const TextStyle(fontSize: 22)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: AppTypography.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (goal.linkedExerciseName != null)
                        Text(
                          goal.linkedExerciseName!,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Text('🏆', style: TextStyle(fontSize: 20)),
                if (isActive && goal.daysRemaining <= 3)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      goal.daysRemaining == 0
                          ? 'Hoje!'
                          : '${goal.daysRemaining}d',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Progress bar
            _AnimatedProgressBar(
              fraction: goal.progressFraction,
              color: isCompleted
                  ? AppColors.prGold
                  : isActive
                      ? AppColors.primary
                      : AppColors.textDisabledLight,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Bottom row
            Row(
              children: [
                Text(
                  '${goal.current.toStringAsFixed(goal.current.truncateToDouble() == goal.current ? 0 : 1)} / ${goal.target.toStringAsFixed(goal.target.truncateToDouble() == goal.target ? 0 : 1)} ${goal.unit}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                Text(
                  '${goal.progressPercent}%',
                  style: AppTypography.labelMedium.copyWith(
                    color: isCompleted ? AppColors.prGold : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            if (isActive) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                goal.daysRemaining > 0
                    ? '${goal.daysRemaining} dias restantes'
                    : 'Prazo expirado hoje',
                style: AppTypography.labelSmall.copyWith(
                  color: goal.daysRemaining <= 3
                      ? AppColors.error
                      : isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _goalEmoji(GoalType type) => switch (type) {
        GoalType.bodyWeight => '⚖️',
        GoalType.specificPR => '🏋️',
        GoalType.weeklyFrequency => '📅',
        GoalType.monthlyDistance => '🏃',
      };
}

// ---- Animated progress bar ----

class _AnimatedProgressBar extends StatefulWidget {
  const _AnimatedProgressBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween<double>(begin: 0, end: widget.fraction)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: LinearProgressIndicator(
          value: _anim.value,
          minHeight: 8,
          backgroundColor: widget.color.withOpacity(0.12),
          valueColor: AlwaysStoppedAnimation(widget.color),
        ),
      ),
    );
  }
}

// ---- Skeleton ----

class _GoalsSkeleton extends StatelessWidget {
  const _GoalsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => const AppLoadingSkeleton(
        width: double.infinity,
        height: 120,
      ),
    );
  }
}

// ---- Create Goal Sheet (multi-step) ----

enum _CreateStep { type, details, deadline }

class _CreateGoalSheet extends ConsumerStatefulWidget {
  const _CreateGoalSheet({required this.onCreated});

  final void Function(GoalModel) onCreated;

  @override
  ConsumerState<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<_CreateGoalSheet> {
  _CreateStep _step = _CreateStep.type;
  GoalType _type = GoalType.specificPR;

  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  String _unit = 'kg';
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isPublic = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: switch (_step) {
          _CreateStep.type => _TypeStep(
              key: const ValueKey('type'),
              selected: _type,
              onSelect: (t) => setState(() {
                _type = t;
                _unit = _defaultUnit(t);
                _step = _CreateStep.details;
              }),
            ),
          _CreateStep.details => _ValuesStep(
              key: const ValueKey('values'),
              type: _type,
              titleCtrl: _titleCtrl,
              targetCtrl: _targetCtrl,
              unit: _unit,
              onUnitChanged: (u) => setState(() => _unit = u),
              isPublic: _isPublic,
              onPublicChanged: (v) => setState(() => _isPublic = v),
              onBack: () => setState(() => _step = _CreateStep.type),
              onNext: () => setState(() => _step = _CreateStep.deadline),
            ),
          _CreateStep.deadline => _DeadlineStep(
              key: const ValueKey('deadline'),
              endDate: _endDate,
              isLoading: _isLoading,
              onDateChanged: (d) => setState(() => _endDate = d),
              onBack: () => setState(() => _step = _CreateStep.details),
              onSubmit: _submit,
            ),
        },
      ),
    );
  }

  String _defaultUnit(GoalType t) => switch (t) {
        GoalType.bodyWeight => 'kg',
        GoalType.specificPR => 'kg',
        GoalType.weeklyFrequency => 'treinos/semana',
        GoalType.monthlyDistance => 'km',
      };

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final target = double.tryParse(_targetCtrl.text.replaceAll(',', '.'));
    if (title.isEmpty || target == null || target <= 0) return;

    setState(() => _isLoading = true);
    try {
      final goal = await ref.read(goalsProvider.notifier).createGoal(
            type: _type,
            title: title,
            target: target,
            unit: _unit,
            endDate: _endDate,
            isPublic: _isPublic,
          );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onCreated(goal);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// Step 1 — type

class _TypeStep extends StatelessWidget {
  const _TypeStep({required this.selected, required this.onSelect, super.key});

  final GoalType selected;
  final void Function(GoalType) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo de meta', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          ...GoalType.values.map((t) => _TypeTile(
                type: t,
                isSelected: t == selected,
                onTap: () => onSelect(t),
              )),
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final GoalType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(_emoji(type), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_label(type), style: AppTypography.bodyMedium),
                  Text(
                    _description(type),
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  String _emoji(GoalType t) => switch (t) {
        GoalType.bodyWeight => '⚖️',
        GoalType.specificPR => '🏋️',
        GoalType.weeklyFrequency => '📅',
        GoalType.monthlyDistance => '🏃',
      };

  String _label(GoalType t) => switch (t) {
        GoalType.bodyWeight => 'Peso corporal',
        GoalType.specificPR => 'PR específico',
        GoalType.weeklyFrequency => 'Frequência semanal',
        GoalType.monthlyDistance => 'Distância mensal',
      };

  String _description(GoalType t) => switch (t) {
        GoalType.bodyWeight => 'Atingir um peso alvo',
        GoalType.specificPR => 'Bater um personal record',
        GoalType.weeklyFrequency => 'Número de treinos por semana',
        GoalType.monthlyDistance => 'Distância a percorrer no mês',
      };
}

// Step 2 — values

class _ValuesStep extends StatelessWidget {
  const _ValuesStep({
    required this.type,
    required this.titleCtrl,
    required this.targetCtrl,
    required this.unit,
    required this.onUnitChanged,
    required this.isPublic,
    required this.onPublicChanged,
    required this.onBack,
    required this.onNext,
    super.key,
  });

  final GoalType type;
  final TextEditingController titleCtrl;
  final TextEditingController targetCtrl;
  final String unit;
  final void Function(String) onUnitChanged;
  final bool isPublic;
  final void Function(bool) onPublicChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  static const _units = ['kg', 'lb', 'km', 'm', 'min', 'reps', 'treinos/semana'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalhes da meta', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: titleCtrl,
            label: 'Título',
            hint: 'Ex: Supino 100kg',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  controller: targetCtrl,
                  label: 'Meta',
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: unit,
                  decoration: const InputDecoration(labelText: 'Unidade'),
                  items: _units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onUnitChanged(v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            value: isPublic,
            onChanged: onPublicChanged,
            title: const Text('Meta pública'),
            subtitle: const Text('Seus seguidores podem ver esta meta'),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Voltar',
                  onPressed: onBack,
                  variant: AppButtonVariant.ghost,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Continuar',
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Step 3 — deadline

class _DeadlineStep extends StatelessWidget {
  const _DeadlineStep({
    required this.endDate,
    required this.isLoading,
    required this.onDateChanged,
    required this.onBack,
    required this.onSubmit,
    super.key,
  });

  final DateTime endDate;
  final bool isLoading;
  final void Function(DateTime) onDateChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prazo', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: endDate,
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) onDateChanged(picked);
            },
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data limite',
                            style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary)),
                        Text(
                          '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${endDate.difference(DateTime.now()).inDays} dias',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Voltar',
                  onPressed: onBack,
                  variant: AppButtonVariant.ghost,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Criar meta',
                  onPressed: isLoading ? null : onSubmit,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
