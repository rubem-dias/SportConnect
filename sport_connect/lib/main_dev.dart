import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SportConnectApp(flavor: AppFlavor.dev),
    ),
  );
}
