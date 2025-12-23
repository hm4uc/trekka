import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/trip.dart' hide TripEvent;
import '../../domain/usecases/add_destination_to_trip.dart';
import '../../domain/usecases/add_event_to_trip.dart';
import '../../domain/usecases/create_trip.dart';
import '../../domain/usecases/delete_trip.dart';
import '../../domain/usecases/get_trip_detail.dart';
import '../../domain/usecases/get_trips.dart';
import '../../domain/usecases/update_trip.dart';
import '../../domain/usecases/update_trip_status.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final GetTripsUseCase getTripsUseCase;
  final GetTripDetailUseCase getTripDetailUseCase;
  final CreateTripUseCase createTripUseCase;
  final UpdateTripUseCase updateTripUseCase;
  final DeleteTripUseCase deleteTripUseCase;
  final UpdateTripStatusUseCase updateTripStatusUseCase;
  final AddDestinationToTripUseCase addDestinationToTripUseCase;
  final AddEventToTripUseCase addEventToTripUseCase;

  TripBloc({
    required this.getTripsUseCase,
    required this.getTripDetailUseCase,
    required this.createTripUseCase,
    required this.updateTripUseCase,
    required this.deleteTripUseCase,
    required this.updateTripStatusUseCase,
    required this.addDestinationToTripUseCase,
    required this.addEventToTripUseCase,
  }) : super(TripInitial()) {
    on<GetTripsEvent>(_onGetTrips);
    on<GetTripDetailEvent>(_onGetTripDetail);
    on<CreateTripEvent>(_onCreateTrip);
    on<UpdateTripEvent>(_onUpdateTrip);
    on<DeleteTripEvent>(_onDeleteTrip);
    on<UpdateTripStatusEvent>(_onUpdateTripStatus);
    on<RefreshTripsEvent>(_onRefreshTrips);
    on<AddDestinationToTripEvent>(_onAddDestinationToTrip);
    on<AddEventToTripEvent>(_onAddEventToTrip);
  }

  Future<void> _onGetTrips(GetTripsEvent event, Emitter<TripState> emit) async {
    // Show loading more if we already have trips
    if (state is TripListLoaded && event.page > 1) {
      emit(TripLoadingMore((state as TripListLoaded).trips));
    } else {
      emit(TripLoading());
    }

    final result = await getTripsUseCase(
      page: event.page,
      limit: event.limit,
      status: event.status,
    );

    result.fold(
      (failure) => emit(TripError(failure.message)),
      (data) {
        final tripList = (data['trips'] as List).cast<Trip>();

        // If loading more, append to existing trips
        if (state is TripLoadingMore) {
          final currentTrips = (state as TripLoadingMore).currentTrips;
          emit(TripListLoaded(
            trips: [...currentTrips, ...tripList],
            total: data['total'] as int,
            currentPage: data['currentPage'] as int,
            totalPages: data['totalPages'] as int,
            currentStatus: event.status,
          ));
        } else {
          emit(TripListLoaded(
            trips: tripList,
            total: data['total'] as int,
            currentPage: data['currentPage'] as int,
            totalPages: data['totalPages'] as int,
            currentStatus: event.status,
          ));
        }
      },
    );
  }

  Future<void> _onGetTripDetail(GetTripDetailEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());

    final result = await getTripDetailUseCase(event.tripId);

    result.fold(
      (failure) => emit(TripError(failure.message)),
      (trip) => emit(TripDetailLoaded(trip)),
    );
  }

  Future<void> _onCreateTrip(CreateTripEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());

    final result = await createTripUseCase(event.tripData);

    result.fold(
      (failure) => emit(TripError(failure.message)),
      (trip) => emit(TripCreated(trip)),
    );
  }

  Future<void> _onUpdateTrip(UpdateTripEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());

    final result = await updateTripUseCase(event.tripId, event.tripData);

    result.fold(
      (failure) => emit(TripError(failure.message)),
      (trip) => emit(TripUpdated(trip)),
    );
  }

  Future<void> _onDeleteTrip(DeleteTripEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());

    final result = await deleteTripUseCase(event.tripId);

    result.fold(
      (failure) => emit(TripError(failure.message)),
      (_) => emit(TripDeleted()),
    );
  }

  Future<void> _onUpdateTripStatus(UpdateTripStatusEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());

    final result = await updateTripStatusUseCase(event.tripId, event.status);

    result.fold(
      (failure) => emit(TripError(failure.message)),
      (trip) => emit(TripUpdated(trip)),
    );
  }

  Future<void> _onRefreshTrips(RefreshTripsEvent event, Emitter<TripState> emit) async {
    // Reset to first page
    add(GetTripsEvent(page: 1, status: event.status));
  }

  Future<void> _onAddDestinationToTrip(AddDestinationToTripEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());

    final result = await addDestinationToTripUseCase(event.tripId, event.destinationData);

    result.fold(
      (failure) => emit(TripError(failure.message)),
      (data) {
        // After adding destination, reload trip detail
        add(GetTripDetailEvent(event.tripId));
      },
    );
  }

  Future<void> _onAddEventToTrip(AddEventToTripEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());

    final result = await addEventToTripUseCase(event.tripId, event.eventData);

    result.fold(
      (failure) => emit(TripError(failure.message)),
      (data) {
        // After adding event, reload trip detail
        add(GetTripDetailEvent(event.tripId));
      },
    );
  }
}
