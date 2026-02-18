# 🔌 API Integration Guide

## Overview

This guide explains how to integrate your backend APIs with the Flutter frontend using the established Clean Architecture and BLoC pattern.

---

## 📋 Prerequisites

Before integrating APIs, ensure you have:
1. ✅ Backend API endpoints ready
2. ✅ API documentation (Swagger/Postman)
3. ✅ Authentication mechanism (JWT, OAuth, etc.)
4. ✅ Base URL for your API

---

## 🎯 Step-by-Step Integration

### Step 1: Configure API Base URL

Update the base URL in the configuration file:

```dart
// lib/core/config/app_config.dart
class AppConfig {
  // Update this with your actual API URL
  static const String baseUrl = 'https://api.cattlemanagement.com/v1';
  
  // If you have an API key
  static const String apiKey = 'YOUR_API_KEY_HERE';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
}
```

---

### Step 2: Create Data Models

Data models extend domain entities and add JSON serialization.

#### Example: Cattle Model

```dart
// lib/features/cattle/data/models/cattle_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cattle.dart';

part 'cattle_model.g.dart';

@JsonSerializable()
class CattleModel extends Cattle {
  const CattleModel({
    required super.id,
    required super.tagNumber,
    required super.name,
    required super.breed,
    required super.gender,
    required super.dateOfBirth,
    super.color,
    super.weight,
    required super.status,
    super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
  });
  
  // From JSON (API Response)
  factory CattleModel.fromJson(Map<String, dynamic> json) =>
      _$CattleModelFromJson(json);
  
  // To JSON (API Request)
  Map<String, dynamic> toJson() => _$CattleModelToJson(this);
  
  // From Entity
  factory CattleModel.fromEntity(Cattle cattle) {
    return CattleModel(
      id: cattle.id,
      tagNumber: cattle.tagNumber,
      name: cattle.name,
      breed: cattle.breed,
      gender: cattle.gender,
      dateOfBirth: cattle.dateOfBirth,
      color: cattle.color,
      weight: cattle.weight,
      status: cattle.status,
      imageUrl: cattle.imageUrl,
      createdAt: cattle.createdAt,
      updatedAt: cattle.updatedAt,
    );
  }
}
```

**Run code generation:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Step 3: Create Remote Data Source

The remote data source handles all API calls for a feature.

```dart
// lib/features/cattle/data/datasources/cattle_remote_datasource.dart
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/cattle_model.dart';

abstract class CattleRemoteDataSource {
  /// Get all cattle
  Future<List<CattleModel>> getAllCattle({
    int? page,
    int? limit,
    String? status,
  });
  
  /// Get cattle by ID
  Future<CattleModel> getCattleById(String id);
  
  /// Add new cattle
  Future<CattleModel> addCattle(CattleModel cattle);
  
  /// Update cattle
  Future<CattleModel> updateCattle(String id, CattleModel cattle);
  
  /// Delete cattle
  Future<void> deleteCattle(String id);
  
  /// Search cattle
  Future<List<CattleModel>> searchCattle(String query);
}

class CattleRemoteDataSourceImpl implements CattleRemoteDataSource {
  final ApiClient client;
  
  CattleRemoteDataSourceImpl(this.client);
  
  @override
  Future<List<CattleModel>> getAllCattle({
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (status != null) queryParams['status'] = status;
      
      final response = await client.get(
        '/cattle',
        queryParameters: queryParams,
      );
      
      // Handle different response structures
      final data = response.data;
      
      // If response has a 'data' field
      final cattleList = data['data'] ?? data;
      
      return (cattleList as List)
          .map((json) => CattleModel.fromJson(json))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch cattle: ${e.toString()}');
    }
  }
  
  @override
  Future<CattleModel> getCattleById(String id) async {
    try {
      final response = await client.get('/cattle/$id');
      
      final data = response.data['data'] ?? response.data;
      return CattleModel.fromJson(data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch cattle details: ${e.toString()}');
    }
  }
  
  @override
  Future<CattleModel> addCattle(CattleModel cattle) async {
    try {
      final response = await client.post(
        '/cattle',
        data: cattle.toJson(),
      );
      
      final data = response.data['data'] ?? response.data;
      return CattleModel.fromJson(data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to add cattle: ${e.toString()}');
    }
  }
  
  @override
  Future<CattleModel> updateCattle(String id, CattleModel cattle) async {
    try {
      final response = await client.put(
        '/cattle/$id',
        data: cattle.toJson(),
      );
      
      final data = response.data['data'] ?? response.data;
      return CattleModel.fromJson(data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update cattle: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteCattle(String id) async {
    try {
      await client.delete('/cattle/$id');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete cattle: ${e.toString()}');
    }
  }
  
  @override
  Future<List<CattleModel>> searchCattle(String query) async {
    try {
      final response = await client.get(
        '/cattle/search',
        queryParameters: {'q': query},
      );
      
      final data = response.data['data'] ?? response.data;
      return (data as List)
          .map((json) => CattleModel.fromJson(json))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to search cattle: ${e.toString()}');
    }
  }
}
```

