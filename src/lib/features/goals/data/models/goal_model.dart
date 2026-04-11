enum GoalType { bodyWeight, specificPR, weeklyFrequency, monthlyDistance }

enum GoalStatus { active, completed, expired }

class GoalModel {
  const GoalModel({
    required this.id,
    required this.type,
    required this.title,
    required this.target,
    required this.unit,
    required this.current,
    required this.startDate,
    required this.endDate,
    this.isPublic = false,
    this.linkedExerciseId,
    this.linkedExerciseName,
  });

  final String id;
  final GoalType type;
  final String title;
  final double target;
  final String unit;
  final double current;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPublic;

  /// For specificPR goals: the exercise this goal tracks.
  final String? linkedExerciseId;
  final String? linkedExerciseName;

  double get progressFraction => target == 0 ? 0 : (current / target).clamp(0.0, 1.0);
  int get progressPercent => (progressFraction * 100).round();

  GoalStatus get status {
    if (progressFraction >= 1.0) return GoalStatus.completed;
    if (DateTime.now().isAfter(endDate)) return GoalStatus.expired;
    return GoalStatus.active;
  }

  int get daysRemaining {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  GoalModel copyWith({
    String? id,
    GoalType? type,
    String? title,
    double? target,
    String? unit,
    double? current,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPublic,
    String? linkedExerciseId,
    String? linkedExerciseName,
  }) {
    return GoalModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      current: current ?? this.current,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isPublic: isPublic ?? this.isPublic,
      linkedExerciseId: linkedExerciseId ?? this.linkedExerciseId,
      linkedExerciseName: linkedExerciseName ?? this.linkedExerciseName,
    );
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id']?.toString() ?? '',
      type: GoalType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => GoalType.specificPR,
      ),
      title: json['title']?.toString() ?? '',
      target: (json['target'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      current: (json['current'] as num?)?.toDouble() ?? 0.0,
      startDate:
          DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate:
          DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      isPublic: json['isPublic'] as bool? ?? false,
      linkedExerciseId: json['linkedExerciseId']?.toString(),
      linkedExerciseName: json['linkedExerciseName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'target': target,
        'unit': unit,
        'current': current,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isPublic': isPublic,
        if (linkedExerciseId != null) 'linkedExerciseId': linkedExerciseId,
        if (linkedExerciseName != null) 'linkedExerciseName': linkedExerciseName,
      };
}
