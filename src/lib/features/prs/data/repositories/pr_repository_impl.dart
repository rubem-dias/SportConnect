import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/repositories/pr_repository.dart';
import '../local/pr_local_cache.dart';
import '../models/exercise_model.dart';
import '../models/pr_model.dart';

final prRepositoryProvider = Provider<PRRepository>(
  (ref) => PRRepositoryImpl(ref.watch(apiClientProvider)),
);

class PRRepositoryImpl implements PRRepository {
  PRRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<ExercisePRSummary>> fetchMyPRSummaries() async {
    try {
      final response = await _client.dio.get<dynamic>(ApiEndpoints.prs);
      final data = response.data;

      final summaries = <ExercisePRSummary>[];

      if (data is List) {
        for (final item in data) {
          if (item is Map) {
            final s = _parseSummary(Map<String, dynamic>.from(item));
            if (s != null) {
              summaries.add(s);
              // Cache every PR from history
              for (final pr in s.history) {
                await PRLocalCache.savePR(pr);
              }
            }
          }
        }
      }

      return summaries;
    } catch (_) {
      return _buildSummariesFromCache();
    }
  }

  Future<List<ExercisePRSummary>> _buildSummariesFromCache() async {
    final allPRs = await PRLocalCache.getAllPRs();
    if (allPRs.isEmpty) return [];

    final grouped = <String, List<PRModel>>{};
    for (final pr in allPRs) {
      grouped.putIfAbsent(pr.exerciseId, () => []).add(pr);
    }

    final summaries = <ExercisePRSummary>[];
    for (final entry in grouped.entries) {
      final history = entry.value..sort((a, b) => b.date.compareTo(a.date));
      final best = history.reduce((a, b) => a.value >= b.value ? a : b);
      summaries.add(ExercisePRSummary(
        exerciseId: entry.key,
        exerciseName: best.exerciseName,
        muscleGroup: best.muscleGroup ?? 'outros',
        unit: best.unit,
        bestPR: best,
        history: history,
      ));
    }

    return summaries;
  }

  ExercisePRSummary? _parseSummary(Map<String, dynamic> json) {
    try {
      final exerciseId = json['exerciseId']?.toString() ?? json['exercise']?['id']?.toString();
      final exerciseName = json['exerciseName']?.toString() ?? json['exercise']?['name']?.toString();
      final muscleGroup = json['muscleGroup']?.toString() ?? json['exercise']?['muscleGroup']?.toString() ?? 'outros';
      final unit = json['unit']?.toString() ?? json['exercise']?['unit']?.toString() ?? 'kg';

      if (exerciseId == null || exerciseName == null) return null;

      final historyJson = json['history'] as List? ?? json['prs'] as List? ?? [];
      final history = historyJson
          .whereType<Map>()
          .map((m) => PRModel.fromJson({
                ...Map<String, dynamic>.from(m),
                'exerciseId': exerciseId,
                'exerciseName': exerciseName,
                'muscleGroup': muscleGroup,
                'unit': m['unit'] ?? unit,
              }))
          .toList();

      if (history.isEmpty) return null;

      history.sort((a, b) => b.value.compareTo(a.value));
      final best = history.first;

      return ExercisePRSummary(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        muscleGroup: muscleGroup,
        unit: unit,
        bestPR: best,
        history: history..sort((a, b) => b.date.compareTo(a.date)),
        isCustom: json['isCustom'] as bool? ?? false,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PRModel>> fetchHistory(String exerciseId) async {
    try {
      final response = await _client.dio.get<dynamic>(
        ApiEndpoints.prsByExercise(exerciseId),
      );
      final data = response.data;
      final prs = <PRModel>[];

      if (data is List) {
        for (final item in data) {
          if (item is Map) {
            final pr = PRModel.fromJson(Map<String, dynamic>.from(item));
            prs.add(pr);
            await PRLocalCache.savePR(pr);
          }
        }
      }

      return prs..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return PRLocalCache.getPRsByExercise(exerciseId);
    }
  }

  @override
  Future<PRModel> createPR({
    required String exerciseId,
    required String exerciseName,
    required double value,
    required String unit,
    required DateTime date,
    required String muscleGroup,
    int? reps,
    String? notes,
    bool shareToFeed = false,
  }) async {
    final body = {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'value': value,
      'unit': unit,
      'date': date.toIso8601String(),
      'muscleGroup': muscleGroup,
      if (reps != null) 'reps': reps,
      if (notes != null) 'notes': notes,
      'shareToFeed': shareToFeed,
    };

    try {
      final response = await _client.dio.post<dynamic>(
        ApiEndpoints.prs,
        data: body,
      );
      final pr = PRModel.fromJson({
        ...Map<String, dynamic>.from(response.data as Map? ?? {}),
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'muscleGroup': muscleGroup,
      });
      await PRLocalCache.savePR(pr);
      return pr;
    } catch (_) {
      // Offline: gerar ID local e salvar na fila de pendentes
      final tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final pr = PRModel(
        id: tempId,
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        value: value,
        unit: unit,
        date: date,
        muscleGroup: muscleGroup,
        reps: reps,
        notes: notes,
        isShared: shareToFeed,
      );
      await PRLocalCache.savePR(pr);
      await PRLocalCache.addToPendingQueue({...body, 'localId': tempId});
      return pr;
    }
  }

  @override
  Future<PRModel> updatePR(PRModel pr) async {
    try {
      final response = await _client.dio.put<dynamic>(
        ApiEndpoints.prsById(pr.id),
        data: pr.toJson(),
      );
      final updated = PRModel.fromJson(Map<String, dynamic>.from(response.data as Map? ?? {}));
      await PRLocalCache.savePR(updated);
      return updated;
    } catch (_) {
      await PRLocalCache.savePR(pr);
      return pr;
    }
  }

  @override
  Future<void> deletePR(String prId) async {
    await PRLocalCache.deletePR(prId);
    try {
      await _client.dio.delete<dynamic>(ApiEndpoints.prsById(prId));
    } catch (_) {}
  }

  @override
  Future<List<ExerciseModel>> fetchExercises({String? query}) async {
    final custom = await PRLocalCache.getCustomExercises();
    final standard = kDefaultExercises.where((e) {
      if (query == null || query.isEmpty) return true;
      return e.name.toLowerCase().contains(query.toLowerCase()) ||
          e.muscleGroup.toLowerCase().contains(query.toLowerCase());
    }).toList();

    final filtered = custom.where((e) {
      if (query == null || query.isEmpty) return true;
      return e.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return [...filtered, ...standard];
  }

  @override
  Future<ExerciseModel> createCustomExercise({
    required String name,
    required String muscleGroup,
    required String unit,
  }) async {
    final exercise = ExerciseModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      muscleGroup: muscleGroup,
      unit: unit,
      isCustom: true,
    );
    await PRLocalCache.saveCustomExercise(exercise);

    try {
      await _client.dio.post<dynamic>(
        ApiEndpoints.exercises,
        data: exercise.toJson(),
      );
    } catch (_) {}

    return exercise;
  }

  @override
  Future<PRModel?> fetchBestPR(String exerciseId) async {
    return PRLocalCache.getBestPR(exerciseId);
  }
}
