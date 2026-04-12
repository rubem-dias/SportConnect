import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/search_result_model.dart';
import '../../data/repositories/search_repository_impl.dart';

// ─── Recent searches (local, in-memory) ────────────────────────────────────

class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String query) {
    if (query.trim().isEmpty) return;
    final trimmed = query.trim();
    state = [trimmed, ...state.where((q) => q != trimmed)].take(10).toList();
  }

  void remove(String query) {
    state = state.where((q) => q != query).toList();
  }

  void clear() => state = [];
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
  RecentSearchesNotifier.new,
);

// ─── Active query ───────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

// ─── Search results per tab ─────────────────────────────────────────────────

class SearchState {
  const SearchState({
    required this.all,
    required this.users,
    required this.groups,
    required this.posts,
    required this.exercises,
  });

  final List<SearchResultModel> all;
  final List<SearchResultModel> users;
  final List<SearchResultModel> groups;
  final List<SearchResultModel> posts;
  final List<SearchResultModel> exercises;

  static const empty = SearchState(
    all: [],
    users: [],
    groups: [],
    posts: [],
    exercises: [],
  );
}

class SearchNotifier extends AsyncNotifier<SearchState> {
  Timer? _debounce;

  @override
  Future<SearchState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    ref.listen(searchQueryProvider, (_, next) => _onQueryChanged(next));
    return SearchState.empty;
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = const AsyncData(SearchState.empty);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _run(query));
  }

  Future<void> _run(String query) async {
    state = const AsyncLoading();
    final repo = ref.read(searchRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final results = await Future.wait([
        repo.search(query),
        repo.searchUsers(query),
        repo.searchGroups(query),
        repo.searchPosts(query),
        repo.searchExercises(query),
      ]);
      return SearchState(
        all: results[0],
        users: results[1],
        groups: results[2],
        posts: results[3],
        exercises: results[4],
      );
    });
  }
}

final searchResultsProvider =
    AsyncNotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);

// ─── Trending & Suggestions (home state) ────────────────────────────────────

final trendingHashtagsProvider =
    FutureProvider<List<TrendingHashtag>>((ref) async {
  return ref.read(searchRepositoryProvider).getTrendingHashtags();
});

final suggestedUsersProvider =
    FutureProvider<List<SearchResultModel>>((ref) async {
  return ref.read(searchRepositoryProvider).getSuggestedUsers();
});

// ─── User search by @username (used in ChatListScreen) ──────────────────────

final userSearchProvider =
    FutureProvider.family<List<SearchResultModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  return ref.read(searchRepositoryProvider).searchUsers(query);
});
