import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/notification_model.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notificações',
          style: AppTypography.titleLarge.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text(
                'Marcar todas',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push(AppRoutes.notificationSettings),
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            tooltip: 'Configurações',
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
      body: state.isLoading
          ? const _NotificationsSkeleton()
          : state.notifications.isEmpty
              ? _EmptyState(isDark: isDark)
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      ref.read(notificationsProvider.notifier).refresh(),
                  child: _NotificationsList(
                    notifications: state.notifications,
                    isDark: isDark,
                  ),
                ),
    );
  }
}

// ─── Notifications List ───────────────────────────────────────────────────────

class _NotificationsList extends ConsumerWidget {
  const _NotificationsList({
    required this.notifications,
    required this.isDark,
  });

  final List<NotificationModel> notifications;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group by date
    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final older = <NotificationModel>[];
    final now = DateTime.now();

    for (final n in notifications) {
      final diff = now.difference(n.createdAt);
      if (diff.inDays == 0) {
        today.add(n);
      } else if (diff.inDays == 1) {
        yesterday.add(n);
      } else {
        older.add(n);
      }
    }

    return ListView(
      children: [
        if (today.isNotEmpty) ...[
          _DateHeader(label: 'Hoje', isDark: isDark),
          ...today.map((n) => _NotificationTile(n: n, isDark: isDark)),
        ],
        if (yesterday.isNotEmpty) ...[
          _DateHeader(label: 'Ontem', isDark: isDark),
          ...yesterday.map((n) => _NotificationTile(n: n, isDark: isDark)),
        ],
        if (older.isNotEmpty) ...[
          _DateHeader(label: 'Anteriores', isDark: isDark),
          ...older.map((n) => _NotificationTile(n: n, isDark: isDark)),
        ],
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

// ─── Notification Tile ────────────────────────────────────────────────────────

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.n, required this.isDark});

  final NotificationModel n;
  final bool isDark;

  IconData _typeIcon() {
    return switch (n.type) {
      NotificationType.reaction => Icons.favorite_rounded,
      NotificationType.comment => Icons.chat_bubble_rounded,
      NotificationType.follower => Icons.person_add_rounded,
      NotificationType.prBeaten => Icons.emoji_events_rounded,
      NotificationType.mention => Icons.alternate_email_rounded,
      NotificationType.groupInvite => Icons.group_add_rounded,
    };
  }

  Color _typeColor() {
    return switch (n.type) {
      NotificationType.reaction => AppColors.secondary,
      NotificationType.comment => AppColors.primary,
      NotificationType.follower => AppColors.info,
      NotificationType.prBeaten => AppColors.prGold,
      NotificationType.mention => AppColors.primary,
      NotificationType.groupInvite => AppColors.success,
    };
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays == 1) return 'ontem';
    return 'há ${diff.inDays} dias';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadBg = isDark
        ? AppColors.primary.withAlpha(20)
        : AppColors.primary.withAlpha(12);

    return InkWell(
      onTap: () =>
          ref.read(notificationsProvider.notifier).markAsRead(n.id),
      child: Container(
        color: n.isRead ? null : unreadBg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with type badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: n.actorAvatar != null
                      ? NetworkImage(n.actorAvatar!)
                      : null,
                  backgroundColor: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariantLight,
                  child: n.actorAvatar == null
                      ? const Icon(Icons.person_rounded)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _typeColor(),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        width: 2,
                      ),
                    ),
                    child: Icon(_typeIcon(), size: 11, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: n.title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight:
                                n.isRead ? FontWeight.w400 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.body,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(n.createdAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: n.isRead
                          ? (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight)
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            if (!n.isRead)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: AppSpacing.sm),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nenhuma notificação',
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Quando alguém interagir com você,\naparecerá aqui.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
                    width: 180,
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
    );
  }
}
