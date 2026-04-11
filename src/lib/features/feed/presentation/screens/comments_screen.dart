import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/post_model.dart';

// ---- Provider ----

final commentsProvider = FutureProvider.family<List<CommentModel>, String>(
  (ref, postId) async {
    final client = ref.read(apiClientProvider);
    try {
      final response =
          await client.dio.get<dynamic>(ApiEndpoints.postComments(postId));
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((m) =>
                CommentModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } catch (_) {
      return _mockComments(postId);
    }
  },
);

List<CommentModel> _mockComments(String postId) => [
      CommentModel(
        id: 'c1',
        postId: postId,
        userId: 'u2',
        content: 'Incrível! Continua assim 💪',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        userName: 'Maria Silva',
      ),
      CommentModel(
        id: 'c2',
        postId: postId,
        userId: 'u3',
        content: 'Que evolução! Qual protocolo você está seguindo?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        userName: 'João Santos',
      ),
      CommentModel(
        id: 'c3',
        postId: postId,
        userId: 'u4',
        content: 'Arrasou! 🔥🔥🔥',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        userName: 'Ana Costa',
        replyToId: 'c1',
        replyToUserName: 'Maria Silva',
      ),
    ];

// ---- Screen ----

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({required this.post, super.key});

  final PostModel post;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollCtrl = ScrollController();

  CommentModel? _replyingTo;
  bool _isSending = false;

  // Optimistic local comments
  final List<CommentModel> _localComments = [];

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final optimistic = CommentModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      userId: 'me',
      content: text,
      createdAt: DateTime.now(),
      userName: 'Você',
      replyToId: _replyingTo?.id,
      replyToUserName: _replyingTo?.userName,
    );

    setState(() {
      _localComments.add(optimistic);
      _replyingTo = null;
      _textCtrl.clear();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post<dynamic>(
        ApiEndpoints.postComments(widget.post.id),
        data: {
          'content': text,
          if (_replyingTo != null) 'replyToId': _replyingTo!.id,
        },
      );
      // Invalidate to refresh from server
      ref.invalidate(commentsProvider(widget.post.id));
    } catch (_) {
      // Keep optimistic comment for offline
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startReply(CommentModel comment) {
    setState(() => _replyingTo = comment);
    _focusNode.requestFocus();
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commentsAsync = ref.watch(commentsProvider(widget.post.id));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Comentários',
          style: AppTypography.titleMedium,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      body: Column(
        children: [
          // Comments list
          Expanded(
            child: commentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                child: Text('Erro ao carregar comentários'),
              ),
              data: (serverComments) {
                final all = [...serverComments, ..._localComments];
                if (all.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('💬', style: TextStyle(fontSize: 40)),
                        SizedBox(height: AppSpacing.md),
                        Text('Seja o primeiro a comentar!'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: all.length,
                  itemBuilder: (_, i) => _CommentTile(
                    comment: all[i],
                    isDark: isDark,
                    onReply: () => _startReply(all[i]),
                  ),
                );
              },
            ),
          ),

          // Reply banner
          if (_replyingTo != null)
            _ReplyBanner(
              userName: _replyingTo!.userName ?? 'Usuário',
              onCancel: () => setState(() => _replyingTo = null),
            ),

          // Input bar
          _CommentInput(
            controller: _textCtrl,
            focusNode: _focusNode,
            isSending: _isSending,
            onSend: _sendComment,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ---- Comment Tile ----

class _CommentTile extends StatefulWidget {
  const _CommentTile({
    required this.comment,
    required this.isDark,
    required this.onReply,
  });

  final CommentModel comment;
  final bool isDark;
  final VoidCallback onReply;

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _showReactions = false;

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final textSecondary = widget.isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() => _showReactions = !_showReactions);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(
              imageUrl: comment.userAvatar,
              name: comment.userName ?? 'U',
              size: AppAvatarSize.xs,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reply context
                  if (comment.replyToUserName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'Respondendo a @${comment.replyToUserName}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                    ),

                  // Bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.userName ?? 'Usuário',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _HashtagText(content: comment.content),
                      ],
                    ),
                  ),

                  // Inline reaction picker
                  if (_showReactions)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: _InlineReactionPicker(
                        onSelect: (e) => setState(() => _showReactions = false),
                      ),
                    ),

                  // Actions row
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Row(
                      children: [
                        Text(
                          _relativeTime(comment.createdAt),
                          style: AppTypography.labelSmall
                              .copyWith(color: textSecondary, fontSize: 11),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        GestureDetector(
                          onTap: widget.onReply,
                          child: Text(
                            'Responder',
                            style: AppTypography.labelSmall.copyWith(
                              color: textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (comment.reactions.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          ...comment.reactions.entries
                              .where((e) => e.value > 0)
                              .map((e) => Text(
                                    '${e.key} ${e.value}',
                                    style: const TextStyle(fontSize: 12),
                                  )),
                        ],
                      ],
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

// ---- Hashtag/Mention rich text ----

class _HashtagText extends StatelessWidget {
  const _HashtagText({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    final parts = _parse(content);
    return RichText(
      text: TextSpan(
        children: parts.map((p) {
          final isTag = p.startsWith('#') || p.startsWith('@');
          return TextSpan(
            text: p,
            style: AppTypography.bodyMedium.copyWith(
              color: isTag ? AppColors.primary : null,
              fontWeight: isTag ? FontWeight.w600 : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<String> _parse(String text) {
    final regex = RegExp(r'([#@][a-zA-ZÀ-ÿ0-9_]+)');
    final parts = <String>[];
    var lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        parts.add(text.substring(lastEnd, match.start));
      }
      parts.add(match.group(0)!);
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      parts.add(text.substring(lastEnd));
    }

    return parts;
  }
}

// ---- Reply banner ----

class _ReplyBanner extends StatelessWidget {
  const _ReplyBanner({required this.userName, required this.onCancel});

  final String userName;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.primary.withOpacity(0.08),
      child: Row(
        children: [
          const Icon(Icons.reply_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Respondendo a @$userName',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            onPressed: onCancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ---- Comment Input ----

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
    required this.isDark,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.sm,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm +
              MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Adicionar comentário...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariantLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: onSend,
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.primary,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Inline Reaction Picker ----

class _InlineReactionPicker extends StatelessWidget {
  const _InlineReactionPicker({required this.onSelect});

  final void Function(String) onSelect;

  static const _emojis = ['❤️', '🔥', '💪', '🏆', '👏', '😮'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _emojis
            .map((e) => GestureDetector(
                  onTap: () => onSelect(e),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
