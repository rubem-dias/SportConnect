import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/repositories/goal_repository.dart';
import '../local/goal_local_cache.dart';
import '../models/goal_model.dart';

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepositoryImpl(ref.watch(apiClientProvider)),
);

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._client);

  final ApiClient _client;

  static const _baseUrl = '/goals';

  @override
  Future<List<GoalModel>> fetchGoals() async {
    try {
      final res = await _client.dio.get<dynamic>(_baseUrl);
      final data = res.data;
      if (data is List) {
        final goals = data
            .whereType<Map>()
            .map((m) => GoalModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        await GoalLocalCache.saveGoals(goals);
        return goals;
      }
    } catch (_) {
      // fall through to cache
    }
    return GoalLocalCache.loadGoals();
  }

  @override
  Future<GoalModel> createGoal({
    required GoalType type,
    required String title,
    required double target,
    required String unit,
    required DateTime endDate,
    bool isPublic = false,
    String? linkedExerciseId,
    String? linkedExerciseName,
  }) async {
    try {
      final body = {
        'type': type.name,
        'title': title,
        'target': target,
        'unit': unit,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isPublic': isPublic,
        if (linkedExerciseId != null) 'linkedExerciseId': linkedExerciseId,
        if (linkedExerciseName != null) 'linkedExerciseName': linkedExerciseName,
      };
      final res = await _client.dio.post<dynamic>(_baseUrl, data: body);
      return GoalModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      // Return optimistic local model
      return GoalModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        title: title,
        target: target,
        unit: unit,
        current: 0,
        startDate: DateTime.now(),
        endDate: endDate,
        isPublic: isPublic,
        linkedExerciseId: linkedExerciseId,
        linkedExerciseName: linkedExerciseName,
      );
    }
  }

  @override
  Future<GoalModel> updateGoal(GoalModel goal) async {
    try {
      final res = await _client.dio
          .put<dynamic>('$_baseUrl/${goal.id}', data: goal.toJson());
      return GoalModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      return goal;
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    try {
      await _client.dio.delete<dynamic>('$_baseUrl/$goalId');
    } catch (_) {}
  }

  @override
  Future<GoalModel> checkIn(String goalId, double newCurrent) async {
    try {
      final res = await _client.dio.patch<dynamic>(
        '$_baseUrl/$goalId/checkin',
        data: {'current': newCurrent},
      );
      return GoalModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      // Return local update; will sync later
      final cached = await GoalLocalCache.loadGoals();
      final goal = cached.firstWhere((g) => g.id == goalId);
      return goal.copyWith(current: newCurrent);
    }
  }

  @override
  Future<void> archiveGoal(String goalId) async {
    try {
      await _client.dio.patch<dynamic>('$_baseUrl/$goalId/archive');
    } catch (_) {}
  }
}
