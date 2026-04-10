import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/repositories/feed_repository.dart';
import '../models/post_model.dart';

class FeedLocalCache {
  static const _boxName = 'feed_cache';
  static const _pageKey = 'first_page';

  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  static Future<Box<dynamic>> _openBox() async {
    await _ensureInitialized();
    return Hive.isBoxOpen(_boxName)
        ? Hive.box<dynamic>(_boxName)
        : await Hive.openBox<dynamic>(_boxName);
  }

  static Future<void> cacheFirstPage(FeedPage page) async {
    final box = await _openBox();
    await box.put(_pageKey, {
      'nextCursor': page.nextCursor,
      'posts': page.posts.map((p) => p.toJson()).toList(),
    });
  }

  static Future<FeedPage?> getFirstPage() async {
    final box = await _openBox();
    final raw = box.get(_pageKey);
    if (raw is! Map) return null;

    final dynamic postsRaw = raw['posts'];
    if (postsRaw is! List) return null;

    final posts = postsRaw
        .whereType<Map>()
        .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return FeedPage(
      posts: posts,
      nextCursor: raw['nextCursor']?.toString(),
    );
  }
}
