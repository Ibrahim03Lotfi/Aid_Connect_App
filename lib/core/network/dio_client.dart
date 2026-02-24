import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../services/local_storage_service.dart';
import '../errors/failures.dart';
import 'api_response.dart';

class DioClient {
  late Dio _dio;
  final Logger _logger = Logger();
  final LocalStorageService _localStorage;

  DioClient(this._localStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8000/api', // Change to your API URL
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    // Request Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to headers if available
          final token = await _localStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Add language header
          options.headers['Accept-Language'] = 'ar';

          if (kDebugMode) {
            _logger.i('REQUEST[${options.method}] => PATH: ${options.path}');
            _logger.i('Headers: ${options.headers}');
            _logger.i('Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            _logger.i('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
            _logger.i('Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            _logger.e('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
            _logger.e('Error: ${error.message}');
            _logger.e('Response: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file with progress
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    required T Function(dynamic) fromJsonT,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure('انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);

        switch (statusCode) {
          case 400:
            return ValidationFailure(message, errors: error.response?.data?['errors']);
          case 401:
            return UnauthorizedFailure(message);
          case 403:
            return UnauthorizedFailure(message);
          case 404:
            return NotFoundFailure(message);
          case 422:
            return ValidationFailure(message, errors: error.response?.data?['errors']);
          case 500:
          case 502:
          case 503:
            return ServerFailure(message, statusCode: statusCode);
          default:
            return ServerFailure(message, statusCode: statusCode);
        }

      case DioExceptionType.connectionError:
        return const NetworkFailure('لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك');

      case DioExceptionType.cancel:
        return const UnknownFailure('تم إلغاء الطلب');

      default:
        return UnknownFailure(error.message ?? 'حدث خطأ غير متوقع');
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'حدث خطأ غير متوقع';
    
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
    }
    
    return 'حدث خطأ غير متوقع';
  }
}
