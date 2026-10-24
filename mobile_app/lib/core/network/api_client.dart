import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import 'api_config.dart';
import 'token_storage.dart';

/// Shared Dio instance: attaches the bearer token to every request and maps
/// failures to [AppException] so screens can keep doing
/// `catch (e) { showError(e.toString()) }` regardless of whether the data
/// came from a mock repository or this real one.
class ApiClient {
  ApiClient._();

  static final Dio instance = _build();

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.readAccessToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await TokenStorage.clear();
          }
          handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: AppException(_messageFor(error)),
            ),
          );
        },
      ),
    );

    return dio;
  }

  static String _messageFor(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return "Can't reach TrustGuard right now. Check your connection and try again.";
    }
    return 'Something went wrong. Please try again.';
  }
}

/// Unwraps a [DioException] thrown by [ApiClient] into the [AppException] it
/// already carries, so call sites can just `catch (e)` and show `e`.
Future<T> unwrapDioErrors<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on DioException catch (e) {
    if (e.error is AppException) throw e.error as AppException;
    rethrow;
  }
}
