import '../../data/models/post_model.dart';

class FeedPage {
  const FeedPage({
    required this.posts,
    required this.nextCursor,
  });

  final List<PostModel> posts;
  final String? nextCursor;
}

abstract interface class FeedRepository {
  Future<FeedPage> fetchFeed({
    String? cursor,
    int limit = 20,
  });

  Future<PostModel> createPost({
    required String content,
    List<String> mediaUrls = const [],
    String? prId,
    String privacy = 'everyone',
  });

  Future<void> reactToPost({
    required String postId,
    required String emoji,
  });

  Future<void> removeReaction({
    required String postId,
    required String emoji,
  });
}
