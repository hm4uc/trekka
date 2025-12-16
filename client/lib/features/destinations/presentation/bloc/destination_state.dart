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

class LikedItemsLoading extends DestinationState {}

class LikedItemsLoadingMore extends DestinationState {
  final List<Destination> currentItems;

  const LikedItemsLoadingMore(this.currentItems);

  @override
  List<Object?> get props => [currentItems];
}

class LikedItemsLoaded extends DestinationState {
  final List<Destination> items;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;

  const LikedItemsLoaded({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, currentPage, totalPages, total, hasMore];

  LikedItemsLoaded copyWith({
    List<Destination>? items,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasMore,
  }) {
    return LikedItemsLoaded(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CheckedInItemsLoading extends DestinationState {}

class CheckedInItemsLoadingMore extends DestinationState {
  final List<Destination> currentItems;

  const CheckedInItemsLoadingMore(this.currentItems);

  @override
  List<Object?> get props => [currentItems];
}

class CheckedInItemsLoaded extends DestinationState {
  final List<Destination> items;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;

  const CheckedInItemsLoaded({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, currentPage, totalPages, total, hasMore];

  CheckedInItemsLoaded copyWith({
    List<Destination>? items,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasMore,
  }) {
    return CheckedInItemsLoaded(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
