import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mock/mock_profile_repository.dart';
import '../../../../shared/providers/global_error_provider.dart';
import '../../../feed/data/models/post_model.dart';
import '../../../prs/data/models/pr_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/repositories/profile_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

// ── Profile ───────────────────────────────────────────────────────────────────

class ProfileNotifier
    extends AutoDisposeFamilyAsyncNotifier<UserProfileModel, String> {
  @override
  Future<UserProfileModel> build(String userId) {
    return ref.read(profileRepositoryProvider).fetchProfile(userId);
  }

  Future<void> follow() async {
    final current = state.valueOrNull;
    if (current == null || current.isFollowing) return;

    // Optimistic update
    state = AsyncData(current.copyWith(
      isFollowing: true,
      followersCount: current.followersCount + 1,
    ));

    try {
      final updated =
          await ref.read(profileRepositoryProvider).followUser(arg);
      state = AsyncData(updated);
    } catch (e) {
      ref.pushError(e);
      state = AsyncData(current); // rollback
    }
  }

  Future<void> unfollow() async {
    final current = state.valueOrNull;
    if (current == null || !current.isFollowing) return;

    state = AsyncData(current.copyWith(
      isFollowing: false,
      followersCount: current.followersCount - 1,
    ));

    try {
      final updated =
          await ref.read(profileRepositoryProvider).unfollowUser(arg);
      state = AsyncData(updated);
    } catch (e) {
      ref.pushError(e);
      state = AsyncData(current); // rollback
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? avatar,
    List<String>? sports,
    String? level,
  }) async {
    try {
      final updated = await ref.read(profileRepositoryProvider).updateProfile(
            name: name,
            bio: bio,
            avatar: avatar,
            sports: sports,
            level: level,
          );
      state = AsyncData(updated);
    } catch (e) {
      ref.pushError(e);
      rethrow;
    }
  }

  Future<void> blockUser() async {
    try {
      await ref.read(profileRepositoryProvider).blockUser(arg);
    } catch (e) {
      ref.pushError(e);
      rethrow;
    }
  }
}

final profileProvider = AsyncNotifierProvider.autoDispose
    .family<ProfileNotifier, UserProfileModel, String>(ProfileNotifier.new);

// ── Posts tab ─────────────────────────────────────────────────────────────────

final userPostsProvider =
    FutureProvider.autoDispose.family<List<PostModel>, String>((ref, userId) {
  return ref.read(profileRepositoryProvider).fetchUserPosts(userId);
});

// ── PRs tab ───────────────────────────────────────────────────────────────────

final userPRsProvider = FutureProvider.autoDispose
    .family<List<ExercisePRSummary>, String>((ref, userId) {
  return ref.read(profileRepositoryProvider).fetchUserPRs(userId);
});
