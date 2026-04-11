import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/features/search/data/models/search_result_model.dart';
import 'package:sport_connect/features/search/data/repositories/search_repository_impl.dart';

void main() {
  late MockSearchRepository repository;

  setUp(() {
    repository = MockSearchRepository();
  });

  group('MockSearchRepository.search', () {
    test('returns all results for blank query (contains match)', () async {
      final result = await repository.search('');
      expect(result, isNotEmpty);
    });

    test('returns matching users case-insensitively', () async {
      final result = await repository.search('mateus');
      expect(
        result.any((u) => u.title.toLowerCase().contains('mateus')),
        isTrue,
      );
    });

    test('returns results for broad query', () async {
      final result = await repository.search('a');
      expect(result, isNotEmpty);
    });

    test('query with no matches returns empty list', () async {
      final result = await repository.search('zzzzzzzzz');
      expect(result, isEmpty);
    });

    test('all results have valid types', () async {
      final result = await repository.search('a');
      expect(
        result.every((r) => SearchResultType.values.contains(r.type)),
        isTrue,
      );
    });
  });

  group('MockSearchRepository.searchUsers', () {
    test('filters users by query', () async {
      final users = await repository.searchUsers('fernanda');
      expect(users, hasLength(1));
      expect(users.first.title, contains('Fernanda'));
    });

    test('all results have type user', () async {
      final users = await repository.searchUsers('a');
      expect(users.every((u) => u.type == SearchResultType.user), isTrue);
    });

    test('empty query returns all users', () async {
      final users = await repository.searchUsers('');
      expect(users, isNotEmpty);
      expect(users.every((u) => u.type == SearchResultType.user), isTrue);
    });
  });

  group('MockSearchRepository.searchGroups', () {
    test('all results have type group', () async {
      final groups = await repository.searchGroups('a');
      expect(groups.every((g) => g.type == SearchResultType.group), isTrue);
    });

    test('empty query returns all groups', () async {
      final groups = await repository.searchGroups('');
      expect(groups, isNotEmpty);
      expect(groups.every((g) => g.type == SearchResultType.group), isTrue);
    });

    test('filters groups by query term', () async {
      final groups = await repository.searchGroups('power');
      expect(
        groups.every(
          (g) =>
              g.title.toLowerCase().contains('power') ||
              (g.subtitle?.toLowerCase().contains('power') ?? false),
        ),
        isTrue,
      );
    });
  });

  group('MockSearchRepository.searchPosts', () {
    test('all results have type post', () async {
      final posts = await repository.searchPosts('treino');
      expect(posts.every((p) => p.type == SearchResultType.post), isTrue);
    });

    test('empty query returns all posts', () async {
      final posts = await repository.searchPosts('');
      expect(posts, isNotEmpty);
      expect(posts.every((p) => p.type == SearchResultType.post), isTrue);
    });
  });

  group('MockSearchRepository.searchExercises', () {
    test('filters exercises by query', () async {
      final exercises = await repository.searchExercises('supino');
      expect(exercises, isNotEmpty);
      expect(
        exercises.every(
          (e) => e.title.toLowerCase().contains('supino'),
        ),
        isTrue,
      );
    });

    test('all results have type exercise', () async {
      final exercises = await repository.searchExercises('a');
      expect(
        exercises.every((e) => e.type == SearchResultType.exercise),
        isTrue,
      );
    });

    test('empty query returns all exercises', () async {
      final exercises = await repository.searchExercises('');
      expect(exercises, isNotEmpty);
      expect(exercises.every((e) => e.type == SearchResultType.exercise), isTrue);
    });
  });

  group('MockSearchRepository.getTrendingHashtags', () {
    test('returns non-empty list', () async {
      final trending = await repository.getTrendingHashtags();
      expect(trending, isNotEmpty);
    });

    test('all hashtags have positive postCount', () async {
      final trending = await repository.getTrendingHashtags();
      expect(trending.every((t) => t.postCount > 0), isTrue);
    });

    test('all tags start with #', () async {
      final trending = await repository.getTrendingHashtags();
      expect(trending.every((t) => t.tag.startsWith('#')), isTrue);
    });
  });

  group('MockSearchRepository.getSuggestedUsers', () {
    test('returns non-empty list', () async {
      final users = await repository.getSuggestedUsers();
      expect(users, isNotEmpty);
    });

    test('all results have type user', () async {
      final users = await repository.getSuggestedUsers();
      expect(users.every((u) => u.type == SearchResultType.user), isTrue);
    });
  });
}
