import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences? _sharedPreferences;

  DioClient({
    FlutterSecureStorage? secureStorage,
    SharedPreferences? sharedPreferences,
  })  : _secureStorage = secureStorage,
        _sharedPreferences = sharedPreferences,
        _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
            receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createLoggerInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
  }

  Dio get dio => _dio;

  // Auth Interceptor - Adds JWT token to requests
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip auth for login/register endpoints
        if (options.path.contains('/auth/login') ||
            options.path.contains('/auth/register')) {
          return handler.next(options);
        }

        // Get token from secure storage (native) or shared preferences (web)
        final token = await _secureStorage?.read(key: 'access_token')
            ?? _sharedPreferences?.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 - Unauthorized (token expired)
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final options = error.requestOptions;
            final token = await _secureStorage?.read(key: 'access_token')
                ?? _sharedPreferences?.getString('access_token');
            options.headers['Authorization'] = 'Bearer $token';

            try {
              final response = await _dio.request(
                options.path,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
                data: options.data,
                queryParameters: options.queryParameters,
              );
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
        }
        return handler.next(error);
      },
    );
  }

  // Logger Interceptor
  Interceptor _createLoggerInterceptor() {
    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    );
  }

  // Error Interceptor
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final message = _handleError(error);
        final modifiedError = DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: message,
        );
        return handler.next(modifiedError);
      },
    );
  }

  // Refresh Token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage?.read(key: 'refresh_token')
          ?? _sharedPreferences?.getString('refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (_secureStorage != null) {
          await _secureStorage.write(key: 'access_token', value: data['accessToken']);
          await _secureStorage.write(key: 'refresh_token', value: data['refreshToken']);
        } else {
          await _sharedPreferences?.setString('access_token', data['accessToken']);
          await _sharedPreferences?.setString('refresh_token', data['refreshToken']);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Handle Errors
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);

      case DioExceptionType.cancel:
        return 'Request was cancelled';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      case DioExceptionType.badCertificate:
        return 'Invalid certificate';

      case DioExceptionType.unknown:
      default:
        return error.response?.data['message'] ?? 'An unexpected error occurred';
    }
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Resource not found';
      case 500:
        return 'Internal server error';
      case 503:
        return 'Service unavailable';
      default:
        return 'Error: $statusCode';
    }
  }
}
