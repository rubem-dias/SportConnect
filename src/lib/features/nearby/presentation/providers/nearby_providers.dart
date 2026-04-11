import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/nearby_model.dart';

// ── Filtros ───────────────────────────────────────────────────────────────────

class NearbyFilters {
  const NearbyFilters({
    this.radiusMeters = 1000,
    this.sport,
    this.level,
  });

  final double radiusMeters;
  final String? sport;
  final String? level;

  NearbyFilters copyWith({
    double? radiusMeters,
    String? sport,
    bool clearSport = false,
    String? level,
    bool clearLevel = false,
  }) {
    return NearbyFilters(
      radiusMeters: radiusMeters ?? this.radiusMeters,
      sport: clearSport ? null : (sport ?? this.sport),
      level: clearLevel ? null : (level ?? this.level),
    );
  }
}

final nearbyFiltersProvider =
    StateProvider<NearbyFilters>((ref) => const NearbyFilters());

// ── Location permission ───────────────────────────────────────────────────────

enum LocationPermissionStatus { unknown, granted, denied, disabled }

final locationPermissionProvider =
    StateProvider<LocationPermissionStatus>(
        (ref) => LocationPermissionStatus.unknown);

final privacyModeProvider =
    StateProvider<PrivacyMode>((ref) => PrivacyMode.neighborhood);

// ── Nearby users (mock) ───────────────────────────────────────────────────────

final nearbyUsersProvider =
    FutureProvider.autoDispose<List<NearbyUser>>((ref) async {
  final filters = ref.watch(nearbyFiltersProvider);
  await Future<void>.delayed(const Duration(milliseconds: 700));
  return _mockUsers
      .where((u) => u.distanceMeters <= filters.radiusMeters)
      .where((u) =>
          filters.sport == null || u.sports.contains(filters.sport))
      .where((u) =>
          filters.level == null || u.level == filters.level)
      .toList();
});

// ── Nearby gyms (mock) ────────────────────────────────────────────────────────

final nearbyGymsProvider =
    FutureProvider.autoDispose<List<NearbyGym>>((ref) async {
  final filters = ref.watch(nearbyFiltersProvider);
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return _mockGyms
      .where((g) => g.distanceMeters <= filters.radiusMeters)
      .toList();
});

// ── Mock data ─────────────────────────────────────────────────────────────────

const _mockUsers = [
  NearbyUser(
    userId: 'u1',
    name: 'Mateus Corrêa',
    username: '@mateus_fit',
    sports: ['Musculação', 'Powerlifting'],
    level: 'advanced',
    distanceMeters: 320,
    isOnline: true,
  ),
  NearbyUser(
    userId: 'u2',
    name: 'Fernanda Lima',
    username: '@feh_lima',
    sports: ['CrossFit', 'Natação'],
    level: 'advanced',
    distanceMeters: 680,
    isOnline: true,
  ),
  NearbyUser(
    userId: 'u3',
    name: 'Rafael Souza',
    username: '@rafa_souza',
    sports: ['Corrida', 'Ciclismo'],
    level: 'intermediate',
    distanceMeters: 950,
    isOnline: false,
  ),
  NearbyUser(
    userId: 'u4',
    name: 'Camila Rocha',
    username: '@camila_run',
    sports: ['Corrida'],
    level: 'intermediate',
    distanceMeters: 1400,
    isOnline: false,
  ),
  NearbyUser(
    userId: 'u5',
    name: 'Bruno Alves',
    username: '@bruno_power',
    sports: ['Musculação'],
    level: 'beginner',
    distanceMeters: 2100,
    isOnline: true,
  ),
];

const _mockGyms = [
  NearbyGym(
    id: 'g1',
    name: 'Academia Smart Fit',
    address: 'Av. Paulista, 1000',
    distanceMeters: 450,
    rating: 4.2,
    isOpen: true,
  ),
  NearbyGym(
    id: 'g2',
    name: 'CrossFit Zone',
    address: 'Rua Augusta, 200',
    distanceMeters: 870,
    rating: 4.8,
    isOpen: true,
  ),
  NearbyGym(
    id: 'g3',
    name: 'Body Tech',
    address: 'Al. Santos, 500',
    distanceMeters: 1200,
    rating: 4.0,
    isOpen: false,
  ),
];
