import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/pr_model.dart';
import '../providers/prs_provider.dart';

// ---- Period filter ----

enum _Period { oneMonth, threeMonths, sixMonths, oneYear, all }

extension _PeriodExt on _Period {
  String label(BuildContext context) => switch (this) {
        _Period.oneMonth => '1M',
        _Period.threeMonths => '3M',
        _Period.sixMonths => '6M',
        _Period.oneYear => '1A',
        _Period.all => context.l10n.prsFilterAll,
      };

  Duration? get duration => switch (this) {
        _Period.oneMonth => const Duration(days: 30),
        _Period.threeMonths => const Duration(days: 90),
        _Period.sixMonths => const Duration(days: 180),
        _Period.oneYear => const Duration(days: 365),
        _Period.all => null,
      };
}

// ---- Screen ----

class PRDetailScreen extends ConsumerStatefulWidget {
  const PRDetailScreen({required this.exerciseId, super.key});

  final String exerciseId;

  @override
  ConsumerState<PRDetailScreen> createState() => _PRDetailScreenState();
}

class _PRDetailScreenState extends ConsumerState<PRDetailScreen> {
  _Period _period = _Period.all;

  List<PRModel> _filterByPeriod(List<PRModel> history) {
    final dur = _period.duration;
    if (dur == null) return history;
    final cutoff = DateTime.now().subtract(dur);
    return history.where((pr) => pr.date.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(prHistoryProvider(widget.exerciseId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorState(
          onRetry: () => ref.invalidate(prHistoryProvider(widget.exerciseId)),
        ),
        data: (history) {
          if (history.isEmpty) {
            return _EmptyState(exerciseId: widget.exerciseId);
          }

          final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
          final filtered = _filterByPeriod(sorted);
          final exerciseName =
              history.isNotEmpty ? history.first.exerciseName : '';
          final unit = history.isNotEmpty ? history.first.unit : '';

          return CustomScrollView(
            slivers: [
              _DetailAppBar(exerciseName: exerciseName, isDark: isDark),

              // Period filter chips
              SliverToBoxAdapter(
                child: _PeriodFilter(
                  selected: _period,
                  onSelect: (p) => setState(() => _period = p),
                ),
              ),

              // Chart
              SliverToBoxAdapter(
                child: _PRChart(
                  history: filtered.isNotEmpty ? filtered : sorted,
                  unit: unit,
                  isDark: isDark,
                ),
              ),

              // Stats row
              SliverToBoxAdapter(
                child: _StatsRow(history: filtered.isNotEmpty ? filtered : sorted),
              ),

              // History list header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                  child: Text(
                    'Histórico',
                    style: AppTypography.titleSmall,
                  ),
                ),
              ),

              // History list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final reversed = (filtered.isNotEmpty ? filtered : sorted)
                        .reversed
                        .toList();
                    final pr = reversed[i];
                    final isFirst = i == 0;
                    return _HistoryTile(
                      pr: pr,
                      isBest: isFirst,
                      isDark: isDark,
                      onEdit: () => context.push(
                        AppRoutes.addPr,
                        extra: pr,
                      ),
                    );
                  },
                  childCount:
                      (filtered.isNotEmpty ? filtered : sorted).length,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---- AppBar ----

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.exerciseName, required this.isDark});

  final String exerciseName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Text(exerciseName, style: AppTypography.titleMedium),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
    );
  }
}

// ---- Period filter ----

class _PeriodFilter extends StatelessWidget {
  const _PeriodFilter({required this.selected, required this.onSelect});

