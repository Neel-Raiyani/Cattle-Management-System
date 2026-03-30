import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String mobile, String password);
  Future<Map<String, dynamic>> register(
    String name,
    String mobile,
    String password,
    String confirmPassword,
    String city,
    String gaushalaName,
    int totalCattle,
  );
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> registerFcmToken(String fcmToken);
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
  Future<Map<String, dynamic>> sendForgotPasswordOtp({
    required String mobileNumber,
  });
  Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required String mobileNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login(String mobile, String password) async {
    try {
      final response = await apiClient.post(
        '/api/auth/login',
        data: {'mobileNumber': mobile, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw ServerException(
          e.response!.data['message'] ?? 'Login failed',
          e.response!.statusCode ?? 400,
        );
      }
      throw ServerException('Failed to login', 500);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to login', 500);
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String name,
    String mobile,
    String password,
    String confirmPassword,
    String city,
    String gaushalaName,
    int totalCattle,
  ) async {
    try {
      final response = await apiClient.post(
        '/api/auth/register',
        data: {
          'name': name,
          'mobileNumber': mobile,
          'password': password,
          'confirmPassword': confirmPassword,
          'city': city,
          'gaushalaName': gaushalaName,
          'totalCattle': totalCattle,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw ServerException(
          e.response!.data['message'] ?? 'Registration failed',
          e.response!.statusCode ?? 400,
        );
      }
      throw ServerException('Failed to register', 500);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to register', 500);
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await apiClient.get('/api/auth/profile');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw ServerException(
          e.response!.data['message'] ?? 'Failed to get profile',
          e.response!.statusCode ?? 400,
        );
      }
      throw ServerException('Failed to get profile', 500);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get profile', 500);
    }
  }

  @override
  Future<Map<String, dynamic>> registerFcmToken(String fcmToken) async {
    try {
      final response = await apiClient.post(
        '/api/auth/profile/fcm-token',
        data: {'fcmToken': fcmToken},
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw ServerException(
          e.response!.data['message'] ?? 'Failed to register FCM token',
          e.response!.statusCode ?? 400,
        );
      }
      throw ServerException('Failed to register FCM token', 500);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to register FCM token', 500);
    }
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/auth/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = Map<String, dynamic>.from(e.response!.data);
        final errors = data['errors'];
        final nestedMessage =
            errors is List && errors.isNotEmpty && errors.first is Map
            ? errors.first['message']?.toString()
            : null;
        throw ServerException(
          nestedMessage ?? data['message'] ?? 'Failed to change password',
          e.response!.statusCode ?? 400,
        );
      }
      throw ServerException('Failed to change password', 500);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to change password', 500);
    }
  }

  @override
  Future<Map<String, dynamic>> sendForgotPasswordOtp({
    required String mobileNumber,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/auth/forgot-password/send-otp',
        data: {'mobileNumber': mobileNumber},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = Map<String, dynamic>.from(e.response!.data);
        final errors = data['errors'];
        final nestedMessage =
            errors is List && errors.isNotEmpty && errors.first is Map
            ? errors.first['message']?.toString()
            : null;
        throw ServerException(
          nestedMessage ?? data['message'] ?? 'Failed to send OTP',
          e.response!.statusCode ?? 400,
        );
      }
      throw ServerException('Failed to send OTP', 500);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to send OTP', 500);
    }
  }

  @override
  Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required String mobileNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/auth/forgot-password/verify',
        data: {
          'mobileNumber': mobileNumber,
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = Map<String, dynamic>.from(e.response!.data);
        final errors = data['errors'];
        final nestedMessage =
            errors is List && errors.isNotEmpty && errors.first is Map
            ? errors.first['message']?.toString()
            : null;
        throw ServerException(
          nestedMessage ?? data['message'] ?? 'Failed to verify OTP',
          e.response!.statusCode ?? 400,
        );
      }
      throw ServerException('Failed to verify OTP', 500);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to verify OTP', 500);
    }
  }
}
