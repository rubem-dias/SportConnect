class BadgeModel {
  const BadgeModel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
    this.unlockedAt,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool isUnlocked;
  final DateTime? unlockedAt;
}

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.sports, required this.level, required this.postsCount, required this.followersCount, required this.followingCount, required this.badges, this.email,
    this.avatar,
    this.bio,
    this.isFollowing = false,
    this.isMe = false,
    this.isNearby = false,
  });

  final String id;
  final String name;
  final String username;
  final String? email;
  final String? avatar;
  final String? bio;
  final List<String> sports;
  final String level;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final List<BadgeModel> badges;
  final bool isFollowing;
  final bool isMe;
  /// True when this user is within the current user's nearby radius.
  final bool isNearby;

  UserProfileModel copyWith({
    String? name,
    String? username,
    String? bio,
    String? avatar,
    List<String>? sports,
    String? level,
    bool? isFollowing,
    int? followersCount,
    bool? isNearby,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      sports: sports ?? this.sports,
      level: level ?? this.level,
      postsCount: postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount,
      badges: badges,
      isFollowing: isFollowing ?? this.isFollowing,
      isMe: isMe,
      isNearby: isNearby ?? this.isNearby,
    );
  }
}
