import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/config/mapbox_config.dart';
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

// ── Posição real do dispositivo ───────────────────────────────────────────────

/// Obtém a posição atual via Fused Location Provider (GPS + WiFi + célula).
///
/// Usa [getPositionStream] em vez de [getCurrentPosition] porque o stream
/// força o sistema a fazer uma medição nova — [getCurrentPosition] pode
/// retornar uma posição em cache incorreta mesmo com [LocationAccuracy.best].
///
/// Só executa quando [locationPermissionProvider] == granted.
final currentPositionProvider = FutureProvider.autoDispose<Position?>((ref) async {
  final perm = ref.watch(locationPermissionProvider);
  if (perm != LocationPermissionStatus.granted) return null;

  final serviceOn = await Geolocator.isLocationServiceEnabled();
  if (!serviceOn) return null;

  try {
    return await Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).first;
  } catch (_) {
    return null;
  }
});

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

// ── Nearby gyms — Mapbox Search Box API ──────────────────────────────────────

/// Busca academias reais próximas via Mapbox Search Box API.
///
/// Usa o mesmo token público (pk.ey...) já configurado no app.
/// Free tier Mapbox: 100 000 requests/mês — muito mais estável que Overpass.
/// Categorias buscadas: gym + fitness_center (cobertura ampla no Brasil).
final nearbyGymsProvider =
    FutureProvider.autoDispose<List<NearbyGym>>((ref) async {
  final pos = ref.watch(currentPositionProvider).valueOrNull;
  final filters = ref.watch(nearbyFiltersProvider);

  if (pos == null) return [];

  final radius = filters.radiusMeters.toInt();

  // Mapbox usa lng,lat (lon primeiro).
  final proximity = '${pos.longitude},${pos.latitude}';

  final dio = Dio();
  final gyms = <NearbyGym>[];
  final seen = <String>{};

  // Busca as duas categorias e funde os resultados.
  for (final category in ['gym', 'fitness_center']) {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        'https://api.mapbox.com/search/searchbox/v1/category/$category',
        queryParameters: {
          'access_token': MapboxConfig.publicToken,
          'proximity': proximity,
          'limit': 25,
          'language': 'pt',
          'country': 'BR',
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      final features = (response.data?['features'] as List<dynamic>?) ?? [];
      for (final f in features.cast<Map<String, dynamic>>()) {
        final geometry = f['geometry'] as Map<String, dynamic>?;
        final coords = geometry?['coordinates'] as List?;
        if (coords == null || coords.length < 2) continue;

        final lng = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();

        final dist = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, lat, lng,
        );

        if (dist > radius) continue;

        final props = (f['properties'] as Map<String, dynamic>?) ?? {};
        final id = (props['mapbox_id'] as String?) ?? '${lat}_$lng';

        // Evita duplicatas entre as duas categorias.
        if (!seen.add(id)) continue;

        final name = (props['name'] as String?) ?? 'Academia';
        // full_address tem endereço completo; address tem só a rua.
        final address = props['full_address'] as String? ??
            props['address'] as String?;

        gyms.add(NearbyGym(
          id: id,
          name: name,
          address: address,
          distanceMeters: dist,
          lat: lat,
          lng: lng,
        ));
      }
    } catch (_) {
      // Falha silenciosa — retorna o que já foi encontrado pela outra categoria.
    }
  }

  gyms.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  return gyms;
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

