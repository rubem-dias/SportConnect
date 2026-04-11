import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/search_result_model.dart';
import '../providers/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  late final TabController _tabController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() => _isSearching = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
    setState(() => _isSearching = value.isNotEmpty);
  }

  void _onSubmit(String value) {
    if (value.trim().isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).add(value.trim());
    }
  }

  void _applyRecent(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    _onQueryChanged(query);
    _focusNode.requestFocus();
  }

  void _clear() {
    _searchController.clear();
    _onQueryChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              controller: _searchController,
              focusNode: _focusNode,
              isDark: isDark,
              onChanged: _onQueryChanged,
              onSubmit: _onSubmit,
              onClear: _clear,
              onBack: () => context.pop(),
            ),
            if (_isSearching) ...[
              _TabBar(controller: _tabController, isDark: isDark),
              Expanded(
                child: _SearchResults(
                  tabController: _tabController,
                  isDark: isDark,
                ),
              ),
            ] else
              Expanded(
                child: _SearchHome(
                  isDark: isDark,
                  onRecentTap: _applyRecent,
                  onHashtagTap: (tag) => _applyRecent(tag),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onSubmit,
    required this.onClear,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar usuários, grupos, posts...',
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: onClear,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: onChanged,
                onSubmitted: onSubmit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Bar ────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller, required this.isDark});

  final TabController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primary,
        unselectedLabelColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelLarge,
        tabs: const [
          Tab(text: 'Tudo'),
          Tab(text: 'Usuários'),
          Tab(text: 'Grupos'),
          Tab(text: 'Posts'),
          Tab(text: 'Exercícios'),
        ],
      ),
    );
  }
}

// ─── Search Results ──────────────────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  const _SearchResults({
    required this.tabController,
    required this.isDark,
  });

  final TabController tabController;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro ao buscar: $e')),
      data: (state) => TabBarView(
        controller: tabController,
        children: [
          _ResultList(items: state.all, isDark: isDark),
          _ResultList(items: state.users, isDark: isDark),
          _ResultList(items: state.groups, isDark: isDark),
          _ResultList(items: state.posts, isDark: isDark),
          _ResultList(items: state.exercises, isDark: isDark),
        ],
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.items, required this.isDark});

  final List<SearchResultModel> items;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhum resultado encontrado',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        indent: AppSpacing.xxxl + AppSpacing.lg,
      ),
      itemBuilder: (context, index) =>
          _ResultTile(item: items[index], isDark: isDark),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.item, required this.isDark});

  final SearchResultModel item;
  final bool isDark;

  IconData _typeIcon() {
    return switch (item.type) {
      SearchResultType.user => Icons.person_outline_rounded,
      SearchResultType.group => Icons.group_outlined,
      SearchResultType.post => Icons.article_outlined,
      SearchResultType.exercise => Icons.fitness_center_rounded,
    };
  }

  void _onTap(BuildContext context) {
    switch (item.type) {
      case SearchResultType.user:
        context.push(AppRoutes.userProfilePath(item.id));
      case SearchResultType.group:
      case SearchResultType.post:
      case SearchResultType.exercise:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListTile(
      onTap: () => _onTap(context),
      leading: item.avatarUrl != null
          ? CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(item.avatarUrl!),
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
            )
          : CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withAlpha(30),
              child: Icon(_typeIcon(), size: 20, color: AppColors.primary),
            ),
      title: Text(
        item.title,
        style: AppTypography.titleSmall.copyWith(color: textColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: AppTypography.bodySmall.copyWith(color: subtitleColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: item.trailing != null
          ? Text(
              item.trailing!,
              style: AppTypography.bodySmall.copyWith(color: subtitleColor),
            )
          : null,
    );
  }
}

// ─── Search Home (idle state) ─────────────────────────────────────────────

class _SearchHome extends ConsumerWidget {
  const _SearchHome({
    required this.isDark,
    required this.onRecentTap,
    required this.onHashtagTap,
  });

  final bool isDark;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onHashtagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentSearchesProvider);
    final trending = ref.watch(trendingHashtagsProvider);
    final suggested = ref.watch(suggestedUsersProvider);

    return ListView(
      children: [
        if (recents.isNotEmpty) ...[
          _SectionHeader(
            title: 'Buscas recentes',
            isDark: isDark,
            trailing: TextButton(
              onPressed: () =>
                  ref.read(recentSearchesProvider.notifier).clear(),
              child: const Text(
                'Limpar',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),
          ...recents.map(
            (q) => _RecentTile(
              query: q,
              isDark: isDark,
              onTap: () => onRecentTap(q),
              onRemove: () =>
                  ref.read(recentSearchesProvider.notifier).remove(q),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Trending hashtags
        _SectionHeader(title: 'Em alta hoje', isDark: isDark),
        trending.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (tags) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: tags
                  .map((t) => _HashtagChip(
                        tag: t.tag,
                        count: t.postCount,
                        isDark: isDark,
                        onTap: () => onHashtagTap(t.tag),
                      ))
                  .toList(),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Suggested users
        _SectionHeader(title: 'Sugestões para você', isDark: isDark),
        suggested.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (users) => Column(
            children: users
                .map((u) => _SuggestedUserTile(user: u, isDark: isDark))
                .toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.isDark,
    this.trailing,
  });

  final String title;
  final bool isDark;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.query,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(
        Icons.history_rounded,
        size: 20,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      title: Text(
        query,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close_rounded, size: 18),
        onPressed: onRemove,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }
}

class _HashtagChip extends StatelessWidget {
  const _HashtagChip({
    required this.tag,
    required this.count,
    required this.isDark,
    required this.onTap,
  });

  final String tag;
  final int count;
  final bool isDark;
  final VoidCallback onTap;

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha(60)),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: tag,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: '  ${_formatCount(count)} posts',
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
            ? const Icon(Icons.person_rounded, size: 22)
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
