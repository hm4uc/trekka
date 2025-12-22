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
import 'features/destinations/data/datasources/destination_remote_data_source.dart';
import 'features/destinations/data/repositories/destination_repository_impl.dart';
import 'features/destinations/domain/repositories/destination_repository.dart';
import 'features/destinations/domain/usecases/get_categories.dart';
import 'features/destinations/domain/usecases/get_categories_by_travel_style.dart';
import 'features/destinations/domain/usecases/get_destinations.dart';
import 'features/destinations/domain/usecases/get_destination_by_id.dart';
import 'features/destinations/domain/usecases/get_nearby_destinations.dart';
import 'features/destinations/domain/usecases/like_destination.dart';
import 'features/destinations/domain/usecases/save_destination.dart';
import 'features/destinations/domain/usecases/checkin_destination.dart';
import 'features/destinations/domain/usecases/get_liked_items.dart';
import 'features/destinations/domain/usecases/get_checked_in_items.dart';
import 'features/destinations/presentation/bloc/destination_bloc.dart';
import 'features/destinations/presentation/bloc/destination_detail_cubit.dart';
import 'features/events/data/datasources/event_remote_data_source.dart';
import 'features/events/data/repositories/event_repository_impl.dart';
import 'features/events/domain/repositories/event_repository.dart';
import 'features/events/domain/usecases/checkin_event.dart';
import 'features/events/domain/usecases/get_event_by_id.dart';
import 'features/events/domain/usecases/get_events.dart';
import 'features/events/domain/usecases/get_upcoming_events.dart';
import 'features/events/domain/usecases/like_event.dart';
import 'features/events/presentation/bloc/event_bloc.dart';
import 'features/reviews/data/datasources/review_remote_data_source.dart';
import 'features/reviews/data/repositories/review_repository_impl.dart';
import 'features/reviews/domain/repositories/review_repository.dart';
import 'features/reviews/domain/usecases/create_review.dart';
import 'features/reviews/domain/usecases/delete_review.dart';
import 'features/reviews/domain/usecases/get_destination_reviews.dart';
import 'features/reviews/domain/usecases/get_event_reviews.dart';
import 'features/reviews/domain/usecases/get_my_reviews.dart';
import 'features/reviews/domain/usecases/mark_review_helpful.dart';
import 'features/reviews/domain/usecases/update_review.dart';
import 'features/reviews/presentation/bloc/review_bloc.dart';
import 'features/trips/data/datasources/trip_remote_data_source.dart';
import 'features/trips/data/repositories/trip_repository_impl.dart';
import 'features/trips/domain/repositories/trip_repository.dart';
import 'features/trips/domain/usecases/add_destination_to_trip.dart';
import 'features/trips/domain/usecases/add_event_to_trip.dart';
import 'features/trips/domain/usecases/create_trip.dart';
import 'features/trips/domain/usecases/delete_trip.dart';
import 'features/trips/domain/usecases/get_trip_detail.dart';
import 'features/trips/domain/usecases/get_trips.dart';
import 'features/trips/domain/usecases/update_trip.dart';
import 'features/trips/domain/usecases/update_trip_status.dart';
import 'features/trips/presentation/bloc/trip_bloc.dart';

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

  //! Features - Destinations
  // Bloc
  sl.registerFactory(() => DestinationBloc(
        getDestinations: sl(),
        getCategories: sl(),
        getCategoriesByTravelStyle: sl(),
        likeDestination: sl(),
        saveDestination: sl(),
        checkinDestination: sl(),
        getLikedItems: sl(),
        getCheckedInItems: sl(),
      ));

  // Cubit
  sl.registerFactory(() => DestinationDetailCubit(
        getDestinationById: sl(),
        getNearbyDestinations: sl(),
        likeDestination: sl(),
        saveDestination: sl(),
        checkinDestination: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetDestinations(sl()));
  sl.registerLazySingleton(() => GetDestinationById(sl()));
  sl.registerLazySingleton(() => GetNearbyDestinations(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetCategoriesByTravelStyle(sl()));
  sl.registerLazySingleton(() => LikeDestination(sl()));
  sl.registerLazySingleton(() => SaveDestination(sl()));
  sl.registerLazySingleton(() => CheckinDestination(sl()));
  sl.registerLazySingleton(() => GetLikedItems(sl()));
  sl.registerLazySingleton(() => GetCheckedInItems(sl()));

  // Repository
  sl.registerLazySingleton<DestinationRepository>(
    () => DestinationRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DestinationRemoteDataSource>(
    () => DestinationRemoteDataSourceImpl(sl()),
  );

  //! Features - Events
  // Bloc
  sl.registerFactory(() => EventBloc(
        getEvents: sl(),
        getUpcomingEvents: sl(),
        getEventById: sl(),
        likeEvent: sl(),
        checkinEvent: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetEvents(sl()));
  sl.registerLazySingleton(() => GetUpcomingEvents(sl()));
  sl.registerLazySingleton(() => GetEventById(sl()));
  sl.registerLazySingleton(() => LikeEvent(sl()));
  sl.registerLazySingleton(() => CheckinEvent(sl()));

  // Repository
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(sl()),
  );

  //! Features - Reviews
  // Bloc
  sl.registerFactory(() => ReviewBloc(
        getDestinationReviews: sl(),
        getEventReviews: sl(),
        getMyReviews: sl(),
        createReview: sl(),
        updateReview: sl(),
        deleteReview: sl(),
        markReviewHelpful: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetDestinationReviews(sl()));
  sl.registerLazySingleton(() => GetEventReviews(sl()));
  sl.registerLazySingleton(() => GetMyReviews(sl()));
  sl.registerLazySingleton(() => CreateReview(sl()));
  sl.registerLazySingleton(() => UpdateReview(sl()));
  sl.registerLazySingleton(() => DeleteReview(sl()));
  sl.registerLazySingleton(() => MarkReviewHelpful(sl()));

  // Repository
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl()),
  );

  //! Features - Trips
  // Bloc
  sl.registerFactory(() => TripBloc(
        getTripsUseCase: sl(),
        getTripDetailUseCase: sl(),
        createTripUseCase: sl(),
        updateTripUseCase: sl(),
        deleteTripUseCase: sl(),
        updateTripStatusUseCase: sl(),
        addDestinationToTripUseCase: sl(),
        addEventToTripUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetTripsUseCase(sl()));
  sl.registerLazySingleton(() => GetTripDetailUseCase(sl()));
  sl.registerLazySingleton(() => CreateTripUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTripUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTripUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTripStatusUseCase(sl()));
  sl.registerLazySingleton(() => AddDestinationToTripUseCase(sl()));
  sl.registerLazySingleton(() => AddEventToTripUseCase(sl()));

  // Repository
  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => ApiClient(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  await SharedPrefsService.init();
  sl.registerLazySingleton(() => Dio());
}
