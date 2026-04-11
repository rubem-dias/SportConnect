import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../infrastructure/chat_websocket_service.dart';
import '../local/chat_local_cache.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    wsService: ref.watch(chatWebSocketServiceProvider),
  );
});

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.apiClient,
    required this.wsService,
  }) {
    _subscribeToWs();
  }

  final ApiClient apiClient;
  final ChatWebSocketService wsService;

  final _incomingCtrl =
      StreamController<ChatMessageModel>.broadcast();
  final _typingCtrl = StreamController<TypingEvent>.broadcast();

  void _subscribeToWs() {
    wsService.messageStream.listen((payload) {
      try {
        final msg = ChatMessageModel.fromJson(
            Map<String, dynamic>.from(payload));
        _incomingCtrl.add(msg);
        ChatLocalCache.appendMessage(msg.conversationId, msg);
      } catch (_) {}
    });

    wsService.typingStream.listen((payload) {
      try {
        _typingCtrl.add(TypingEvent(
          conversationId: payload['conversationId']?.toString() ?? '',
          userId: payload['userId']?.toString() ?? '',
          userName: payload['userName']?.toString() ?? '',
          isTyping: payload['isTyping'] == true,
        ));
      } catch (_) {}
    });
  }

  @override
  Future<List<ConversationModel>> fetchConversations() async {
    try {
      final res =
          await apiClient.dio.get<dynamic>(ApiEndpoints.conversations);
      final list = (res.data as List? ?? [])
          .whereType<Map>()
          .map((m) => ConversationModel.fromJson(
              Map<String, dynamic>.from(m)))
          .toList();
      await ChatLocalCache.cacheConversations(list);
      return list;
    } catch (_) {
      final cached = await ChatLocalCache.getConversations();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<ChatMessageModel>> fetchMessages(
    String conversationId, {
    String? cursor,
    int limit = 30,
  }) async {
    try {
      final res = await apiClient.dio.get<dynamic>(
        ApiEndpoints.conversationMessages(conversationId),
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      final list = (res.data as List? ?? [])
          .whereType<Map>()
          .map((m) => ChatMessageModel.fromJson(
              Map<String, dynamic>.from(m)))
          .toList();
      if (cursor == null) {
        await ChatLocalCache.cacheMessages(conversationId, list);
      }
      return list;
    } catch (_) {
      final cached = await ChatLocalCache.getMessages(conversationId);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
  }) async {
    final res = await apiClient.dio.post<dynamic>(
      ApiEndpoints.conversationMessages(conversationId),
      data: {
        'content': content,
        'type': type.name,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      },
    );
    return ChatMessageModel.fromJson(
        Map<String, dynamic>.from(res.data as Map? ?? {}));
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    await apiClient.dio.post<void>(
      '${ApiEndpoints.conversationsById(conversationId)}/read',
    );
  }

  @override
  Future<void> sendTyping(
    String conversationId, {
    required bool isTyping,
  }) async {
    wsService.send(WsEvent(
      type: WsEventType.typing,
      conversationId: conversationId,
      payload: {'isTyping': isTyping},
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<void> addReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
  }) async {
    await apiClient.dio.post<void>(
      '${ApiEndpoints.conversationsById(conversationId)}/messages/$messageId/reactions',
      data: {'emoji': emoji},
    );
  }

  @override
  Stream<ChatMessageModel> get incomingMessages => _incomingCtrl.stream;

  @override
  Stream<TypingEvent> get typingEvents => _typingCtrl.stream;

  @override
  Stream<ConnectionStatus> get connectionStatus =>
      wsService.connectionStream;

  @override
  void dispose() {
    _incomingCtrl.close();
    _typingCtrl.close();
  }
}