---

### Step 4: Create Local Data Source (for Offline Support)

```dart
// lib/features/cattle/data/datasources/cattle_local_datasource.dart
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../models/cattle_model.dart';

abstract class CattleLocalDataSource {
  Future<List<CattleModel>> getCachedCattle();
  Future<void> cacheCattle(List<CattleModel> cattle);
  Future<CattleModel?> getCachedCattleById(String id);
  Future<void> cacheSingleCattle(CattleModel cattle);
  Future<void> deleteCachedCattle(String id);
  Future<void> clearCache();
}

class CattleLocalDataSourceImpl implements CattleLocalDataSource {
  late Box<Map> cattleBox;
  
  CattleLocalDataSourceImpl() {
    _initBox();
  }
  
  Future<void> _initBox() async {
    cattleBox = await Hive.openBox<Map>(AppConfig.cattleBoxName);
  }
  
  @override
  Future<List<CattleModel>> getCachedCattle() async {
    try {
      final cattleList = cattleBox.values
          .map((json) => CattleModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return cattleList;
    } catch (e) {
      throw CacheException('Failed to get cached cattle');
    }
  }
  
  @override
  Future<void> cacheCattle(List<CattleModel> cattle) async {
    try {
      await cattleBox.clear();
      for (var item in cattle) {
        await cattleBox.put(item.id, item.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache cattle');
    }
  }
  
  @override
  Future<CattleModel?> getCachedCattleById(String id) async {
    try {
      final json = cattleBox.get(id);
      if (json == null) return null;
      return CattleModel.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      throw CacheException('Failed to get cached cattle by ID');
    }
  }
  
  @override
  Future<void> cacheSingleCattle(CattleModel cattle) async {
    try {
      await cattleBox.put(cattle.id, cattle.toJson());
    } catch (e) {
      throw CacheException('Failed to cache single cattle');
    }
  }
  
  @override
  Future<void> deleteCachedCattle(String id) async {
    try {
      await cattleBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete cached cattle');
    }
  }
  
  @override
  Future<void> clearCache() async {
    try {
      await cattleBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }
}
```

---

### Step 5: Create Repository Implementation

The repository coordinates between remote and local data sources.

```dart
// lib/features/cattle/data/repositories/cattle_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cattle.dart';
import '../../domain/repositories/cattle_repository.dart';
import '../datasources/cattle_remote_datasource.dart';
import '../datasources/cattle_local_datasource.dart';

class CattleRepositoryImpl implements CattleRepository {
  final CattleRemoteDataSource remoteDataSource;
  final CattleLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  CattleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<Cattle>>> getAllCattle({
    bool forceRefresh = false,
  }) async {
    final isConnected = await networkInfo.isConnected;
    
    if (isConnected || forceRefresh) {
      try {
        final cattle = await remoteDataSource.getAllCattle();
        await localDataSource.cacheCattle(cattle);
        return Right(cattle);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      try {
        final cattle = await localDataSource.getCachedCattle();
        return Right(cattle);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }
  
  @override
  Future<Either<Failure, Cattle>> getCattleById(String id) async {
    final isConnected = await networkInfo.isConnected;
    
    if (isConnected) {
      try {
        final cattle = await remoteDataSource.getCattleById(id);
        await localDataSource.cacheSingleCattle(cattle);
        return Right(cattle);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cattle = await localDataSource.getCachedCattleById(id);
        if (cattle == null) {
          return Left(CacheFailure('Cattle not found in cache'));
        }
        return Right(cattle);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }
  
  @override
  Future<Either<Failure, Cattle>> addCattle(Cattle cattle) async {
    try {
      final cattleModel = CattleModel.fromEntity(cattle);
      final result = await remoteDataSource.addCattle(cattleModel);
      await localDataSource.cacheSingleCattle(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, Cattle>> updateCattle(Cattle cattle) async {
    try {
      final cattleModel = CattleModel.fromEntity(cattle);
      final result = await remoteDataSource.updateCattle(cattle.id, cattleModel);
      await localDataSource.cacheSingleCattle(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteCattle(String id) async {
    try {
      await remoteDataSource.deleteCattle(id);
      await localDataSource.deleteCachedCattle(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

---

### Step 6: Create Repository Interface (Domain Layer)

```dart
// lib/features/cattle/domain/repositories/cattle_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cattle.dart';

