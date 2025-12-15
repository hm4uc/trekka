import 'package:equatable/equatable.dart';
import '../../domain/entities/destination.dart';

// States
abstract class DestinationDetailState extends Equatable {
  const DestinationDetailState();

  @override
  List<Object?> get props => [];
}

class DestinationDetailInitial extends DestinationDetailState {}

class DestinationDetailLoading extends DestinationDetailState {}

class DestinationDetailLoaded extends DestinationDetailState {
  final Destination destination;
  final List<Destination> nearbyDestinations;
  final bool isLiked;
  final bool isSaved;

  const DestinationDetailLoaded({
    required this.destination,
    this.nearbyDestinations = const [],
    this.isLiked = false,
    this.isSaved = false,
  });

  DestinationDetailLoaded copyWith({
    Destination? destination,
    List<Destination>? nearbyDestinations,
    bool? isLiked,
    bool? isSaved,
  }) {
    return DestinationDetailLoaded(
      destination: destination ?? this.destination,
      nearbyDestinations: nearbyDestinations ?? this.nearbyDestinations,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [destination, nearbyDestinations, isLiked, isSaved];
}

class DestinationDetailError extends DestinationDetailState {
  final String message;

  const DestinationDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class DestinationDetailActionLoading extends DestinationDetailState {
  final String action; // 'like', 'save', 'checkin'

  const DestinationDetailActionLoading(this.action);

  @override
  List<Object?> get props => [action];
}

class DestinationDetailActionSuccess extends DestinationDetailState {
  final String message;

  const DestinationDetailActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DestinationDetailActionError extends DestinationDetailState {
  final String message;

  const DestinationDetailActionError(this.message);

  @override
  List<Object?> get props => [message];
}

