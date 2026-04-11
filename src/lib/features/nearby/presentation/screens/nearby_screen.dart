import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_skeleton.dart';
import '../../data/models/nearby_model.dart';
import '../providers/nearby_providers.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Solicita permissão na primeira visita
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  void _requestLocationPermission() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () {
              ref.read(locationPermissionProvider.notifier).state =
                  LocationPermissionStatus.denied;
              Navigator.pop(context);
            },
            child: const Text('Não agora'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(locationPermissionProvider.notifier).state =
                  LocationPermissionStatus.granted;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
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
          // Ícone de privacidade
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
          dividerColor:
              isDark ? AppColors.borderDark : AppColors.borderLight,
          tabs: const [
            Tab(text: 'Atletas'),
            Tab(text: 'Academias'),
          ],
        ),
      ),
      body: permission == LocationPermissionStatus.denied
          ? _PermissionDeniedState(
              onRetry: _requestLocationPermission)
          : TabBarView(
              controller: _tabController,
              children: [
                _UsersTab(isDark: isDark),
                _GymsTab(isDark: isDark),
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
                  Text('Raio de busca: ${_radiusLabel(filters.radiusMeters)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
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

// ── Users Tab ─────────────────────────────────────────────────────────────────

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
            subtitle:
                'Aumente o raio de busca ou volte mais tarde',
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
            itemBuilder: (context, i) =>
                _UserTile(user: users[i], isDark: isDark),
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
          Text(user.username,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)),
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
          const Text('de distância',
              style: TextStyle(
                  fontSize: 10, color: AppColors.textSecondaryLight)),
        ],
      ),
      onTap: () => _showUserSheet(context, user),
    );
  }

  void _showUserSheet(BuildContext context, NearbyUser user) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _UserBottomSheet(user: user),
    );
  }
}

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
                style: const TextStyle(
                    color: AppColors.textSecondaryLight)),
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
                      context.push(
                          AppRoutes.userProfilePath(user.userId));
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

// ── Gyms Tab ──────────────────────────────────────────────────────────────────

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
            Text(gym.address!,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight)),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: (gym.isOpen!
                            ? AppColors.success
                            : AppColors.error)
                        .withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    gym.isOpen! ? 'Aberto' : 'Fechado',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: gym.isOpen!
                            ? AppColors.success
                            : AppColors.error),
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
      title: Text(title,
          style: TextStyle(
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded,
              color: AppColors.primary)
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
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            const AppLoadingSkeleton(width: 48, height: 48, borderRadius: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLoadingSkeleton(height: 14, borderRadius: 4),
                  const SizedBox(height: 6),
                  AppLoadingSkeleton(
                      width: 120, height: 12, borderRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            AppLoadingSkeleton(width: 44, height: 14, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}
