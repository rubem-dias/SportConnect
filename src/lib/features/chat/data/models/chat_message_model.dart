import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

enum MessageStatus { sending, sent, read }

enum MessageType { text, image, audio, file, pr }

@freezed
class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String content,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sent) MessageStatus status,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderName,
    @Default({}) Map<String, int> reactions,
    required DateTime createdAt,
    @Default(false) bool isPending,
    // PR card attachment
    String? prExercise,
    String? prValue,
    String? prUnit,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}