  final _Period selected;
  final void Function(_Period) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: _Period.values
            .map((p) => Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding:
                          const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: selected == p
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: selected == p
                              ? AppColors.primary
                              : AppColors.borderLight.withOpacity(0.5),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        p.label(context),
                        style: AppTypography.labelSmall.copyWith(
                          color: selected == p ? Colors.white : null,
                          fontWeight: selected == p
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ---- Chart ----

class _PRChart extends StatefulWidget {
  const _PRChart({
    required this.history,
    required this.unit,
    required this.isDark,
  });

  final List<PRModel> history;
  final String unit;
  final bool isDark;

  @override
  State<_PRChart> createState() => _PRChartState();
}

class _PRChartState extends State<_PRChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.history.length < 2) {
      return _SinglePointChart(pr: widget.history.first, isDark: widget.isDark);
    }

    final spots = widget.history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = widget.history.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = widget.history.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15;

    final textColor = widget.isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.md, AppSpacing.lg, 0),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: minY - padding,
            maxY: maxY + padding,
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY + 2 * padding) / 4,
              getDrawingHorizontalLine: (_) => FlLine(
                color: (widget.isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight)
                    .withOpacity(0.5),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    final label = value == value.truncateToDouble()
                        ? value.toInt().toString()
                        : value.toStringAsFixed(1);
                    return Text(
                      '$label ${widget.unit}',
                      style: AppTypography.labelSmall.copyWith(
                        color: textColor,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: widget.history.length > 6
                      ? (widget.history.length / 4).ceilToDouble()
                      : 1,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= widget.history.length) {
                      return const SizedBox.shrink();
                    }
                    final date = widget.history[idx].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${date.day}/${date.month}',
                        style: AppTypography.labelSmall.copyWith(
                          color: textColor,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            lineTouchData: LineTouchData(
              touchCallback: (_, response) {
                setState(() {
                  _touchedIndex =
                      response?.lineBarSpots?.firstOrNull?.spotIndex;
                });
              },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) =>
                    AppColors.primary.withOpacity(0.9),
                getTooltipItems: (spots) => spots.map((s) {
                  final pr = widget.history[s.spotIndex];
                  return LineTooltipItem(
                    pr.displayValue,
                    AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              // Trend line (smoothed)
              if (widget.history.length >= 3)
                LineChartBarData(
                  spots: _trendLine(spots),
                  isCurved: true,
                  color: AppColors.primary.withOpacity(0.3),
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                  dashArray: [6, 4],
                ),
              // Main line
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.25,
                color: AppColors.primary,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, __, idx) {
                    final isBest = spot.y == maxY;
                    final isTouched = idx == _touchedIndex;
                    return FlDotCirclePainter(
                      radius: isBest || isTouched ? 5 : 3,
                      color: isBest ? AppColors.prGold : AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.01),
                    ],
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 400),
        ),
      ),
    );
  }

  /// Simple linear regression for the trend line.
  List<FlSpot> _trendLine(List<FlSpot> spots) {
    final n = spots.length;
    final sumX = spots.fold<double>(0, (s, p) => s + p.x);
    final sumY = spots.fold<double>(0, (s, p) => s + p.y);
    final sumXY = spots.fold<double>(0, (s, p) => s + p.x * p.y);
    final sumX2 = spots.fold<double>(0, (s, p) => s + p.x * p.x);
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    return [
      FlSpot(spots.first.x, slope * spots.first.x + intercept),
      FlSpot(spots.last.x, slope * spots.last.x + intercept),
    ];
  }
}

class _SinglePointChart extends StatelessWidget {
  const _SinglePointChart({required this.pr, required this.isDark});

  final PRModel pr;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 32)),
            const SizedBox(height: AppSpacing.sm),
            Text(pr.displayValue,
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.primary)),
            Text(
              'Registre mais PRs para ver o gráfico',
              style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Stats row ----

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.history});

  final List<PRModel> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final best = history.reduce((a, b) => a.value > b.value ? a : b);
    final first = history.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
    final improvement = best.value - first.value;
    final improvementStr = improvement >= 0
        ? '+${improvement.toStringAsFixed(1)}'
        : improvement.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          _StatCard(
            emoji: '🏆',
            label: 'Melhor',
            value: best.displayValue,
            color: AppColors.prGold,
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatCard(
            emoji: '📈',
            label: 'Evolução',
            value: '$improvementStr ${first.unit}',
            color: improvement >= 0 ? AppColors.prGreen : AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatCard(
            emoji: '📋',
            label: 'Registros',
            value: '${history.length}',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---- History tile ----

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.pr,
    required this.isBest,
    required this.isDark,
    required this.onEdit,
  });

  final PRModel pr;
  final bool isBest;
  final bool isDark;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isBest
                    ? AppColors.prGold.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                isBest ? '🥇' : '📌',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(context, pr.date),
                    style: AppTypography.labelSmall
                        .copyWith(color: textSecondary),
                  ),
                  if (pr.notes != null && pr.notes!.isNotEmpty)
                    Text(
                      pr.notes!,
                      style: AppTypography.labelSmall
                          .copyWith(color: textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pr.displayValue,
                  style: AppTypography.titleSmall.copyWith(
                    color: isBest ? AppColors.prGold : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isBest)
                  Text(
                    'Melhor PR',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.prGold,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.edit_outlined, size: 14, color: textSecondary),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l = context.l10n;
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return l.prsTimeToday;
    if (diff.inDays == 1) return l.prsTimeYesterday;
    if (diff.inDays < 7) return l.prsTimeDaysAgo(diff.inDays);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ---- Empty / Error states ----

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text(context.l10n.prsEmptyFirstTime,
              style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.addPr),
            icon: const Icon(Icons.add_rounded),
            label: Text(context.l10n.addPrSubmit),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

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
          Text(context.l10n.prsErrorMessage),
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.prsRetry),
          ),
        ],
      ),
    );
  }
}
