import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/global_error_provider.dart';
import 'app_snackbar.dart';

class GlobalErrorListener extends ConsumerWidget {
  const GlobalErrorListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(globalErrorProvider, (_, error) {
      if (error == null) return;
      AppSnackbar.error(context, error);
      ref.read(globalErrorProvider.notifier).state = null;
    });
    return child;
  }
}
