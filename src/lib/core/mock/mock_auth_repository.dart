import '../../features/auth/data/models/auth_token_model.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  static final _mockUser = UserModel(
    id: 'dev-user-1',
    email: 'dev@sportconnect.app',
    name: 'Dev User',
    sports: ['Musculação', 'Corrida'],
    level: 'intermediate',
    createdAt: DateTime(2024),
  );

  static final _mockTokens = AuthTokenModel(
    accessToken: 'mock-access-token',
    refreshToken: 'mock-refresh-token',
    expiresAt: DateTime.now().add(const Duration(days: 7)),
  );

  @override
  Future<UserModel?> getCurrentUser() async => _mockUser;

  @override
  Future<({UserModel user, AuthTokenModel tokens})> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return (user: _mockUser, tokens: _mockTokens);
  }

  @override
  Future<({UserModel user, AuthTokenModel tokens})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return (user: _mockUser, tokens: _mockTokens);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<({UserModel user, AuthTokenModel tokens})> socialLogin({
    required String provider,
    required String token,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return (user: _mockUser, tokens: _mockTokens);
  }
}
