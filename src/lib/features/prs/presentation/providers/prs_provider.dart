import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/exercise_model.dart';
import '../../data/models/pr_model.dart';
import '../../data/repositories/pr_repository_impl.dart';

// ---- State ----

class PRsState {
  const PRsState({
    required this.summaries,
    this.selectedMuscleGroup,
    this.searchQuery = '',
    this.showFavoritesOnly = false,
  });

  final List<ExercisePRSummary> summaries;
  final String? selectedMuscleGroup;
  final String searchQuery;
  final bool showFavoritesOnly;

  List<ExercisePRSummary> get filtered {
    var list = summaries;

    if (showFavoritesOnly) {
      list = list.where((s) => s.isFavorite).toList();
    }

    if (selectedMuscleGroup != null) {
      list = list.where((s) => s.muscleGroup == selectedMuscleGroup).toList();
    }

    if (searchQuery.isNotEmpty) {
      list = list
          .where((s) =>
              s.exerciseName.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return list;
  }

  List<ExercisePRSummary> get top3 {
    final sorted = [...summaries]
      ..sort((a, b) => b.bestPR.value.compareTo(a.bestPR.value));
    return sorted.take(3).toList();
  }

  PRsState copyWith({
    List<ExercisePRSummary>? summaries,
    String? selectedMuscleGroup,
    bool clearMuscleFilter = false,
    String? searchQuery,
    bool? showFavoritesOnly,
  }) {
    return PRsState(
      summaries: summaries ?? this.summaries,
      selectedMuscleGroup:
          clearMuscleFilter ? null : (selectedMuscleGroup ?? this.selectedMuscleGroup),
      searchQuery: searchQuery ?? this.searchQuery,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
    );
  }
}

// ---- Notifier ----

class PRsNotifier extends AsyncNotifier<PRsState> {
  @override
  Future<PRsState> build() async {
    final summaries = await ref.read(prRepositoryProvider).fetchMyPRSummaries();
    return PRsState(summaries: summaries);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final summaries = await ref.read(prRepositoryProvider).fetchMyPRSummaries();
      return PRsState(summaries: summaries);
    });
  }

  void setMuscleGroupFilter(String? group) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      selectedMuscleGroup: group,
      clearMuscleFilter: group == null,
    ));
  }

  void setSearch(String query) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(searchQuery: query));
  }

  void toggleFavorites() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
        current.copyWith(showFavoritesOnly: !current.showFavoritesOnly));
  }

  Future<PRModel> addPR({
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
    final pr = await ref.read(prRepositoryProvider).createPR(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          value: value,
          unit: unit,
          date: date,
          muscleGroup: muscleGroup,
          reps: reps,
          notes: notes,
          shareToFeed: shareToFeed,
        );
    await refresh();
    return pr;
  }

  Future<void> deletePR(String prId) async {
    await ref.read(prRepositoryProvider).deletePR(prId);
    await refresh();
  }
}

final prsProvider = AsyncNotifierProvider<PRsNotifier, PRsState>(
  PRsNotifier.new,
);

// Provider for exercise history
final prHistoryProvider = FutureProvider.family<List<PRModel>, String>(
  (ref, exerciseId) =>
      ref.read(prRepositoryProvider).fetchHistory(exerciseId),
);

// Provider for exercise search
final exerciseSearchProvider = FutureProvider.family<List<ExerciseModel>, String>(
  (ref, query) =>
      ref.read(prRepositoryProvider).fetchExercises(query: query),
);
