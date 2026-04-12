import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_skeleton.dart';
import '../../../search/data/models/search_result_model.dart';
import '../../../search/presentation/providers/search_providers.dart';
import '../providers/chat_providers.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/create_group_sheet.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  bool _isSearching = false;
  String _query = '';
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _query = '';
    });
    _searchController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversations = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: _isSearching ? 40 : null,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _stopSearch,
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por @username ou nome...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontSize: 16,
                ),
              )
            : Text(
                'Mensagens',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
        actions: _isSearching
            ? [
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: _startSearch,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                IconButton(
                  icon: const Icon(Icons.group_add_rounded),
                  onPressed: () => showCreateGroupSheet(context),
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
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
      body: conversations.when(
        loading: () => const _ConversationsSkeleton(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.textDisabledLight),
              const SizedBox(height: AppSpacing.md),
              const Text('Erro ao carregar mensagens'),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: () =>
                    ref.read(conversationsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (list) {
          var visible = list.where((c) => !c.isArchived).toList();

          if (_query.isNotEmpty) {
            final q = _query.toLowerCase();
            visible = visible
                .where((c) => c.name.toLowerCase().contains(q))
                .toList();
          }

          if (!_isSearching && visible.isEmpty) {
            return AppEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Nenhuma conversa ainda',
              subtitle: 'Encontre pessoas próximas e comece a conversar!',
              actionLabel: 'Explorar nearby',
              onAction: () => context.go(AppRoutes.nearby),
            );
          }

          return CustomScrollView(
            slivers: [
              // Conversas existentes
              if (visible.isNotEmpty) ...[
                if (_isSearching && _query.isNotEmpty)
                  _SliverSectionHeader(
                    label: 'Conversas',
                    isDark: isDark,
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final conv = visible[index];
                      final isLast = index == visible.length - 1;
                      return Column(
                        children: [
                          Dismissible(
                            key: ValueKey(conv.id),
                            direction: DismissDirection.endToStart,
                            background: _ArchiveBackground(),
                            confirmDismiss: (_) async => false,
                            child: ConversationTile(
                              conversation: conv,
                              onTap: () {
                                ref
                                    .read(conversationsProvider.notifier)
                                    .markRead(conv.id);
                                context.push(
                                  AppRoutes.chatConversationPath(conv.id),
                                  extra: conv,
                                );
                              },
                              onLongPress: () =>
                                  _showConversationOptions(context, conv.id),
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 72,
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                        ],
                      );
                    },
                    childCount: visible.length,
                  ),
                ),
              ],

              // Seção "Pessoas" — busca global por @username (estilo Telegram)
              if (_isSearching && _query.isNotEmpty)
                _UserSearchSection(query: _query, isDark: isDark),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showConversationOptions(BuildContext context, String convId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive_rounded),
              title: const Text('Arquivar'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.volume_off_rounded),
              title: const Text('Mutar notificações'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_rounded, color: AppColors.error),
              title: const Text(
                'Excluir',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── User search section (Telegram-style global search) ─────────────────────

class _UserSearchSection extends ConsumerWidget {
  const _UserSearchSection({
    required this.query,
    required this.isDark,
  });

  final String query;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(userSearchProvider(query));

    return results.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (users) {
        if (users.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        return SliverMainAxisGroup(
          slivers: [
            _SliverSectionHeader(label: 'Pessoas', isDark: isDark),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = users[index];
                  final isLast = index == users.length - 1;
                  return Column(
                    children: [
                      _UserResultTile(user: user, isDark: isDark),
                      if (!isLast)
                        Divider(
                          height: 1,
                          indent: 72,
                          color:
                              isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                    ],
                  );
                },
                childCount: users.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UserResultTile extends StatelessWidget {
  const _UserResultTile({required this.user, required this.isDark});

  final SearchResultModel user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push(AppRoutes.userProfilePath(user.id)),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        backgroundColor:
            isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        child: user.avatarUrl == null
            ? const Icon(Icons.person_rounded, size: 26)
            : null,
      ),
      title: Text(
        user.title,
        style: AppTypography.titleSmall.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
      trailing: user.trailing != null
          ? Text(
              user.trailing!,
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

// ─── Section header ──────────────────────────────────────────────────────────

class _SliverSectionHeader extends StatelessWidget {
  const _SliverSectionHeader({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xs,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ─── Archive background ───────────────────────────────────────────────────────

class _ArchiveBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.info,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.archive_rounded, color: Colors.white),
          SizedBox(height: 4),
          Text(
            'Arquivar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _ConversationsSkeleton extends StatelessWidget {
  const _ConversationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            AppLoadingSkeleton(width: 52, height: 52, borderRadius: 26),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppLoadingSkeleton(height: 14, borderRadius: 4),
                      ),
                      SizedBox(width: AppSpacing.xl),
                      AppLoadingSkeleton(
                          width: 36, height: 10, borderRadius: 4),
                    ],
                  ),
                  SizedBox(height: 6),
                  AppLoadingSkeleton(height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
