import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app.dart';
import 'core/config/mapbox_config.dart';
import 'core/env/env.dart';
import 'core/mock/mock_auth_repository.dart';
import 'core/mock/mock_feed_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/feed/data/repositories/feed_repository_impl.dart';
import 'shared/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(MapboxConfig.publicToken);
  runApp(
    ProviderScope(
      overrides: [
        // Bypassa o guard de autenticação — vai direto pro feed
        devBypassAuthProvider.overrideWith((ref) => true),

        // Mock do repositório de auth — login/register funcionam sem backend
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),

        // Mock do repositório de feed — posts fake com delay simulado
        feedRepositoryProvider.overrideWithValue(MockFeedRepository()),
      ],
      child: const SportConnectApp(flavor: AppFlavor.dev),
    ),
  );
}
