import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/config/mapbox_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_skeleton.dart';
import '../../data/models/nearby_model.dart';
import '../providers/nearby_providers.dart';

// ── Tela principal ────────────────────────────────────────────────────────────

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// true = mostra mapa; false = mostra lista por tabs.
  /// O widget do mapa SEMPRE existe na árvore (IndexedStack) para não
  /// reinicializar o MapboxMap desnecessariamente (cada init = 1 map load).
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      final perm = ref.read(locationPermissionProvider);
      if (perm == LocationPermissionStatus.unknown) {
        _requestLocationPermission();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    // Verifica se já foi concedida (ex: segundo launch do app).
    var existing = await geo.Geolocator.checkPermission();
    if (existing == geo.LocationPermission.always ||
        existing == geo.LocationPermission.whileInUse) {
      if (mounted) {
        ref.read(locationPermissionProvider.notifier).state =
            LocationPermissionStatus.granted;
      }
      return;
    }

    if (!mounted) return;

    // Mostra nossa explicação LGPD antes do diálogo do sistema.
    final userAgreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Text('📍', style: TextStyle(fontSize: 24)),
            SizedBox(width: AppSpacing.sm),
            Text('Sua localização'),
          ],
        ),
        content: const Text(
          'Para descobrir atletas e academias perto de você, '
          'precisamos acessar sua localização.\n\n'
          'Em modo "Bairro" compartilhamos apenas sua '
          'localização aproximada, sem expor seu endereço exato.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Não agora'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );

    if (userAgreed != true) {
      ref.read(locationPermissionProvider.notifier).state =
          LocationPermissionStatus.denied;
      return;
    }

    // Solicita a permissão real do sistema.
    final result = await geo.Geolocator.requestPermission();
    if (!mounted) return;

    if (result == geo.LocationPermission.always ||
        result == geo.LocationPermission.whileInUse) {
      ref.read(locationPermissionProvider.notifier).state =
          LocationPermissionStatus.granted;
    } else {
      ref.read(locationPermissionProvider.notifier).state =
          LocationPermissionStatus.denied;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final permission = ref.watch(locationPermissionProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Nearby',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(privacyModeProvider) == PrivacyMode.exact
                  ? Icons.location_on_rounded
                  : Icons.location_city_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'Modo de privacidade',
            onPressed: () => _showPrivacySheet(context),
          ),
          IconButton(
            icon: Icon(
              _showMap ? Icons.list_rounded : Icons.map_rounded,
            ),
            tooltip: _showMap ? 'Ver lista' : 'Ver mapa',
            onPressed: () => setState(() => _showMap = !_showMap),
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFiltersSheet(context),
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          indicatorColor: AppColors.primary,
          dividerColor: isDark ? AppColors.borderDark : AppColors.borderLight,
          tabs: const [
            Tab(text: 'Atletas'),
            Tab(text: 'Academias'),
          ],
        ),
      ),
      body: permission == LocationPermissionStatus.denied
          ? _PermissionDeniedState(onRetry: _requestLocationPermission)
          : IndexedStack(
              // IndexedStack mantém ambas as views vivas simultaneamente.
              // O MapboxMap nunca é descartado → zero reinicializações desnecessárias.
              index: _showMap ? 0 : 1,
              children: [
                _NearbyMapView(key: const ValueKey('nearby_mapbox_map')),
                TabBarView(
                  controller: _tabController,
                  children: [
                    _UsersTab(isDark: isDark),
                    _GymsTab(isDark: isDark),
                  ],
                ),
              ],
            ),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final mode = ref.watch(privacyModeProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo de Privacidade',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PrivacyOption(
                    icon: Icons.location_on_rounded,
                    title: 'Exato',
                    subtitle: 'Compartilha sua posição precisa',
                    selected: mode == PrivacyMode.exact,
                    onTap: () => ref
                        .read(privacyModeProvider.notifier)
                        .state = PrivacyMode.exact,
                  ),
                  _PrivacyOption(
                    icon: Icons.location_city_rounded,
                    title: 'Bairro',
                    subtitle: 'Mostra apenas a área do bairro (recomendado)',
                    selected: mode == PrivacyMode.neighborhood,
                    onTap: () => ref
                        .read(privacyModeProvider.notifier)
                        .state = PrivacyMode.neighborhood,
                  ),
                  _PrivacyOption(
                    icon: Icons.location_off_rounded,
                    title: 'Desativado',
                    subtitle: 'Não aparece no mapa para ninguém',
                    selected: mode == PrivacyMode.disabled,
                    onTap: () => ref
                        .read(privacyModeProvider.notifier)
                        .state = PrivacyMode.disabled,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final filters = ref.watch(nearbyFiltersProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtros',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Raio de busca: ${_radiusLabel(filters.radiusMeters)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: filters.radiusMeters,
                    min: 500,
                    max: 5000,
                    divisions: 9,
                    activeColor: AppColors.primary,
                    label: _radiusLabel(filters.radiusMeters),
                    onChanged: (v) => ref
                        .read(nearbyFiltersProvider.notifier)
                        .state = filters.copyWith(radiusMeters: v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Esporte',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      'Musculação',
                      'Corrida',
                      'CrossFit',
                      'Natação',
                      'Ciclismo',
                    ].map((s) {
                      final selected = filters.sport == s;
                      return FilterChip(
                        label: Text(s),
                        selected: selected,
                        selectedColor: AppColors.primary.withAlpha(40),
                        checkmarkColor: AppColors.primary,
                        onSelected: (_) => ref
                            .read(nearbyFiltersProvider.notifier)
                            .state = selected
                                ? filters.copyWith(clearSport: true)
                                : filters.copyWith(sport: s),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _radiusLabel(double meters) {
    if (meters < 1000) return '${meters.toInt()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }
}

// ── Mapa Mapbox ───────────────────────────────────────────────────────────────

/// Exibe o mapa Mapbox com pins de atletas e academias.
///
/// Otimizações de free tier aplicadas:
/// • [IndexedStack] no pai → widget nunca é descartado → zero reinits do MapboxMap.
///   Cada inicialização do MapboxMap = 1 "map load" no quota de 50k/mês.
/// • Vector tiles (streets-v12) → Mapbox agrupa todos os tiles de uma sessão
///   em um único map load, sem cobranças extras por tile individual.
/// • Tiles são cacheados automaticamente pelo SDK (até 75 MB on-device) →
///   regiões já visitadas não geram novas requisições ao abrir o app.
/// • [PointAnnotationManager] criado UMA vez e reusado em cada atualização.
///   Evita overhead de recriar managers (seria um extra style load por vez).
/// • rotate e pitch desativados via [GesturesSettings] → menos processamento.
class _NearbyMapView extends ConsumerStatefulWidget {
  const _NearbyMapView({super.key});

  @override
  ConsumerState<_NearbyMapView> createState() => _NearbyMapViewState();
}

class _NearbyMapViewState extends ConsumerState<_NearbyMapView> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _userManager;
  PointAnnotationManager? _gymManager;

  /// Mapeia annotation.id → NearbyUser para identificar o tap correto.
  final Map<String, NearbyUser> _userById = {};

  /// Mapeia annotation.id → NearbyGym para identificar o tap correto.
  final Map<String, NearbyGym> _gymById = {};

  /// Imagens dos pins renderizadas via Canvas uma única vez e reutilizadas
  /// em todas as anotações do mesmo tipo.
  Uint8List? _myPin;
  Uint8List? _userPin;
  Uint8List? _gymPin;

  /// true quando os três pins já foram renderizados e estão prontos.
  bool _pinsReady = false;

  /// Referência ao annotation "minha localização" para atualizar sem re-sync geral.
  PointAnnotation? _myAnnotation;

  /// Posição atual do usuário (GeoJSON [lng, lat]).
  /// Começa como null; preenchida quando geolocator responde.
  Position? _myPosition;

  // Fallback enquanto GPS não está pronto (centro do Brasil para não
  // mostrar SP/RJ por padrão — o mapa vai voar para a posição real assim que
  // currentPositionProvider resolver).
  static const _fallbackLat = -15.7801;
  static const _fallbackLng = -47.9292; // Brasília

  @override
  void initState() {
    super.initState();
    _buildPins();
  }

  // ── Renderização dos pins ─────────────────────────────────────────────────

  /// Renderiza os três tipos de pin em paralelo usando Flutter Canvas.
  /// Resultado em PNG bytes — compatível diretamente com [PointAnnotationOptions.image].
  Future<void> _buildPins() async {
    final results = await Future.wait([
      _renderPin(fillColor: AppColors.primary),   // minha localização
      _renderPin(fillColor: AppColors.secondary), // outros atletas
      _renderPin(fillColor: AppColors.success),   // academias
    ]);
    if (!mounted) return;
    _myPin = results[0];
    _userPin = results[1];
    _gymPin = results[2];
    _pinsReady = true;
    // Sincroniza se os managers já estão prontos (não só o mapa).
    if (_userManager != null && _gymManager != null) _syncMarkers();
  }

  /// Pinta um círculo com sombra e borda branca e retorna PNG de 48×48 px.
  /// Executado uma vez por cor — resultado é reutilizado para todos os pins
  /// daquele tipo, sem custo adicional de requisição ao Mapbox.
  Future<Uint8List> _renderPin({required Color fillColor}) async {
    const sz = 48.0;
    const center = Offset(sz / 2, sz / 2);
    const r = sz / 2 - 5.0;

    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);

    // Sombra suave
    canvas.drawCircle(
      center.translate(0, 1.5),
      r,
      Paint()
        ..color = Colors.black.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Preenchimento colorido
    canvas.drawCircle(center, r, Paint()..color = fillColor);

    // Borda branca
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final img = await rec.endRecording().toImage(sz.toInt(), sz.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  // ── Localização real ─────────────────────────────────────────────────────

  /// Chamado quando o GPS responde. Voa a câmera e atualiza o pin "eu"
  /// sem recriar todos os outros markers.
  Future<void> _onPositionReady(geo.Position pos) async {
    _myPosition = Position(pos.longitude, pos.latitude);

    // Voa para a posição real com animação suave.
    await _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: _myPosition!),
        zoom: 14.0,
      ),
      MapAnimationOptions(duration: 900),
    );

    // Atualiza apenas o pin "eu" sem deletar todos os outros markers.
    // try/catch necessário: _myAnnotation pode ter sido removida pelo
    // deleteAll() em _syncMarkers concorrente — nesse caso re-sincroniza tudo.
    final ann = _myAnnotation;
    if (ann != null) {
      try {
        ann.geometry = Point(coordinates: _myPosition!);
        await _userManager?.update(ann);
      } catch (_) {
        // Annotation foi removida do mapa (race com _syncMarkers) — recria tudo.
        _syncMarkers();
      }
    }
  }

  // ── Callbacks do mapa ─────────────────────────────────────────────────────

  void _onMapCreated(MapboxMap map) async {
    _mapboxMap = map;

    // Desativa rotação e inclinação — não usados no Nearby e evitam
    // processamento desnecessário no render loop.
    await map.gestures.updateSettings(
      GesturesSettings(rotateEnabled: false, pitchEnabled: false),
    );

    // Managers são criados em _onStyleLoaded, onde o estilo está garantidamente
    // carregado. Criar aqui pode causar PlatformException silenciosa se o
    // estilo ainda não terminou de carregar.
  }

  /// Chamado pelo SDK quando o estilo foi completamente carregado.
  ///
  /// Annotation managers exigem que o estilo esteja pronto — criá-los em
  /// [_onMapCreated] pode falhar silenciosamente se o estilo ainda estava
  /// carregando (o callback é async void, então a exceção é descartada).
  void _onStyleLoaded(StyleLoadedEventData _) async {
    final map = _mapboxMap;
    if (map == null) return;

    // Managers criados UMA vez por carregamento de estilo.
    // Ordem importa: gyms embaixo, users em cima.
    _gymManager =
        await map.annotations.createPointAnnotationManager(id: 'sc_gyms');
    _userManager =
        await map.annotations.createPointAnnotationManager(id: 'sc_users');

    // Listeners de tap via implementação dedicada (exigência da API do SDK).
    _userManager!.addOnPointAnnotationClickListener(
      _AnnotationClickListener<NearbyUser>(
        dataById: _userById,
        onTap: _showUserSheet,
      ),
    );
    _gymManager!.addOnPointAnnotationClickListener(
      _AnnotationClickListener<NearbyGym>(
        dataById: _gymById,
        onTap: _showGymSheet,
      ),
    );

    // Sincroniza agora que o estilo e os managers estão prontos.
    // ref.read lê o valor atual dos providers sem criar nova subscrição.
    if (_pinsReady) _syncMarkers();
  }

  // ── Sincronização de markers ──────────────────────────────────────────────

  /// Recria todos os markers com os dados atuais dos providers.
  ///
  /// Usa [deleteAll] + [createMulti] para batch eficiente —
  /// muito mais rápido que deletar/criar individualmente.
  Future<void> _syncMarkers() async {
    // Captura referências locais — garante que nenhuma seja null durante a
    // execução assíncrona (race condition entre _buildPins e _onMapCreated).
    final userMgr = _userManager;
    final gymMgr = _gymManager;
    final myPin = _myPin;
    final userPin = _userPin;
    final gymPin = _gymPin;
    if (userMgr == null || gymMgr == null ||
        myPin == null || userPin == null || gymPin == null) return;

    final users = ref.read(nearbyUsersProvider).valueOrNull ?? [];
    final gyms = ref.read(nearbyGymsProvider).valueOrNull ?? [];

    _userById.clear();
    _gymById.clear();

    await Future.wait([
      userMgr.deleteAll(),
      gymMgr.deleteAll(),
    ]);

    // Pin "minha localização"
    final myCoords = _myPosition ?? Position(_fallbackLng, _fallbackLat);
    _myAnnotation = await userMgr.create(PointAnnotationOptions(
      geometry: Point(coordinates: myCoords),
      image: myPin,
      iconSize: 1.1,
    ));

    // Pins de atletas — batch create
    final usersWithCoords =
        users.where((u) => u.lat != null && u.lng != null).toList();
    if (usersWithCoords.isNotEmpty) {
      final created = await userMgr.createMulti(
        usersWithCoords
            .map((u) => PointAnnotationOptions(
                  geometry: Point(coordinates: Position(u.lng!, u.lat!)),
                  image: userPin,
                  iconSize: 1.0,
                  textField: u.name,
                  textSize: 11.0,
                  textOffset: [0.0, 2.2],
                  textColor: Colors.black.value,
                  textHaloColor: Colors.white.value,
                  textHaloWidth: 1.5,
                ))
            .toList(),
      );
      for (var i = 0; i < created.length; i++) {
        final id = created[i]?.id;
        if (id != null) _userById[id] = usersWithCoords[i];
      }
    }

    // Pins de academias — batch create
    final gymsWithCoords =
        gyms.where((g) => g.lat != null && g.lng != null).toList();
    if (gymsWithCoords.isNotEmpty) {
      final created = await gymMgr.createMulti(
        gymsWithCoords
            .map((g) => PointAnnotationOptions(
                  geometry: Point(coordinates: Position(g.lng!, g.lat!)),
                  image: gymPin,
                  iconSize: 1.0,
                  textField: g.name,
                  textSize: 11.0,
                  textOffset: [0.0, 2.2],
                  textColor: Colors.black.value,
                  textHaloColor: Colors.white.value,
                  textHaloWidth: 1.5,
                ))
            .toList(),
      );
      for (var i = 0; i < created.length; i++) {
        final id = created[i]?.id;
        if (id != null) _gymById[id] = gymsWithCoords[i];
      }
    }
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────────

  void _showUserSheet(NearbyUser user) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _UserBottomSheet(user: user),
    );
  }

  void _showGymSheet(NearbyGym gym) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _GymBottomSheet(gym: gym),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Voa para posição real via listener (side-effect, não precisa de rebuild).
    ref.listen(currentPositionProvider, (_, next) {
      next.whenData((pos) {
        if (pos != null) _onPositionReady(pos);
      });
    });

    // Watch em vez de listen — causa rebuild quando os dados chegam.
    // Após o rebuild, agenda _syncMarkers para o próximo frame,
    // garantindo que managers e pins já estão prontos.
    final gymsAsync = ref.watch(nearbyGymsProvider);
    final usersAsync = ref.watch(nearbyUsersProvider);

    if (gymsAsync.hasValue || usersAsync.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncMarkers();
      });
    }

    return MapWidget(
      // Chave estável: impede que o Flutter recrie o widget ao reordenar a
      // árvore, garantindo que o mesmo MapboxMap (e seus tiles em cache)
      // sejam reutilizados durante toda a sessão.
      key: const ValueKey('nearby_mapbox_map_inner'),
      styleUri: isDark ? MapboxConfig.styleDark : MapboxConfig.styleLight,
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: _myPosition ?? Position(_fallbackLng, _fallbackLat),
        ),
        zoom: _myPosition != null ? 14.0 : 4.5, // zoom out no fallback
        bearing: 0.0,
        pitch: 0.0,
      ),
      onMapCreated: _onMapCreated,
      // Annotation managers só podem ser criados depois que o estilo carregou.
      // onStyleLoadedListener garante essa ordem e evita PlatformException silenciosa.
      onStyleLoadedListener: _onStyleLoaded,
    );
  }
}

