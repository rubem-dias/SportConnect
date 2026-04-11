class CommentModel {
  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.replyToId,
    this.replyToUserName,
    this.reactions = const {},
  });

  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;
  final String? replyToId;
  final String? replyToUserName;
  final Map<String, int> reactions;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final raw = json['reactions'];
    final rawUser = json['user'];
    final userMap =
        rawUser is Map ? Map<String, dynamic>.from(rawUser) : <String, dynamic>{};
    final reactionsMap = <String, int>{};
    if (raw is Map) {
      for (final e in raw.entries) {
        if (e.value is num) {
          reactionsMap[e.key.toString()] = (e.value as num).toInt();
        }
      }
    }

    return CommentModel(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
        userName: json['userName']?.toString() ?? userMap['name']?.toString(),
        userAvatar:
          json['userAvatar']?.toString() ?? userMap['avatar']?.toString(),
      replyToId: json['replyToId']?.toString(),
      replyToUserName: json['replyToUserName']?.toString(),
      reactions: reactionsMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'userId': userId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        if (userName != null) 'userName': userName,
        if (userAvatar != null) 'userAvatar': userAvatar,
        if (replyToId != null) 'replyToId': replyToId,
        if (replyToUserName != null) 'replyToUserName': replyToUserName,
        'reactions': reactions,
      };
}
