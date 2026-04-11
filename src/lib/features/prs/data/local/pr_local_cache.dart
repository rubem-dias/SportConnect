import 'package:hive_flutter/hive_flutter.dart';

import '../models/exercise_model.dart';
import '../models/pr_model.dart';

class PRLocalCache {
  static const _prsBox = 'prs_cache';
  static const _exercisesBox = 'custom_exercises_cache';
  static const _summariesKey = 'pr_summaries';

  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  static Future<Box<dynamic>> _openPRsBox() async {
    await _ensureInitialized();
    return Hive.isBoxOpen(_prsBox)
        ? Hive.box<dynamic>(_prsBox)
        : await Hive.openBox<dynamic>(_prsBox);
  }

  static Future<Box<dynamic>> _openExercisesBox() async {
    await _ensureInitialized();
    return Hive.isBoxOpen(_exercisesBox)
        ? Hive.box<dynamic>(_exercisesBox)
        : await Hive.openBox<dynamic>(_exercisesBox);
  }

  // --- PRs ---

  static Future<void> savePR(PRModel pr) async {
    final box = await _openPRsBox();
    await box.put(pr.id, pr.toJson());
  }

  static Future<void> deletePR(String prId) async {
    final box = await _openPRsBox();
    await box.delete(prId);
  }

  static Future<List<PRModel>> getAllPRs() async {
    final box = await _openPRsBox();
    final prs = <PRModel>[];
    for (final key in box.keys) {
      if (key == _summariesKey) continue;
      final raw = box.get(key);
      if (raw is Map) {
        try {
          prs.add(PRModel.fromJson(Map<String, dynamic>.from(raw)));
        } catch (_) {}
      }
    }
    return prs;
  }

  static Future<List<PRModel>> getPRsByExercise(String exerciseId) async {
    final all = await getAllPRs();
    return all.where((p) => p.exerciseId == exerciseId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<PRModel?> getBestPR(String exerciseId) async {
    final history = await getPRsByExercise(exerciseId);
    if (history.isEmpty) return null;
    history.sort((a, b) => b.value.compareTo(a.value));
    return history.first;
  }

  // --- Custom exercises ---

  static Future<void> saveCustomExercise(ExerciseModel exercise) async {
    final box = await _openExercisesBox();
    await box.put(exercise.id, exercise.toJson());
  }

  static Future<List<ExerciseModel>> getCustomExercises() async {
    final box = await _openExercisesBox();
    final exercises = <ExerciseModel>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        try {
          exercises.add(ExerciseModel.fromJson(Map<String, dynamic>.from(raw)));
        } catch (_) {}
      }
    }
    return exercises;
  }

  // --- Pending sync queue ---

  static const _pendingKey = 'pending_prs';

  static Future<void> addToPendingQueue(Map<String, dynamic> prJson) async {
    final box = await _openPRsBox();
    final pending = List<dynamic>.from(box.get(_pendingKey) as List? ?? []);
    pending.add(prJson);
    await box.put(_pendingKey, pending);
  }

  static Future<List<Map<String, dynamic>>> getPendingQueue() async {
    final box = await _openPRsBox();
    final pending = box.get(_pendingKey);
    if (pending is! List) return [];
    return pending.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  static Future<void> clearPendingQueue() async {
    final box = await _openPRsBox();
    await box.delete(_pendingKey);
  }
}
