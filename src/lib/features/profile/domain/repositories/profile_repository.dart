import '../../../feed/data/models/post_model.dart';
import '../../../prs/data/models/pr_model.dart';
import '../../data/models/user_profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfileModel> fetchProfile(String userId);
  Future<List<PostModel>> fetchUserPosts(String userId, {String? cursor});
  Future<List<ExercisePRSummary>> fetchUserPRs(String userId);
  Future<UserProfileModel> updateProfile({
    String? name,
    String? bio,
    String? avatar,
    List<String>? sports,
    String? level,
  });
  Future<UserProfileModel> followUser(String userId);
  Future<UserProfileModel> unfollowUser(String userId);
  Future<void> blockUser(String userId);
}
