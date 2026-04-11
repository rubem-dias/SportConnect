import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../data/models/post_model.dart';

/// Card destacado para posts do tipo Personal Record.
/// Exibe fundo verde escuro com badge de troféu, diferenciando visualmente
/// do PostCard padrão.
class PRCard extends StatelessWidget {
  const PRCard({required this.post, super.key, this.onComment, this.onShare});

  final PostModel post;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  String _relativeTime(BuildContext context, DateTime dt) {
    final l10n = context.l10n;
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return l10n.postTimeNow;
    if (diff.inMinutes < 60) return l10n.postTimeMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.postTimeHours(diff.inHours);
    if (diff.inDays < 7) return l10n.postTimeDays(diff.inDays);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String get _prValue {
    final data = post.prData;
    if (data == null) return '';
    final exercise = data['exercise']?.toString() ?? data['exerciseName']?.toString() ?? '';
    final value = data['value']?.toString() ?? '';
    final unit = data['unit']?.toString() ?? '';
    final reps = data['reps'];
    if (exercise.isEmpty && value.isEmpty) return '';
    if (reps != null) return '$exercise — $value$unit × $reps reps';
    return '$exercise — $value$unit';
  }

  @override
  Widget build(BuildContext context) {
    final prLabel = _prValue;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003300), Color(0xFF004D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.prGreen.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.prGreen.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PRHeader(post: post, relativeTime: _relativeTime(context, post.createdAt)),
            if (prLabel.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _PRValueBox(label: prLabel),
            ],
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                post.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _PRActionBar(post: post, onComment: onComment, onShare: onShare),
          ],
        ),
      ),
    );
  }
}

class _PRHeader extends StatelessWidget {
  const _PRHeader({required this.post, required this.relativeTime});

  final PostModel post;
  final String relativeTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(
          imageUrl: post.userAvatar,
          name: post.userName ?? 'U',
          size: AppAvatarSize.sm,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName ?? context.l10n.postDefaultUser,
                style: AppTypography.titleSmall.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                relativeTime,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.prGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.prGreen.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                context.l10n.prCardNewBadge,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.prGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PRValueBox extends StatelessWidget {
  const _PRValueBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.prGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.prGreen.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.titleSmall.copyWith(
          color: AppColors.prGold,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PRActionBar extends StatelessWidget {
  const _PRActionBar({
    required this.post,
    this.onComment,
    this.onShare,
  });

  final PostModel post;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  int get _totalReactions =>
      post.reactions.values.fold(0, (sum, v) => sum + v);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_totalReactions > 0) ...[
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$_totalReactions',
            style: AppTypography.labelSmall.copyWith(color: Colors.white60),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
        const Spacer(),
        if (post.commentsCount > 0)
          _PRAction(
            icon: Icons.chat_bubble_outline_rounded,
            label: '${post.commentsCount}',
            onTap: onComment,
          ),
        const SizedBox(width: AppSpacing.lg),
        _PRAction(
          icon: Icons.share_outlined,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _PRAction extends StatelessWidget {
  const _PRAction({required this.icon, this.label, this.onTap});

  final IconData icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white54),
          if (label != null && label!.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: AppTypography.labelSmall.copyWith(color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }
}
