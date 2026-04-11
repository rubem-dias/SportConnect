import '../../data/models/chat_message_model.dart';
import '../../data/models/conversation_model.dart';

enum ConnectionStatus { connected, reconnecting, offline }

class TypingEvent {
  const TypingEvent({
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.isTyping,
  });

  final String conversationId;
  final String userId;
  final String userName;
  final bool isTyping;
}

abstract class ChatRepository {
  // ── Conversations ────────────────────────────────────────────────────────
  Future<List<ConversationModel>> fetchConversations();

  // ── Messages ─────────────────────────────────────────────────────────────
  Future<List<ChatMessageModel>> fetchMessages(
    String conversationId, {
    String? cursor,
    int limit = 30,
  });

  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
  });

  Future<void> markAsRead(String conversationId);

  // ── Real-time ─────────────────────────────────────────────────────────────
  Future<void> sendTyping(String conversationId, {required bool isTyping});

  Future<void> addReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
  });

  // ── Streams ───────────────────────────────────────────────────────────────
  Stream<ChatMessageModel> get incomingMessages;
  Stream<TypingEvent> get typingEvents;
  Stream<ConnectionStatus> get connectionStatus;

  void dispose();
}
