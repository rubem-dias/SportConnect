import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_skeleton.dart';
import '../providers/feed_provider.dart';
import '../widgets/create_post_sheet.dart';
import '../widgets/post_card.dart';
import '../widgets/pr_card.dart';
import '../widgets/stories_bar.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreatePostSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: feed.when(
        loading: () => const _FeedSkeleton(),
        error: (e, _) => _FeedError(
          error: e,
          onRetry: () => ref.read(feedProvider.notifier).refresh(),
        ),
        data: (state) {
          if (state.posts.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.read(feedProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  _FeedAppBar(isDark: isDark),
                  SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: context.l10n.feedEmptyTitle,
                      subtitle: context.l10n.feedEmptySubtitle,
                      actionLabel: context.l10n.feedEmptyAction,
                      onAction: () {},
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.read(feedProvider.notifier).refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _FeedAppBar(isDark: isDark),
                SliverToBoxAdapter(
                  child: Container(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    child: Column(
                      children: [
                        const StoriesBar(),
                        Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= state.posts.length) {
                        return state.isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: PostCardSkeleton(),
                              )
                            : const SizedBox.shrink();
                      }

                      final post = state.posts[index];
                      final isPR = post.prData != null;

                      if (isPR) {
                        return PRCard(
                          post: post,
                          onComment: () => context.push(
                            AppRoutes.postCommentsPath(post.id),
                            extra: post,
                          ),
                          onShare: () {},
                        );
                      }

                      return Column(
                        children: [
                          PostCard(
                            post: post,
                            onComment: () => context.push(
                              AppRoutes.postCommentsPath(post.id),
                              extra: post,
                            ),
                            onShare: () {},
                          ),
                          _PostDivider(isDark: isDark),
                        ],
                      );
                    },
                    childCount: state.posts.length + 1,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxxl),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeedAppBar extends StatelessWidget {
  const _FeedAppBar({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          const Text(
            'Sport',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          Text(
            'Connect',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.explore_outlined),
          onPressed: () => context.push(AppRoutes.explore),
        ),
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => context.push(AppRoutes.search),
        ),
        IconButton(
          icon: const Icon(Icons.add_box_outlined),
          onPressed: () => showCreatePostSheet(context),
        ),
      ],
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

class _PostDivider extends StatelessWidget {
  const _PostDivider({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const PostCardSkeleton(),
            childCount: 4,
          ),
        ),
      ],
    );
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textDisabledLight,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.feedErrorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.feedRetry),
            ),
          ],
        ),
      ),
    );
  }
}
