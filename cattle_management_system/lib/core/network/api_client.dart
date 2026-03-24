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
import '../services/app_feedback_service.dart';
import '../services/navigation_service.dart';

/// API Client using Dio
class ApiClient {
  late final Dio _dio;
  static bool _isHandlingUnauthorized = false;
  final Map<String, Response> _cache = {};
  final Map<String, DateTime> _cacheTime = {};
  final Map<String, Future<Response>> _inFlightGetRequests = {};
  final Duration _cacheTTL = const Duration(minutes: 5);

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
          if (options.method == 'GET') {
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
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
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
              response.statusCode == 200) {
            final cacheKey =
                "${response.requestOptions.path}${response.requestOptions.queryParameters}";
            _cache[cacheKey] = response;
            _cacheTime[cacheKey] = DateTime.now();
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isHandlingUnauthorized) {
            _isHandlingUnauthorized = true;
            final ctx = NavigationService.navigatorKey.currentContext;

            if (ctx != null) {
              final lang = Localizations.localeOf(ctx).languageCode;
              final title = lang == 'hi'
                  ? 'सत्र समाप्त'
                  : lang == 'gu'
                      ? 'સેશન સમાપ્ત'
                      : 'Session expired';
              final message = lang == 'hi'
                  ? 'सत्र समाप्त हो गया है। कृपया फिर से लॉग इन करें।'
                  : lang == 'gu'
                      ? 'સેશન સમાપ્ત થયું છે. કૃપા કરીને ફરી લૉગિન કરો.'
                      : 'Session expired. Please log in again.';
              final buttonText = lang == 'hi'
                  ? 'फिर से लॉगिन करें'
                  : lang == 'gu'
                      ? 'ફરી લૉગિન કરો'
                      : 'Login again';

              await AppFeedbackService.showPopup(
                title: title,
                message: message,
                type: AppFeedbackType.error,
                dedupeKey: 'session_expired',
                primaryLabel: buttonText,
                barrierDismissible: false,
                onPrimary: () async {
                  try {
                    await get_it.GetIt.instance<AuthRepository>().logout();
                  } catch (_) {}

                  if (ctx.mounted) {
                    Navigator.pushAndRemoveUntil(
                      ctx,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
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

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final cacheKey =
        '$path${queryParameters ?? const <String, dynamic>{}}${options?.responseType ?? ResponseType.json}';

    final inFlight = _inFlightGetRequests[cacheKey];
    if (inFlight != null) {
      debugPrint('--- [ApiClient] Joining In-Flight GET: $path ---');
      return await inFlight;
    }

    late final Future<Response> requestFuture;
    requestFuture = _dio
        .get(
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
        final message =
            error.response?.data['message'] ?? 'Server error occurred';

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
