import 'dart:convert';

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' as get_it;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../config/app_config.dart';
import '../error/exceptions.dart';
import '../services/navigation_service.dart';

/// API Client using Dio
class ApiClient {
  late final Dio _dio;
  static bool _isHandlingUnauthorized = false;
  static bool _hasRedirectedToLogin = false;
  final Map<String, Response> _cache = {};
  final Map<String, DateTime> _cacheTime = {};
  final Map<String, Future<Response>> _inFlightGetRequests = {};
  final Duration _cacheTTL = const Duration(minutes: 5);
  static const int _maxGetRetries = 2;

  bool _isNonCacheableGet(String path) {
    return path == '/api/animal/media/presigned-url';
  }

  void _clearGetCache() {
    _cache.clear();
    _cacheTime.clear();
  }

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConfig.connectionTimeout,
        ),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Cache check for GET requests
          if (options.method == 'GET' && !_isNonCacheableGet(options.path)) {
            final cacheKey = "${options.path}${options.queryParameters}";
            final cachedResponse = _cache[cacheKey];
            final cachedTime = _cacheTime[cacheKey];

            if (cachedTime != null &&
                DateTime.now().difference(cachedTime) < _cacheTTL &&
                cachedResponse != null) {
              debugPrint("--- [ApiClient] Serving Cache: ${options.path} ---");
              return handler.resolve(cachedResponse);
            }
          }

          final token = await _getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            _hasRedirectedToLogin = false;
          }

          final gaushalaId = await _getGaushalaId();
          if (gaushalaId != null) {
            options.headers['gaushala-id'] = gaushalaId;
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Record successful GET responses into memory cache
          if (response.requestOptions.method == 'GET' &&
              !_isNonCacheableGet(response.requestOptions.path) &&
              response.statusCode == 200) {
            final cacheKey =
                "${response.requestOptions.path}${response.requestOptions.queryParameters}";
            _cache[cacheKey] = response;
            _cacheTime[cacheKey] = DateTime.now();
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !_isHandlingUnauthorized &&
              !_hasRedirectedToLogin &&
              await _shouldTreat401AsSessionExpired(error)) {
            _isHandlingUnauthorized = true;
            _hasRedirectedToLogin = true;

            try {
              await get_it.GetIt.instance<AuthRepository>().logout();
            } catch (_) {}

            final ctx = NavigationService.navigatorKey.currentContext;
            if (ctx != null && ctx.mounted) {
              Navigator.pushAndRemoveUntil(
                ctx,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            }

            _isHandlingUnauthorized = false;
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getGaushalaId() async {
    try {
      final prefs = await get_it.GetIt.instance.getAsync<SharedPreferences>();
      return prefs.getString('gaushala_id');
    } catch (_) {
      try {
        final prefs = get_it.GetIt.instance<SharedPreferences>();
        return prefs.getString('gaushala_id');
      } catch (_) {
        return null;
      }
    }
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await get_it.GetIt.instance.getAsync<SharedPreferences>();
      return prefs.getString('auth_token');
    } catch (_) {
      try {
        final prefs = get_it.GetIt.instance<SharedPreferences>();
        return prefs.getString('auth_token');
      } catch (_) {
        return null;
      }
    }
  }

  Future<bool> _shouldTreat401AsSessionExpired(DioException error) async {
    final path = error.requestOptions.path.toLowerCase();
    if (path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/forgot') ||
        path.contains('/api/auth/reset') ||
        path.contains('/api/auth/verify')) {
      return false;
    }

    final token = await _getAuthToken();
    final authHeader =
        error.requestOptions.headers['Authorization']?.toString();
    if ((token == null || token.isEmpty) &&
        (authHeader == null || authHeader.isEmpty)) {
      return false;
    }

    if (token == null || token.isEmpty) return true;
    if (_isJwtExpired(token)) return true;

    final responseData = error.response?.data;
    if (responseData is Map) {
      final directMessage = responseData['message']?.toString().toLowerCase();
      final errors = responseData['errors'];
      final nestedMessage =
          errors is List && errors.isNotEmpty && errors.first is Map
          ? errors.first['message']?.toString().toLowerCase()
          : null;
      final combined = '${directMessage ?? ''} ${nestedMessage ?? ''}';
      if (combined.contains('expired') ||
          combined.contains('invalid token') ||
          combined.contains('jwt') ||
          combined.contains('token')) {
        return true;
      }
    }

    return false;
  }

  bool _isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded);
      if (data is! Map<String, dynamic>) return false;

      final exp = data['exp'];
      if (exp is! num) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (_) {
      return false;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (_isNonCacheableGet(path)) {
      try {
        return await _executeGetWithRetry(
          path,
          queryParameters: queryParameters,
          options: options,
        );
      } on DioException catch (e) {
        throw _handleDioError(e);
      }
    }

    final cacheKey =
        '$path${queryParameters ?? const <String, dynamic>{}}${options?.responseType ?? ResponseType.json}';

    final inFlight = _inFlightGetRequests[cacheKey];
    if (inFlight != null) {
      debugPrint('--- [ApiClient] Joining In-Flight GET: $path ---');
      return await inFlight;
    }

    late final Future<Response> requestFuture;
    requestFuture = _executeGetWithRetry(
          path,
          queryParameters: queryParameters,
          options: options,
        )
        .whenComplete(() {
          _inFlightGetRequests.remove(cacheKey);
        });

    _inFlightGetRequests[cacheKey] = requestFuture;

    try {
      final response = await requestFuture;
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> _executeGetWithRetry(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    DioException? lastError;

    for (var attempt = 0; attempt < _maxGetRetries; attempt++) {
      try {
        return await _dio.get(
          path,
          queryParameters: queryParameters,
          options: options,
        );
      } on DioException catch (e) {
        lastError = e;
        if (!_shouldRetryGet(e) || attempt == _maxGetRetries - 1) {
          rethrow;
        }

        final retryDelaySeconds = attempt + 1;
        debugPrint(
          '--- [ApiClient] Retrying GET $path in ${retryDelaySeconds}s (attempt ${attempt + 2}/$_maxGetRetries) ---',
        );
        await Future.delayed(Duration(seconds: retryDelaySeconds));
      }
    }

    throw lastError ??
        DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.unknown,
        );
  }

  bool _shouldRetryGet(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    final statusCode = error.response?.statusCode;
    return statusCode == 502 || statusCode == 503 || statusCode == 504;
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      _clearGetCache();
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      _clearGetCache();
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      _clearGetCache();
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      _clearGetCache();
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Request timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String message = 'Server error occurred';
        if (responseData is Map) {
          final directMessage = responseData['message']?.toString().trim();
          final errors = responseData['errors'];
          final nestedMessage =
              errors is List && errors.isNotEmpty && errors.first is Map
              ? (errors.first['message']?.toString().trim())
              : null;
          if (directMessage != null && directMessage.isNotEmpty) {
            message = directMessage;
          } else if (nestedMessage != null && nestedMessage.isNotEmpty) {
            message = nestedMessage;
          }
        }

        if (statusCode == 401) {
          return AuthenticationException(message, statusCode);
        } else if (statusCode == 403) {
          return PermissionException(message);
        } else if (statusCode == 404) {
          return ServerException('Resource not found', statusCode);
        } else if (statusCode != null && statusCode >= 500) {
          // Check for Prisma / Database transaction timeouts specifically
          if (message.contains('transaction') && message.contains('expired')) {
            return ServerException(
              'Database is busy. Clearing animal history is taking longer than expected. Please try again in 10 seconds.',
              statusCode,
            );
          }
          if (statusCode == 502 || statusCode == 503 || statusCode == 504) {
            return ServerException(
              'Server is busy right now. Please try again in a moment.',
              statusCode,
            );
          }
          return ServerException(
            'Server error. Please try again later.',
            statusCode,
          );
        }
        return ServerException(message, statusCode);

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.cancel:
        return ServerException('Request cancelled');

      default:
        return ServerException('An unexpected error occurred');
    }
  }
}

