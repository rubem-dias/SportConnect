import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/chat/data/models/conversation_model.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/events/presentation/screens/eventos_screen.dart';
import '../../features/explore/presentation/screens/explorar_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/nearby/presentation/screens/nearby_screen.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/prs/data/models/pr_model.dart';
import '../../features/prs/presentation/screens/add_pr_screen.dart';
import '../../features/prs/presentation/screens/pr_detail_screen.dart';
import '../../features/prs/presentation/screens/prs_screen.dart';
import '../../features/search/presentation/screens/explore_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../shared/providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'app_page_transitions.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);
  final devBypassAuth = ref.watch(devBypassAuthProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null || devBypassAuth;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.splash;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.chat;
      }
      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Feed — comentado, fora do shell por enquanto
      // GoRoute(
      //   path: '/feed/post/:postId/comments',
      //   pageBuilder: (context, state) {
      //     final post = state.extra as PostModel?;
      //     return slideTransitionPage(
      //       pageKey: state.pageKey,
      //       child: post == null
      //           ? const Scaffold(
      //               body: Center(child: Text('Post não encontrado')),
      //             )
      //           : CommentsScreen(post: post),
      //     );
      //   },
      // ),

      // Add / Edit PR
      GoRoute(
        path: AppRoutes.addPr,
        pageBuilder: (_, state) {
          final editPR = state.extra is PRModel ? state.extra as PRModel : null;
          return modalTransitionPage(
            pageKey: state.pageKey,
            child: AddPrScreen(editPR: editPR),
          );
        },
      ),

      // PR detail / history
      GoRoute(
        path: AppRoutes.prDetail,
        pageBuilder: (_, state) => slideTransitionPage(
          pageKey: state.pageKey,
          child: PRDetailScreen(
            exerciseId: state.pathParameters['exerciseId'] ?? '',
          ),
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ScaffoldWithBottomNav(navigationShell: navigationShell),
        branches: [
          // Chat — tela inicial
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chat,
                builder: (_, __) => const ChatListScreen(),
                routes: [
                  GoRoute(
                    path: ':conversationId',
                    pageBuilder: (_, state) {
                      final conv = state.extra is ConversationModel
                          ? state.extra as ConversationModel
                          : null;
                      return slideTransitionPage(
                        pageKey: state.pageKey,
                        child: ChatScreen(
                          conversationId:
                              state.pathParameters['conversationId'] ?? '',
                          conversation: conv,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Nearby
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.nearby,
                builder: (_, __) => const NearbyScreen(),
              ),
            ],
          ),

          // Eventos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.eventos,
                builder: (_, __) => const EventosScreen(),
              ),
            ],
          ),

          // Explorar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explorar,
                builder: (_, __) => const ExplorarScreen(),
              ),
            ],
          ),

          // Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: ':userId',
                    builder: (_, state) => ProfileScreen(
                      userId: state.pathParameters['userId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Feed — comentado
      // GoRoute(
      //   path: AppRoutes.feed,
      //   pageBuilder: (_, state) => slideTransitionPage(
      //     pageKey: state.pageKey,
      //     child: const FeedScreen(),
      //   ),
      // ),

      // PRs (acessível via Explorar)
      GoRoute(
        path: AppRoutes.prs,
        pageBuilder: (_, state) => slideTransitionPage(
          pageKey: state.pageKey,
          child: const PrsScreen(),
        ),
      ),

      // Goals (acessível via Explorar)
      GoRoute(
        path: AppRoutes.goals,
        pageBuilder: (_, state) => slideTransitionPage(
          pageKey: state.pageKey,
          child: const GoalsScreen(),
        ),
      ),

      // Notifications
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (_, state) => slideTransitionPage(
          pageKey: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        pageBuilder: (_, state) => slideTransitionPage(
          pageKey: state.pageKey,
          child: const NotificationSettingsScreen(),
        ),
      ),

      // Search
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (_, state) => slideTransitionPage(
          pageKey: state.pageKey,
          child: const SearchScreen(),
        ),
      ),

      // Explore / Trending
      GoRoute(
        path: AppRoutes.explore,
        pageBuilder: (_, state) => slideTransitionPage(
          pageKey: state.pageKey,
          child: const ExploreScreen(),
        ),
      ),
    ],
    errorBuilder: (_, state) => _NotFoundScreen(error: state.error),
  );
}

class _ScaffoldWithBottomNav extends StatelessWidget {
  const _ScaffoldWithBottomNav({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _NavDestination(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chat',
    ),
    _NavDestination(
      icon: Icons.location_on_outlined,
      activeIcon: Icons.location_on,
      label: 'Nearby',
    ),
    _NavDestination(
      icon: Icons.event_outlined,
      activeIcon: Icons.event,
      label: 'Eventos',
    ),
    _NavDestination(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'Explorar',
    ),
    _NavDestination(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _FluidBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
        destinations: _destinations,
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _FluidBottomNav extends StatefulWidget {
  const _FluidBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavDestination> destinations;

  @override
  State<_FluidBottomNav> createState() => _FluidBottomNavState();
}

class _FluidBottomNavState extends State<_FluidBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _indicatorCtrl;
  late Animation<double> _indicatorPos;
  int _prevIndex = 0;
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;
    _indicatorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _indicatorPos = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(_indicatorCtrl);
  }

  @override
  void didUpdateWidget(_FluidBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _indicatorPos = Tween<double>(
        begin: _prevIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(
        CurvedAnimation(
          parent: _indicatorCtrl,
          curve: Curves.easeOutCubic,
        ),
      );
      _prevIndex = widget.currentIndex;
      _indicatorCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _indicatorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = widget.destinations.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: AnimatedBuilder(
            animation: _indicatorCtrl,
            builder: (context, _) {
              return Stack(
                children: [
                  // Sliding indicator pill
                  Positioned(
                    top: 4,
                    left: (_indicatorPos.value / (count - 1)) *
                            (MediaQuery.sizeOf(context).width -
                                (MediaQuery.sizeOf(context).width / count)) +
                        (MediaQuery.sizeOf(context).width / count - 48) / 2,
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Tab items
                  Row(
                    children: List.generate(count, (i) {
                      final dest = widget.destinations[i];
                      final isActive = widget.currentIndex == i;
                      return Expanded(
                        child: Semantics(
                          label: '${dest.label}${isActive ? ", selecionado" : ""}',
                          button: true,
                          child: GestureDetector(
                            onTap: () {
                              final now = DateTime.now();
                              if (_lastTap != null &&
                                  now.difference(_lastTap!) <
                                      const Duration(milliseconds: 400)) {
                                return;
                              }
                              _lastTap = now;
                              widget.onTap(i);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isActive ? dest.activeIcon : dest.icon,
                                  key: ValueKey(isActive),
                                  color: isActive
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dest.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página não encontrada')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('404 — Rota não encontrada'),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.chat),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
