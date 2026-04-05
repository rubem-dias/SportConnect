import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../../../../../core/router/app_routes.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    authState.whenData((user) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (user != null) {
          context.go(AppRoutes.feed);
        } else {
          context.go(AppRoutes.login);
        }
      });
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
