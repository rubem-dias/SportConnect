import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/chat_message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message, required this.isMe, required this.showSenderName, super.key,
    this.onLongPress,
    this.onSwipeReply,
  });

  final ChatMessageModel message;
  final bool isMe;
  final bool showSenderName;
  final VoidCallback? onLongPress;
  final VoidCallback? onSwipeReply;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          margin: EdgeInsets.only(
            left: isMe ? AppSpacing.xl : AppSpacing.lg,
            right: isMe ? AppSpacing.lg : AppSpacing.xl,
            bottom: AppSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (showSenderName && !isMe)
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppSpacing.sm, bottom: 2),
                  child: Text(
                    message.senderName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: isMe
                      ? (isDark
                          ? AppColors.chatBubbleMeDark
                          : AppColors.chatBubbleMe)
                      : (isDark
                          ? AppColors.chatBubbleOtherDark
                          : AppColors.chatBubbleOther),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.replyToContent != null)
                      _ReplyPreview(
                        senderName: message.replyToSenderName ?? '',
                        content: message.replyToContent!,
                        isMe: isMe,
                        isDark: isDark,
                      ),
                    if (message.type == MessageType.pr)
                      _PRAttachment(
                        exercise: message.prExercise ?? '',
                        value: message.prValue ?? '',
                        unit: message.prUnit ?? '',
                        isMe: isMe,
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 8, 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(message.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: isMe
                                  ? Colors.white60
                                  : (isDark
                                      ? AppColors.textDisabledDark
                                      : AppColors.textDisabledLight),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _StatusIcon(status: message.status),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (message.reactions.isNotEmpty)
                _ReactionsRow(reactions: message.reactions, isMe: isMe),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({
    required this.senderName,
    required this.content,
    required this.isMe,
    required this.isDark,
  });

  final String senderName;
  final String content;
  final bool isMe;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withAlpha(40)
            : (isDark
                ? AppColors.primary.withAlpha(40)
                : AppColors.primary.withAlpha(20)),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            senderName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isMe ? Colors.white70 : AppColors.primary,
            ),
          ),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: isMe
                  ? Colors.white60
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PRAttachment extends StatelessWidget {
  const _PRAttachment({
    required this.exercise,
    required this.value,
    required this.unit,
    required this.isMe,
  });

  final String exercise;
  final String value;
  final String unit;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.prGreen.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.prGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isMe ? Colors.white : AppColors.prGreen,
                ),
              ),
              Text(
                '$value $unit — Novo PR!',
                style: TextStyle(
                  fontSize: 12,
                  color: isMe ? Colors.white70 : AppColors.prGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white60,
          ),
        );
      case MessageStatus.sent:
        return const Icon(Icons.done, size: 14, color: Colors.white60);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 14, color: Colors.white);
    }
  }
}

class _ReactionsRow extends StatelessWidget {
  const _ReactionsRow({required this.reactions, required this.isMe});

  final Map<String, int> reactions;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        left: isMe ? 0 : AppSpacing.sm,
        right: isMe ? AppSpacing.sm : 0,
      ),
      child: Wrap(
        spacing: 4,
        children: reactions.entries.map((e) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              '${e.key} ${e.value}',
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DateSeparator extends StatelessWidget {
  const DateSeparator({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final isToday = date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
    final isYesterday = date.day == now.subtract(const Duration(days: 1)).day &&
        date.month == now.subtract(const Duration(days: 1)).month &&
        date.year == now.subtract(const Duration(days: 1)).year;

    final label = isToday
        ? 'Hoje'
        : isYesterday
            ? 'Ontem'
            : DateFormat('dd/MM/yyyy').format(date);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
