enum MessageStatus { sending, sent, read }

enum MessageType { text, image, audio, file, pr }

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content, required this.createdAt, this.senderAvatar,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToSenderName,
    this.reactions = const {},
    this.isPending = false,
    this.prExercise,
    this.prValue,
    this.prUnit,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final String? replyToMessageId;
  final String? replyToContent;
  final String? replyToSenderName;
  final Map<String, int> reactions;
  final DateTime createdAt;
  final bool isPending;
  final String? prExercise;
  final String? prValue;
  final String? prUnit;

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? type,
    MessageStatus? status,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderName,
    Map<String, int>? reactions,
    DateTime? createdAt,
    bool? isPending,
    String? prExercise,
    String? prValue,
    String? prUnit,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
      prExercise: prExercise ?? this.prExercise,
      prValue: prValue ?? this.prValue,
      prUnit: prUnit ?? this.prUnit,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      senderAvatar: json['senderAvatar']?.toString(),
      content: json['content']?.toString() ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      replyToMessageId: json['replyToMessageId']?.toString(),
      replyToContent: json['replyToContent']?.toString(),
      replyToSenderName: json['replyToSenderName']?.toString(),
      reactions: (json['reactions'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          const {},
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isPending: json['isPending'] as bool? ?? false,
      prExercise: json['prExercise']?.toString(),
      prValue: json['prValue']?.toString(),
      prUnit: json['prUnit']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        if (senderAvatar != null) 'senderAvatar': senderAvatar,
        'content': content,
        'type': type.name,
        'status': status.name,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (replyToContent != null) 'replyToContent': replyToContent,
        if (replyToSenderName != null) 'replyToSenderName': replyToSenderName,
        'reactions': reactions,
        'createdAt': createdAt.toIso8601String(),
        'isPending': isPending,
        if (prExercise != null) 'prExercise': prExercise,
        if (prValue != null) 'prValue': prValue,
        if (prUnit != null) 'prUnit': prUnit,
      };
}
