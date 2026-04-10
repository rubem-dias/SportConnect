sealed class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException({super.message = 'Sem conexão com a internet.'});
}

final class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Tempo limite da requisição excedido.'});
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Sessão expirada. Faça login novamente.',
    super.statusCode = 401,
  });
}

final class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Você não tem permissão para esta ação.',
    super.statusCode = 403,
  });
}

final class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Recurso não encontrado.',
    super.statusCode = 404,
  });
}

final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    required this.errors,
    super.statusCode = 422,
  });

  final Map<String, List<String>> errors;
}

final class ServerException extends AppException {
  const ServerException({
    super.message = 'Erro interno do servidor. Tente novamente.',
    super.statusCode = 500,
  });
}

final class UnknownException extends AppException {
  const UnknownException({super.message = 'Ocorreu um erro inesperado.'});
}
