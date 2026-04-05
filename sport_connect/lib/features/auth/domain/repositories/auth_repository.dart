import '../../data/models/auth_token_model.dart';
import '../../data/models/user_model.dart';

abstract interface class AuthRepository {
  Future<({UserModel user, AuthTokenModel tokens})> login({
    required String email,
    required String password,
  });

  Future<({UserModel user, AuthTokenModel tokens})> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<({UserModel user, AuthTokenModel tokens})> socialLogin({
    required String provider,
    required String token,
  });
}
