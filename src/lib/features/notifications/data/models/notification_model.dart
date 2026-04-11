enum NotificationType {
  reaction,
  comment,
  follower,
  prBeaten,
  mention,
  groupInvite,
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.actorName,
    this.actorAvatar,
    this.targetId,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? actorName;
  final String? actorAvatar;
  final String? targetId;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      actorName: actorName,
      actorAvatar: actorAvatar,
      targetId: targetId,
    );
  }
}
