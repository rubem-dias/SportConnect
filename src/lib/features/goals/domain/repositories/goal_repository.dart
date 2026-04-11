import '../../data/models/goal_model.dart';

abstract interface class GoalRepository {
  Future<List<GoalModel>> fetchGoals();

  Future<GoalModel> createGoal({
    required GoalType type,
    required String title,
    required double target,
    required String unit,
    required DateTime endDate,
    bool isPublic,
    String? linkedExerciseId,
    String? linkedExerciseName,
  });

  Future<GoalModel> updateGoal(GoalModel goal);

  Future<void> deleteGoal(String goalId);

  /// Check-in: update current progress.
  Future<GoalModel> checkIn(String goalId, double newCurrent);

  /// Archive completed/expired goal.
  Future<void> archiveGoal(String goalId);
}
