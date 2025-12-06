import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trekka/core/services/shared_prefs_service.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_with_email.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register_with_email.dart';
import 'features/auth/domain/usecases/update_profile.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding/data/datasources/preferences_remote_data_source.dart';
import 'features/onboarding/data/repositories/preferences_repository_impl.dart';
import 'features/onboarding/domain/repositories/preferences_repository.dart';
import 'features/onboarding/domain/usecases/get_travel_constants.dart';
import 'features/onboarding/domain/usecases/update_travel_settings.dart';
import 'features/onboarding/presentation/bloc/preferences_bloc.dart';

// Biến toàn cục để truy cập dependency
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      authRepository: sl(),
      logoutUseCase: sl(),
      updateProfileUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => RegisterWithEmail(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Preferences
  // Bloc
  sl.registerFactory(() => PreferencesBloc(getTravelConstants: sl(), updateTravelSettings: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetTravelConstants(sl()));
  sl.registerLazySingleton(() => UpdateTravelSettings(sl()));

  // Repository
  sl.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PreferencesRemoteDataSource>(
        () => PreferencesRemoteDataSourceImpl(
      apiClient: sl(),
      authLocalDataSource: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton(() => ApiClient(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  await SharedPrefsService.init();
  sl.registerLazySingleton(() => Dio());
}
