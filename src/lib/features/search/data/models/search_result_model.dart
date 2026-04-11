enum SearchResultType { user, group, post, exercise }

class SearchResultModel {
  const SearchResultModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.trailing,
    this.meta,
  });

  final String id;
  final SearchResultType type;
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final String? trailing;
  final Map<String, dynamic>? meta;
}

class TrendingHashtag {
  const TrendingHashtag({
    required this.tag,
    required this.postCount,
  });

  final String tag;
  final int postCount;
}
