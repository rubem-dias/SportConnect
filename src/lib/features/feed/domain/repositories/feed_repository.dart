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
}
