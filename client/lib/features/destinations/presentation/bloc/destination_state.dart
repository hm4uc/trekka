import 'package:equatable/equatable.dart';
import '../../domain/entities/destination.dart';

abstract class DestinationState extends Equatable {
  const DestinationState();

  @override
  List<Object?> get props => [];
}

class DestinationInitial extends DestinationState {}

class DestinationLoading extends DestinationState {}

class DestinationLoadingMore extends DestinationState {
  final List<Destination> currentDestinations;
  final List<DestinationCategory> categories;

  const DestinationLoadingMore({
    required this.currentDestinations,
    required this.categories,
  });

  @override
  List<Object?> get props => [currentDestinations, categories];
}

class DestinationLoaded extends DestinationState {
  final List<Destination> destinations;
  final List<DestinationCategory> categories;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;

  const DestinationLoaded({
    required this.destinations,
    required this.categories,
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.hasMore,
  });

  @override
  List<Object?> get props =>
      [destinations, categories, currentPage, totalPages, total, hasMore];

  DestinationLoaded copyWith({
    List<Destination>? destinations,
    List<DestinationCategory>? categories,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasMore,
  }) {
    return DestinationLoaded(
      destinations: destinations ?? this.destinations,
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class DestinationError extends DestinationState {
  final String message;

  const DestinationError(this.message);

  @override
  List<Object?> get props => [message];
}

class DestinationActionSuccess extends DestinationState {
  final String message;

  const DestinationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

