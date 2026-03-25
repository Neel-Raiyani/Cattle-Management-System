import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, String>> login(String mobile, String password) async {
    if (await networkInfo.isConnected) {
      try {
        dynamic data;
        try {
          data = await remoteDataSource.login(mobile, password);
        } catch (e) {
          // Retry logic for cold start / wake up timeout
          debugPrint('[Auth] Login timed out, retrying once in 2s...');
          await Future.delayed(const Duration(seconds: 2));
          data = await remoteDataSource.login(mobile, password);
        }
        
        final token = data['token'] as String?;

        // Extract the gaushalaId from the gaushalas array properly
        String? gaushalaId;
        if (data['gaushalas'] != null &&
            data['gaushalas'] is List &&
            data['gaushalas'].isNotEmpty) {
          gaushalaId = data['gaushalas'][0]['id'] as String?;
          // Fallback if 'id' key differs
          gaushalaId ??= data['gaushalas'][0]['_id'] as String?;
        }

        if (token != null) {
          await sharedPreferences.setString('auth_token', token);
          if (gaushalaId != null) {
            await sharedPreferences.setString('gaushala_id', gaushalaId);
          }
          // Profile name will be fetched lazily when requested via getUserName()
          // or on the dashboard, to keep login fast.
          await localDataSource.loginUser(mobile, mobile); // simulate local
        }
        return Right(token ?? 'UnknownToken');
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String name,
    String mobile,
    String password,
    String confirmPassword,
    String city,
    String gaushalaName,
    int totalCattle,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.register(
          name,
          mobile,
          password,
          confirmPassword,
          city,
          gaushalaName,
          totalCattle,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await sharedPreferences.remove('auth_token');
      await sharedPreferences.remove('gaushala_id');
      await sharedPreferences.remove('user_name');
      await localDataSource.logout();
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure('Logout failed'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = sharedPreferences.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      if (_isTokenExpired(token)) {
        await logout();
        return false;
      }
      return true;
    }
    return await localDataSource.isLoggedIn();
  }

  bool _isTokenExpired(String token) {
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

  @override
  Future<Either<Failure, String>> getUserName() async {
    // 1. Try SharedPreferences first
    final cachedName = sharedPreferences.getString('user_name');
    if (cachedName != null && cachedName.isNotEmpty) {
      return Right(cachedName);
    }

    // 2. Otherwise fetch from profile API
    if (await networkInfo.isConnected) {
      try {
        final profile = await remoteDataSource.getProfile();
        final name = profile['name'] as String? ?? 'User';
        await sharedPreferences.setString('user_name', name);
        return Right(name);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
