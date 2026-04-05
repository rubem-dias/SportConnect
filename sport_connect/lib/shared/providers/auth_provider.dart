import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<UserModel?> build() async {
    return ref.watch(authRepositoryProvider).getCurrentUser();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      return result.user;
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password);
      return result.user;
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
