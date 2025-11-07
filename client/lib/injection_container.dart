import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:trekka/core/network/api_client.dart';
import 'package:trekka/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:trekka/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:trekka/features/auth/domain/repositories/auth_repository.dart';
import 'package:trekka/features/auth/domain/usecases/login_user.dart';
import 'package:trekka/features/auth/domain/usecases/register_user.dart';
import 'package:trekka/features/auth/presentation/bloc/auth_bloc.dart';
import 'core/storage/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  await LocalStorageService.init();

  // Bloc
  sl.registerFactory(() => AuthBloc(
    loginUser: sl(),
    registerUser: sl(),
    localStorageService: LocalStorageService(),
  ));

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));

  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // External
  sl.registerLazySingleton(() => Dio());
}