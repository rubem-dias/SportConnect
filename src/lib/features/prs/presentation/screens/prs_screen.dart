import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_empty_state.dart';
import '../../../../../shared/widgets/app_loading_skeleton.dart';
import '../../data/models/pr_model.dart';
import '../providers/prs_provider.dart';

class PrsScreen extends ConsumerStatefulWidget {
  const PrsScreen({super.key});

  @override
  ConsumerState<PrsScreen> createState() => _PrsScreenState();
}

class _PrsScreenState extends ConsumerState<PrsScreen> {
  final _searchController = TextEditingController();

  static const _muscleGroups = [
    'peito',
    'costas',
    'pernas',
    'ombros',
    'bíceps',
    'tríceps',
    'core',
    'cardio',
    'olímpico',
    'outros',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: state.when(
        loading: () => const _PRsSkeleton(),
        error: (e, _) => _PRsError(
          onRetry: () => ref.read(prsProvider.notifier).refresh(),
        ),
        data: (data) => _PRsContent(
          data: data,
          isDark: isDark,
          searchController: _searchController,
          muscleGroups: _muscleGroups,
          onSearch: (q) => ref.read(prsProvider.notifier).setSearch(q),
          onFilterGroup: (g) =>
              ref.read(prsProvider.notifier).setMuscleGroupFilter(g),
          onRefresh: () => ref.read(prsProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addPr),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _PRsContent extends StatelessWidget {
  const _PRsContent({
    required this.data,
    required this.isDark,
    required this.searchController,
    required this.muscleGroups,
    required this.onSearch,
    required this.onFilterGroup,
    required this.onRefresh,
  });

  final PRsState data;
  final bool isDark;
  final TextEditingController searchController;
  final List<String> muscleGroups;
  final void Function(String) onSearch;
  final void Function(String?) onFilterGroup;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final filtered = data.filtered;
    final top3 = data.top3;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor:
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Personal Records',
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(112),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearch,
                      decoration: InputDecoration(
                        hintText: 'Buscar exercício...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  searchController.clear();
                                  onSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                  // Muscle group filter chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      children: [
                        _FilterChip(
                          label: 'Todos',
                          isSelected: data.selectedMuscleGroup == null,
                          onTap: () => onFilterGroup(null),
                        ),
                        ...muscleGroups.map(
                          (g) => _FilterChip(
                            label: _capitalize(g),
                            isSelected: data.selectedMuscleGroup == g,
                            onTap: () => onFilterGroup(
                                data.selectedMuscleGroup == g ? null : g),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),

          // Top 3 Destaques
          if (top3.isNotEmpty && data.searchQuery.isEmpty && data.selectedMuscleGroup == null)
            SliverToBoxAdapter(
              child: _HighlightsSection(top3: top3, isDark: isDark),
            ),

          // List header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  Text(
                    'Todos os exercícios',
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filtered.length} ${filtered.length == 1 ? 'exercício' : 'exercícios'}',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Empty state
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: AppEmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'Nenhum PR encontrado',
                subtitle: data.summaries.isEmpty
                    ? 'Registre seu primeiro Personal Record!'
                    : 'Tente outros filtros ou termos de busca.',
                actionLabel: data.summaries.isEmpty ? 'Adicionar PR' : null,
                onAction: data.summaries.isEmpty ? () {} : null,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final summary = filtered[index];
                  return _ExercisePRCard(
                    summary: summary,
                    isDark: isDark,
                  );
                },
                childCount: filtered.length,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl + 64),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection({required this.top3, required this.isDark});

  final List<ExercisePRSummary> top3;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Meus Destaques',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.prGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: top3.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? AppSpacing.sm : 0),
                  child: _HighlightCard(summary: s, rank: i + 1),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.summary, required this.rank});

  final ExercisePRSummary summary;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final emoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.prGold.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.prGold.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            summary.exerciseName,
            style: AppTypography.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            summary.bestPR.displayValue,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderLight.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ExercisePRCard extends StatelessWidget {
  const _ExercisePRCard({required this.summary, required this.isDark});

  final ExercisePRSummary summary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: () => context.push(AppRoutes.prDetailPath(summary.exerciseId)),
      child: Container(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Muscle group icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: Text(
                _muscleEmoji(summary.muscleGroup),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Name + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.exerciseName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(summary.bestPR.date),
                    style: AppTypography.labelSmall.copyWith(
                        color: textSecondary),
                  ),
                ],
              ),
            ),

            // Best mark + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  summary.bestPR.displayValue,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (summary.isRecentPR)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.prGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Novo PR! 🔥',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.prGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  String _muscleEmoji(String group) {
    return switch (group) {
      'peito' => '🫁',
      'costas' => '🔙',
      'pernas' => '🦵',
      'ombros' => '💪',
      'bíceps' => '💪',
      'tríceps' => '💪',
      'core' => '🎯',
      'cardio' => '🏃',
      'olímpico' => '🏋️',
      _ => '⚡',
    };
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PRsSkeleton extends StatelessWidget {
  const _PRsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 120),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemBuilder: (_, __) => const AppLoadingSkeleton(
        width: double.infinity,
        height: 72,
      ),
    );
  }
}

class _PRsError extends StatelessWidget {
  const _PRsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.textDisabledLight),
          const SizedBox(height: AppSpacing.lg),
          const Text('Erro ao carregar PRs', textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