// ── Listener de tap nas annotations ──────────────────────────────────────────

/// Implementação genérica de [OnPointAnnotationClickListener].
///
/// Necessário como classe separada pois o SDK exige um objeto que implemente
/// a interface — closures não são aceitas diretamente.
class _AnnotationClickListener<T> implements OnPointAnnotationClickListener {
  const _AnnotationClickListener({
    required this.dataById,
    required this.onTap,
  });

  final Map<String, T> dataById;
  final void Function(T) onTap;

  @override
  bool onPointAnnotationClick(PointAnnotation annotation) {
    final data = dataById[annotation.id];
    if (data != null) onTap(data);
    // true = evento consumido, não propaga para o mapa
    return true;
  }
}

// ── Tab de Atletas ────────────────────────────────────────────────────────────

class _UsersTab extends ConsumerWidget {
  const _UsersTab({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(nearbyUsersProvider);

    return usersAsync.when(
      loading: () => _NearbyListSkeleton(isDark: isDark),
      error: (_, __) =>
          const Center(child: Text('Erro ao carregar usuários')),
      data: (users) {
        if (users.isEmpty) {
          return AppEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'Ninguém por aqui',
            subtitle: 'Aumente o raio de busca ou volte mais tarde',
            actionLabel: 'Ajustar filtros',
            onAction: () {},
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.refresh(nearbyUsersProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: users.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 72,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            itemBuilder: (_, i) => _UserTile(user: users[i], isDark: isDark),
          ),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.isDark});

  final NearbyUser user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withAlpha(40),
            backgroundImage:
                user.avatar != null ? NetworkImage(user.avatar!) : null,
            child: user.avatar == null
                ? const Icon(Icons.person_rounded, color: AppColors.primary)
                : null,
          ),
          if (user.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.online,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(user.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.username,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Wrap(
            spacing: 4,
            children: user.sports
                .take(2)
                .map((s) => AppBadge(label: s, isSmall: true))
                .toList(),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user.distanceLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'de distância',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (_) => _UserBottomSheet(user: user),
      ),
    );
  }
}

// ── Tab de Academias ──────────────────────────────────────────────────────────

class _GymsTab extends ConsumerWidget {
  const _GymsTab({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymsAsync = ref.watch(nearbyGymsProvider);

    return gymsAsync.when(
      loading: () => _NearbyListSkeleton(isDark: isDark),
      error: (_, __) =>
          const Center(child: Text('Erro ao carregar academias')),
      data: (gyms) {
        if (gyms.isEmpty) {
          return const AppEmptyState(
            icon: Icons.fitness_center_outlined,
            title: 'Nenhuma academia próxima',
            subtitle: 'Aumente o raio de busca',
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.refresh(nearbyGymsProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: gyms.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 72,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            itemBuilder: (_, i) => _GymTile(gym: gyms[i], isDark: isDark),
          ),
        );
      },
    );
  }
}

class _GymTile extends StatelessWidget {
  const _GymTile({required this.gym, required this.isDark});

  final NearbyGym gym;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.secondary.withAlpha(30),
        backgroundImage:
            gym.photo != null ? NetworkImage(gym.photo!) : null,
        child: gym.photo == null
            ? const Icon(Icons.fitness_center_rounded,
                color: AppColors.secondary)
            : null,
      ),
      title: Text(gym.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (gym.address != null)
            Text(
              gym.address!,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          Row(
            children: [
              if (gym.rating != null) ...[
                const Icon(Icons.star_rounded,
                    size: 12, color: AppColors.warning),
                Text(gym.rating!.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: AppSpacing.xs),
              ],
              if (gym.isOpen != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: (gym.isOpen! ? AppColors.success : AppColors.error)
                        .withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    gym.isOpen! ? 'Aberto' : 'Fechado',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color:
                          gym.isOpen! ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: Text(
        gym.distanceLabel,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          fontSize: 13,
        ),
      ),
      isThreeLine: true,
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (_) => _GymBottomSheet(gym: gym),
      ),
    );
  }
}

// ── Bottom Sheets ─────────────────────────────────────────────────────────────

class _UserBottomSheet extends StatelessWidget {
  const _UserBottomSheet({required this.user});

  final NearbyUser user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withAlpha(40),
              backgroundImage:
                  user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? const Icon(Icons.person_rounded,
                      size: 36, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(user.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 18)),
            Text(user.username,
                style: const TextStyle(color: AppColors.textSecondaryLight)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${user.distanceLabel} de você',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              children: user.sports.map((s) => AppBadge(label: s)).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.userProfilePath(user.userId));
                    },
                    icon: const Icon(Icons.person_rounded, size: 16),
                    label: const Text('Ver Perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(
                          AppRoutes.chatConversationPath(user.userId));
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 16),
                    label: const Text('Mensagem'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.fitness_center_rounded, size: 16),
                label: const Text('Treinar junto'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.secondary),
                  foregroundColor: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GymBottomSheet extends StatelessWidget {
  const _GymBottomSheet({required this.gym});

  final NearbyGym gym;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.secondary.withAlpha(30),
                  child: const Icon(Icons.fitness_center_rounded,
                      color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gym.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      if (gym.address != null)
                        Text(gym.address!,
                            style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (gym.rating != null) ...[
                  const Icon(Icons.star_rounded,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(gym.rating!.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: AppSpacing.md),
                ],
                const Icon(Icons.near_me_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  gym.distanceLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                if (gym.isOpen != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          (gym.isOpen! ? AppColors.success : AppColors.error)
                              .withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      gym.isOpen! ? 'Aberto' : 'Fechado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: gym.isOpen! ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _PermissionDeniedState extends StatelessWidget {
  const _PermissionDeniedState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📍', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Localização necessária',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Permita o acesso à localização para descobrir '
              'atletas e academias próximas de você.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Permitir localização'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  const _PrivacyOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _NearbyListSkeleton extends StatelessWidget {
  const _NearbyListSkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            AppLoadingSkeleton(width: 48, height: 48, borderRadius: 24),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLoadingSkeleton(height: 14, borderRadius: 4),
                  SizedBox(height: 6),
                  AppLoadingSkeleton(width: 120, height: 12, borderRadius: 4),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            AppLoadingSkeleton(width: 44, height: 14, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}
