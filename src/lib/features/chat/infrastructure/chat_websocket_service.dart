import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/repositories/chat_repository.dart';

/// Protocolo de mensagem WebSocket.
/// `{type, conversationId, payload, timestamp}`
class WsEvent {
  const WsEvent({
    required this.type,
    required this.conversationId,
    required this.payload,
    required this.timestamp,
  });

  final WsEventType type;
  final String conversationId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  String toJson() => jsonEncode({
        'type': type.name,
        'conversationId': conversationId,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      });
}

enum WsEventType { message, typing, read, reaction, presence }

/// Serviço de WebSocket com reconexão automática e fila de mensagens pendentes.
///
/// Em desenvolvimento (sem backend), o serviço permanece [ConnectionStatus.offline]
/// e o [MockChatRepository] injeta eventos diretamente via [injectEvent].
class ChatWebSocketService {
  ChatWebSocketService({
    this.wsUrl,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final String? wsUrl;
  // ignore: unused_field
  final FlutterSecureStorage _storage;

  final _messageCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionCtrl =
      StreamController<ConnectionStatus>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageCtrl.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingCtrl.stream;
  Stream<ConnectionStatus> get connectionStream => _connectionCtrl.stream;

  ConnectionStatus _status = ConnectionStatus.offline;
  ConnectionStatus get status => _status;

  final _pendingQueue = <WsEvent>[];
  Timer? _reconnectTimer;
  // ignore: unused_field
  int _reconnectAttempts = 0;

  // ignore: unused_field
  dynamic _socket; // reservado para o canal ws real

  Future<void> connect() async {
    if (wsUrl == null) return; // mock mode
    _setStatus(ConnectionStatus.reconnecting);
    // TODO(backend): abrir WebSocket com wsUrl + Bearer token
    // _socket = await WebSocket.connect(wsUrl!, headers: {...});
    // _listenToSocket();
  }

  /// Chamado pelo MockChatRepository para simular eventos WS.
  void injectEvent(WsEvent event) {
    switch (event.type) {
      case WsEventType.message:
        _messageCtrl.add(event.payload);
      case WsEventType.typing:
        _typingCtrl.add(event.payload);
      default:
        break;
    }
  }

  /// Envia evento para o servidor (ou enfileira se offline).
  void send(WsEvent event) {
    if (_status == ConnectionStatus.connected) {
      // TODO(backend): _socket.add(event.toJson());
    } else {
      _pendingQueue.add(event);
    }
  }

  void _setStatus(ConnectionStatus s) {
    _status = s;
    _connectionCtrl.add(s);
  }

  // ignore: unused_element
  void _flushQueue() {
    final copy = List<WsEvent>.from(_pendingQueue);
    _pendingQueue.clear();
    for (final e in copy) {
      send(e);
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    // TODO(backend): _socket?.close();
    _setStatus(ConnectionStatus.offline);
  }

  void dispose() {
    disconnect();
    _messageCtrl.close();
    _typingCtrl.close();
    _connectionCtrl.close();
  }
}

final chatWebSocketServiceProvider = Provider<ChatWebSocketService>((ref) {
  final svc = ChatWebSocketService();
  ref.onDispose(svc.dispose);
  return svc;
});
