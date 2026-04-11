import '../../data/models/exercise_model.dart';
import '../../data/models/pr_model.dart';

abstract class PRRepository {
  /// Lista exercícios com o melhor PR de cada um para o usuário atual.
  Future<List<ExercisePRSummary>> fetchMyPRSummaries();

  /// Histórico de PRs de um exercício específico.
  Future<List<PRModel>> fetchHistory(String exerciseId);

  /// Cria um novo PR.
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
  });

  /// Atualiza um PR existente.
  Future<PRModel> updatePR(PRModel pr);

  /// Deleta um PR.
  Future<void> deletePR(String prId);

  /// Busca exercícios da biblioteca (padrão + personalizados do usuário).
  Future<List<ExerciseModel>> fetchExercises({String? query});

  /// Cria um exercício personalizado.
  Future<ExerciseModel> createCustomExercise({
    required String name,
    required String muscleGroup,
    required String unit,
  });

  /// Retorna o melhor PR anterior para comparação ao registrar novo.
  Future<PRModel?> fetchBestPR(String exerciseId);
}
