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
import '../../features/feed/data/models/post_model.dart';
import '../../features/feed/presentation/screens/comments_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/nearby/presentation/screens/nearby_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/prs/data/models/pr_model.dart';
import '../../features/prs/presentation/screens/add_pr_screen.dart';
import '../../features/prs/presentation/screens/pr_detail_screen.dart';
import '../../features/prs/presentation/screens/prs_screen.dart';
import '../../shared/providers/auth_provider.dart';
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
        return AppRoutes.feed;
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

      // Shell — Bottom Navigation
      // Comments screen (takes post via extra)
      GoRoute(
        path: '/feed/post/:postId/comments',
        builder: (context, state) {
          final post = state.extra as PostModel?;
          if (post == null) {
            return const Scaffold(
              body: Center(child: Text('Post não encontrado')),
            );
          }
          return CommentsScreen(post: post);
        },
      ),

      // Add / Edit PR
      GoRoute(
        path: AppRoutes.addPr,
        builder: (_, state) {
          final editPR = state.extra is PRModel ? state.extra as PRModel : null;
          return AddPrScreen(editPR: editPR);
        },
      ),

      // PR detail / history
      GoRoute(
        path: AppRoutes.prDetail,
        builder: (_, state) => PRDetailScreen(
          exerciseId: state.pathParameters['exerciseId'] ?? '',
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ScaffoldWithBottomNav(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.feed,
                builder: (_, __) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.prs,
                builder: (_, __) => const PrsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.nearby,
                builder: (_, __) => const NearbyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chat,
                builder: (_, __) => const ChatListScreen(),
                routes: [
                  GoRoute(
                    path: ':conversationId',
                    builder: (_, state) {
                      final conv = state.extra is ConversationModel
                          ? state.extra as ConversationModel
                          : null;
                      return ChatScreen(
                        conversationId:
                            state.pathParameters['conversationId'] ?? '',
                        conversation: conv,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
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

      // Goals
      GoRoute(
        path: AppRoutes.goals,
        builder: (_, __) => const GoalsScreen(),
      ),

      // Notifications (modal-like, outside shell)
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (_, state) => _NotFoundScreen(error: state.error),
  );
}

class _ScaffoldWithBottomNav extends StatelessWidget {
  const _ScaffoldWithBottomNav({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'PRs',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
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
              onPressed: () => context.go(AppRoutes.feed),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
