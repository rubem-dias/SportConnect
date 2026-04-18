import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app.dart';
import 'core/config/mapbox_config.dart';
import 'core/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o token antes de qualquer MapWidget ser criado.
  // Uma única chamada por sessão — não gera requisições extras.
  MapboxOptions.setAccessToken(MapboxConfig.publicToken);
  timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
  runApp(
    const ProviderScope(
      child: SportConnectApp(flavor: AppFlavor.prod),
    ),
  );
}
