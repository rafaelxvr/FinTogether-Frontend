import 'package:dio/dio.dart';
import '../utils/failure.dart';

mixin BaseRepositoryMixin {
  Failure handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timed out. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] as String?;
        if (statusCode == 401) {
          return UnauthorizedFailure(message ?? 'Session expired. Please login again.');
        }
        if (statusCode == 403) {
          return ServerFailure(message ?? 'Access denied.');
        }
        if (statusCode == 404) {
          return ServerFailure(message ?? 'Resource not found.');
        }
        return ServerFailure(message ?? 'An error occurred');
      case DioExceptionType.cancel:
        return const ServerFailure('Request was cancelled.');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection. Please check your network.');
      case DioExceptionType.unknown:
      default:
        return ServerFailure(e.message ?? 'An unexpected error occurred.');
    }
  }
}
