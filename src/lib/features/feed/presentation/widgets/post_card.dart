import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../data/models/post_model.dart';

class PostCard extends StatefulWidget {
  const PostCard({required this.post, super.key, this.onComment, this.onShare, this.onReaction});

  final PostModel post;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final void Function(String emoji)? onReaction;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  static const _maxLines = 4;
  bool _expanded = false;

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(post: post, relativeTime: _relativeTime(post.createdAt), textSecondary: textSecondary),
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _ContentText(
              content: post.content,
              expanded: _expanded,
              maxLines: _maxLines,
              onToggle: () => setState(() => _expanded = !_expanded),
            ),
          ],
          if (post.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _MediaGrid(urls: post.mediaUrls),
          ],
          const SizedBox(height: AppSpacing.sm),
          _ActionBar(
            post: post,
            textSecondary: textSecondary,
            onReaction: widget.onReaction,
            onComment: widget.onComment,
            onShare: widget.onShare,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.post,
    required this.relativeTime,
    required this.textSecondary,
  });

  final PostModel post;
  final String relativeTime;
  final Color textSecondary;

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
                post.userName ?? 'Usuário',
                style: AppTypography.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                relativeTime,
                style: AppTypography.labelSmall.copyWith(color: textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          iconSize: 20,
          color: textSecondary,
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _ContentText extends StatelessWidget {
  const _ContentText({
    required this.content,
    required this.expanded,
    required this.maxLines,
    required this.onToggle,
  });

  final String content;
  final bool expanded;
  final int maxLines;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: content,
          style: AppTypography.bodyMedium.copyWith(color: textColor),
        );
        final tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final overflows = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: AppTypography.bodyMedium.copyWith(color: textColor),
              maxLines: expanded ? null : maxLines,
              overflow: expanded ? null : TextOverflow.ellipsis,
            ),
            if (overflows)
              GestureDetector(
                onTap: onToggle,
                child: Text(
                  expanded ? 'ver menos' : 'ver mais',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final count = urls.length;

    if (count == 1) {
      return _ImageTile(url: urls[0], borderRadius: AppRadius.cardBorderRadius);
    }

    if (count == 2) {
      return Row(
        children: [
          Expanded(
            child: _ImageTile(
              url: urls[0],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: _ImageTile(
              url: urls[1],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppRadius.md),
                bottomRight: Radius.circular(AppRadius.md),
              ),
            ),
          ),
        ],
      );
    }

    if (count == 3) {
      return Row(
        children: [
          Expanded(
            child: _ImageTile(
              url: urls[0],
              height: 200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                _ImageTile(
                  url: urls[1],
                  height: 99,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppRadius.md),
                  ),
                ),
                const SizedBox(height: 2),
                _ImageTile(
                  url: urls[2],
                  height: 99,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(AppRadius.md),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 4+ images
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ImageTile(
                url: urls[0],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: _ImageTile(
                url: urls[1],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppRadius.md),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: _ImageTile(
                url: urls[2],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Stack(
                children: [
                  _ImageTile(
                    url: urls[3],
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(AppRadius.md),
                    ),
                  ),
                  if (count > 4)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(AppRadius.md),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+${count - 4}',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.url,
    this.height = 200,
    this.borderRadius,
  });

  final String url;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: height,
          color: AppColors.surfaceVariantLight,
        ),
        errorWidget: (_, __, ___) => Container(
          height: height,
          color: AppColors.surfaceVariantLight,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, color: AppColors.textDisabledLight),
        ),
      ),
    );
  }
}

class _ActionBar extends StatefulWidget {
  const _ActionBar({
    required this.post,
    required this.textSecondary,
    this.onReaction,
    this.onComment,
    this.onShare,
  });

  final PostModel post;
  final Color textSecondary;
  final void Function(String emoji)? onReaction;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar> {
  static const _reactionEmojis = ['🔥', '💪', '🏆'];

  String? _myReaction;

  Map<String, int> get _reactions => widget.post.reactions;

  int _countFor(String emoji) => _reactions[emoji] ?? 0;

  void _tapReaction(String emoji) {
    setState(() {
      _myReaction = _myReaction == emoji ? null : emoji;
    });
    widget.onReaction?.call(emoji);
  }

  void _longPressReaction(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReactionPicker(
        emojis: _reactionEmojis,
        onSelect: (e) {
          Navigator.pop(context);
          _tapReaction(e);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ..._reactionEmojis.map(
          (e) => _ReactionChip(
            emoji: e,
            count: _countFor(e) + (_myReaction == e ? 1 : 0),
            isActive: _myReaction == e,
            onTap: () => _tapReaction(e),
            onLongPress: () => _longPressReaction(context),
          ),
        ),
        const Spacer(),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: widget.post.commentsCount > 0
              ? '${widget.post.commentsCount}'
              : '',
          color: widget.textSecondary,
          onTap: widget.onComment,
        ),
        const SizedBox(width: AppSpacing.sm),
        _ActionButton(
          icon: Icons.share_outlined,
          color: widget.textSecondary,
          onTap: widget.onShare,
        ),
      ],
    );
  }
}

class _ReactionChip extends StatefulWidget {
  const _ReactionChip({
    required this.emoji,
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
  });

  final String emoji;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_ReactionChip> createState() => _ReactionChipState();
}

class _ReactionChipState extends State<_ReactionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _animate() {
    _ctrl.reverse().then((_) => _ctrl.forward());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animate,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(right: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.primary.withOpacity(0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 16)),
              if (widget.count > 0) ...[
                const SizedBox(width: 3),
                Text(
                  '${widget.count}',
                  style: AppTypography.labelSmall.copyWith(
                    color: widget.isActive ? AppColors.primary : null,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    this.label,
    this.onTap,
  });

  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          if (label != null && label!.isNotEmpty) ...[
            const SizedBox(width: 3),
            Text(
              label!,
              style: AppTypography.labelSmall.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReactionPicker extends StatelessWidget {
  const _ReactionPicker({required this.emojis, required this.onSelect});

  final List<String> emojis;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xl),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: emojis
              .map(
                (e) => GestureDetector(
                  onTap: () => onSelect(e),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text(e, style: const TextStyle(fontSize: 32)),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