abstract class CattleRepository {
  Future<Either<Failure, List<Cattle>>> getAllCattle({bool forceRefresh = false});
  Future<Either<Failure, Cattle>> getCattleById(String id);
  Future<Either<Failure, Cattle>> addCattle(Cattle cattle);
  Future<Either<Failure, Cattle>> updateCattle(Cattle cattle);
  Future<Either<Failure, void>> deleteCattle(String id);
}
```

---

### Step 7: Register Dependencies

```dart
// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import '../features/cattle/data/datasources/cattle_remote_datasource.dart';
import '../features/cattle/data/datasources/cattle_local_datasource.dart';
import '../features/cattle/data/repositories/cattle_repository_impl.dart';
import '../features/cattle/domain/repositories/cattle_repository.dart';
import '../features/cattle/presentation/bloc/cattle_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ... existing core dependencies
  
  _initCattleFeature();
}

void _initCattleFeature() {
  // Data sources
  sl.registerLazySingleton<CattleRemoteDataSource>(
    () => CattleRemoteDataSourceImpl(sl()),
  );
  
  sl.registerLazySingleton<CattleLocalDataSource>(
    () => CattleLocalDataSourceImpl(),
  );
  
  // Repository
  sl.registerLazySingleton<CattleRepository>(
    () => CattleRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // BLoC
  sl.registerFactory(
    () => CattleBloc(repository: sl()),
  );
}
```

---

### Step 8: Update BLoC to Use Repository

```dart
// lib/features/cattle/presentation/bloc/cattle_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cattle_repository.dart';
import 'cattle_event.dart';
import 'cattle_state.dart';

class CattleBloc extends Bloc<CattleEvent, CattleState> {
  final CattleRepository repository;
  
  CattleBloc({required this.repository}) : super(CattleInitial()) {
    on<LoadCattleList>(_onLoadCattleList);
    on<AddCattle>(_onAddCattle);
    // ... other events
  }
  
  Future<void> _onLoadCattleList(
    LoadCattleList event,
    Emitter<CattleState> emit,
  ) async {
    emit(CattleLoading());
    
    final result = await repository.getAllCattle(
      forceRefresh: event.forceRefresh,
    );
    
    result.fold(
      (failure) => emit(CattleError(failure.message)),
      (cattleList) {
        if (cattleList.isEmpty) {
          emit(const CattleEmpty('No cattle found'));
        } else {
          emit(CattleListLoaded(cattleList));
        }
      },
    );
  }
  
  Future<void> _onAddCattle(
    AddCattle event,
    Emitter<CattleState> emit,
  ) async {
    emit(CattleLoading());
    
    final result = await repository.addCattle(event.cattle);
    
    result.fold(
      (failure) => emit(CattleError(failure.message)),
      (cattle) => emit(CattleAdded(cattle)),
    );
  }
}
```

---

## 🔐 Authentication

### JWT Token Management

```dart
// lib/core/network/api_client.dart
Future<String?> _getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(AppConfig.userTokenKey);
}

// Save token after login
Future<void> saveAuthToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(AppConfig.userTokenKey, token);
}

// Clear token on logout
Future<void> clearAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(AppConfig.userTokenKey);
}
```

---

## 📊 API Response Formats

### Standard Success Response
```json
{
  "success": true,
  "data": {
    "id": "123",
    "tagNumber": "COW-001",
    "name": "Gaumata",
    ...
  },
  "message": "Cattle added successfully"
}
```

### List Response
```json
{
  "success": true,
  "data": [
    { "id": "1", ... },
    { "id": "2", ... }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": 400,
    "message": "Validation failed",
    "details": {
      "tagNumber": "Tag number already exists"
    }
  }
}
```

---

## 🧪 Testing API Integration

### Using Postman/Thunder Client

1. Test each endpoint individually
2. Verify response structure
3. Check error handling
4. Test with invalid data

### Using Flutter

```dart
// Test in main.dart temporarily
void testApi() async {
  final client = ApiClient();
  try {
    final response = await client.get('/cattle');
    print('Success: ${response.data}');
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## 🚀 Next Steps

1. ✅ Configure base URL
2. ✅ Create data models
3. ✅ Implement data sources
4. ✅ Create repositories
5. ✅ Update BLoC
6. ✅ Test integration
7. 🔄 Add error handling
8. 🔄 Implement offline sync
9. 🔄 Add authentication
10. 🔄 Test on production

---

**Your API is now integrated! 🎉**
