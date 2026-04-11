import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

enum ConversationType { dm, group, channel }

@freezed
class ConversationModel with _$ConversationModel {
  const factory ConversationModel({
    required String id,
    @Default(ConversationType.dm) ConversationType type,
    // Para DMs: nome do outro usuário. Para grupos: nome do grupo.
    required String name,
    String? avatar,
    required String lastMessage,
    required DateTime lastMessageAt,
    @Default(0) int unreadCount,
    @Default(false) bool isMuted,
    @Default(false) bool isArchived,
    @Default([]) List<ConversationMember> members,
    // Para DMs: indica se o outro usuário está online
    @Default(false) bool isOnline,
  }) = _ConversationModel;

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);
}

@freezed
class ConversationMember with _$ConversationMember {
  const factory ConversationMember({
    required String userId,
    required String name,
    String? avatar,
    @Default(false) bool isAdmin,
    @Default(false) bool isOnline,
  }) = _ConversationMember;

  factory ConversationMember.fromJson(Map<String, dynamic> json) =>
      _$ConversationMemberFromJson(json);
}
