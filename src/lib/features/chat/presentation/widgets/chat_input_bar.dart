import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/chat_message_model.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSend, required this.onTypingChanged, super.key,
    this.replyTo,
    this.onCancelReply,
  });

  final ValueChanged<String> onSend;
  final ValueChanged<bool> onTypingChanged;
  final ChatMessageModel? replyTo;
  final VoidCallback? onCancelReply;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _wasTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);

    final isTyping = _controller.text.isNotEmpty;
    if (isTyping != _wasTyping) {
      _wasTyping = isTyping;
      widget.onTypingChanged(isTyping);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
    widget.onTypingChanged(false);
    _wasTyping = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.replyTo != null) _ReplyBar(
            message: widget.replyTo!,
            onCancel: widget.onCancelReply ?? () {},
            isDark: isDark,
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color:
                      isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Botão de mídia
                IconButton(
                  onPressed: () {}, // TODO(rubem): abrir picker de arquivos.
                  icon: const Icon(Icons.attach_file_rounded),
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Campo de texto
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mensagem',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Botão enviar / áudio
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasText
                      ? _SendButton(onTap: _send)
                      : _AudioButton(onTap: () {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyBar extends StatelessWidget {
  const _ReplyBar({
    required this.message,
    required this.onCancel,
    required this.isDark,
  });

  final ChatMessageModel message;
  final VoidCallback onCancel;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
              color:
                  isDark ? AppColors.borderDark : AppColors.borderLight),
          left: const BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded),
            iconSize: 18,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: const ValueKey('send'),
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _AudioButton extends StatelessWidget {
  const _AudioButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: const ValueKey('audio'),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.mic_rounded,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          size: 22,
        ),
      ),
    );
  }
}
