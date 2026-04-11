class StoryModel {
  const StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.mediaUrl,
    required this.createdAt,
    required this.expiresAt,
    this.text,
    this.textColor,
    this.isViewed = false,
    this.isMe = false,
  });

  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String mediaUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? text;
  final int? textColor;
  final bool isViewed;
  final bool isMe;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  StoryModel copyWith({bool? isViewed}) {
    return StoryModel(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      mediaUrl: mediaUrl,
      createdAt: createdAt,
      expiresAt: expiresAt,
      text: text,
      textColor: textColor,
      isViewed: isViewed ?? this.isViewed,
      isMe: isMe,
    );
  }
}

class StoryGroup {
  const StoryGroup({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.stories,
    this.isMe = false,
  });

  final String userId;
  final String userName;
  final String? userAvatar;
  final List<StoryModel> stories;
  final bool isMe;

  bool get hasUnviewed => stories.any((s) => !s.isViewed);
}
