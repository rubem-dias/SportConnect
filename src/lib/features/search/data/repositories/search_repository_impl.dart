import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_result_model.dart';
import 'search_repository.dart';

class MockSearchRepository implements SearchRepository {
  static const _users = [
    SearchResultModel(
      id: 'u1',
      type: SearchResultType.user,
      title: 'Mateus Corrêa',
      subtitle: '@mateus_fit • Musculação',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      trailing: '2.3k seguidores',
    ),
    SearchResultModel(
      id: 'u2',
      type: SearchResultType.user,
      title: 'Fernanda Lima',
      subtitle: '@fernanda_fit • CrossFit',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      trailing: '5.1k seguidores',
    ),
    SearchResultModel(
      id: 'u3',
      type: SearchResultType.user,
      title: 'Rafael Souza',
      subtitle: '@rafael_strong • Powerlifting',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
      trailing: '890 seguidores',
    ),
    SearchResultModel(
      id: 'u4',
      type: SearchResultType.user,
      title: 'Camila Rocha',
      subtitle: '@camila_run • Corrida',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      trailing: '3.7k seguidores',
    ),
    SearchResultModel(
      id: 'u5',
      type: SearchResultType.user,
      title: 'Bruno Alves',
      subtitle: '@bruno_alves • Musculação',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      trailing: '1.2k seguidores',
    ),
    SearchResultModel(
      id: 'u6',
      type: SearchResultType.user,
      title: 'Ana Paula',
      subtitle: '@ana_yoga • Yoga',
      avatarUrl: 'https://i.pravatar.cc/150?img=16',
      trailing: '4.5k seguidores',
    ),
  ];

  static const _groups = [
    SearchResultModel(
      id: 'g1',
      type: SearchResultType.group,
      title: 'CrossFit SP',
      subtitle: 'Grupo público • 1.2k membros',
      trailing: 'CrossFit',
    ),
    SearchResultModel(
      id: 'g2',
      type: SearchResultType.group,
      title: 'Powerlifters Brasil',
      subtitle: 'Grupo público • 3.4k membros',
      trailing: 'Powerlifting',
    ),
    SearchResultModel(
      id: 'g3',
      type: SearchResultType.group,
      title: 'Corredores de Rua',
      subtitle: 'Grupo público • 876 membros',
      trailing: 'Corrida',
    ),
    SearchResultModel(
      id: 'g4',
      type: SearchResultType.group,
      title: 'Musculação & Hipertrofia',
      subtitle: 'Grupo público • 5.6k membros',
      trailing: 'Musculação',
    ),
    SearchResultModel(
      id: 'g5',
      type: SearchResultType.group,
      title: 'Academia em Casa',
      subtitle: 'Grupo privado • 234 membros',
      trailing: 'Musculação',
    ),
  ];

  static const _posts = [
    SearchResultModel(
      id: 'p1',
      type: SearchResultType.post,
      title: 'Supino 120kg! Nunca pensei que chegaria aqui.',
      subtitle: '@fernanda_fit • há 5h',
      trailing: '31 🔥',
    ),
    SearchResultModel(
      id: 'p2',
      type: SearchResultType.post,
      title: 'Treino de peito concluído. A consistência está valendo.',
      subtitle: '@mateus_fit • há 2h',
      trailing: '14 🔥',
    ),
    SearchResultModel(
      id: 'p3',
      type: SearchResultType.post,
      title: 'Sub-20 minutos nos 5km! Meta de 2024 cumprida.',
      subtitle: '@camila_run • há 12h',
      trailing: '45 🔥',
    ),
  ];

  static const _exercises = [
    SearchResultModel(
      id: 'e1',
      type: SearchResultType.exercise,
      title: 'Supino Reto',
      subtitle: 'Peito • kg',
    ),
    SearchResultModel(
      id: 'e2',
      type: SearchResultType.exercise,
      title: 'Agachamento Livre',
      subtitle: 'Pernas • kg',
    ),
    SearchResultModel(
      id: 'e3',
      type: SearchResultType.exercise,
      title: 'Levantamento Terra',
      subtitle: 'Costas • kg',
    ),
    SearchResultModel(
      id: 'e4',
      type: SearchResultType.exercise,
      title: 'Desenvolvimento',
      subtitle: 'Ombros • kg',
    ),
    SearchResultModel(
      id: 'e5',
      type: SearchResultType.exercise,
      title: 'Corrida 5km',
      subtitle: 'Cardio • min',
    ),
    SearchResultModel(
      id: 'e6',
      type: SearchResultType.exercise,
      title: 'Barra Fixa',
      subtitle: 'Costas • reps',
    ),
  ];

  static final _trending = [
    const TrendingHashtag(tag: '#supino', postCount: 1240),
    const TrendingHashtag(tag: '#crossfit', postCount: 980),
    const TrendingHashtag(tag: '#hipertrofia', postCount: 875),
    const TrendingHashtag(tag: '#corrida', postCount: 760),
    const TrendingHashtag(tag: '#deadlift', postCount: 650),
    const TrendingHashtag(tag: '#yoga', postCount: 580),
    const TrendingHashtag(tag: '#agachamento', postCount: 520),
    const TrendingHashtag(tag: '#powerlifting', postCount: 490),
  ];

  List<T> _filter<T extends SearchResultModel>(List<T> list, String query) {
    final q = query.toLowerCase();
    return list
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              (e.subtitle?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Future<List<SearchResultModel>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final q = query.replaceFirst(RegExp(r'^#'), '');
    return [
      ..._filter(_users, q),
      ..._filter(_groups, q),
      ..._filter(_posts, q),
      ..._filter(_exercises, q),
    ];
  }

  @override
  Future<List<SearchResultModel>> searchUsers(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _filter(_users, query);
  }

  @override
  Future<List<SearchResultModel>> searchGroups(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _filter(_groups, query);
  }

  @override
  Future<List<SearchResultModel>> searchPosts(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _filter(_posts, query);
  }

  @override
  Future<List<SearchResultModel>> searchExercises(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _filter(_exercises, query);
  }

  @override
  Future<List<TrendingHashtag>> getTrendingHashtags() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _trending;
  }

  @override
  Future<List<SearchResultModel>> getSuggestedUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _users.take(4).toList();
  }
}

final searchRepositoryProvider = Provider<SearchRepository>(
  (_) => MockSearchRepository(),
);
