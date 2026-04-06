import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/repositories/feed_repository.dart';
import '../local/feed_local_cache.dart';
import '../models/post_model.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepositoryImpl(ref.watch(apiClientProvider)),
);

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<FeedPage> fetchFeed({String? cursor, int limit = 20}) async {
    try {
      final response = await _client.dio.get<dynamic>(
        ApiEndpoints.feed,
        queryParameters: {
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          'limit': limit,
        },
      );

      final parsed = _parseFeedPage(response.data);
      if (cursor == null) {
        await FeedLocalCache.cacheFirstPage(parsed);
      }
      return parsed;
    } catch (_) {
      if (cursor != null) rethrow;
      final cached = await FeedLocalCache.getFirstPage();
      if (cached != null) return cached;
      rethrow;
    }
  }

  FeedPage _parseFeedPage(dynamic payload) {
    List<dynamic> postsJson = const <dynamic>[];
    String? nextCursor;

    if (payload is List) {
      postsJson = payload;
    } else if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final items = map['items'] ?? map['posts'] ?? map['data'];
      if (items is List) {
        postsJson = items;
      }
      nextCursor = map['nextCursor']?.toString() ?? map['cursor']?.toString();
    }

    final posts = postsJson
        .whereType<Map>()
        .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return FeedPage(posts: posts, nextCursor: nextCursor);
  }
}
