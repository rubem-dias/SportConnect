class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.mediaUrls,
    required this.exerciseData,
    required this.prData,
    required this.reactions,
    required this.commentsCount,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  final String id;
  final String userId;
  final String content;
  final List<String> mediaUrls;
  final Map<String, dynamic>? exerciseData;
  final Map<String, dynamic>? prData;
  final Map<String, int> reactions;
  final int commentsCount;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final rawReactions = json['reactions'];
    final rawUser = json['user'];
    final userMap =
        rawUser is Map ? Map<String, dynamic>.from(rawUser) : <String, dynamic>{};
    final reactionsMap = <String, int>{};
    if (rawReactions is Map) {
      for (final entry in rawReactions.entries) {
        final value = entry.value;
        if (value is num) {
          reactionsMap[entry.key.toString()] = value.toInt();
        }
      }
    }

    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      mediaUrls: (json['mediaUrls'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(),
      exerciseData: json['exerciseData'] is Map<String, dynamic>
          ? json['exerciseData'] as Map<String, dynamic>
          : null,
      prData: json['prData'] is Map<String, dynamic>
          ? json['prData'] as Map<String, dynamic>
          : null,
      reactions: reactionsMap,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        userName: json['userName']?.toString() ?? userMap['name']?.toString(),
      userAvatar:
          json['userAvatar']?.toString() ?? userMap['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'mediaUrls': mediaUrls,
      'exerciseData': exerciseData,
      'prData': prData,
      'reactions': reactions,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      if (userName != null) 'userName': userName,
      if (userAvatar != null) 'userAvatar': userAvatar,
    };
  }
}
