import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../utils/date_time_utils.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../services/api_service.dart';
import '../../features/milk_production/data/datasources/feed_local_data_source.dart';
import '../../features/milk_production/data/repositories/milk_production_repository_impl.dart';
import '../../features/milk_production/domain/repositories/milk_production_repository.dart';
import '../../features/milk_production/presentation/bloc/milk_production_bloc.dart';

// Cattle Feature Imports
import '../../features/cattle/data/datasources/cattle_remote_data_source.dart';
import '../../features/cattle/data/datasources/cattle_local_data_source.dart';
import '../../features/cattle/data/repositories/cattle_repository_impl.dart';
import '../../features/cattle/domain/repositories/cattle_repository.dart';
import '../../features/cattle/presentation/bloc/cattle_bloc.dart';

// Auth Feature Imports
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // ========== Core ==========

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => Connectivity());

  // Initialize Hive
  await Hive.initFlutter();

  // Utils
  sl.registerLazySingleton(() => DateTimeUtils());

  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => ApiService(apiClient: sl()));

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<FeedLocalDataSource>(
    () => FeedLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ========== Features ==========
  _initCattleFeature();
  _initAuthFeature();
  _initMilkProductionFeature();
}

void _initMilkProductionFeature() {
  sl.registerLazySingleton<MilkProductionRepository>(
        () => MilkProductionRepositoryImpl(apiService: sl()),
  );

  sl.registerFactory(() => MilkProductionBloc(
    repository: sl(),
    cattleBloc: sl<CattleBloc>(), // This can stay if you want, but the UI method is more reliable
  ));
}// Example feature initialization
void _initAuthFeature() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerFactory(() => AuthBloc(repository: sl()));
}

void _initCattleFeature() {
  // Data sources
  sl.registerLazySingleton<CattleRemoteDataSource>(
    () => CattleRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CattleLocalDataSource>(
    () => CattleLocalDataSourceImpl(sharedPreferences: sl()),
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
  sl.registerFactory(() => CattleBloc(repository: sl()));
}
