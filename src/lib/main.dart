import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app.dart';
import 'core/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
  runApp(
    const ProviderScope(
      child: SportConnectApp(flavor: AppFlavor.prod),
    ),
  );
}
