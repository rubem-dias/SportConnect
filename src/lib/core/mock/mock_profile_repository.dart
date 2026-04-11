import '../../features/feed/data/models/post_model.dart';
import '../../features/profile/data/models/user_profile_model.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/prs/data/models/pr_model.dart';

class MockProfileRepository implements ProfileRepository {
  static final _me = UserProfileModel(
    id: 'dev-user-1',
    name: 'Dev User',
    username: '@devuser',
    email: 'dev@sportconnect.app',
    bio: 'Apaixonado por musculação e corrida 🏋️‍♂️🏃 | Sempre em evolução',
    sports: ['Musculação', 'Corrida', 'CrossFit'],
    level: 'intermediate',
    postsCount: 42,
    followersCount: 318,
    followingCount: 127,
    badges: _buildBadges(isMe: true),
    isMe: true,
  );

  static final _others = <String, UserProfileModel>{
    'u1': UserProfileModel(
      id: 'u1',
      name: 'Mateus Corrêa',
      username: '@mateus_fit',
      bio: 'Powerlifter amador 💪 | SBD athlete',
      sports: ['Powerlifting', 'Musculação'],
      level: 'advanced',
      postsCount: 87,
      followersCount: 1240,
      followingCount: 89,
      badges: _buildBadges(isMe: false),
      isFollowing: false,
    ),
    'u2': UserProfileModel(
      id: 'u2',
      name: 'Fernanda Lima',
      username: '@feh_lima',
      bio: 'CrossFit | Nutrição esportiva 🥗',
      sports: ['CrossFit', 'Natação'],
      level: 'advanced',
      postsCount: 53,
      followersCount: 892,
      followingCount: 210,
      badges: _buildBadges(isMe: false),
      isFollowing: true,
    ),
  };

  @override
  Future<UserProfileModel> fetchProfile(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (userId == 'me' || userId == 'dev-user-1') return _me;
    return _others[userId] ??
        UserProfileModel(
          id: userId,
          name: 'Usuário',
          username: '@usuario',
          sports: const [],
          level: 'beginner',
          postsCount: 0,
          followersCount: 0,
          followingCount: 0,
          badges: const [],
        );
  }

  @override
  Future<List<PostModel>> fetchUserPosts(
    String userId, {
    String? cursor,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      PostModel(
        id: 'up1',
        userId: userId,
        userName: 'Dev User',
        content: 'Treino de peito concluído 💪 Supino 120kg!',
        mediaUrls: [
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400',
        ],
        reactions: const {'🔥': 14, '💪': 8},
        commentsCount: 3,
        createdAt: now.subtract(const Duration(days: 1)),
        exerciseData: null,
        prData: null,
      ),
      PostModel(
        id: 'up2',
        userId: userId,
        userName: 'Dev User',
        content: 'PR novo no deadlift! 180kg 🏆',
        mediaUrls: const [],
        reactions: const {'🔥': 31, '🏆': 15, '💪': 22},
        commentsCount: 7,
        createdAt: now.subtract(const Duration(days: 3)),
        exerciseData: null,
        prData: const {'exercise': 'Levantamento Terra', 'value': '180', 'unit': 'kg'},
      ),
      PostModel(
        id: 'up3',
        userId: userId,
        userName: 'Dev User',
        content: 'Sábado de corrida! 10km em 52min',
        mediaUrls: [
          'https://images.unsplash.com/photo-1526676037777-05a232554f77?w=400',
          'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400',
        ],
        reactions: const {'🔥': 6, '💪': 3},
        commentsCount: 1,
        createdAt: now.subtract(const Duration(days: 5)),
        exerciseData: null,
        prData: null,
      ),
      PostModel(
        id: 'up4',
        userId: userId,
        userName: 'Dev User',
        content: 'Semana de volume alta. Foco total! 🎯',
        mediaUrls: const [],
        reactions: const {'🔥': 9},
        commentsCount: 0,
        createdAt: now.subtract(const Duration(days: 7)),
        exerciseData: null,
        prData: null,
      ),
    ];
  }

