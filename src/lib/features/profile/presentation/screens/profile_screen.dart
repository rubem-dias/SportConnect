import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_loading_skeleton.dart';
import '../../../feed/data/models/post_model.dart';
import '../../data/models/user_profile_model.dart';
import '../providers/profile_providers.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedId = userId ?? 'me';
    final profileAsync = ref.watch(profileProvider(resolvedId));

    return profileAsync.when(
      loading: () => const _ProfileSkeleton(),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_rounded,
                  size: 48, color: AppColors.textDisabledLight),
              const SizedBox(height: AppSpacing.md),
              const Text('Perfil não encontrado'),
              TextButton(
                onPressed: () => ref.invalidate(profileProvider(resolvedId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      data: (profile) => _ProfileContent(
        profile: profile,
        profileId: resolvedId,
      ),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _ProfileContent extends ConsumerStatefulWidget {
  const _ProfileContent({
    required this.profile,
    required this.profileId,
  });

  final UserProfileModel profile;
  final String profileId;

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile =
        ref.watch(profileProvider(widget.profileId)).valueOrNull ??
            widget.profile;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _ProfileSliverAppBar(
            profile: profile,
            profileId: widget.profileId,
            isDark: isDark,
            innerBoxIsScrolled: innerBoxIsScrolled,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              isDark: isDark,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _PostsTab(userId: widget.profileId),
            _PRsTab(userId: widget.profileId),
            _BadgesTab(badges: profile.badges),
          ],
        ),
      ),
    );
  }
}

// ── Sliver AppBar ─────────────────────────────────────────────────────────────

class _ProfileSliverAppBar extends ConsumerWidget {
  const _ProfileSliverAppBar({
    required this.profile,
    required this.profileId,
    required this.isDark,
    required this.innerBoxIsScrolled,
  });

  final UserProfileModel profile;
  final String profileId;
  final bool isDark;
  final bool innerBoxIsScrolled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: profile.isMe ? 270 : 290,
      backgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      elevation: innerBoxIsScrolled ? 2 : 0,
      leading: profile.isMe
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
      automaticallyImplyLeading: !profile.isMe,
      actions: [
        if (profile.isMe)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        if (!profile.isMe)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              if (value == 'block') {
                await ref
                    .read(profileProvider(profileId).notifier)
                    .blockUser();
                if (context.mounted) context.pop();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_rounded, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Bloquear',
                        style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _ProfileHeader(
          profile: profile,
          profileId: profileId,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({
    required this.profile,
    required this.profileId,
    required this.isDark,
  });

  final UserProfileModel profile;
  final String profileId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(profileProvider(profileId)).valueOrNull ?? profile;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg + 48,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.primary.withAlpha(40),
                  backgroundImage: current.avatar != null
                      ? NetworkImage(current.avatar!)
                      : null,
                  child: current.avatar == null
                      ? const Icon(Icons.person_rounded,
                          size: 38, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatColumn(label: 'Posts', value: current.postsCount),
                      _StatColumn(
                          label: 'Seguidores', value: current.followersCount),
                      _StatColumn(
                          label: 'Seguindo', value: current.followingCount),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              current.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              current.username,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (current.bio != null && current.bio!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                current.bio!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  height: 1.4,
                ),
              ),
            ],
            if (current.sports.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                children: current.sports.map((s) => AppBadge(label: s)).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (current.isMe)
              _EditProfileButton(profile: current, profileId: profileId)
            else
              _OtherUserActions(profile: current, profileId: profileId),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final int value;

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          _fmt(value),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton({required this.profile, required this.profileId});

  final UserProfileModel profile;
  final String profileId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => showEditProfileSheet(context, profile, profileId),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Editar Perfil'),
      ),
    );
  }
}

class _OtherUserActions extends ConsumerWidget {
  const _OtherUserActions({required this.profile, required this.profileId});

  final UserProfileModel profile;
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(profileProvider(profileId)).valueOrNull ?? profile;

