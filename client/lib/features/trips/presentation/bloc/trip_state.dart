import 'package:equatable/equatable.dart';
import '../../domain/entities/trip.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripListLoaded extends TripState {
  final List<Trip> trips;
  final int total;
  final int currentPage;
  final int totalPages;
  final String? currentStatus;

  const TripListLoaded({
    required this.trips,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    this.currentStatus,
  });

  @override
  List<Object?> get props => [trips, total, currentPage, totalPages, currentStatus];
}

class TripDetailLoaded extends TripState {
  final Trip trip;

  const TripDetailLoaded(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripCreated extends TripState {
  final Trip trip;

  const TripCreated(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripUpdated extends TripState {
  final Trip trip;

  const TripUpdated(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripDeleted extends TripState {}

class TripError extends TripState {
  final String message;

  const TripError(this.message);

  @override
  List<Object?> get props => [message];
}

class TripLoadingMore extends TripState {
  final List<Trip> currentTrips;

  const TripLoadingMore(this.currentTrips);

  @override
  List<Object?> get props => [currentTrips];
}

