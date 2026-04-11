import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/conversation_model.dart';

// Default members used when none are passed (mock).
const _defaultMembers = [
  ConversationMember(userId: 'u1', name: 'Mateus Corrêa'),
  ConversationMember(userId: 'u2', name: 'Fernanda Lima'),
  ConversationMember(userId: 'u3', name: 'Rafael Souza'),
  ConversationMember(userId: 'u4', name: 'Camila Rocha'),
  ConversationMember(userId: 'all', name: 'todos'),
];

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSend,
    required this.onTypingChanged,
    super.key,
    this.replyTo,
    this.onCancelReply,
    this.members,
  });

  final ValueChanged<String> onSend;
  final ValueChanged<bool> onTypingChanged;
  final ChatMessageModel? replyTo;
  final VoidCallback? onCancelReply;
  /// Members for @mention suggestions. When null, a mock list is used.
  final List<ConversationMember>? members;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _wasTyping = false;

  // @mention state
  List<ConversationMember> _mentionSuggestions = [];

  List<ConversationMember> get _allMembers =>
      widget.members ?? _defaultMembers;

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

    _updateMentionSuggestions();
  }

  void _updateMentionSuggestions() {
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;
    if (cursor < 0) {
      setState(() { _mentionSuggestions = []; });
      return;
    }
    final before = text.substring(0, cursor);
    // Find last @ before cursor on the same word
    final atIndex = before.lastIndexOf('@');
    if (atIndex < 0) {
      setState(() { _mentionSuggestions = []; });
      return;
    }
    final partial = before.substring(atIndex + 1);
    // Only show if no space in partial (still in the same word)
    if (partial.contains(' ')) {
      setState(() { _mentionSuggestions = []; });
      return;
    }
    final q = partial.toLowerCase();
    final matches = _allMembers
        .where((m) => m.name.toLowerCase().contains(q))
        .toList();
    setState(() {
      _mentionSuggestions = matches;
    });
  }

  void _insertMention(ConversationMember member) {
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;
    if (cursor < 0) return;

    final before = text.substring(0, cursor);
    final after = text.substring(cursor);
    final atIndex = before.lastIndexOf('@');
    if (atIndex < 0) return;

    final mention = '@${member.name} ';
    final newText = text.substring(0, atIndex) + mention + after;
    final newCursor = atIndex + mention.length;

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor),
    );

    setState(() { _mentionSuggestions = []; });
    _focusNode.requestFocus();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
    widget.onTypingChanged(false);
    _wasTyping = false;
    setState(() { _mentionSuggestions = []; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_mentionSuggestions.isNotEmpty)
            _MentionSuggestions(
              suggestions: _mentionSuggestions,
              onTap: _insertMention,
              isDark: isDark,
            ),
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
                Semantics(
                  label: 'Anexar arquivo',
                  button: true,
                  child: IconButton(
                    onPressed: () {}, // TODO(rubem): abrir picker de arquivos.
                    icon: const Icon(Icons.attach_file_rounded),
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
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
    return Semantics(
      label: 'Enviar mensagem',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          key: const ValueKey('send'),
          width: 44,
          height: 44,
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
      ),
    );
  }
}

class _MentionSuggestions extends StatelessWidget {
  const _MentionSuggestions({
    required this.suggestions,
    required this.onTap,
    required this.isDark,
  });

  final List<ConversationMember> suggestions;
  final ValueChanged<ConversationMember> onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final member = suggestions[index];
          return InkWell(
            onTap: () => onTap(member),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withAlpha(40),
                    child: Text(
                      member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : '@',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '@${member.name}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
    return Semantics(
      label: 'Gravar áudio',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          key: const ValueKey('audio'),
          width: 44,
          height: 44,
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
      ),
    );
  }
}
