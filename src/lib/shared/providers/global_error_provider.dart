import 'package:flutter_riverpod/flutter_riverpod.dart';

final globalErrorProvider = StateProvider<String?>((ref) => null);

extension GlobalErrorRef on Ref {
  void pushError(Object error) {
    final message = switch (error) {
      final Exception e => e.toString().replaceFirst('Exception: ', ''),
      _ => error.toString(),
    };
    Future.microtask(
      () => read(globalErrorProvider.notifier).state = message,
    );
  }
}
