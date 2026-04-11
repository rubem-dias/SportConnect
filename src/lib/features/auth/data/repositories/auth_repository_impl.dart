import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(apiClientProvider));

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<({UserModel user, AuthTokenModel tokens})> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );
    final data = response.data!;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final tokens =
        AuthTokenModel.fromJson(data['tokens'] as Map<String, dynamic>);
    await _client.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return (user: user, tokens: tokens);
  }

  @override
  Future<({UserModel user, AuthTokenModel tokens})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiEndpoints.authRegister,
      data: {'name': name, 'email': email, 'password': password},
    );
    final data = response.data!;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final tokens =
        AuthTokenModel.fromJson(data['tokens'] as Map<String, dynamic>);
    await _client.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return (user: user, tokens: tokens);
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post<void>(ApiEndpoints.authLogout);
    } finally {
      await _client.clearTokens();
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _client.getAccessToken();
    if (token == null) return null;
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiEndpoints.usersMe,
    );
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<({UserModel user, AuthTokenModel tokens})> socialLogin({
    required String provider,
    required String token,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiEndpoints.authSocial(provider),
      data: {'token': token},
    );
    final data = response.data!;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final tokens =
        AuthTokenModel.fromJson(data['tokens'] as Map<String, dynamic>);
    await _client.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return (user: user, tokens: tokens);
  }
}
