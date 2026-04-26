import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/router/app_routes.dart';
import '../../../../shared/providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    void navigate(String route) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(route));
    }

    authState.when(
      data: (user) => navigate(user != null ? AppRoutes.chat : AppRoutes.login),
      error: (_, __) => navigate(AppRoutes.login),
      loading: () {},
    );

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
