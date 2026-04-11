import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/goal_model.dart';
import '../../data/repositories/goal_repository_impl.dart';

// ---- State ----

class GoalsState {
  const GoalsState({required this.goals});

  final List<GoalModel> goals;

  List<GoalModel> get active =>
      goals.where((g) => g.status == GoalStatus.active).toList();

  List<GoalModel> get completed =>
      goals.where((g) => g.status == GoalStatus.completed).toList();

  List<GoalModel> get expired =>
      goals.where((g) => g.status == GoalStatus.expired).toList();

  GoalsState copyWith({List<GoalModel>? goals}) =>
      GoalsState(goals: goals ?? this.goals);
}

// ---- Notifier ----

class GoalsNotifier extends AsyncNotifier<GoalsState> {
  @override
  Future<GoalsState> build() async {
    final goals = await ref.read(goalRepositoryProvider).fetchGoals();
    return GoalsState(goals: goals);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final goals = await ref.read(goalRepositoryProvider).fetchGoals();
      return GoalsState(goals: goals);
    });
  }

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
    final goal = await ref.read(goalRepositoryProvider).createGoal(
          type: type,
          title: title,
          target: target,
          unit: unit,
          endDate: endDate,
          isPublic: isPublic,
          linkedExerciseId: linkedExerciseId,
          linkedExerciseName: linkedExerciseName,
        );
    _addGoalToState(goal);
    return goal;
  }

  Future<void> deleteGoal(String goalId) async {
    await ref.read(goalRepositoryProvider).deleteGoal(goalId);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        goals: current.goals.where((g) => g.id != goalId).toList(),
      ));
    }
  }

  Future<void> archiveGoal(String goalId) async {
    await ref.read(goalRepositoryProvider).archiveGoal(goalId);
    await refresh();
  }

  /// Called automatically when a PR is registered for a linked exercise.
  Future<void> autoCheckInForPR({
    required String exerciseId,
    required double prValue,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final linked = current.goals.where(
      (g) =>
          g.type == GoalType.specificPR &&
          g.linkedExerciseId == exerciseId &&
          g.status == GoalStatus.active,
    );

    for (final goal in linked) {
      final updated =
          await ref.read(goalRepositoryProvider).checkIn(goal.id, prValue);
      _replaceGoalInState(updated);
    }
  }

  void _addGoalToState(GoalModel goal) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(goals: [...current.goals, goal]));
  }

  void _replaceGoalInState(GoalModel updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      goals: current.goals
          .map((g) => g.id == updated.id ? updated : g)
          .toList(),
    ));
  }
}

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, GoalsState>(
  GoalsNotifier.new,
);
