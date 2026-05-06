import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../services/local_storage_service.dart';
import '../../shared/constants/app_constants.dart';
import '../errors/failures.dart';
import 'api_response.dart';

class HttpClient {
  final Logger _logger = Logger();
  final LocalStorageService _localStorage;
  final http.Client _client;

  HttpClient(this._localStorage, {http.Client? client})
    : _client = client ?? http.Client();

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      fromJsonT: fromJsonT,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    return _request(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJsonT: fromJsonT,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    return _request(
      method: 'PUT',
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJsonT: fromJsonT,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    return _request(
      method: 'DELETE',
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJsonT: fromJsonT,
    );
  }

  Future<ApiResponse<T>> _request<T>({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
  }) async {
    try {
      final token = await _localStorage.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse(
        '${AppConstants.baseUrl}$path',
      ).replace(queryParameters: _encodeQuery(queryParameters));

      if (kDebugMode) {
        _logger.i('$method => $uri');
      }

      late http.Response response;
      final encodedBody = data == null ? null : jsonEncode(data);
      final timeout = Duration(seconds: AppConstants.connectionTimeout);

      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(timeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encodedBody)
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers, body: encodedBody)
              .timeout(timeout);
          break;
        default:
          throw const UnknownFailure('HTTP method not supported');
      }

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};
      final body = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(body, fromJsonT);
      }

      throw _mapHttpError(response.statusCode, body);
    } on TimeoutException {
      throw const TimeoutFailure('انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى');
    } on Failure {
      rethrow;
    } on http.ClientException {
      throw const NetworkFailure('لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك');
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Failure _mapHttpError(int statusCode, Map<String, dynamic> body) {
    final message = _extractErrorMessage(body);
    switch (statusCode) {
      case 400:
        return ValidationFailure(message, errors: body['errors']);
      case 401:
      case 403:
        return UnauthorizedFailure(message);
      case 404:
        return NotFoundFailure(message);
      case 422:
        return ValidationFailure(message, errors: body['errors']);
      default:
        return ServerFailure(message, statusCode: statusCode);
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return 'حدث خطأ غير متوقع';
  }

  Map<String, String>? _encodeQuery(Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return null;
    return queryParameters.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }
}
