import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/search_result_model.dart';
import '../providers/search_providers.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trending = ref.watch(trendingHashtagsProvider);
    final suggested = ref.watch(suggestedUsersProvider);
    final hotPosts = ref.watch(_hotPostsProvider);
    final suggestedGroups = ref.watch(_suggestedGroupsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor:
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Explorar',
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => context.push(AppRoutes.search),
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(trendingHashtagsProvider);
                ref.invalidate(suggestedUsersProvider);
                ref.invalidate(_hotPostsProvider);
                ref.invalidate(_suggestedGroupsProvider);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Trending Hashtags ────────────────────────────────
                  _SectionTitle(title: 'Em alta hoje', isDark: isDark),
                  trending.when(
                    loading: () => const _SkeletonChips(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (tags) => _TrendingGrid(tags: tags, isDark: isDark),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Posts em alta ────────────────────────────────────
                  _SectionTitle(
                    title: 'Posts em alta',
                    subtitle: 'Mais reactions nas últimas 24h',
                    isDark: isDark,
                  ),
                  hotPosts.when(
                    loading: () => const _SkeletonList(itemCount: 3),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (posts) => _HotPostsList(posts: posts, isDark: isDark),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Grupos sugeridos ─────────────────────────────────
                  _SectionTitle(
                    title: 'Grupos para você',
                    subtitle: 'Baseado nos seus esportes',
                    isDark: isDark,
                  ),
                  suggestedGroups.when(
                    loading: () => const _SkeletonList(itemCount: 3),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (groups) =>
                        _GroupList(groups: groups, isDark: isDark),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Usuários sugeridos ───────────────────────────────
                  _SectionTitle(
                    title: 'Pessoas para seguir',
                    isDark: isDark,
                  ),
                  suggested.when(
                    loading: () => const _SkeletonList(itemCount: 4),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (users) =>
                        _SuggestedUsersList(users: users, isDark: isDark),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Internal providers for hot posts & suggested groups ─────────────────────

final _hotPostsProvider = FutureProvider<List<SearchResultModel>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 400));
  return const [
    SearchResultModel(
      id: 'p4',
      type: SearchResultType.post,
      title: 'Deadlift 200kg. Próxima meta: 220.',
      subtitle: '@carlos_mendes • 77 🔥 60 💪 35 🏆',
      trailing: '22 comentários',
    ),
    SearchResultModel(
      id: 'p5',
      type: SearchResultType.post,
      title: 'Sub-20 minutos nos 5km! Meta cumprida.',
      subtitle: '@camila_run • 45 🔥 30 💪 20 🏆',
      trailing: '18 comentários',
    ),
    SearchResultModel(
      id: 'p6',
      type: SearchResultType.post,
      title: 'Não existe segredo, existe trabalho. -12kg e bati todos os PRs.',
      subtitle: '@joao_victor • 88 🔥 55 💪',
      trailing: '34 comentários',
    ),
  ];
});

final _suggestedGroupsProvider =
    FutureProvider<List<SearchResultModel>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 350));
  return const [
    SearchResultModel(
      id: 'g1',
      type: SearchResultType.group,
      title: 'Musculação & Hipertrofia',
      subtitle: '5.6k membros • Grupo público',
      trailing: '12 ativos agora',
    ),
    SearchResultModel(
      id: 'g4',
      type: SearchResultType.group,
      title: 'CrossFit SP',
      subtitle: '1.2k membros • Grupo público',
      trailing: '5 ativos agora',
    ),
    SearchResultModel(
      id: 'g3',
      type: SearchResultType.group,
      title: 'Corredores de Rua',
      subtitle: '876 membros • Grupo público',
      trailing: '3 ativos agora',
    ),
  ];
});

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.isDark,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Trending Grid ─────────────────────────────────────────────────────────

class _TrendingGrid extends StatelessWidget {
  const _TrendingGrid({required this.tags, required this.isDark});

  final List<TrendingHashtag> tags;
  final bool isDark;

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k posts';
    return '$n posts';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 72,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          return _TrendingCard(
            tag: tag.tag,
            count: _formatCount(tag.postCount),
            rank: index + 1,
            isDark: isDark,
            onTap: () => context.push(
              AppRoutes.search,
            ),
          );
        },
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({
    required this.tag,
    required this.count,
    required this.rank,
    required this.isDark,
    required this.onTap,
  });

  final String tag;
  final String count;
  final int rank;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTop3
                ? AppColors.primary.withAlpha(80)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                if (isTop3)
                  Text(
                    '#$rank ',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                Expanded(
                  child: Text(
                    tag,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hot Posts List ───────────────────────────────────────────────────────────

class _HotPostsList extends StatelessWidget {
  const _HotPostsList({required this.posts, required this.isDark});

  final List<SearchResultModel> posts;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: posts.map((p) => _PostTile(post: p, isDark: isDark)).toList(),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post, required this.isDark});

  final SearchResultModel post;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.secondary.withAlpha(30),
        child: const Icon(Icons.local_fire_department_rounded,
            size: 20, color: AppColors.secondary),
      ),
      title: Text(
        post.title,
        style: AppTypography.bodyMedium.copyWith(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: post.subtitle != null
          ? Text(
              post.subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: post.trailing != null
          ? Text(
              post.trailing!,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
    );
  }
}

// ─── Group List ───────────────────────────────────────────────────────────────

class _GroupList extends StatelessWidget {
  const _GroupList({required this.groups, required this.isDark});

  final List<SearchResultModel> groups;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: groups
          .map((g) => _GroupTile(group: g, isDark: isDark))
          .toList(),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.isDark});

  final SearchResultModel group;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary.withAlpha(30),
        child: const Icon(Icons.group_rounded, size: 22, color: AppColors.primary),
      ),
      title: Text(
        group.title,
        style: AppTypography.titleSmall.copyWith(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: group.subtitle != null
          ? Text(
              group.subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Entrar',
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ─── Suggested Users List ─────────────────────────────────────────────────────

class _SuggestedUsersList extends StatelessWidget {
  const _SuggestedUsersList({required this.users, required this.isDark});

  final List<SearchResultModel> users;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: users
          .map((u) => _SuggestedUserTile(user: u, isDark: isDark))
          .toList(),
    );
  }
}

class _SuggestedUserTile extends StatelessWidget {
  const _SuggestedUserTile({required this.user, required this.isDark});

  final SearchResultModel user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        backgroundColor: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        child: user.avatarUrl == null
            ? const Icon(Icons.person_rounded)
            : null,
      ),
      title: Text(
        user.title,
        style: AppTypography.titleSmall.copyWith(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: user.subtitle != null
          ? Text(
              user.subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Seguir',
          style: TextStyle(color: AppColors.primary),
        ),
      ),
      onTap: () => context.push(AppRoutes.userProfilePath(user.id)),
    );
  }
}

// ─── Skeletons ────────────────────────────────────────────────────────────────

class _SkeletonChips extends StatelessWidget {
  const _SkeletonChips();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: List.generate(
          6,
          (_) => Container(
            width: 100,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(40),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(40),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
