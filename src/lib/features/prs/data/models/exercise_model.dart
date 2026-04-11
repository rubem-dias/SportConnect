class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.unit,
    this.isCustom = false,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String muscleGroup;
  final String unit; // 'kg', 'km', 'min', 'reps', 'm', 'lb'
  final bool isCustom;
  final bool isFavorite;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      muscleGroup: json['muscleGroup']?.toString() ?? 'outros',
      unit: json['unit']?.toString() ?? 'kg',
      isCustom: json['isCustom'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'unit': unit,
        'isCustom': isCustom,
        'isFavorite': isFavorite,
      };

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? unit,
    bool? isCustom,
    bool? isFavorite,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      unit: unit ?? this.unit,
      isCustom: isCustom ?? this.isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Biblioteca de exercícios padrão embutida no app
final kDefaultExercises = <ExerciseModel>[
  // Peito
  const ExerciseModel(id: 'bench_press', name: 'Supino Reto', muscleGroup: 'peito', unit: 'kg'),
  const ExerciseModel(id: 'incline_bench', name: 'Supino Inclinado', muscleGroup: 'peito', unit: 'kg'),
  const ExerciseModel(id: 'decline_bench', name: 'Supino Declinado', muscleGroup: 'peito', unit: 'kg'),
  const ExerciseModel(id: 'chest_fly', name: 'Crucifixo', muscleGroup: 'peito', unit: 'kg'),
  const ExerciseModel(id: 'pushup', name: 'Flexão', muscleGroup: 'peito', unit: 'reps'),
  // Costas
  const ExerciseModel(id: 'deadlift', name: 'Levantamento Terra', muscleGroup: 'costas', unit: 'kg'),
  const ExerciseModel(id: 'pullup', name: 'Barra Fixa', muscleGroup: 'costas', unit: 'reps'),
  const ExerciseModel(id: 'bent_row', name: 'Remada Curvada', muscleGroup: 'costas', unit: 'kg'),
  const ExerciseModel(id: 'lat_pulldown', name: 'Puxada Frontal', muscleGroup: 'costas', unit: 'kg'),
  const ExerciseModel(id: 'seated_row', name: 'Remada Sentada', muscleGroup: 'costas', unit: 'kg'),
  // Pernas
  const ExerciseModel(id: 'squat', name: 'Agachamento', muscleGroup: 'pernas', unit: 'kg'),
  const ExerciseModel(id: 'leg_press', name: 'Leg Press', muscleGroup: 'pernas', unit: 'kg'),
  const ExerciseModel(id: 'hack_squat', name: 'Hack Squat', muscleGroup: 'pernas', unit: 'kg'),
  const ExerciseModel(id: 'lunges', name: 'Avanço', muscleGroup: 'pernas', unit: 'kg'),
  const ExerciseModel(id: 'calf_raise', name: 'Panturrilha', muscleGroup: 'pernas', unit: 'kg'),
  // Ombros
  const ExerciseModel(id: 'overhead_press', name: 'Desenvolvimento', muscleGroup: 'ombros', unit: 'kg'),
  const ExerciseModel(id: 'lateral_raise', name: 'Elevação Lateral', muscleGroup: 'ombros', unit: 'kg'),
  const ExerciseModel(id: 'front_raise', name: 'Elevação Frontal', muscleGroup: 'ombros', unit: 'kg'),
  // Bíceps
  const ExerciseModel(id: 'barbell_curl', name: 'Rosca Direta', muscleGroup: 'bíceps', unit: 'kg'),
  const ExerciseModel(id: 'hammer_curl', name: 'Rosca Martelo', muscleGroup: 'bíceps', unit: 'kg'),
  const ExerciseModel(id: 'preacher_curl', name: 'Rosca Scott', muscleGroup: 'bíceps', unit: 'kg'),
  // Tríceps
  const ExerciseModel(id: 'tricep_pushdown', name: 'Tríceps Corda', muscleGroup: 'tríceps', unit: 'kg'),
  const ExerciseModel(id: 'skull_crusher', name: 'Tríceps Testa', muscleGroup: 'tríceps', unit: 'kg'),
  const ExerciseModel(id: 'dips', name: 'Mergulho', muscleGroup: 'tríceps', unit: 'reps'),
  // Cardio
  const ExerciseModel(id: 'run_5k', name: 'Corrida 5km', muscleGroup: 'cardio', unit: 'min'),
  const ExerciseModel(id: 'run_10k', name: 'Corrida 10km', muscleGroup: 'cardio', unit: 'min'),
  const ExerciseModel(id: 'cycling', name: 'Ciclismo', muscleGroup: 'cardio', unit: 'km'),
  const ExerciseModel(id: 'rowing', name: 'Remo', muscleGroup: 'cardio', unit: 'min'),
  // Core
  const ExerciseModel(id: 'plank', name: 'Prancha', muscleGroup: 'core', unit: 'min'),
  const ExerciseModel(id: 'ab_crunch', name: 'Abdominal', muscleGroup: 'core', unit: 'reps'),
  // Olympic
  const ExerciseModel(id: 'clean_jerk', name: 'Arranco', muscleGroup: 'olímpico', unit: 'kg'),
  const ExerciseModel(id: 'snatch', name: 'Arranque', muscleGroup: 'olímpico', unit: 'kg'),
];
