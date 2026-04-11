import 'dart:async';
import 'dart:math';

import '../../features/chat/data/models/chat_message_model.dart';
import '../../features/chat/data/models/conversation_model.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  MockChatRepository() {
    // Simula mensagem recebida 3s após inicializar
    Future<void>.delayed(const Duration(seconds: 3), _simulateIncoming);
  }

  final _incomingCtrl =
      StreamController<ChatMessageModel>.broadcast();
  final _typingCtrl = StreamController<TypingEvent>.broadcast();
  final _connectionCtrl =
      StreamController<ConnectionStatus>.broadcast();

  final _conversationsData = _buildConversations();
  final _messagesData = _buildAllMessages();

  @override
  Future<List<ConversationModel>> fetchConversations() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _conversationsData;
  }

  @override
  Future<List<ChatMessageModel>> fetchMessages(
    String conversationId, {
    String? cursor,
    int limit = 30,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final all = _messagesData[conversationId] ?? [];
    if (cursor != null) {
      final idx = all.indexWhere((m) => m.id == cursor);
      if (idx > 0) return all.sublist(max(0, idx - limit), idx);
      return [];
    }
    return all.length > limit ? all.sublist(all.length - limit) : all;
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final msg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'me',
      senderName: 'Você',
      content: content,
      type: type,
      replyToMessageId: replyToMessageId,
      createdAt: DateTime.now(),
    );

    // Atualiza lista local
    _messagesData.putIfAbsent(conversationId, () => []).add(msg);

    // Simula confirmação de leitura após 2s
    Future<void>.delayed(const Duration(seconds: 2), () {
      final read = msg.copyWith(status: MessageStatus.read);
      _incomingCtrl.add(read);
    });

    return msg;
  }

  @override
  Future<void> markAsRead(String conversationId) async {}

  @override
  Future<void> sendTyping(
    String conversationId, {
    required bool isTyping,
  }) async {}

  @override
  Future<void> addReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
  }) async {}

  @override
  Stream<ChatMessageModel> get incomingMessages => _incomingCtrl.stream;

  @override
  Stream<TypingEvent> get typingEvents => _typingCtrl.stream;

  @override
  Stream<ConnectionStatus> get connectionStatus => _connectionCtrl.stream;

  @override
  void dispose() {
    _incomingCtrl.close();
    _typingCtrl.close();
    _connectionCtrl.close();
  }

  // ── Simulações ────────────────────────────────────────────────────────────

  Future<void> _simulateIncoming() async {
    // Simula "digitando" na conversa conv1
    _typingCtrl.add(const TypingEvent(
      conversationId: 'conv1',
      userId: 'u1',
      userName: 'Mateus Corrêa',
      isTyping: true,
    ));

    await Future<void>.delayed(const Duration(seconds: 2));

    _typingCtrl.add(const TypingEvent(
      conversationId: 'conv1',
      userId: 'u1',
      userName: 'Mateus Corrêa',
      isTyping: false,
    ));

    final msg = ChatMessageModel(
      id: 'msg_incoming_1',
      conversationId: 'conv1',
      senderId: 'u1',
      senderName: 'Mateus Corrêa',
      content: 'Bora treinar amanhã cedo? 💪',
      createdAt: DateTime.now(),
    );

    _messagesData['conv1']?.add(msg);
    _incomingCtrl.add(msg);
  }

  // ── Mock data ─────────────────────────────────────────────────────────────

  static List<ConversationModel> _buildConversations() {
    final now = DateTime.now();
    return [
      ConversationModel(
        id: 'conv1',
        name: 'Mateus Corrêa',
        lastMessage: 'Que treino fez hoje?',
        lastMessageAt: now.subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isOnline: true,
        members: const [
          ConversationMember(
              userId: 'u1', name: 'Mateus Corrêa', isOnline: true),
        ],
      ),
      ConversationModel(
        id: 'conv2',
        type: ConversationType.group,
        name: 'CrossFit Turma A',
        lastMessage: 'Rafael: PR no clean! 110kg 🏆',
        lastMessageAt: now.subtract(const Duration(hours: 1)),
        unreadCount: 7,
        members: const [
          ConversationMember(userId: 'u2', name: 'Rafael Souza'),
          ConversationMember(userId: 'u3', name: 'Camila Rocha'),
          ConversationMember(userId: 'u4', name: 'João Victor'),
        ],
      ),
      ConversationModel(
        id: 'conv3',
        name: 'Fernanda Lima',
        lastMessage: 'Valeu pela dica de suplementação!',
        lastMessageAt: now.subtract(const Duration(hours: 3)),
        members: const [
          ConversationMember(userId: 'u5', name: 'Fernanda Lima'),
        ],
      ),
      ConversationModel(
        id: 'conv4',
        type: ConversationType.channel,
        name: 'SportConnect Oficial',
        lastMessage: 'Nova feature: Stories chegando! 🚀',
        lastMessageAt: now.subtract(const Duration(hours: 6)),
        unreadCount: 1,
      ),
      ConversationModel(
        id: 'conv5',
        type: ConversationType.group,
        name: 'Maratona SP 2025',
        lastMessage: 'Eu: Rota de treino para domingo enviada 🗺️',
        lastMessageAt: now.subtract(const Duration(days: 1)),
        members: const [
          ConversationMember(userId: 'u6', name: 'Ana Paula'),
          ConversationMember(userId: 'u7', name: 'Bruno Alves'),
        ],
      ),
    ];
  }

  static Map<String, List<ChatMessageModel>> _buildAllMessages() {
    final now = DateTime.now();

    return {
      'conv1': [
        ChatMessageModel(
          id: 'm1_1',
          conversationId: 'conv1',
          senderId: 'u1',
          senderName: 'Mateus Corrêa',
          content: 'E aí, bora na academia hoje?',
          status: MessageStatus.read,
          createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        ),
        ChatMessageModel(
          id: 'm1_2',
          conversationId: 'conv1',
          senderId: 'me',
          senderName: 'Você',
          content: 'Sim! Vou às 18h. Tu vai?',
          status: MessageStatus.read,
          createdAt: now.subtract(const Duration(hours: 2, minutes: 20)),
        ),
        ChatMessageModel(
          id: 'm1_3',
          conversationId: 'conv1',
          senderId: 'u1',
          senderName: 'Mateus Corrêa',
          content: 'Pode ser. Vou terminar o trabalho e apareço',
          status: MessageStatus.read,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        ChatMessageModel(
          id: 'm1_4',
          conversationId: 'conv1',
          senderId: 'u1',
          senderName: 'Mateus Corrêa',
          content: 'Que treino fez hoje?',
          createdAt: now.subtract(const Duration(minutes: 5)),
        ),
      ],
      'conv2': [
        ChatMessageModel(
          id: 'm2_1',
          conversationId: 'conv2',
          senderId: 'u2',
          senderName: 'Rafael Souza',
          content: 'Galera, treino hoje foi pesado! 🔥',
          status: MessageStatus.read,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        ChatMessageModel(
          id: 'm2_2',
          conversationId: 'conv2',
          senderId: 'u3',
          senderName: 'Camila Rocha',
          content: 'Concordo! O WOD de hoje quebrou o pessoal',
          status: MessageStatus.read,
          createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
        ),
        ChatMessageModel(
          id: 'm2_3',
          conversationId: 'conv2',
          senderId: 'u2',
          senderName: 'Rafael Souza',
          content: 'PR no clean! 110kg 🏆',
          type: MessageType.pr,
          prExercise: 'Clean',
          prValue: '110',
          prUnit: 'kg',
          reactions: const {'🔥': 4, '🏆': 2},
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
      ],
      'conv3': [
        ChatMessageModel(
          id: 'm3_1',
          conversationId: 'conv3',
          senderId: 'me',
          senderName: 'Você',
          content: 'Ei Fernanda, qual whey você usa pós treino?',
          status: MessageStatus.read,
          createdAt: now.subtract(const Duration(hours: 4)),
        ),
        ChatMessageModel(
          id: 'm3_2',
          conversationId: 'conv3',
          senderId: 'u5',
          senderName: 'Fernanda Lima',
          content:
              'Uso Whey Protein da Optimum Nutrition. Misturado com leite integral fica ótimo',
          status: MessageStatus.read,
          createdAt: now.subtract(const Duration(hours: 3, minutes: 30)),
        ),
        ChatMessageModel(
          id: 'm3_3',
          conversationId: 'conv3',
          senderId: 'me',
          senderName: 'Você',
          content: 'Valeu pela dica de suplementação!',
          status: MessageStatus.read,
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
    };
  }
}
