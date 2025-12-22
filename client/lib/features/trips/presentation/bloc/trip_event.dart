import 'package:equatable/equatable.dart';
import '../../domain/entities/trip.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class GetTripsEvent extends TripEvent {
  final int page;
  final int limit;
  final String? status;

  const GetTripsEvent({
    this.page = 1,
    this.limit = 10,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
}

class GetTripDetailEvent extends TripEvent {
  final String tripId;

  const GetTripDetailEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class CreateTripEvent extends TripEvent {
  final Map<String, dynamic> tripData;

  const CreateTripEvent(this.tripData);

  @override
  List<Object?> get props => [tripData];
}

class UpdateTripEvent extends TripEvent {
  final String tripId;
  final Map<String, dynamic> tripData;

  const UpdateTripEvent(this.tripId, this.tripData);

  @override
  List<Object?> get props => [tripId, tripData];
}

class DeleteTripEvent extends TripEvent {
  final String tripId;

  const DeleteTripEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class UpdateTripStatusEvent extends TripEvent {
  final String tripId;
  final String status;

  const UpdateTripStatusEvent(this.tripId, this.status);

  @override
  List<Object?> get props => [tripId, status];
}

class RefreshTripsEvent extends TripEvent {
  final String? status;

  const RefreshTripsEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class AddDestinationToTripEvent extends TripEvent {
  final String tripId;
  final Map<String, dynamic> destinationData;

  const AddDestinationToTripEvent(this.tripId, this.destinationData);

  @override
  List<Object?> get props => [tripId, destinationData];
}

class AddEventToTripEvent extends TripEvent {
  final String tripId;
  final Map<String, dynamic> eventData;

  const AddEventToTripEvent(this.tripId, this.eventData);

  @override
  List<Object?> get props => [tripId, eventData];
}
