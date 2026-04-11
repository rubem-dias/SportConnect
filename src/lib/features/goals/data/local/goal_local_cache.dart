import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/goal_model.dart';

/// Simple Hive-based cache for goals (offline-first).
class GoalLocalCache {
  static const _boxName = 'goals_cache';

  static Future<Box<String>> _box() async =>
      Hive.isBoxOpen(_boxName)
          ? Hive.box<String>(_boxName)
          : await Hive.openBox<String>(_boxName);

  static Future<void> saveGoals(List<GoalModel> goals) async {
    final box = await _box();
    await box.put(
      'all',
      jsonEncode(goals.map((g) => g.toJson()).toList()),
    );
  }

  static Future<List<GoalModel>> loadGoals() async {
    final box = await _box();
    final raw = box.get('all');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(GoalModel.fromJson)
        .toList();
  }

  static Future<void> clear() async {
    final box = await _box();
    await box.delete('all');
  }
}
