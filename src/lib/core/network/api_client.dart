import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_endpoints.dart';
import 'app_exception.dart';

part 'api_client.g.dart';

const _kAccessTokenKey = 'access_token';
const _kRefreshTokenKey = 'refresh_token';

@riverpod
ApiClient apiClient(Ref ref) => ApiClient();

class ApiClient {
  ApiClient() {
    _dio = _buildDio();
    _addInterceptors();
  }

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  Dio _buildDio() {
    // Base URL is resolved at runtime from env — injected via interceptor
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  void _addInterceptors() {
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio),
      PrettyDioLogger(
        requestBody: true,
        compact: false,
      ),
    ]);
  }

  Future<void> setBaseUrl(String baseUrl) async {
    _dio.options.baseUrl = baseUrl;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessTokenKey, value: accessToken),
      _storage.write(key: _kRefreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessTokenKey),
      _storage.delete(key: _kRefreshTokenKey),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: _kAccessTokenKey);
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, this._dio);

  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _kAccessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.read(key: _kRefreshTokenKey);
        if (refreshToken == null) {
          _isRefreshing = false;
          return handler.reject(err);
        }

        final response = await _dio.post<Map<String, dynamic>>(
          ApiEndpoints.authRefresh,
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken =
            response.data?['accessToken'] as String?;
        final newRefreshToken =
            response.data?['refreshToken'] as String?;

        if (newAccessToken == null) {
          _isRefreshing = false;
          return handler.reject(err);
        }

        await _storage.write(key: _kAccessTokenKey, value: newAccessToken);
        if (newRefreshToken != null) {
          await _storage.write(key: _kRefreshTokenKey, value: newRefreshToken);
        }

        // Retry original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch<dynamic>(err.requestOptions);
        _isRefreshing = false;
        return handler.resolve(retryResponse);
      } on DioException catch (_) {
        _isRefreshing = false;
        await _storage.deleteAll();
        return handler.reject(err);
      }
    }

    handler.next(_mapDioError(err));
  }

  DioException _mapDioError(DioException err) {
    final AppException appEx = switch (err.type) {
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        const TimeoutException(),
      DioExceptionType.badResponse => _mapStatusCode(err),
      _ => const UnknownException(),
    };

    return err.copyWith(
      error: appEx,
      message: appEx.message,
    );
  }

  AppException _mapStatusCode(DioException err) {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final serverMessage =
        data is Map ? data['message'] as String? : null;

    return switch (status) {
      401 => const UnauthorizedException(),
      403 => const ForbiddenException(),
      404 => const NotFoundException(),
      422 => ValidationException(
          message: serverMessage ?? 'Dados inválidos.',
          errors: _parseValidationErrors(data),
        ),
      final s when s != null && s >= 500 => const ServerException(),
      _ => UnknownException(message: serverMessage ?? 'Erro desconhecido.'),
    };
  }

  Map<String, List<String>> _parseValidationErrors(dynamic data) {
    if (data is! Map) return {};
    final errors = data['errors'];
    if (errors is! Map) return {};
    return errors.map(
      (key, value) => MapEntry(
        key.toString(),
        (value as List).map((e) => e.toString()).toList(),
      ),
    );
  }
}
