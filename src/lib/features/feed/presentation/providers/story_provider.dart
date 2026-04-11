import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/story_model.dart';

class StoriesNotifier extends Notifier<List<StoryGroup>> {
  @override
  List<StoryGroup> build() => _mockStories();

  void markViewed(String userId, String storyId) {
    state = state.map((group) {
      if (group.userId != userId) return group;
      return StoryGroup(
        userId: group.userId,
        userName: group.userName,
        userAvatar: group.userAvatar,
        isMe: group.isMe,
        stories: group.stories
            .map((s) => s.id == storyId ? s.copyWith(isViewed: true) : s)
            .toList(),
      );
    }).toList();
  }

  static List<StoryGroup> _mockStories() {
    final now = DateTime.now();
    final expiry = now.add(const Duration(hours: 24));

    return [
      // My story (add story button)
      const StoryGroup(
        userId: 'me',
        userName: 'Você',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        isMe: true,
        stories: [],
      ),
      StoryGroup(
        userId: 'u2',
        userName: 'Fernanda',
        userAvatar: 'https://i.pravatar.cc/150?img=5',
        stories: [
          StoryModel(
            id: 's1',
            userId: 'u2',
            userName: 'Fernanda Lima',
            userAvatar: 'https://i.pravatar.cc/150?img=5',
            mediaUrl:
                'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
            createdAt: now.subtract(const Duration(hours: 1)),
            expiresAt: expiry,
            text: 'Treino pesado hoje! 💪',
            textColor: 0xFFFFFFFF,
          ),
          StoryModel(
            id: 's2',
            userId: 'u2',
            userName: 'Fernanda Lima',
            userAvatar: 'https://i.pravatar.cc/150?img=5',
            mediaUrl:
                'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
            createdAt: now.subtract(const Duration(minutes: 30)),
            expiresAt: expiry,
          ),
        ],
      ),
      StoryGroup(
        userId: 'u1',
        userName: 'Mateus',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        stories: [
          StoryModel(
            id: 's3',
            userId: 'u1',
            userName: 'Mateus Corrêa',
            userAvatar: 'https://i.pravatar.cc/150?img=1',
            mediaUrl:
                'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
            createdAt: now.subtract(const Duration(hours: 3)),
            expiresAt: expiry,
            text: '120kg no supino! 🏆',
            textColor: 0xFFFFD700,
          ),
        ],
      ),
      StoryGroup(
        userId: 'u4',
        userName: 'Camila',
        userAvatar: 'https://i.pravatar.cc/150?img=9',
        stories: [
          StoryModel(
            id: 's4',
            userId: 'u4',
            userName: 'Camila Rocha',
            userAvatar: 'https://i.pravatar.cc/150?img=9',
            mediaUrl:
                'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
            createdAt: now.subtract(const Duration(hours: 5)),
            expiresAt: expiry,
            text: 'Corrida matinal 🏃‍♀️',
            textColor: 0xFFFFFFFF,
            isViewed: true,
          ),
        ],
      ),
      StoryGroup(
        userId: 'u3',
        userName: 'Rafael',
        userAvatar: 'https://i.pravatar.cc/150?img=8',
        stories: [
          StoryModel(
            id: 's5',
            userId: 'u3',
            userName: 'Rafael Souza',
            userAvatar: 'https://i.pravatar.cc/150?img=8',
            mediaUrl:
                'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=800',
            createdAt: now.subtract(const Duration(hours: 8)),
            expiresAt: expiry,
            isViewed: true,
          ),
        ],
      ),
      StoryGroup(
        userId: 'u6',
        userName: 'Ana Paula',
        userAvatar: 'https://i.pravatar.cc/150?img=16',
        stories: [
          StoryModel(
            id: 's6',
            userId: 'u6',
            userName: 'Ana Paula',
            userAvatar: 'https://i.pravatar.cc/150?img=16',
            mediaUrl:
                'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
            createdAt: now.subtract(const Duration(hours: 10)),
            expiresAt: expiry,
            text: 'Namastê 🧘‍♀️',
            textColor: 0xFFFFFFFF,
            isViewed: true,
          ),
        ],
      ),
    ];
  }
}

final storiesProvider =
    NotifierProvider<StoriesNotifier, List<StoryGroup>>(StoriesNotifier.new);
