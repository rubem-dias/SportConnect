class PRModel {
  const PRModel({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.value,
    required this.unit,
    required this.date,
    this.reps,
    this.notes,
    this.isShared = false,
    this.muscleGroup,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final double value;
  final String unit;
  final DateTime date;
  final int? reps;
  final String? notes;
  final bool isShared;
  final String? muscleGroup;

  String get displayValue {
    final val = value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$val $unit${reps != null ? ' × $reps reps' : ''}';
  }

  factory PRModel.fromJson(Map<String, dynamic> json) {
    return PRModel(
      id: json['id']?.toString() ?? '',
      exerciseId: json['exerciseId']?.toString() ?? '',
      exerciseName: json['exerciseName']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'kg',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      reps: (json['reps'] as num?)?.toInt(),
      notes: json['notes']?.toString(),
      isShared: json['isShared'] as bool? ?? false,
      muscleGroup: json['muscleGroup']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'value': value,
        'unit': unit,
        'date': date.toIso8601String(),
        if (reps != null) 'reps': reps,
        if (notes != null) 'notes': notes,
        'isShared': isShared,
        if (muscleGroup != null) 'muscleGroup': muscleGroup,
      };

  PRModel copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    double? value,
    String? unit,
    DateTime? date,
    int? reps,
    String? notes,
    bool? isShared,
    String? muscleGroup,
  }) {
    return PRModel(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
      isShared: isShared ?? this.isShared,
      muscleGroup: muscleGroup ?? this.muscleGroup,
    );
  }
}

// Representa o melhor PR de um exercício com histórico
class ExercisePRSummary {
  const ExercisePRSummary({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.unit,
    required this.bestPR,
    required this.history,
    this.isCustom = false,
    this.isFavorite = false,
  });

  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final String unit;
  final PRModel bestPR;
  final List<PRModel> history;
  final bool isCustom;
  final bool isFavorite;

  bool get isRecentPR {
    final diff = DateTime.now().difference(bestPR.date);
    return diff.inDays <= 7;
  }
}