  @override
  Future<List<ExercisePRSummary>> fetchUserPRs(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      ExercisePRSummary(
        exerciseId: 'e1',
        exerciseName: 'Supino Reto',
        muscleGroup: 'Peito',
        unit: 'kg',
        bestPR: PRModel(
          id: 'pr1',
          exerciseId: 'e1',
          exerciseName: 'Supino Reto',
          value: 120,
          unit: 'kg',
          date: now.subtract(const Duration(days: 7)),
          reps: 1,
          isShared: true,
          muscleGroup: 'Peito',
        ),
        history: [],
      ),
      ExercisePRSummary(
        exerciseId: 'e2',
        exerciseName: 'Levantamento Terra',
        muscleGroup: 'Costas',
        unit: 'kg',
        bestPR: PRModel(
          id: 'pr2',
          exerciseId: 'e2',
          exerciseName: 'Levantamento Terra',
          value: 180,
          unit: 'kg',
          date: now.subtract(const Duration(days: 3)),
          reps: 1,
          isShared: true,
          muscleGroup: 'Costas',
        ),
        history: [],
      ),
      ExercisePRSummary(
        exerciseId: 'e3',
        exerciseName: 'Agachamento Livre',
        muscleGroup: 'Pernas',
        unit: 'kg',
        bestPR: PRModel(
          id: 'pr3',
          exerciseId: 'e3',
          exerciseName: 'Agachamento Livre',
          value: 150,
          unit: 'kg',
          date: now.subtract(const Duration(days: 14)),
          reps: 1,
          isShared: false,
          muscleGroup: 'Pernas',
        ),
        history: [],
      ),
      ExercisePRSummary(
        exerciseId: 'e4',
        exerciseName: '5km',
        muscleGroup: 'Cardio',
        unit: 'min',
        bestPR: PRModel(
          id: 'pr4',
          exerciseId: 'e4',
          exerciseName: '5km',
          value: 22,
          unit: 'min',
          date: now.subtract(const Duration(days: 20)),
          isShared: false,
          muscleGroup: 'Cardio',
        ),
        history: [],
      ),
    ];
  }

  @override
  Future<UserProfileModel> updateProfile({
    String? name,
    String? bio,
    String? avatar,
    List<String>? sports,
    String? level,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _me.copyWith(
      name: name,
      bio: bio,
      avatar: avatar,
      sports: sports,
      level: level,
    );
  }

  @override
  Future<UserProfileModel> followUser(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final profile = _others[userId];
    if (profile == null) throw Exception('User not found');
    final updated = profile.copyWith(
      isFollowing: true,
      followersCount: profile.followersCount + 1,
    );
    _others[userId] = updated;
    return updated;
  }

  @override
  Future<UserProfileModel> unfollowUser(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final profile = _others[userId];
    if (profile == null) throw Exception('User not found');
    final updated = profile.copyWith(
      isFollowing: false,
      followersCount: profile.followersCount - 1,
    );
    _others[userId] = updated;
    return updated;
  }

  @override
  Future<void> blockUser(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  static List<BadgeModel> _buildBadges({required bool isMe}) {
    return [
      BadgeModel(
        id: 'first_pr',
        emoji: '🏆',
        title: 'Primeiro PR',
        description: 'Registrou seu primeiro personal record',
        isUnlocked: true,
        unlockedAt: DateTime(2024, 3, 15),
      ),
      BadgeModel(
        id: 'week_streak',
        emoji: '🔥',
        title: 'Semana Intensa',
        description: 'Treinou 5 dias seguidos',
        isUnlocked: true,
        unlockedAt: DateTime(2024, 4, 1),
      ),
      BadgeModel(
        id: 'social_butterfly',
        emoji: '🦋',
        title: 'Sociável',
        description: 'Seguiu 50 pessoas',
        isUnlocked: isMe,
        unlockedAt: isMe ? DateTime(2024, 5, 10) : null,
      ),
      BadgeModel(
        id: 'century',
        emoji: '💯',
        title: 'Centenário',
        description: 'Acumulou 100kg no supino',
        isUnlocked: true,
        unlockedAt: DateTime(2024, 6, 20),
      ),
      BadgeModel(
        id: 'marathon',
        emoji: '🏃',
        title: 'Maratonista',
        description: 'Correu mais de 42km em um mês',
        isUnlocked: false,
      ),
      BadgeModel(
        id: 'pr_month',
        emoji: '📈',
        title: 'Em Ascensão',
        description: 'Bateu 5 PRs em um mês',
        isUnlocked: isMe,
        unlockedAt: isMe ? DateTime(2024, 7, 5) : null,
      ),
    ];
  }
}
