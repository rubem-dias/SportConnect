import '../models/search_result_model.dart';

abstract interface class SearchRepository {
  Future<List<SearchResultModel>> search(String query);
  Future<List<SearchResultModel>> searchUsers(String query);
  Future<List<SearchResultModel>> searchGroups(String query);
  Future<List<SearchResultModel>> searchPosts(String query);
  Future<List<SearchResultModel>> searchExercises(String query);
  Future<List<TrendingHashtag>> getTrendingHashtags();
  Future<List<SearchResultModel>> getSuggestedUsers();
}
