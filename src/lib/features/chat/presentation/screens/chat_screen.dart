import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_loading_skeleton.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/conversation_model.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  final String conversationId;
  final ConversationModel? conversation;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(chatProvider(widget.conversationId).notifier)
          .loadMoreMessages();
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    if (animated) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatAsync = ref.watch(chatProvider(widget.conversationId));

    // Scroll ao chegar nova mensagem
    ref.listen(chatProvider(widget.conversationId), (prev, next) {
      final prevCount = prev?.valueOrNull?.messages.length ?? 0;
      final nextCount = next.valueOrNull?.messages.length ?? 0;
      if (nextCount > prevCount) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 40,
        titleSpacing: 0,
        title: _ChatAppBarTitle(
          conversation: widget.conversation,
          conversationId: widget.conversationId,
          isDark: isDark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () {},
            color: AppColors.primary,
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () {},
            color: AppColors.primary,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
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
      body: chatAsync.when(
        loading: () => const _ChatSkeleton(),
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
                onPressed: () => ref.invalidate(
                    chatProvider(widget.conversationId)),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (state) => Column(
          children: [
            Expanded(
              child: _MessageList(
                state: state,
                scrollController: _scrollController,
                conversationId: widget.conversationId,
              ),
            ),
            TypingIndicator(userNames: state.typingUsers),
            ChatInputBar(
              replyTo: state.replyTo,
              onCancelReply: () => ref
                  .read(chatProvider(widget.conversationId).notifier)
                  .setReply(null),
              onSend: (content) {
                ref
                    .read(chatProvider(widget.conversationId).notifier)
                    .sendMessage(content);
              },
              onTypingChanged: (isTyping) {
                ref
                    .read(chatProvider(widget.conversationId).notifier)
                    .sendTypingIndicator(isTyping: isTyping);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends ConsumerWidget {
  const _MessageList({
    required this.state,
    required this.scrollController,
    required this.conversationId,
  });

  final ChatState state;
  final ScrollController scrollController;
  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = state.messages;

    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma mensagem ainda.\nDiga olá! 👋',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textDisabledLight),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.only(
          top: AppSpacing.md, bottom: AppSpacing.sm),
      itemCount: messages.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        // Lista invertida: index 0 = mais recente
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex];
        final isMe = message.senderId == 'me';

        // Separador de data
        final showDateSeparator = reversedIndex == 0 ||
            !_isSameDay(
              messages[reversedIndex - 1].createdAt,
              message.createdAt,
            );

        // Mostra nome do remetente em grupos ou quando muda de usuário
        final prevMsg =
            reversedIndex > 0 ? messages[reversedIndex - 1] : null;
        final showSenderName = !isMe &&
            (prevMsg == null || prevMsg.senderId != message.senderId);

        return Column(
          children: [
            if (showDateSeparator)
              DateSeparator(date: message.createdAt),
            GestureDetector(
              // Swipe direita para responder
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! > 300) {
                  ref
                      .read(chatProvider(conversationId).notifier)
                      .setReply(message);
                }
              },
              child: MessageBubble(
                message: message,
                isMe: isMe,
                showSenderName: showSenderName,
                onLongPress: () =>
                    _showMessageOptions(context, ref, message),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showMessageOptions(
    BuildContext context,
    WidgetRef ref,
    ChatMessageModel message,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reactions rápidas
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['❤️', '🔥', '💪', '🏆', '😂', '👍'].map((e) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ref
                          .read(chatProvider(conversationId).notifier);
                      // TODO: addReaction
                    },
                    child: Text(e, style: const TextStyle(fontSize: 28)),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Responder'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(chatProvider(conversationId).notifier)
                    .setReply(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy_rounded),
              title: const Text('Copiar'),
              onTap: () => Navigator.pop(context),
            ),
            if (message.senderId == 'me')
              ListTile(
                leading: const Icon(Icons.delete_rounded,
                    color: AppColors.error),
                title: const Text('Apagar',
                    style: TextStyle(color: AppColors.error)),
                onTap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatAppBarTitle extends StatelessWidget {
  const _ChatAppBarTitle({
    required this.conversation,
    required this.conversationId,
    required this.isDark,
  });

  final ConversationModel? conversation;
  final String conversationId;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final name = conversation?.name ?? conversationId;
    final isOnline = conversation?.isOnline ?? false;
    final isGroup = conversation?.type == ConversationType.group ||
        conversation?.type == ConversationType.channel;

    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withAlpha(40),
              backgroundImage: conversation?.avatar != null
                  ? NetworkImage(conversation!.avatar!)
                  : null,
              child: conversation?.avatar == null
                  ? Icon(
                      isGroup
                          ? Icons.group_rounded
                          : Icons.person_rounded,
                      color: AppColors.primary,
                      size: 18,
                    )
                  : null,
            ),
            if (isOnline && !isGroup)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isOnline && !isGroup)
                const Text(
                  'online',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.online,
                  ),
                )
              else if (isGroup &&
                  conversation != null &&
                  conversation!.members.isNotEmpty)
                Text(
                  '${conversation!.members.length} membros',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatSkeleton extends StatelessWidget {
  const _ChatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: 8,
            itemBuilder: (_, index) {
              final isMe = index % 3 == 0;
              return Align(
                alignment:
                    isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppLoadingSkeleton(
                    width: 180 + (index % 3) * 30,
                    height: 44,
                    borderRadius: 18,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
