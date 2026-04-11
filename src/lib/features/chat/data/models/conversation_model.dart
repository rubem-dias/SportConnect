enum ConversationType { dm, group, channel }

class ConversationModel {
  const ConversationModel({
    required this.id,
    this.type = ConversationType.dm,
    required this.name,
    this.avatar,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isArchived = false,
    this.members = const [],
    this.isOnline = false,
  });

  final String id;
  final ConversationType type;
  final String name;
  final String? avatar;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isMuted;
  final bool isArchived;
  final List<ConversationMember> members;
  final bool isOnline;

  ConversationModel copyWith({
    ConversationType? type,
    String? name,
    String? avatar,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isMuted,
    bool? isArchived,
    List<ConversationMember>? members,
    bool? isOnline,
  }) {
    return ConversationModel(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      members: members ?? this.members,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      type: ConversationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ConversationType.dm,
      ),
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastMessageAt:
          DateTime.tryParse(json['lastMessageAt']?.toString() ?? '') ??
              DateTime.now(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isMuted: json['isMuted'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      members: (json['members'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ConversationMember.fromJson)
              .toList() ??
          const [],
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        if (avatar != null) 'avatar': avatar,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt.toIso8601String(),
        'unreadCount': unreadCount,
        'isMuted': isMuted,
        'isArchived': isArchived,
        'members': members.map((m) => m.toJson()).toList(),
        'isOnline': isOnline,
      };
}

class ConversationMember {
  const ConversationMember({
    required this.userId,
    required this.name,
    this.avatar,
    this.isAdmin = false,
    this.isOnline = false,
  });

  final String userId;
  final String name;
  final String? avatar;
  final bool isAdmin;
  final bool isOnline;

  factory ConversationMember.fromJson(Map<String, dynamic> json) {
    return ConversationMember(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      isAdmin: json['isAdmin'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        if (avatar != null) 'avatar': avatar,
        'isAdmin': isAdmin,
        'isOnline': isOnline,
      };
}
