import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/mock_chat_repository.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../domain/repositories/chat_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────────

/// Troque por [chatRepositoryProvider] (impl real) quando o backend estiver pronto.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repo = MockChatRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

// ── Connection status ─────────────────────────────────────────────────────────

final chatConnectionStatusProvider =
    StreamProvider<ConnectionStatus>((ref) {
  return ref.watch(chatRepositoryProvider).connectionStatus;
});

// ── Conversations list ────────────────────────────────────────────────────────

class ConversationsNotifier
    extends AsyncNotifier<List<ConversationModel>> {
  @override
  Future<List<ConversationModel>> build() {
    return ref.read(chatRepositoryProvider).fetchConversations();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(chatRepositoryProvider).fetchConversations(),
    );
  }

  /// Atualiza a última mensagem de uma conversa em tempo real.
  void updateLastMessage(ChatMessageModel msg) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.map((c) {
        if (c.id != msg.conversationId) return c;
        return c.copyWith(
          lastMessage: msg.content,
          lastMessageAt: msg.createdAt,
          unreadCount: msg.senderId == 'me'
              ? 0
              : c.unreadCount + 1,
        );
      }).toList()
        ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt)),
    );
  }

  void markRead(String conversationId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current
          .map((c) =>
              c.id == conversationId ? c.copyWith(unreadCount: 0) : c)
          .toList(),
    );
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationModel>>(
  ConversationsNotifier.new,
);

// ── Chat screen (messages) ────────────────────────────────────────────────────

class ChatState {
  const ChatState({
    required this.messages,
    required this.isLoadingMore,
    this.hasMore = true,
    this.replyTo,
    this.typingUsers = const [],
  });

  final List<ChatMessageModel> messages;
  final bool isLoadingMore;
  final bool hasMore;
  final ChatMessageModel? replyTo;
  final List<String> typingUsers;

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isLoadingMore,
    bool? hasMore,
    ChatMessageModel? replyTo,
    bool clearReply = false,
    List<String>? typingUsers,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      replyTo: clearReply ? null : (replyTo ?? this.replyTo),
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }
}

class ChatNotifier extends AutoDisposeFamilyAsyncNotifier<ChatState, String> {
  late StreamSubscription<ChatMessageModel> _msgSub;
  late StreamSubscription<TypingEvent> _typingSub;

  @override
  Future<ChatState> build(String conversationId) async {
    final repo = ref.read(chatRepositoryProvider);

    final messages = await repo.fetchMessages(conversationId);

    _msgSub = repo.incomingMessages.listen((msg) {
      if (msg.conversationId != conversationId) return;
      _onNewMessage(msg);
    });

    _typingSub = repo.typingEvents.listen((event) {
      if (event.conversationId != conversationId) return;
      _onTyping(event);
    });

    ref.onDispose(() {
      _msgSub.cancel();
      _typingSub.cancel();
    });

    await repo.markAsRead(conversationId);

    return ChatState(
      messages: messages,
      isLoadingMore: false,
    );
  }

  void _onNewMessage(ChatMessageModel msg) {
    final current = state.valueOrNull;
    if (current == null) return;

    // Se for confirmação de leitura de mensagem própria, atualiza status
    final existingIndex =
        current.messages.indexWhere((m) => m.id == msg.id);
    if (existingIndex >= 0) {
      final updated = List<ChatMessageModel>.from(current.messages);
      updated[existingIndex] = msg;
      state = AsyncData(current.copyWith(messages: updated));
    } else {
      state = AsyncData(
        current.copyWith(messages: [...current.messages, msg]),
      );
    }

    // Atualiza a lista de conversas
    ref.read(conversationsProvider.notifier).updateLastMessage(msg);
  }

  void _onTyping(TypingEvent event) {
    final current = state.valueOrNull;
    if (current == null) return;
    final users = List<String>.from(current.typingUsers);
    if (event.isTyping && !users.contains(event.userName)) {
      users.add(event.userName);
    } else if (!event.isTyping) {
      users.remove(event.userName);
    }
    state = AsyncData(current.copyWith(typingUsers: users));
  }

  Future<void> sendMessage(String content) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Optimistic: adiciona mensagem com status "sending"
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessageModel(
      id: tempId,
      conversationId: arg,
      senderId: 'me',
      senderName: 'Você',
      content: content,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
      isPending: true,
      replyToMessageId: current.replyTo?.id,
      replyToContent: current.replyTo?.content,
      replyToSenderName: current.replyTo?.senderName,
    );

    state = AsyncData(
      current.copyWith(
        messages: [...current.messages, optimistic],
        clearReply: true,
      ),
    );

    try {
      final sent = await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: arg,
            content: content,
            replyToMessageId: current.replyTo?.id,
          );

      // Substitui o optimistic pelo confirmado
      final msgs = state.valueOrNull?.messages ?? [];
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          messages: msgs
              .map((m) => m.id == tempId ? sent : m)
              .toList(),
        ),
      );

      ref.read(conversationsProvider.notifier).updateLastMessage(sent);
    } catch (_) {
      // Marca como pendente (falhou)
      final msgs = state.valueOrNull?.messages ?? [];
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          messages: msgs
              .map((m) => m.id == tempId
                  ? m.copyWith(status: MessageStatus.sending, isPending: true)
                  : m)
              .toList(),
        ),
      );
    }
  }

  Future<void> loadMoreMessages() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final oldest =
          current.messages.isNotEmpty ? current.messages.first.id : null;
      final older = await ref
          .read(chatRepositoryProvider)
          .fetchMessages(arg, cursor: oldest);

      state = AsyncData(
        current.copyWith(
          messages: [...older, ...current.messages],
          isLoadingMore: false,
          hasMore: older.isNotEmpty,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  void setReply(ChatMessageModel? message) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      message != null
          ? current.copyWith(replyTo: message)
          : current.copyWith(clearReply: true),
    );
  }

  Future<void> sendTypingIndicator({required bool isTyping}) async {
    await ref
        .read(chatRepositoryProvider)
        .sendTyping(arg, isTyping: isTyping);
  }
}

final chatProvider = AsyncNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, String>(ChatNotifier.new);
