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

// Mock base location: Av. Paulista, São Paulo (-23.5613, -46.6563)
const _baseLat = -23.5613;
const _baseLng = -46.6563;

const _mockUsers = [
  NearbyUser(
    userId: 'u1',
    name: 'Mateus Corrêa',
    username: '@mateus_fit',
    sports: ['Musculação', 'Powerlifting'],
    level: 'advanced',
    distanceMeters: 320,
    isOnline: true,
    lat: _baseLat + 0.0029,
    lng: _baseLng + 0.0013,
  ),
  NearbyUser(
    userId: 'u2',
    name: 'Fernanda Lima',
    username: '@feh_lima',
    sports: ['CrossFit', 'Natação'],
    level: 'advanced',
    distanceMeters: 680,
    isOnline: true,
    lat: _baseLat - 0.0043,
    lng: _baseLng - 0.0054,
  ),
  NearbyUser(
    userId: 'u3',
    name: 'Rafael Souza',
    username: '@rafa_souza',
    sports: ['Corrida', 'Ciclismo'],
    level: 'intermediate',
    distanceMeters: 950,
    lat: _baseLat + 0.0086,
    lng: _baseLng - 0.0020,
  ),
  NearbyUser(
    userId: 'u4',
    name: 'Camila Rocha',
    username: '@camila_run',
    sports: ['Corrida'],
    level: 'intermediate',
    distanceMeters: 1400,
    lat: _baseLat - 0.0089,
    lng: _baseLng + 0.0113,
  ),
  NearbyUser(
    userId: 'u5',
    name: 'Bruno Alves',
    username: '@bruno_power',
    sports: ['Musculação'],
    level: 'beginner',
    distanceMeters: 2100,
    isOnline: true,
    lat: _baseLat + 0.0045,
    lng: _baseLng - 0.0239,
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
    lat: _baseLat - 0.0020,
    lng: _baseLng + 0.0036,
  ),
  NearbyGym(
    id: 'g2',
    name: 'CrossFit Zone',
    address: 'Rua Augusta, 200',
    distanceMeters: 870,
    rating: 4.8,
    isOpen: true,
    lat: _baseLat + 0.0050,
    lng: _baseLng + 0.0070,
  ),
  NearbyGym(
    id: 'g3',
    name: 'Body Tech',
    address: 'Al. Santos, 500',
    distanceMeters: 1200,
    rating: 4.0,
    isOpen: false,
    lat: _baseLat - 0.0075,
    lng: _baseLng - 0.0080,
  ),
];