    return Row(
      children: [
        Expanded(
          child: current.isFollowing
              ? OutlinedButton(
                  onPressed: () =>
                      ref.read(profileProvider(profileId).notifier).unfollow(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Seguindo'),
                )
              : ElevatedButton(
                  onPressed: () =>
                      ref.read(profileProvider(profileId).notifier).follow(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Seguir'),
                ),
        ),
        const SizedBox(width: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () =>
              context.push(AppRoutes.chatConversationPath(profileId)),
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
          label: const Text('Mensagem'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

// ── Tab bar delegate ──────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.tabController, required this.isDark});

  final TabController tabController;
  final bool isDark;

  @override
  double get minExtent => 46;
  @override
  double get maxExtent => 46;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: isDark ? AppColors.borderDark : AppColors.borderLight,
        tabs: const [
          Tab(icon: Icon(Icons.grid_on_rounded, size: 20)),
          Tab(icon: Icon(Icons.emoji_events_rounded, size: 20)),
          Tab(icon: Icon(Icons.military_tech_rounded, size: 20)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

// ── Posts tab ─────────────────────────────────────────────────────────────────

class _PostsTab extends ConsumerWidget {
  const _PostsTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      loading: () => GridView.builder(
        padding: const EdgeInsets.all(1),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemCount: 9,
        itemBuilder: (_, __) =>
            const AppLoadingSkeleton(height: double.infinity),
      ),
      error: (_, __) =>
          const Center(child: Text('Erro ao carregar posts')),
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 48, color: AppColors.textDisabledLight),
                SizedBox(height: AppSpacing.md),
                Text('Nenhum post ainda'),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: posts.length,
          itemBuilder: (_, i) => _PostThumbnail(post: posts[i], isDark: isDark),
        );
      },
    );
  }
}

class _PostThumbnail extends StatelessWidget {
  const _PostThumbnail({required this.post, required this.isDark});

  final PostModel post;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isPR = post.prData != null;

    if (post.mediaUrls.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post.mediaUrls.first,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
            ),
          ),
          if (post.mediaUrls.length > 1)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.copy_all_rounded,
                    size: 12, color: Colors.white),
              ),
            ),
        ],
      );
    }

    return Container(
      color: isPR
          ? AppColors.prGreen.withAlpha(30)
          : (isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight),
      child: Center(
        child: isPR
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 24)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs),
                    child: Text(
                      post.prData!['exercise']?.toString() ?? 'PR',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.prGreen),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Icon(
                Icons.format_quote_rounded,
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textDisabledLight,
              ),
      ),
    );
  }
}

// ── PRs tab ───────────────────────────────────────────────────────────────────

class _PRsTab extends ConsumerWidget {
  const _PRsTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prsAsync = ref.watch(userPRsProvider(userId));

    return prsAsync.when(
      loading: () => ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [
              const AppLoadingSkeleton(
                  width: 44, height: 44, borderRadius: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLoadingSkeleton(height: 14, borderRadius: 4),
                    const SizedBox(height: 6),
                    AppLoadingSkeleton(
                        width: 100, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      error: (_, __) => const Center(child: Text('Erro ao carregar PRs')),
      data: (prs) {
        if (prs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 48, color: AppColors.textDisabledLight),
                SizedBox(height: AppSpacing.md),
                Text('Nenhum PR registrado'),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: prs.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 68,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          itemBuilder: (_, i) {
            final s = prs[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withAlpha(30),
                child: Text(
                  _muscleEmoji(s.muscleGroup),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              title: Text(s.exerciseName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(s.muscleGroup),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.bestPR.displayValue,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                  if (s.isRecentPR)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.prGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Novo PR!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _muscleEmoji(String group) {
    switch (group.toLowerCase()) {
      case 'peito':
        return '💪';
      case 'costas':
        return '🔙';
      case 'pernas':
        return '🦵';
      case 'ombro':
        return '🏋️';
      case 'cardio':
        return '🏃';
      default:
        return '💪';
    }
  }
}

// ── Badges tab ────────────────────────────────────────────────────────────────

class _BadgesTab extends StatelessWidget {
  const _BadgesTab({required this.badges});

  final List<BadgeModel> badges;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, i) {
        final badge = badges[i];
        return GestureDetector(
          onTap: () => _showBadgeInfo(context, badge),
          child: AnimatedOpacity(
            opacity: badge.isUnlocked ? 1 : 0.35,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? AppColors.primary.withAlpha(20)
                    : (isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight),
                borderRadius: BorderRadius.circular(12),
                border: badge.isUnlocked
                    ? Border.all(color: AppColors.primary.withAlpha(80))
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(badge.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs),
                    child: Text(
                      badge.title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badge.isUnlocked
                            ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight)
                            : (isDark
                                ? AppColors.textDisabledDark
                                : AppColors.textDisabledLight),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!badge.isUnlocked) ...[
                    const SizedBox(height: 2),
                    const Icon(Icons.lock_rounded,
                        size: 12, color: AppColors.textDisabledLight),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBadgeInfo(BuildContext context, BadgeModel badge) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(badge.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description),
            if (badge.isUnlocked && badge.unlockedAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Desbloqueado em '
                '${badge.unlockedAt!.day.toString().padLeft(2, '0')}/'
                '${badge.unlockedAt!.month.toString().padLeft(2, '0')}/'
                '${badge.unlockedAt!.year}',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ] else if (!badge.isUnlocked)
              const Text(
                'Ainda bloqueado',
                style: TextStyle(color: AppColors.textDisabledLight),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Row(
                children: [
                  const AppLoadingSkeleton(
                      width: 76, height: 76, borderRadius: 38),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        3,
                        (_) => Column(
                          children: [
                            const AppLoadingSkeleton(
                                width: 36, height: 18, borderRadius: 4),
                            const SizedBox(height: 4),
                            AppLoadingSkeleton(
                                width: 48, height: 12, borderRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const AppLoadingSkeleton(
                  width: 160, height: 16, borderRadius: 4),
              const SizedBox(height: 6),
              const AppLoadingSkeleton(
                  width: 100, height: 12, borderRadius: 4),
              const SizedBox(height: 8),
              const AppLoadingSkeleton(height: 12, borderRadius: 4),
              const SizedBox(height: 4),
              const AppLoadingSkeleton(
                  width: 200, height: 12, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}
