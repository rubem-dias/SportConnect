import 'package:hive_flutter/hive_flutter.dart';

import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

class ChatLocalCache {
  static const _conversationsBox = 'chat_conversations';
  static const _messagesBoxPrefix = 'chat_messages_';

  static Future<Box<dynamic>> _openBox(String name) async {
    return Hive.isBoxOpen(name)
        ? Hive.box<dynamic>(name)
        : await Hive.openBox<dynamic>(name);
  }

  // ── Conversations ─────────────────────────────────────────────────────────

  static Future<void> cacheConversations(
      List<ConversationModel> conversations) async {
    final box = await _openBox(_conversationsBox);
    await box.put(
      'list',
      conversations.map((c) => c.toJson()).toList(),
    );
  }

  static Future<List<ConversationModel>?> getConversations() async {
    final box = await _openBox(_conversationsBox);
    final raw = box.get('list');
    if (raw is! List) return null;
    return raw
        .whereType<Map>()
        .map((m) =>
            ConversationModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  static String _msgBox(String conversationId) =>
      '$_messagesBoxPrefix$conversationId';

  static Future<void> cacheMessages(
    String conversationId,
    List<ChatMessageModel> messages,
  ) async {
    final box = await _openBox(_msgBox(conversationId));
    await box.put(
      'messages',
      messages.map((m) => m.toJson()).toList(),
    );
  }

  static Future<List<ChatMessageModel>?> getMessages(
      String conversationId) async {
    final box = await _openBox(_msgBox(conversationId));
    final raw = box.get('messages');
    if (raw is! List) return null;
    return raw
        .whereType<Map>()
        .map((m) => ChatMessageModel.fromJson(
            Map<String, dynamic>.from(m)))
        .toList();
  }

  static Future<void> appendMessage(
    String conversationId,
    ChatMessageModel message,
  ) async {
    final existing = await getMessages(conversationId) ?? [];
    final updated = [...existing, message];
    await cacheMessages(conversationId, updated);
  }
}
