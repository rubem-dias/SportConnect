import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/post_model.dart';
import '../../data/repositories/feed_repository_impl.dart';

class FeedState {
  const FeedState({
    required this.posts,
    required this.nextCursor,
    required this.isLoadingMore,
  });

  final List<PostModel> posts;
  final String? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  FeedState copyWith({
    List<PostModel>? posts,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class FeedNotifier extends AsyncNotifier<FeedState> {
  @override
  Future<FeedState> build() async {
    final page = await ref.read(feedRepositoryProvider).fetchFeed();
    return FeedState(
      posts: page.posts,
      nextCursor: page.nextCursor,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final page = await ref.read(feedRepositoryProvider).fetchFeed();
      return FeedState(
        posts: page.posts,
        nextCursor: page.nextCursor,
        isLoadingMore: false,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final page = await ref.read(feedRepositoryProvider).fetchFeed(
            cursor: current.nextCursor,
          );

      state = AsyncData(
        current.copyWith(
          posts: [...current.posts, ...page.posts],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null || page.nextCursor!.isEmpty,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }
}

final feedProvider = AsyncNotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);
