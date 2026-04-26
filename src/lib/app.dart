import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/env/env.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'shared/widgets/global_error_listener.dart';

class SportConnectApp extends ConsumerWidget {
  const SportConnectApp({required this.flavor, super.key});

  final AppFlavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'SportConnect',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: flavor == AppFlavor.dev,
      // Cap text scale at 1.3× so large-font users don't break layouts.
      // Text remains larger than default (accessibility) while layouts stay intact.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScale =
            mediaQuery.textScaler.clamp(maxScaleFactor: 1.3);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScale),
          child: GlobalErrorListener(child: child!),
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt'),
        Locale('en'),
      ],
    );
  }
}
