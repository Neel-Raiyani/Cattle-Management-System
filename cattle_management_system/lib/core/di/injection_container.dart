import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../utils/date_time_utils.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

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
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
  
  sl.registerLazySingleton(() => ApiClient());

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  // ========== Features ==========
  // TODO: Register feature-specific dependencies here
  // Example:
  // _initCattleFeature();
  // _initHealthRecordsFeature();
  // _initMilkProductionFeature();
}

// Example feature initialization
// void _initCattleFeature() {
//   // Data sources
//   sl.registerLazySingleton<CattleRemoteDataSource>(
//     () => CattleRemoteDataSourceImpl(sl()),
//   );
//   
//   sl.registerLazySingleton<CattleLocalDataSource>(
//     () => CattleLocalDataSourceImpl(sl()),
//   );
//   
//   // Repository
//   sl.registerLazySingleton<CattleRepository>(
//     () => CattleRepositoryImpl(
//       remoteDataSource: sl(),
//       localDataSource: sl(),
//       networkInfo: sl(),
//     ),
//   );
//   
//   // Use cases
//   sl.registerLazySingleton(() => GetAllCattle(sl()));
//   sl.registerLazySingleton(() => GetCattleById(sl()));
//   sl.registerLazySingleton(() => AddCattle(sl()));
//   sl.registerLazySingleton(() => UpdateCattle(sl()));
//   sl.registerLazySingleton(() => DeleteCattle(sl()));
//   
//   // BLoC
//   sl.registerFactory(
//     () => CattleBloc(
//       getAllCattle: sl(),
//       getCattleById: sl(),
//       addCattle: sl(),
//       updateCattle: sl(),
//       deleteCattle: sl(),
//     ),
//   );
// }
